Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id A67456B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 21:03:56 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id g63-v6so80715ybi.22
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 18:03:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x185sor1096931ywf.142.2018.04.10.18.03.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 18:03:55 -0700 (PDT)
MIME-Version: 1.0
References: <201804080259.VS5U0mKT%fengguang.wu@intel.com> <20180410005908.167976-1-gthelen@google.com>
 <20180410133759.8ffd3170e5aaa7eb7eddcba6@linux-foundation.org>
In-Reply-To: <20180410133759.8ffd3170e5aaa7eb7eddcba6@linux-foundation.org>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 11 Apr 2018 01:03:43 +0000
Message-ID: <CAHH2K0b1q8+WgR1SmXE8F_yz+MH6Gju3+d-7RR4j_Q3E4Rk-SQ@mail.gmail.com>
Subject: Re: [PATCH v3] writeback: safer lock nesting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wang Long <wanglong19@meituan.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, npiggin@gmail.com, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, Apr 10, 2018 at 1:38 PM Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Mon,  9 Apr 2018 17:59:08 -0700 Greg Thelen <gthelen@google.com> wrote:

> > lock_page_memcg()/unlock_page_memcg() use spin_lock_irqsave/restore() if
> > the page's memcg is undergoing move accounting, which occurs when a
> > process leaves its memcg for a new one that has
> > memory.move_charge_at_immigrate set.
> >
> > unlocked_inode_to_wb_begin,end() use spin_lock_irq/spin_unlock_irq() if
the
> > given inode is switching writeback domains.  Switches occur when enough
> > writes are issued from a new domain.
> >
> > This existing pattern is thus suspicious:
> >     lock_page_memcg(page);
> >     unlocked_inode_to_wb_begin(inode, &locked);
> >     ...
> >     unlocked_inode_to_wb_end(inode, locked);
> >     unlock_page_memcg(page);
> >
> > If both inode switch and process memcg migration are both in-flight then
> > unlocked_inode_to_wb_end() will unconditionally enable interrupts while
> > still holding the lock_page_memcg() irq spinlock.  This suggests the
> > possibility of deadlock if an interrupt occurs before
> > unlock_page_memcg().
> >
> >     truncate
> >     __cancel_dirty_page
> >     lock_page_memcg
> >     unlocked_inode_to_wb_begin
> >     unlocked_inode_to_wb_end
> >     <interrupts mistakenly enabled>
> >                                     <interrupt>
> >                                     end_page_writeback
> >                                     test_clear_page_writeback
> >                                     lock_page_memcg
> >                                     <deadlock>
> >     unlock_page_memcg
> >
> > Due to configuration limitations this deadlock is not currently possible
> > because we don't mix cgroup writeback (a cgroupv2 feature) and
> > memory.move_charge_at_immigrate (a cgroupv1 feature).
> >
> > If the kernel is hacked to always claim inode switching and memcg
> > moving_account, then this script triggers lockup in less than a minute:
> >   cd /mnt/cgroup/memory
> >   mkdir a b
> >   echo 1 > a/memory.move_charge_at_immigrate
> >   echo 1 > b/memory.move_charge_at_immigrate
> >   (
> >     echo $BASHPID > a/cgroup.procs
> >     while true; do
> >       dd if=/dev/zero of=/mnt/big bs=1M count=256
> >     done
> >   ) &
> >   while true; do
> >     sync
> >   done &
> >   sleep 1h &
> >   SLEEP=$!
> >   while true; do
> >     echo $SLEEP > a/cgroup.procs
> >     echo $SLEEP > b/cgroup.procs
> >   done
> >
> > Given the deadlock is not currently possible, it's debatable if there's
> > any reason to modify the kernel.  I suggest we should to prevent future
> > surprises.
> >
> > ...
> >
> > Changelog since v2:
> > - explicitly initialize wb_lock_cookie to silence compiler warnings.

> But only in some places.  What's up with that?

I annotated it in places where my compiler was complaining about.  But
you're right.  It's better to init all 4.

