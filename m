Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 83B0282965
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 20:53:18 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id ft15so3074778pdb.28
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 17:53:18 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id v1si7943039pdn.13.2014.07.09.17.53.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 17:53:17 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so9917331pde.3
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 17:53:16 -0700 (PDT)
Date: Wed, 9 Jul 2014 17:51:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: shm: hang in shmem_fallocate
In-Reply-To: <alpine.LSU.2.11.1407091518530.13001@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1407091732300.13483@eggly.anvils>
References: <52AE7B10.2080201@oracle.com> <52F6898A.50101@oracle.com> <alpine.LSU.2.11.1402081841160.26825@eggly.anvils> <52F82E62.2010709@oracle.com> <539A0FC8.8090504@oracle.com> <alpine.LSU.2.11.1406151921070.2850@eggly.anvils> <53A9A7D8.2020703@suse.cz>
 <alpine.LSU.2.11.1406251152450.1580@eggly.anvils> <53ABE479.3080508@suse.cz> <alpine.LSU.2.11.1406262108390.27670@eggly.anvils> <20140709215906.GA27323@cmpxchg.org> <alpine.LSU.2.11.1407091518530.13001@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 9 Jul 2014, Hugh Dickins wrote:
> On Wed, 9 Jul 2014, Johannes Weiner wrote:
> > On Thu, Jun 26, 2014 at 10:36:20PM -0700, Hugh Dickins wrote:
> > > Hannes, a question for you please, I just could not make up my mind.
> > > In mm/truncate.c truncate_inode_pages_range(), what should be done
> > > with a failed clear_exceptional_entry() in the case of hole-punch?
> > > Is that case currently depending on the rescan loop (that I'm about
> > > to revert) to remove a new page, so I would need to add a retry for
> > > that rather like the shmem_free_swap() one?  Or is it irrelevant,
> > > and can stay unchanged as below?  I've veered back and forth,
> > > thinking first one and then the other.
> > 
> > I realize you have given up on changing truncate.c in the meantime,
> > but I'm still asking myself about the swap retry case: why retry for
> > swap-to-page changes, yet not for page-to-page changes?
> > 
> > In case faults are disabled through i_size, concurrent swapin could
> > still turn swap entries into pages, so I can see the need to retry.
> > There is no equivalent for shadow entries, though, and they can only
> > be turned through page faults, so no retry necessary in that case.
> > 
> > However, you explicitely mentioned the hole-punch case above: if that
> > can't guarantee the hole will be reliably cleared under concurrent
> > faults, I'm not sure why it would put in more effort to free it of
> > swap (or shadow) entries than to free it of pages.
> > 
> > What am I missing?
> 
> In dropping the pincer effect, I am conceding that data written (via
> mmap) racily into the hole, behind the punching cursor, between the
> starting and the ending of the punch operation, may be allowed to
> remain.  It will not often happen (given the two loops), but it might.
> 
> But I insist that all data in the hole at the starting of the punch
> operation must be removed by the ending of the punch operation (though
> of course, given the paragraph above, identical data might be written
> in its place concurrently, via mmap, if the application chooses).
> 
> I think you probably agree with both of those propositions.
> 
> As the punching cursor moves along the radix_tree, it gathers page
> pointers and swap entries (the emply slots are already skipped at
> the level below; and tmpfs takes care that there is no instant in
> switching between page and swap when the slot appears empty).
> 
> Dealing with the page pointers is easy: a reference is already held,
> then shmem_undo_range takes the page lock which prevents swizzling
> to swap, then truncates that page out of the tree.
> 
> But dealing with swap entries is slippery: there is no reference
> held, and no lock to prevent swizzling to page (outside of the
> tree_lock taken in shmem_free_swap).
> 
> So, as I see it, the page lock ensures that any pages present at
> the starting of the punch operation will be removed, without any
> need to go back and retry.  But a swap entry present at the starting
> of the punch operation might be swizzled back to page (and, if we
> imagine massive preemption, even back to swap again, and to page
> again, etc) at the wrong moment: so for swap we do need to retry.
> 
> (What I said there is not quite correct: that swap would actually
> have to be a locked page at the time when the first loop meets it.)
> 
> Does that make sense?

Allow me to disagree with myself: no, I now think you were right
to press me on this, and we need also the patch below.  Do you
agree, or do you see something more is needed?

Note to onlookers: this would have no bearing on the shmem_fallocate
hang which Sasha reported seeing on -next yesterday (in another thread),
but is nonetheless a correction to the patch we have there - I think.

Hugh

--- 3.16-rc3-mm1/mm/shmem.c	2014-07-02 15:32:22.220311543 -0700
+++ linux/mm/shmem.c	2014-07-09 17:38:49.972818635 -0700
@@ -516,6 +516,11 @@ static void shmem_undo_range(struct inod
 				if (page->mapping == mapping) {
 					VM_BUG_ON_PAGE(PageWriteback(page), page);
 					truncate_inode_page(mapping, page);
+				} else {
+					/* Page was replaced by swap: retry */
+					unlock_page(page);
+					index--;
+					break;
 				}
 			}
 			unlock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
