Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4A76B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 08:15:08 -0400 (EDT)
Received: by qgev79 with SMTP id v79so140043284qge.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 05:15:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 49si16654386qgn.69.2015.09.15.05.15.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 05:15:07 -0700 (PDT)
Date: Tue, 15 Sep 2015 14:12:01 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: LTP regressions due to 6dc296e7df4c ("mm: make sure all file
	VMAs have ->vm_ops set")
Message-ID: <20150915121201.GA10104@redhat.com>
References: <20150914105346.GB23878@arm.com> <20150914115800.06242CE@black.fi.intel.com> <20150914170547.GA28535@redhat.com> <20150914182033.GA4165@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914182033.GA4165@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, hpa@zytor.com, luto@amacapital.net, dave.hansen@linux.intel.com, mingo@elte.hu, minchan@kernel.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/14, Kirill A. Shutemov wrote:
>
> On Mon, Sep 14, 2015 at 07:05:47PM +0200, Oleg Nesterov wrote:
> > On 09/14, Kirill A. Shutemov wrote:
> > >
> > > Fix is below. I don't really like it, but I cannot find any better
> > > solution.
> >
> > Me too...
> >
> > But this change "documents" the nasty special "vm_file && !vm_ops" case, and
> > I am not sure how we can remove it later...
> >
> > So perhaps we should change vma_is_anonymous() back to check ->fault too,
> >
> > 	 static inline bool vma_is_anonymous(struct vm_area_struct *vma)
> > 	 {
> > 	-	return !vma->vm_ops;
> > 	+	return !vma->vm_ops || !vma->vm_ops->fault;
>
> No. This would give a lot false positives from drives which setup page
> tables upfront and don't use ->fault at all.

And? I mean, I am not sure I understand what exactly do you dislike.

Firstly, I still think that (in the long term) we should change them
to use .faul = no_fault() which just returns VM_FAULT_SIGBUS.

Until then I do not see why the change above can be really bad. The
VM_SHARED case is fine, do_anonymous_page() will return VM_FAULT_SIGBUS.

So afaics the only problem is that after the change above the private
mapping can silently get an anonymous page after (say) MADV_DONTNEED
instead of the nice SIGBUS from do_fault(). I agree, this is not good,
but see above.

Or I missed something else?

Let me repeat, I am not going to really argue, you understand this all
much better than me. But imho we should try to avoid the special case
added by your change as much as possible, in this sense the change above
looks "obviously better" at least as a short-term fix.


Whether we need to keep the vm_ops/fault check in __vma_link_rb() and
mmap_region() is another issue. But if we keep them, then I think we
should at least turn the !vma->vm_ops check in mmap_region into
WARN_ON() as well.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
