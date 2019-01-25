Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81E1A8E00B5
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 23:19:56 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id g12so5461178pll.22
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 20:19:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n11sor34371640pfk.44.2019.01.24.20.19.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 20:19:54 -0800 (PST)
Date: Thu, 24 Jan 2019 20:19:45 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: BUG() due to "mm: put_and_wait_on_page_locked() while page is
 migrated"
In-Reply-To: <20190123093002.GP4087@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1901241909180.2158@eggly.anvils>
References: <f87ecfb2-64d3-23d4-54d7-a8ac37733206@lca.pw> <20190123093002.GP4087@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: Michal Hocko <mhocko@suse.com>, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>, torvalds@linux-foundation.org, vbabka@suse.cz, akpm@linux-foundation.org, Linux-MM <linux-mm@kvack.org>

On Wed, 23 Jan 2019, Michal Hocko wrote:
> On Tue 22-01-19 23:29:04, Qian Cai wrote:
> > Running LTP migrate_pages03 [1] a few times triggering BUG() below on an arm64
> > ThunderX2 server. Reverted the commit 9a1ea439b16b9 ("mm:
> > put_and_wait_on_page_locked() while page is migrated") allows it to run
> > continuously.
> > 
> > put_and_wait_on_page_locked
> >   wait_on_page_bit_common
> >     put_page
> >       put_page_testzero
> >         VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
> > 
> > [1]
> > https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/migrate_pages/migrate_pages03.c
> > 
> > [ 1304.643587] page:ffff7fe0226ff000 count:2 mapcount:0 mapping:ffff8095c3406d58 index:0x7
> > [ 1304.652082] xfs_address_space_operations [xfs]
> [...]
> > [ 1304.682652] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)
> 
> This looks like a page reference countimbalance to me. The page seemed
> to be freed at the the migration code (wait_on_page_bit_common) called
> put_page and immediatelly got reused for xfs allocation and that is why
> we see its ref count==2. But I fail to see how that is possible as
> __migration_entry_wait already does get_page_unless_zero so the
> imbalance must have been preexisting.

This report worried me, but I've thought around it, and agree with
Michal that it must be reflecting a preexisting refcount imbalance -
preexisting in the sense that the imbalance occurred sometime before
reaching put_and_wait_on_page_locked(), and in the sense that the bug
causing the imbalance came in before the put_and_wait_on_page_locked()
commit, perhaps even long ago.

If it is a software bug at all - I wonder if any other hardware shows
the same issue - I have not seen it on x86 (though I wasn't using xfs),
nor heard of anyone else reporting it - but thank you for doing so,
it could be important.

But I (probably) disagree with Michal about the page being freed and
reused for xfs allocation. I have no proof, but I think the likelihood
is that the page shown is the old xfs page (from libc-2.28.so, I see)
which is currently being migrated.

I realize that "last migrate reason: syscall_or_cpuset" would not get 
set until later, but I think it's left over from the previous migration:
migrate_pages03 looks like it's migrating pages back and forth repeatedly.

What I think happened is that something at some time earlier did a
mistaken put_page() on the page.  Then __migration_entry_wait() raced
with migrate_page_move_mapping(), in such a way that get_page_unless_zero()
then briefly raised the page's refcount to expected_count, so migration was
able to freeze the page (set its refcount transiently to 0).  Then put_and
_wait_on_page_locked() reached the put_page() in wait_on_page_bit_common()
while migration still had the refcount frozen at 0, and bang, your crash.

But how come reverting the put_and_wait commit appears to fix it for you?
That puzzled me, for a while I expected you then to see an equally visible
crash in the old put_page() after wait_on_page_locked(), or else at the
migration end where it puts the page afterwards (putback_lru_page perhaps).

I guess the answer comes from that "libc-2.28.so".  This page is one of
those very popular pages which were next-to-impossible to migrate before
the put_and_wait commit, because they are so widely mapped, and their
migration entries so frequently faulted, that migration could not freeze
them.  (With enough migration waiters to outweigh the off-by-one of the
incorrect refcount.)

Being so widely used, the refcount imbalance on that page would (I think)
only show up when unmounting the root at shutdown: easily missed.

So I think you've identified that the put_and_wait commit has exposed
an existing bug, and it may be very tedious to track down where that is.
Maybe the bug is itself triggered by migrate_pages03, but quite likely not.

Hugh
