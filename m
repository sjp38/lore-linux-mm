Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id CB5256B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 11:16:14 -0400 (EDT)
Received: by qkfq186 with SMTP id q186so73354749qkf.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 08:16:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p68si17309496qkh.42.2015.09.15.08.16.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 08:16:13 -0700 (PDT)
Date: Tue, 15 Sep 2015 17:13:18 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: LTP regressions due to 6dc296e7df4c ("mm: make sure all file
	VMAs have ->vm_ops set")
Message-ID: <20150915151318.GA15866@redhat.com>
References: <20150914105346.GB23878@arm.com> <20150914115800.06242CE@black.fi.intel.com> <20150914170547.GA28535@redhat.com> <20150914182033.GA4165@node.dhcp.inet.fi> <20150915121201.GA10104@redhat.com> <20150915134216.GA16093@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915134216.GA16093@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, hpa@zytor.com, luto@amacapital.net, dave.hansen@linux.intel.com, mingo@elte.hu, minchan@kernel.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/15, Kirill A. Shutemov wrote:
>
> On Tue, Sep 15, 2015 at 02:12:01PM +0200, Oleg Nesterov wrote:
> > On 09/14, Kirill A. Shutemov wrote:
> > >
> > > On Mon, Sep 14, 2015 at 07:05:47PM +0200, Oleg Nesterov wrote:
> > > > On 09/14, Kirill A. Shutemov wrote:
> > > > >
> > > > > Fix is below. I don't really like it, but I cannot find any better
> > > > > solution.
> > > >
> > > > Me too...
> > > >
> > > > But this change "documents" the nasty special "vm_file && !vm_ops" case, and
> > > > I am not sure how we can remove it later...
> > > >
> > > > So perhaps we should change vma_is_anonymous() back to check ->fault too,
> > > >
> > > > 	 static inline bool vma_is_anonymous(struct vm_area_struct *vma)
> > > > 	 {
> > > > 	-	return !vma->vm_ops;
> > > > 	+	return !vma->vm_ops || !vma->vm_ops->fault;
> > >
> > > No. This would give a lot false positives from drives which setup page
> > > tables upfront and don't use ->fault at all.
> >
> > And? I mean, I am not sure I understand what exactly do you dislike.
> >
> > Firstly, I still think that (in the long term) we should change them
> > to use .faul = no_fault() which just returns VM_FAULT_SIGBUS.
>
> I would rather like to see consolidated fault path between file and anon
> with ->vm_ops set for both. So vma_is_anonymous() will be trivial
> vma->vm_ops == anon_vm_ops.

I too thought about this. Perhaps but I guess this needs another
discussion.

In particular I am not sure we should just rely on vm_ops == anon_vm_ops.
Again, it is not that I think that the VM_MPX check in arch_vma_name() is
that bad. Still I think it would be better if mpx_mmap() could install
vma->vm_ops = mpx_vm_ops with ->name(). So perhaps ->anon_fault() makes
more sense. But lets not discuss this right now.

>
> > Until then I do not see why the change above can be really bad. The
> > VM_SHARED case is fine, do_anonymous_page() will return VM_FAULT_SIGBUS.
> >
> > So afaics the only problem is that after the change above the private
> > mapping can silently get an anonymous page after (say) MADV_DONTNEED
> > instead of the nice SIGBUS from do_fault(). I agree, this is not good,
> > but see above.
>
> So, what the point to introduce vma_is_anonymous() if it often produces
> false result? vma_is_anonymous_or_maybe_not()?

Heh.

Then what the point to demand that "All file mapping must have ->vm_ops set"
if mmap(MAP_PRIVATE, "/dev/zero") has ->vm_ops == NULL ? Because this is
not actually the file mapping, yes. And this is why we want vma_is_anonymous()
to return T in this case.

vma_is_anonymous() just says that a page fault will use do_anonymous_page().
I agree, it would be nice to ensure vma_is_anonymous() can only be true
if this vma can only have the anon pages. Let me repeat that I suggested
this change as a short-term fix (at least without other changes like we
discuss above). Because the mmap_zero() hack looks worse to me. Damn, even
the ugly hack below looks better to me.

> > Whether we need to keep the vm_ops/fault check in __vma_link_rb() and
> > mmap_region() is another issue. But if we keep them, then I think we
> > should at least turn the !vma->vm_ops check in mmap_region into
> > WARN_ON() as well.
>
> It would require first fix all known cases where ->f_op->mmap() returns
> vma->vm_ops == NULL. Not subject for 4.3, I think.

Kirill, I even sent you the private email to clarify that - of course! -
I only meant "in the longer term" ;)

Oleg.

--- x/include/linux/mm.h
+++ x/include/linux/mm.h
@@ -1289,9 +1289,11 @@ static inline int vma_growsdown(struct v
 	return vma && (vma->vm_end == addr) && (vma->vm_flags & VM_GROWSDOWN);
 }
 
+#define xxx_fault	((void*)1)
+
 static inline bool vma_is_anonymous(struct vm_area_struct *vma)
 {
-	return !vma->vm_ops;
+	return !vma->vm_ops || vma->vm_ops->fault == xxx_fault;
 }
 
 static inline int stack_guard_page_start(struct vm_area_struct *vma,
--- x/drivers/char/mem.c
+++ x/drivers/char/mem.c
@@ -653,11 +653,17 @@ static ssize_t read_iter_zero(struct kio
 
 static int mmap_zero(struct file *file, struct vm_area_struct *vma)
 {
+	static const struct vm_operations_struct xxx_ops = {
+		.fault = xxx_fault,
+	};
+		}
 #ifndef CONFIG_MMU
 	return -ENOSYS;
 #endif
 	if (vma->vm_flags & VM_SHARED)
 		return shmem_zero_setup(vma);
+
+	vma->vm_ops = &xxx_ops;
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
