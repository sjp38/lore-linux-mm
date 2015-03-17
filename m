Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id B1D586B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 09:45:05 -0400 (EDT)
Received: by qgfa8 with SMTP id a8so8069752qgf.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 06:45:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i204si13242450qhc.55.2015.03.17.06.45.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 06:45:05 -0700 (PDT)
Date: Tue, 17 Mar 2015 14:43:09 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: install_special_mapping && vm_pgoff (Was: vvar, gup &&
	coredump)
Message-ID: <20150317134309.GA365@redhat.com>
References: <87zj7r5fpz.fsf@redhat.com> <20150305205744.GA13165@host1.jankratochvil.net> <20150311200052.GA22654@redhat.com> <20150312143438.GA4338@redhat.com> <CALCETrW5rmAHutzm_OwK2LTd_J0XByV3pvWGyW=AmC=v7rLfhQ@mail.gmail.com> <20150312165423.GA10073@redhat.com> <20150312174653.GA13086@redhat.com> <20150316190154.GA18472@redhat.com> <CALCETrU9pLE2x3+vei1xw6B8uu4B33DOEzP03ue9DeS8sJhYUg@mail.gmail.com> <20150316194446.GA21791@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150316194446.GA21791@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kratochvil <jan.kratochvil@redhat.com>, Sergio Durigan Junior <sergiodj@redhat.com>, GDB Patches <gdb-patches@sourceware.org>, Pedro Alves <palves@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/16, Oleg Nesterov wrote:
>
> On 03/16, Andy Lutomirski wrote:
> >
> > Ick, you're probably right.  For what it's worth, the vdso *seems* to
> > be okay (on 64-bit only, and only if you don't poke at it too hard) if
> > you mremap it in one piece.  CRIU does that.
>
> I need to run away till tomorrow, but looking at this code even if "one piece"
> case doesn't look right if it was cow'ed. I'll verify tomorrow.

And I am still not sure this all is 100% correct, but I got lost in this code.
Probably this is fine...

But at least the bug exposed by the test-case looks clear:

	do_linear_fault:

		vmf->pgoff = (((address & PAGE_MASK) - vma->vm_start) >> PAGE_SHIFT)
				+ vma->vm_pgoff;
		...

		special_mapping_fault:

			pgoff = vmf->pgoff - vma->vm_pgoff;


So special_mapping_fault() can only work if this mapping starts from the
first page in ->pages[].

So perhaps we need _something like_ the (wrong/incomplete) patch below...

Or, really, perhaps we can create vdso_mapping ? So that map_vdso() could
simply mmap the anon_inode file...

Oleg.

--- x/mm/mmap.c
+++ x/mm/mmap.c
@@ -2832,6 +2832,8 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 	return 0;
 }
 
+bool is_special_vma(struct vm_area_struct *vma);
+
 /*
  * Copy the vma structure to a new location in the same mm,
  * prior to moving page table entries, to effect an mremap move.
@@ -2851,7 +2853,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	 * If anonymous vma has not yet been faulted, update new pgoff
 	 * to match new location, to increase its chance of merging.
 	 */
-	if (unlikely(!vma->vm_file && !vma->anon_vma)) {
+	if (unlikely(!vma->vm_file && !is_special_vma(vma) && !vma->anon_vma)) {
 		pgoff = addr >> PAGE_SHIFT;
 		faulted_in_anon_vma = false;
 	}
@@ -2953,6 +2955,11 @@ static const struct vm_operations_struct legacy_special_mapping_vmops = {
 	.fault = special_mapping_fault,
 };
 
+bool is_special_vma(struct vm_area_struct *vma)
+{
+	return vma->vm_ops == &special_mapping_vmops;
+}
+
 static int special_mapping_fault(struct vm_area_struct *vma,
 				struct vm_fault *vmf)
 {
@@ -2965,7 +2972,7 @@ static int special_mapping_fault(struct vm_area_struct *vma,
 	 * We are allowed to do this because we are the mm; do not copy
 	 * this code into drivers!
 	 */
-	pgoff = vmf->pgoff - vma->vm_pgoff;
+	pgoff = vmf->pgoff;
 
 	if (vma->vm_ops == &legacy_special_mapping_vmops)
 		pages = vma->vm_private_data;
@@ -3014,6 +3021,7 @@ static struct vm_area_struct *__install_special_mapping(
 	if (ret)
 		goto out;
 
+	vma->vm_pgoff = 0;
 	mm->total_vm += len >> PAGE_SHIFT;
 
 	perf_event_mmap(vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
