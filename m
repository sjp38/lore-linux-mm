Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8476B0072
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 14:04:41 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id va8so22448819obc.3
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 11:04:41 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id m38si11182149oik.13.2014.12.22.11.04.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 11:04:39 -0800 (PST)
Message-ID: <1419275072.8812.1.camel@stgolabs.net>
Subject: Re: mm: NULL ptr deref in unlink_file_vma
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 22 Dec 2014 11:04:32 -0800
In-Reply-To: <20141222180420.GA20261@node.dhcp.inet.fi>
References: <549832E2.8060609@oracle.com>
	 <20141222180102.GA8072@node.dhcp.inet.fi>
	 <20141222180420.GA20261@node.dhcp.inet.fi>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>

On Mon, 2014-12-22 at 20:04 +0200, Kirill A. Shutemov wrote:
> [ fixed Davidlohr's address. ]
> 
> On Mon, Dec 22, 2014 at 08:01:02PM +0200, Kirill A. Shutemov wrote:
> > On Mon, Dec 22, 2014 at 10:04:02AM -0500, Sasha Levin wrote:
> > > Hi all,
> > > 
> > > While fuzzing with trinity inside a KVM tools guest running the latest -next
> > > kernel, I've stumbled on the following spew:
> > > 
> > > [  432.376425] BUG: unable to handle kernel NULL pointer dereference at 0000000000000038
> > > [  432.378876] IP: down_write (./arch/x86/include/asm/rwsem.h:105 ./arch/x86/include/asm/rwsem.h:121 kernel/locking/rwsem.c:71)
> > 
> > Looks like vma->vm_file->mapping is NULL. Somebody freed ->vm_file from
> > under us?
> > 
> > I suspect Davidlohr's patchset on i_mmap_lock, but I cannot find any code
> > path which could lead to the crash.

Sasha, does this still occur if you revert c8475d144abb?

> > I've noticed one strange code path, which probably is not related to the
> > issue:
> > 
> > unmap_mapping_range()
> >   i_mmap_lock_read(mapping);
> >   unmap_mapping_range_tree()
> >     unmap_mapping_range_vma()
> >       zap_page_range_single()
> >         unmap_single_vma()
> > 	  if (unlikely(is_vm_hugetlb_page(vma))) {
> > 	    i_mmap_lock_write(vma->vm_file->f_mapping);

Right, this is would be completely bogus. But the deadlock cannot happen
in reality as hugetlb uses its own handlers and thus never calls
unmap_mapping_range.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
