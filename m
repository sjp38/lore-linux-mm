Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 733846B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 18:42:34 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w1-v6so1335334ply.12
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 15:42:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7-v6sor2433641pgk.232.2018.07.23.15.42.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 15:42:33 -0700 (PDT)
Date: Mon, 23 Jul 2018 15:42:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
In-Reply-To: <20180723203628.GA18236@bombadil.infradead.org>
Message-ID: <alpine.LSU.2.11.1807231531240.2545@eggly.anvils>
References: <000000000000d624c605705e9010@google.com> <20180709143610.GD2662@bombadil.infradead.org> <alpine.LSU.2.11.1807221856350.5536@eggly.anvils> <20180723140150.GA31843@bombadil.infradead.org> <alpine.LSU.2.11.1807231111310.1698@eggly.anvils>
 <20180723203628.GA18236@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Mon, 23 Jul 2018, Matthew Wilcox wrote:
> On Mon, Jul 23, 2018 at 12:14:41PM -0700, Hugh Dickins wrote:
> > On Mon, 23 Jul 2018, Matthew Wilcox wrote:
> > > On Sun, Jul 22, 2018 at 07:28:01PM -0700, Hugh Dickins wrote:
> > > > Whether or not that fixed syzbot's kernel BUG at mm/shmem.c:815!
> > > > I don't know, but I'm afraid it has not fixed linux-next breakage of
> > > > huge tmpfs: I get a similar page_to_pgoff BUG at mm/filemap.c:1466!
> > > > 
> > > > Please try something like
> > > > mount -o remount,huge=always /dev/shm
> > > > cp /dev/zero /dev/shm
> > > > 
> > > > Writing soon crashes in find_lock_entry(), looking up offset 0x201
> > > > but getting the page for offset 0x3c1 instead.
> > > 
> > > Hmm.  I don't see a crash while running that command,
> > 
> > Thanks for looking.
> > 
> > It is the VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page)
> > in find_lock_entry(). Perhaps you didn't have CONFIG_DEBUG_VM=y
> > on this occasion? Or you don't think of an oops as a kernel crash,
> > and didn't notice it in dmesg? I see now that I've arranged for oops
> > to crash, since I don't like to miss them myself; but it is a very
> > clean oops, no locks held, so can just kill the process and continue.
> 
> Usually I run with that turned on, but somehow in my recent messing
> with my test system, that got turned off.  Once I turned it back on,
> it spots the bug instantly.
> 
> > Or is there something more mysterious stopping it from showing up for
> > you? It's repeatable for me. When not crashing, that "cp" should fill
> > up about half of RAM before it hits the implicit tmpfs volume limit;
> > but I am assuming a not entirely fragmented machine - it does need
> > to allocate two 2MB pages before hitting the VM_BUG_ON_PAGE().
> 
> I tried that too, before noticing that DEBUG_VM was off; raised my test
> VM's memory from 2GB to 8GB.
> 
> > Are you sure that those pages are free, rather than most of them tails
> > of one of the two compound pages involved? I think it's the same in your
> > rewrite of struct page, the compound_head field (lru.next), with its low
> > bit set, were how to recognize a tail page.
> 
> Yes, PageTail was set, and so was TAIL_MAPPING (0xdead0000000000400).
> What was going on was the first 2MB page was being stored at indices
> 0-511, then the second 2MB page was being stored at indices 64-575
> instead of 512-1023.
> 
> I figured out a fix and pushed it to the 'ida' branch in
> git://git.infradead.org/users/willy/linux-dax.git

Great, thanks a lot for sorting that out so quickly. But I've cloned
the tree and don't see today's patch, so assume you've folded the fix
into an existing commit? If possible, please append the diff of today's
fix to this thread so that we can try it out. Or if that's difficult,
please at least tell which files were modified, then I can probably
work it out from the diff of those files against mmotm.

Thanks,
Hugh

> 
> It won't be in linux-next tomorrow because the nvdimm people have
> just dumped a pile of patches into their tree that conflict with
> the XArray-DAX rewrite, so Stephen has pulled the XArray tree out
> of linux-next temporarily.  I didn't have time to sort out the merge
> conflict today because I judged your bug report more important.
