Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EF0446B03B4
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:17:44 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 10so11208807pgb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:17:44 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0053.outbound.protection.outlook.com. [104.47.32.53])
        by mx.google.com with ESMTPS id a61si7703684plc.67.2017.03.02.07.17.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:17:43 -0800 (PST)
Subject: [RFC PATCH v2 25/32] kvm: svm: Add support for SEV LAUNCH_START
 command
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:17:35 -0500
Message-ID: <148846785574.2349.2756610033917941226.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The command is used to bootstrap SEV guest from unencrypted boot images.
The command creates a new VM encryption key (VEK) using the guest owner's
public DH certificates, and session data. The VEK will be used to encrypt
the guest memory.

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/kvm/svm.c |  302 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 301 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index fb63398..b5fa8c0 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -37,6 +37,7 @@
 #include <linux/amd-iommu.h>
 #include <linux/hashtable.h>
 #include <linux/psp-sev.h>
+#include <linux/file.h>
 
 #include <asm/apic.h>
 #include <asm/perf_event.h>
@@ -497,6 +498,10 @@ static inline bool gif_set(struct vcpu_svm *svm)
 /* Secure Encrypted Virtualization */
 static unsigned int max_sev_asid;
 static unsigned long *sev_asid_bitmap;
+static void sev_deactivate_handle(struct kvm *kvm);
+static void sev_decommission_handle(struct kvm *kvm);
+static int sev_asid_new(void);
+static void sev_asid_free(int asid);
 
 static bool kvm_sev_enabled(void)
 {
@@ -1534,6 +1539,17 @@ static inline int avic_free_vm_id(int id)
 	return 0;
 }
 
+static void sev_vm_destroy(struct kvm *kvm)
+{
+	if (!sev_guest(kvm))
+		return;
+
+	/* release the firmware resources */
+	sev_deactivate_handle(kvm);
+	sev_decommission_handle(kvm);
+	sev_asid_free(sev_get_asid(kvm));
+}
+
 static void avic_vm_destroy(struct kvm *kvm)
 {
 	unsigned long flags;
@@ -1551,6 +1567,12 @@ static void avic_vm_destroy(struct kvm *kvm)
 	spin_unlock_irqrestore(&svm_vm_data_hash_lock, flags);
 }
 
+static void svm_vm_destroy(struct kvm *kvm)
+{
+	avic_vm_destroy(kvm);
+	sev_vm_destroy(kvm);
+}
+
 static int avic_vm_init(struct kvm *kvm)
 {
 	unsigned long flags;
@@ -5502,6 +5524,282 @@ static inline void avic_post_state_restore(struct kvm_vcpu *vcpu)
 	avic_handle_ldr_update(vcpu);
 }
 
