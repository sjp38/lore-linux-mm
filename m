Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id DD1026B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 21:26:10 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so4277902pdj.3
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 18:26:10 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tv5si21785450pbc.72.2014.04.21.18.26.09
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 18:26:09 -0700 (PDT)
Date: Mon, 21 Apr 2014 18:26:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] mm: extract code to fault in a page from
 __get_user_pages()
Message-Id: <20140421182649.3df6180b.akpm@linux-foundation.org>
In-Reply-To: <20140422012022.GA28319@node.dhcp.inet.fi>
References: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1396535722-31108-5-git-send-email-kirill.shutemov@linux.intel.com>
	<20140421163522.41bba07f9e6ea11549383ad4@linux-foundation.org>
	<20140422005036.GA27749@node.dhcp.inet.fi>
	<20140421180227.e372200c.akpm@linux-foundation.org>
	<20140422012022.GA28319@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Tue, 22 Apr 2014 04:20:22 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Apr 21, 2014 at 06:02:27PM -0700, Andrew Morton wrote:
> > > Could you show resulting faultin_page() from you tree? Or I can just
> > > rebase it on top of your tree once it will be published if you wish.
> > 
> > It looked like this:
> > 
> > 				ret = faultin_page(tsk, vma, start, &foll_flags,
> > 						nonblocking);
> > 				switch (ret) {
> > 				case 0:
> > 					break;
> > 				case -EFAULT:
> > 				case -ENOMEM:
> > 				case -EHWPOISON:
> > 					return i ? i : ret;
> > 				case -EBUSY:
> > 					return i;
> > 				case -ENOENT:
> > 					goto next_page;
> > 				default:
> > 					BUILD_BUG();
> > 				}
> > 
> > is that what you tested?
> 
> Yes. But I wanted to see faultin_page() itself, not caller. :)

It's a gcc thing.

static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
		unsigned long address, unsigned int *flags, int *nonblocking)
{
	struct mm_struct *mm = vma->vm_mm;
	unsigned int fault_flags = 0;
	int ret;

	/* For mlock, just skip the stack guard page. */
	if ((*flags & FOLL_MLOCK) && stack_guard_page(vma, address))
		return -ENOENT;
	if (*flags & FOLL_WRITE)
		fault_flags |= FAULT_FLAG_WRITE;
	if (nonblocking)
		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
	if (*flags & FOLL_NOWAIT)
		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;

	ret = handle_mm_fault(mm, vma, address, fault_flags);
	if (ret & VM_FAULT_ERROR) {
		if (ret & VM_FAULT_OOM)
			return -ENOMEM;
		if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))
			return *flags & FOLL_HWPOISON ? -EHWPOISON : -EFAULT;
		if (ret & VM_FAULT_SIGBUS)
			return -EFAULT;
		BUG();
	}

	if (tsk) {
		if (ret & VM_FAULT_MAJOR)
			tsk->maj_flt++;
		else
			tsk->min_flt++;
	}

	if (ret & VM_FAULT_RETRY) {
		if (nonblocking)
			*nonblocking = 0;
		return -EBUSY;
	}

	/*
	 * The VM_FAULT_WRITE bit tells us that do_wp_page has broken COW when
	 * necessary, even if maybe_mkwrite decided not to set pte_write. We
	 * can thus safely do subsequent page lookups as if they were reads.
	 * But only do so when looping for pte_write is futile: in some cases
	 * userspace may also be wanting to write to the gotten user page,
	 * which a read fault here might prevent (a readonly page might get
	 * reCOWed by userspace write).
	 */
	if ((ret & VM_FAULT_WRITE) && !(vma->vm_flags & VM_WRITE))
		*flags &= ~FOLL_WRITE;
	return 0;
}

> > I suspect what happened is that your gcc worked out that faultin_page()
> > cannot return anything other than one of those six values and so the
> > compiler elided the BUILD_BUG() code.  But my gcc-4.4.4 isn't that smart.
> 
> Could be. I use gcc-4.8.2.
> 
> > No matter, let's just leave it as a BUG().
> 
> I'm okay with that.
> 
> I just want to make sure that we don't step on a real bug here. I'll
> recheck everything once your updated tree will be in linux-next.

OK, I'll get onto that tomorrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
