Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 11AC96B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 09:42:20 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so29486396wic.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:42:19 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id ex18si24504390wid.77.2015.09.15.06.42.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 06:42:18 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so29485221wic.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 06:42:18 -0700 (PDT)
Date: Tue, 15 Sep 2015 16:42:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: LTP regressions due to 6dc296e7df4c ("mm: make sure all file
 VMAs have ->vm_ops set")
Message-ID: <20150915134216.GA16093@node.dhcp.inet.fi>
References: <20150914105346.GB23878@arm.com>
 <20150914115800.06242CE@black.fi.intel.com>
 <20150914170547.GA28535@redhat.com>
 <20150914182033.GA4165@node.dhcp.inet.fi>
 <20150915121201.GA10104@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915121201.GA10104@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, hpa@zytor.com, luto@amacapital.net, dave.hansen@linux.intel.com, mingo@elte.hu, minchan@kernel.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 15, 2015 at 02:12:01PM +0200, Oleg Nesterov wrote:
> On 09/14, Kirill A. Shutemov wrote:
> >
> > On Mon, Sep 14, 2015 at 07:05:47PM +0200, Oleg Nesterov wrote:
> > > On 09/14, Kirill A. Shutemov wrote:
> > > >
> > > > Fix is below. I don't really like it, but I cannot find any better
> > > > solution.
> > >
> > > Me too...
> > >
> > > But this change "documents" the nasty special "vm_file && !vm_ops" case, and
> > > I am not sure how we can remove it later...
> > >
> > > So perhaps we should change vma_is_anonymous() back to check ->fault too,
> > >
> > > 	 static inline bool vma_is_anonymous(struct vm_area_struct *vma)
> > > 	 {
> > > 	-	return !vma->vm_ops;
> > > 	+	return !vma->vm_ops || !vma->vm_ops->fault;
> >
> > No. This would give a lot false positives from drives which setup page
> > tables upfront and don't use ->fault at all.
> 
> And? I mean, I am not sure I understand what exactly do you dislike.
> 
> Firstly, I still think that (in the long term) we should change them
> to use .faul = no_fault() which just returns VM_FAULT_SIGBUS.

I would rather like to see consolidated fault path between file and anon
with ->vm_ops set for both. So vma_is_anonymous() will be trivial
vma->vm_ops == anon_vm_ops.

> Until then I do not see why the change above can be really bad. The
> VM_SHARED case is fine, do_anonymous_page() will return VM_FAULT_SIGBUS.
> 
> So afaics the only problem is that after the change above the private
> mapping can silently get an anonymous page after (say) MADV_DONTNEED
> instead of the nice SIGBUS from do_fault(). I agree, this is not good,
> but see above.

So, what the point to introduce vma_is_anonymous() if it often produces
false result? vma_is_anonymous_or_maybe_not()?

> Or I missed something else?
> 
> Let me repeat, I am not going to really argue, you understand this all
> much better than me. But imho we should try to avoid the special case
> added by your change as much as possible, in this sense the change above
> looks "obviously better" at least as a short-term fix.
> 
> 
> Whether we need to keep the vm_ops/fault check in __vma_link_rb() and
> mmap_region() is another issue. But if we keep them, then I think we
> should at least turn the !vma->vm_ops check in mmap_region into
> WARN_ON() as well.

It would require first fix all known cases where ->f_op->mmap() returns
vma->vm_ops == NULL. Not subject for 4.3, I think.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