+static int sev_asid_new(void)
+{
+	int pos;
+
+	if (!max_sev_asid)
+		return -EINVAL;
+
+	pos = find_first_zero_bit(sev_asid_bitmap, max_sev_asid);
+	if (pos >= max_sev_asid)
+		return -EBUSY;
+
+	set_bit(pos, sev_asid_bitmap);
+	return pos + 1;
+}
+
+static void sev_asid_free(int asid)
+{
+	int cpu, pos;
+	struct svm_cpu_data *sd;
+
+	pos = asid - 1;
+	clear_bit(pos, sev_asid_bitmap);
+
+	for_each_possible_cpu(cpu) {
+		sd = per_cpu(svm_data, cpu);
+		sd->sev_vmcbs[pos] = NULL;
+	}
+}
+
+static int sev_issue_cmd(struct kvm *kvm, int id, void *data, int *error)
+{
+	int ret;
+	struct fd f;
+	int fd = sev_get_fd(kvm);
+
+	f = fdget(fd);
+	if (!f.file)
+		return -EBADF;
+
+	ret = sev_issue_cmd_external_user(f.file, id, data, 0, error);
+	fdput(f);
+
+	return ret;
+}
+
+static void sev_decommission_handle(struct kvm *kvm)
+{
+	int ret, error;
+	struct sev_data_decommission *data;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return;
+
+	data->handle = sev_get_handle(kvm);
+	ret = sev_guest_decommission(data, &error);
+	if (ret)
+		pr_err("SEV: DECOMMISSION %d (%#x)\n", ret, error);
+
+	kfree(data);
+}
+
+static void sev_deactivate_handle(struct kvm *kvm)
+{
+	int ret, error;
+	struct sev_data_deactivate *data;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return;
+
+	data->handle = sev_get_handle(kvm);
+	ret = sev_guest_deactivate(data, &error);
+	if (ret) {
+		pr_err("SEV: DEACTIVATE %d (%#x)\n", ret, error);
+		goto buffer_free;
+	}
+
+	wbinvd_on_all_cpus();
+
+	ret = sev_guest_df_flush(&error);
+	if (ret)
+		pr_err("SEV: DF_FLUSH %d (%#x)\n", ret, error);
+
+buffer_free:
+	kfree(data);
+}
+
+static int sev_activate_asid(unsigned int handle, int asid, int *error)
+{
+	int ret;
+	struct sev_data_activate *data;
+
+	wbinvd_on_all_cpus();
+
+	ret = sev_guest_df_flush(error);
+	if (ret) {
+		pr_err("SEV: DF_FLUSH %d (%#x)\n", ret, *error);
+		return ret;
+	}
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+	data->handle = handle;
+	data->asid   = asid;
+	ret = sev_guest_activate(data, error);
+	if (ret)
+		pr_err("SEV: ACTIVATE %d (%#x)\n", ret, *error);
+
+	kfree(data);
+	return ret;
+}
+
+static int sev_pre_start(struct kvm *kvm, int *asid)
+{
+	int ret;
+
+	/* If guest has active SEV handle then deactivate before creating the
+	 * encryption context.
+	 */
+	if (sev_guest(kvm)) {
+		sev_deactivate_handle(kvm);
+		sev_decommission_handle(kvm);
+		*asid = sev_get_asid(kvm);  /* reuse the asid */
+		ret = 0;
+	} else {
+		/* Allocate new asid for this launch */
+		ret = sev_asid_new();
+		if (ret < 0) {
+			pr_err("SEV: failed to get free asid\n");
+			return ret;
+		}
+		*asid = ret;
+		ret = 0;
+	}
+
+	return ret;
+}
+
+static int sev_post_start(struct kvm *kvm, int asid, int handle,
+			int sev_fd, int *error)
+{
+	int ret;
+
+	/* activate asid */
+	ret = sev_activate_asid(handle, asid, error);
+	if (ret)
+		return ret;
+
+	kvm->arch.sev_info.handle = handle;
+	kvm->arch.sev_info.asid = asid;
+	kvm->arch.sev_info.sev_fd = sev_fd;
+
+	return 0;
+}
+
+static int sev_launch_start(struct kvm *kvm, struct kvm_sev_cmd *argp)
+{
+	int ret, asid = 0;
+	void *dh_cert_addr = NULL;
+	void *session_addr = NULL;
+	struct kvm_sev_launch_start params;
+	struct sev_data_launch_start *start;
+	int *error = &argp->error;
+	struct fd f;
+
+	f = fdget(argp->sev_fd);
+	if (!f.file)
+		return -EBADF;
+
+	/* Get parameter from the user */
+	ret = -EFAULT;
+	if (copy_from_user(&params, (void *)argp->data,
+				sizeof(struct kvm_sev_launch_start)))
+		goto err_1;
+
+	ret = -ENOMEM;
+	start = kzalloc(sizeof(*start), GFP_KERNEL);
+	if (!start)
+		goto err_1;
+
+	ret = sev_pre_start(kvm, &asid);
+	if (ret)
+		goto err_2;
+
+	start->handle = params.handle;
+	start->policy = params.policy;
+
+	/* Copy DH certificate from userspace */
+	if (params.dh_cert_length && params.dh_cert_data) {
+		dh_cert_addr = kmalloc(params.dh_cert_length, GFP_KERNEL);
+		if (!dh_cert_addr) {
+			ret = -EFAULT;
+			goto err_3;
+		}
+		if (copy_from_user(dh_cert_addr, (void *)params.dh_cert_data,
+				params.dh_cert_length)) {
+			ret = -EFAULT;
+			goto err_3;
+		}
+
+		start->dh_cert_address = __psp_pa(dh_cert_addr);
+		start->dh_cert_length = params.dh_cert_length;
+	}
+
+	/* Copy session data from userspace */
+	if (params.session_length && params.session_data) {
+		session_addr = kmalloc(params.dh_cert_length, GFP_KERNEL);
+		if (!session_addr) {
+			ret = -EFAULT;
+			goto err_3;
+		}
+		if (copy_from_user(session_addr, (void *)params.session_data,
+				params.session_length)) {
+			ret = -EFAULT;
+			goto err_3;
+		}
+		start->session_data_address = __psp_pa(session_addr);
+		start->session_data_length = params.session_length;
+	}
+
+	/* launch start */
+	ret = sev_issue_cmd_external_user(f.file, SEV_CMD_LAUNCH_START,
+					  start, 0, error);
+	if (ret) {
+		pr_err("SEV: LAUNCH_START ret=%d (%#010x)\n", ret, *error);
+		goto err_3;
+	}
+
+	ret = sev_post_start(kvm, asid, start->handle, argp->sev_fd, error);
+	if (ret)
+		goto err_3;
+
+	params.handle = start->handle;
+	if (copy_to_user((void *) argp->data, &params,
+				sizeof(struct kvm_sev_launch_start)))
+		ret = -EFAULT;
+err_3:
+	if (ret && asid) /* free asid if we have encountered error */
+		sev_asid_free(asid);
+	kfree(dh_cert_addr);
+	kfree(session_addr);
+err_2:
+	kfree(start);
+err_1:
+	fdput(f);
+	return ret;
+}
+
+static int amd_memory_encryption_cmd(struct kvm *kvm, void __user *argp)
+{
+	int r = -ENOTTY;
+	struct kvm_sev_cmd sev_cmd;
+
+	if (copy_from_user(&sev_cmd, argp, sizeof(struct kvm_sev_cmd)))
+		return -EFAULT;
+
+	mutex_lock(&kvm->lock);
+
+	switch (sev_cmd.id) {
+	case KVM_SEV_LAUNCH_START: {
+		r = sev_launch_start(kvm, &sev_cmd);
+		break;
+	}
+	default:
+		break;
+	}
+
+	mutex_unlock(&kvm->lock);
+	if (copy_to_user(argp, &sev_cmd, sizeof(struct kvm_sev_cmd)))
+		r = -EFAULT;
+	return r;
+}
+
 static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.cpu_has_kvm_support = has_svm,
 	.disabled_by_bios = is_disabled,
@@ -5518,7 +5816,7 @@ static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.vcpu_reset = svm_vcpu_reset,
 
 	.vm_init = avic_vm_init,
-	.vm_destroy = avic_vm_destroy,
+	.vm_destroy = svm_vm_destroy,
 
 	.prepare_guest_switch = svm_prepare_guest_switch,
 	.vcpu_load = svm_vcpu_load,
@@ -5617,6 +5915,8 @@ static struct kvm_x86_ops svm_x86_ops __ro_after_init = {
 	.pmu_ops = &amd_pmu_ops,
 	.deliver_posted_interrupt = svm_deliver_avic_intr,
 	.update_pi_irte = svm_update_pi_irte,
+
+	.memory_encryption_op = amd_memory_encryption_cmd,
 };
 
 static int __init svm_init(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
