Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67C626B03B6
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:17:53 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id n127so103451239qkf.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:17:53 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0062.outbound.protection.outlook.com. [104.47.33.62])
        by mx.google.com with ESMTPS id j34si7139933qtb.65.2017.03.02.07.17.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:17:52 -0800 (PST)
Subject: [RFC PATCH v2 26/32] kvm: svm: Add support for SEV
 LAUNCH_UPDATE_DATA command
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:17:47 -0500
Message-ID: <148846786714.2349.17724971671841396908.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The command is used for encrypting the guest memory region using the VM
encryption key (VEK) created from LAUNCH_START.

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/kvm/svm.c |  150 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 150 insertions(+)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index b5fa8c0..62c2b22 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -38,6 +38,8 @@
 #include <linux/hashtable.h>
 #include <linux/psp-sev.h>
 #include <linux/file.h>
+#include <linux/pagemap.h>
+#include <linux/swap.h>
 
 #include <asm/apic.h>
 #include <asm/perf_event.h>
@@ -502,6 +504,7 @@ static void sev_deactivate_handle(struct kvm *kvm);
 static void sev_decommission_handle(struct kvm *kvm);
 static int sev_asid_new(void);
 static void sev_asid_free(int asid);
+#define __sev_page_pa(x) ((page_to_pfn(x) << PAGE_SHIFT) | sme_me_mask)
 
 static bool kvm_sev_enabled(void)
 {
@@ -5775,6 +5778,149 @@ static int sev_launch_start(struct kvm *kvm, struct kvm_sev_cmd *argp)
 	return ret;
 }
 
+static struct page **sev_pin_memory(unsigned long uaddr, unsigned long ulen,
+				    unsigned long *n)
+{
+	struct page **pages;
+	int first, last;
+	unsigned long npages, pinned;
+
+	/* Get number of pages */
+	first = (uaddr & PAGE_MASK) >> PAGE_SHIFT;
+	last = ((uaddr + ulen - 1) & PAGE_MASK) >> PAGE_SHIFT;
+	npages = (last - first + 1);
+
+	pages = kzalloc(npages * sizeof(struct page *), GFP_KERNEL);
+	if (!pages)
+		return NULL;
+
+	/* pin the user virtual address */
+	down_read(&current->mm->mmap_sem);
+	pinned = get_user_pages_fast(uaddr, npages, 1, pages);
+	up_read(&current->mm->mmap_sem);
+	if (pinned != npages) {
+		printk(KERN_ERR "SEV: failed to pin  %ld pages (got %ld)\n",
+				npages, pinned);
+		goto err;
+	}
+
+	*n = npages;
+	return pages;
+err:
+	if (pinned > 0)
+		release_pages(pages, pinned, 0);
+	kfree(pages);
+
+	return NULL;
+}
+
+static void sev_unpin_memory(struct page **pages, unsigned long npages)
+{
+	release_pages(pages, npages, 0);
+	kfree(pages);
+}
+
+static void sev_clflush_pages(struct page *pages[], int num_pages)
+{
+	unsigned long i;
+	uint8_t *page_virtual;
+
+	if (num_pages == 0 || pages == NULL)
+		return;
+
+	for (i = 0; i < num_pages; i++) {
+		page_virtual = kmap_atomic(pages[i]);
+		clflush_cache_range(page_virtual, PAGE_SIZE);
+		kunmap_atomic(page_virtual);
+	}
+}
+
+static int sev_launch_update_data(struct kvm *kvm, struct kvm_sev_cmd *argp)
+{
+	struct page **inpages;
+	unsigned long uaddr, ulen;
+	int i, len, ret, offset;
+	unsigned long nr_pages;
+	struct kvm_sev_launch_update_data params;
+	struct sev_data_launch_update_data *data;
+
+	if (!sev_guest(kvm))
+		return -EINVAL;
+
+	/* Get the parameters from the user */
+	ret = -EFAULT;
+	if (copy_from_user(&params, (void *)argp->data,
+			sizeof(struct kvm_sev_launch_update_data)))
+		goto err_1;
+
+	uaddr = params.address;
+	ulen = params.length;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data) {
+		ret = -ENOMEM;
+		goto err_1;
+	}
+
+	/* pin user pages */
+	inpages = sev_pin_memory(params.address, params.length, &nr_pages);
+	if (!inpages) {
+		ret = -ENOMEM;
+		goto err_2;
+	}
+
+	/* invalidate the cache line for these pages to ensure that DRAM
+	 * has recent content before calling the SEV commands to perform
+	 * the encryption.
+	 */
+	sev_clflush_pages(inpages, nr_pages);
+
+	/* the array of pages returned by get_user_pages() is a page-aligned
+	 * memory. Since the user buffer is probably not page-aligned, we need
+	 * to calculate the offset within a page for first update entry.
+	 */
+	offset = uaddr & (PAGE_SIZE - 1);
+	len = min_t(size_t, (PAGE_SIZE - offset), ulen);
+	ulen -= len;
+
+	/* update first page -
+	 * special care need to be taken for the first page because we might
+	 * be dealing with offset within the page
+	 */
+	data->handle = sev_get_handle(kvm);
+	data->length = len;
+	data->address = __sev_page_pa(inpages[0]) + offset;
+	ret = sev_issue_cmd(kvm, SEV_CMD_LAUNCH_UPDATE_DATA,
+			data, &argp->error);
+	if (ret)
+		goto err_3;
+
+	/* update remaining pages */
+	for (i = 1; i < nr_pages; i++) {
+
+		len = min_t(size_t, PAGE_SIZE, ulen);
+		ulen -= len;
+		data->length = len;
+		data->address = __sev_page_pa(inpages[i]);
+		ret = sev_issue_cmd(kvm, SEV_CMD_LAUNCH_UPDATE_DATA,
+					data, &argp->error);
+		if (ret)
+			goto err_3;
+	}
+
+	/* mark pages dirty */
+	for (i = 0; i < nr_pages; i++) {
+		set_page_dirty_lock(inpages[i]);
+		mark_page_accessed(inpages[i]);
+	}
+err_3:
+	sev_unpin_memory(inpages, nr_pages);
+err_2:
+	kfree(data);
+err_1:
+	return ret;
+}
+
 static int amd_memory_encryption_cmd(struct kvm *kvm, void __user *argp)
 {
 	int r = -ENOTTY;
@@ -5790,6 +5936,10 @@ static int amd_memory_encryption_cmd(struct kvm *kvm, void __user *argp)
 		r = sev_launch_start(kvm, &sev_cmd);
 		break;
 	}
+	case KVM_SEV_LAUNCH_UPDATE_DATA: {
+		r = sev_launch_update_data(kvm, &sev_cmd);
+		break;
+	}
 	default:
 		break;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
