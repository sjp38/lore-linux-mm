Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 71B766B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 06:10:23 -0400 (EDT)
Date: Wed, 5 Jun 2013 11:10:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Handling NUMA page migration
Message-ID: <20130605101019.GA18242@suse.de>
References: <201306040922.10235.frank.mehnert@oracle.com>
 <20130604115807.GF3672@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130604115807.GF3672@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Frank Mehnert <frank.mehnert@oracle.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Tue, Jun 04, 2013 at 06:58:07AM -0500, Robin Holt wrote:
> > B) 1. allocate memory with alloc_pages()
> >    2. SetPageReserved()
> >    3. vm_mmap() to allocate a userspace mapping
> >    4. vm_insert_page()
> >    5. vm_flags |= (VM_DONTEXPAND | VM_DONTDUMP)
> >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND | 0xff)
> > 
> > At least the memory allocated like B) is affected by automatic NUMA page
> > migration. I'm not sure about A).
> > 
> > 1. How can I prevent automatic NUMA page migration on this memory?
> > 2. Can NUMA page migration also be handled on such kind of memory without
> >    preventing migration?
> > 

Page migration does not expect a PageReserved && PageLRU page. The only
reserved check that is made by migration is for the zero page and that
happens in the syscall path for move_pages() which is not used by either
compaction or automatic balancing.

At some point you must have a driver that is setting PageReserved on
anonymous pages that is later encountered by automatic numa balancing
during a NUMA hinting fault.  I expect this is an out-of-tree driver or
a custom kernel of some sort. Memory should be pinned by elevating the
reference count of the page, not setting PageReserved.

It's not particularly clear how you avoid hitting the same bug due to THP and
memory compaction to be honest but maybe your setup hits a steady state that
simply never hit the problem or it happens rarely and it was not identified.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