> >
> > ...
> >
> > --- a/include/linux/backing-dev.h
> > +++ b/include/linux/backing-dev.h
> > @@ -346,7 +346,7 @@ static inline struct bdi_writeback
*inode_to_wb(const struct inode *inode)
> >  /**
> >   * unlocked_inode_to_wb_begin - begin unlocked inode wb access
transaction
> >   * @inode: target inode
> > - * @lockedp: temp bool output param, to be passed to the end function
> > + * @cookie: output param, to be passed to the end function
> >   *
> >   * The caller wants to access the wb associated with @inode but isn't
> >   * holding inode->i_lock, mapping->tree_lock or wb->list_lock.  This
> > @@ -354,12 +354,11 @@ static inline struct bdi_writeback
*inode_to_wb(const struct inode *inode)
> >   * association doesn't change until the transaction is finished with
> >   * unlocked_inode_to_wb_end().
> >   *
> > - * The caller must call unlocked_inode_to_wb_end() with *@lockdep
> > - * afterwards and can't sleep during transaction.  IRQ may or may not
be
> > - * disabled on return.
> > + * The caller must call unlocked_inode_to_wb_end() with *@cookie
afterwards and
> > + * can't sleep during transaction.  IRQ may or may not be disabled on
return.
> >   */

> Grammar is a bit awkward here,

> >
> > ...
> >
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -2501,13 +2501,13 @@ void account_page_redirty(struct page *page)
> >       if (mapping && mapping_cap_account_dirty(mapping)) {
> >               struct inode *inode = mapping->host;
> >               struct bdi_writeback *wb;
> > -             bool locked;
> > +             struct wb_lock_cookie cookie = {0};

> Trivia: it's better to use "= {}" here.  That has the same effect and
> it doesn't assume that the first field is a scalar.  And indeed, the
> first field is a bool so it should be {false}!

Nod.  Thanks for the tip.

> So...


> --- a/include/linux/backing-dev.h~writeback-safer-lock-nesting-fix
> +++ a/include/linux/backing-dev.h
> @@ -355,7 +355,8 @@ static inline struct bdi_writeback *inod
>     * unlocked_inode_to_wb_end().
>     *
>     * The caller must call unlocked_inode_to_wb_end() with *@cookie
afterwards and
> - * can't sleep during transaction.  IRQ may or may not be disabled on
return.
> + * can't sleep during the transaction.  IRQs may or may not be disabled
on
> + * return.
>     */
>    static inline struct bdi_writeback *
>    unlocked_inode_to_wb_begin(struct inode *inode, struct wb_lock_cookie
*cookie)
> --- a/mm/page-writeback.c~writeback-safer-lock-nesting-fix
> +++ a/mm/page-writeback.c
> @@ -2501,7 +2501,7 @@ void account_page_redirty(struct page *p
>           if (mapping && mapping_cap_account_dirty(mapping)) {
>                   struct inode *inode = mapping->host;
>                   struct bdi_writeback *wb;
> -               struct wb_lock_cookie cookie = {0};
> +               struct wb_lock_cookie cookie = {};

>                   wb = unlocked_inode_to_wb_begin(inode, &cookie);
>                   current->nr_dirtied--;
> @@ -2613,7 +2613,7 @@ void __cancel_dirty_page(struct page *pa
>           if (mapping_cap_account_dirty(mapping)) {
>                   struct inode *inode = mapping->host;
>                   struct bdi_writeback *wb;
> -               struct wb_lock_cookie cookie = {0};
> +               struct wb_lock_cookie cookie = {};

>                   lock_page_memcg(page);
>                   wb = unlocked_inode_to_wb_begin(inode, &cookie);
> @@ -2653,7 +2653,7 @@ int clear_page_dirty_for_io(struct page
>           if (mapping && mapping_cap_account_dirty(mapping)) {
>                   struct inode *inode = mapping->host;
>                   struct bdi_writeback *wb;
> -               struct wb_lock_cookie cookie = {0};
> +               struct wb_lock_cookie cookie = {};

>                   /*
>                    * Yes, Virginia, this is indeed insane.

> But I wonder about the remaining uninitialized wb_lock_cookies?

Yeah, I'll post an v4 with everything folded in.
