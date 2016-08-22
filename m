Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2720D83098
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:36:00 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so233653594pac.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 16:36:00 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0044.outbound.protection.outlook.com. [104.47.40.44])
        by mx.google.com with ESMTPS id z185si510347pfz.64.2016.08.22.16.28.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 16:28:56 -0700 (PDT)
Subject: [RFC PATCH v1 23/28] KVM: SVM: add SEV launch update command
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Mon, 22 Aug 2016 19:28:44 -0400
Message-ID: <147190852423.9523.11936794196855765674.stgit@brijesh-build-machine>
In-Reply-To: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, linux-crypto@vger.kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The command is used for encrypting guest memory region.

For more information see [1], section 6.2

[1] http://support.amd.com/TechDocs/55766_SEV-KM%20API_Spec.pdf

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/kvm/svm.c |  126 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 126 insertions(+)

diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 0b6da4a..c78bdc6 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -35,6 +35,8 @@
 #include <linux/trace_events.h>
 #include <linux/slab.h>
 #include <linux/ccp-psp.h>
+#include <linux/pagemap.h>
+#include <linux/swap.h>
 
 #include <asm/apic.h>
 #include <asm/perf_event.h>
@@ -263,6 +265,8 @@ static unsigned long *sev_asid_bitmap;
 #define svm_sev_guest()		(svm->vcpu.kvm->arch.sev_info.handle)
 #define svm_sev_ref_count()	(svm->vcpu.kvm->arch.sev_info.ref_count)
 
+#define __sev_page_pa(x) ((page_to_pfn(x) << PAGE_SHIFT) | sme_me_mask)
+
 static int sev_asid_new(void);
 static void sev_asid_free(int asid);
 static void sev_deactivate_handle(unsigned int handle);
@@ -5376,6 +5380,123 @@ err_1:
 	return ret;
 }
 
+static int sev_pre_update(struct page **pages, unsigned long uaddr, int npages)
+{
+	int pinned;
+
+	/* pin the user virtual address */
+	down_read(&current->mm->mmap_sem);
+	pinned = get_user_pages(uaddr, npages, 1, 0, pages, NULL);
+	up_read(&current->mm->mmap_sem);
+	if (pinned != npages) {
+		printk(KERN_ERR "SEV: failed to pin  %d pages (got %d)\n",
+				npages, pinned);
+		goto err;
+	}
+
+	return 0;
+err:
+	if (pinned > 0)
+		release_pages(pages, pinned, 0);
+	return 1;
+}
+
+static int sev_launch_update(struct kvm *kvm,
+			     struct kvm_sev_launch_update __user *arg,
+			     int *psp_ret)
+{
+	int first, last;
+	struct page **inpages;
+	int ret, nr_pages;
+	unsigned long uaddr, ulen;
+	int i, buffer_len, len, offset;
+	struct kvm_sev_launch_update params;
+	struct psp_data_launch_update *update;
+
+	/* Get the parameters from the user */
+	if (copy_from_user(&params, arg, sizeof(*arg)))
+		return -EFAULT;
+
+	uaddr = params.address;
+	ulen = params.length;
+
+	/* Get number of pages */
+	first = (uaddr & PAGE_MASK) >> PAGE_SHIFT;
+	last = ((uaddr + ulen - 1) & PAGE_MASK) >> PAGE_SHIFT;
+	nr_pages = (last - first + 1);
+
+	/* allocate the buffers */
+	buffer_len = sizeof(*update);
+	update = kzalloc(buffer_len, GFP_KERNEL);
+	if (!update)
+		return -ENOMEM;
+
+	ret = -ENOMEM;
+	inpages = kzalloc(nr_pages * sizeof(struct page *), GFP_KERNEL);
+	if (!inpages)
+		goto err_1;
+
+	ret = sev_pre_update(inpages, uaddr, nr_pages);
+	if (ret)
+		goto err_2;
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
+	update->hdr.buffer_len = buffer_len;
+	update->handle = kvm_sev_handle();
+	update->length = len;
+	update->address = __sev_page_pa(inpages[0]) + offset;
+	clflush_cache_range(page_address(inpages[0]), PAGE_SIZE);
+	ret = psp_guest_launch_update(update, 5, psp_ret);
+	if (ret) {
+		printk(KERN_ERR "SEV: LAUNCH_UPDATE addr %#llx len %d "
+				"ret=%d (%#010x)\n", update->address,
+				update->length, ret, *psp_ret);
+		goto err_3;
+	}
+
+	/* update remaining pages */
+	for (i = 1; i < nr_pages; i++) {
+
+		len = min_t(size_t, PAGE_SIZE, ulen);
+		ulen -= len;
+		update->length = len;
+		update->address = __sev_page_pa(inpages[i]);
+		clflush_cache_range(page_address(inpages[i]), PAGE_SIZE);
+
+		ret = psp_guest_launch_update(update, 5, psp_ret);
+		if (ret) {
+			printk(KERN_ERR "SEV: LAUNCH_UPDATE addr %#llx len %d "
+				"ret=%d (%#010x)\n", update->address,
+				update->length, ret, *psp_ret);
+			goto err_3;
+		}
+	}
+
+err_3:
+	/* mark pages dirty */
+	for (i = 0; i < nr_pages; i++) {
+		set_page_dirty_lock(inpages[i]);
+		mark_page_accessed(inpages[i]);
+	}
+	release_pages(inpages, nr_pages, 0);
+err_2:
+	kfree(inpages);
+err_1:
+	kfree(update);
+	return ret;
+}
+ 
 static int amd_sev_issue_cmd(struct kvm *kvm,
 			     struct kvm_sev_issue_cmd __user *user_data)
 {
@@ -5391,6 +5512,11 @@ static int amd_sev_issue_cmd(struct kvm *kvm,
 					&arg.ret_code);
 		break;
 	}
+	case KVM_SEV_LAUNCH_UPDATE: {
+		r = sev_launch_update(kvm, (void *)arg.opaque,
+					&arg.ret_code);
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
