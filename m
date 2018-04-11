Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB726B0007
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 04:50:41 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id g8-v6so445075ybf.23
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 01:50:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l187-v6sor118270ybl.185.2018.04.11.01.50.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 01:50:40 -0700 (PDT)
MIME-Version: 1.0
References: <CAHH2K0bcehi-OH3AQs-VK7+d4-THOVXARTXik2UxRhZOuDrHTQ@mail.gmail.com>
 <20180411084521.254006-1-gthelen@google.com>
In-Reply-To: <20180411084521.254006-1-gthelen@google.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 11 Apr 2018 08:50:28 +0000
Message-ID: <CAHH2K0a_6Z3O4KPfLmZd9PRYfj-kZ8RFzOrXj2PZz4M-Xfxf9w@mail.gmail.com>
Subject: Re: [PATCH for-4.4] writeback: safer lock nesting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <wanglong19@meituan.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Sasha Levin <Alexander.Levin@microsoft.com>
Cc: npiggin@gmail.com, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, stable@vger.kernel.org

On Wed, Apr 11, 2018 at 1:45 AM Greg Thelen <gthelen@google.com> wrote:

> lock_page_memcg()/unlock_page_memcg() use spin_lock_irqsave/restore() if
> the page's memcg is undergoing move accounting, which occurs when a
> process leaves its memcg for a new one that has
> memory.move_charge_at_immigrate set.

> unlocked_inode_to_wb_begin,end() use spin_lock_irq/spin_unlock_irq() if
the
> given inode is switching writeback domains.  Switches occur when enough
> writes are issued from a new domain.

> This existing pattern is thus suspicious:
>      lock_page_memcg(page);
>      unlocked_inode_to_wb_begin(inode, &locked);
>      ...
>      unlocked_inode_to_wb_end(inode, locked);
>      unlock_page_memcg(page);

> If both inode switch and process memcg migration are both in-flight then
> unlocked_inode_to_wb_end() will unconditionally enable interrupts while
> still holding the lock_page_memcg() irq spinlock.  This suggests the
> possibility of deadlock if an interrupt occurs before
> unlock_page_memcg().

>      truncate
>      __cancel_dirty_page
>      lock_page_memcg
>      unlocked_inode_to_wb_begin
>      unlocked_inode_to_wb_end
>      <interrupts mistakenly enabled>
>                                      <interrupt>
>                                      end_page_writeback
>                                      test_clear_page_writeback
>                                      lock_page_memcg
>                                      <deadlock>
>      unlock_page_memcg

> Due to configuration limitations this deadlock is not currently possible
> because we don't mix cgroup writeback (a cgroupv2 feature) and
> memory.move_charge_at_immigrate (a cgroupv1 feature).

> If the kernel is hacked to always claim inode switching and memcg
> moving_account, then this script triggers lockup in less than a minute:
>    cd /mnt/cgroup/memory
>    mkdir a b
>    echo 1 > a/memory.move_charge_at_immigrate
>    echo 1 > b/memory.move_charge_at_immigrate
>    (
>      echo $BASHPID > a/cgroup.procs
>      while true; do
>        dd if=/dev/zero of=/mnt/big bs=1M count=256
>      done
>    ) &
>    while true; do
>      sync
>    done &
>    sleep 1h &
>    SLEEP=$!
>    while true; do
>      echo $SLEEP > a/cgroup.procs
>      echo $SLEEP > b/cgroup.procs
>    done

> The deadlock does not seem possible, so it's debatable if there's
> any reason to modify the kernel.  I suggest we should to prevent future
> surprises.  And Wang Long said "this deadlock occurs three times in our
> environment", so there's more reason to apply this, even to stable.

Wang Long: I wasn't able to reproduce the 4.4 problem.  But tracing
suggests this 4.4 patch is effective.  If you can reproduce the problem in
your 4.4 environment, then it'd be nice to confirm this fixes it.  Thanks!

> [ This patch is only for 4.4 stable.  Newer stable kernels should use be
able to
>    cherry pick the upstream "writeback: safer lock nesting" patch. ]

> Fixes: 682aa8e1a6a1 ("writeback: implement unlocked_inode_to_wb
transaction and use it for stat updates")
> Cc: stable@vger.kernel.org # v4.2+
> Reported-by: Wang Long <wanglong19@meituan.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Wang Long <wanglong19@meituan.com>
> ---
>   fs/fs-writeback.c                |  7 ++++---
>   include/linux/backing-dev-defs.h |  5 +++++
>   include/linux/backing-dev.h      | 31 +++++++++++++++++--------------
>   mm/page-writeback.c              | 18 +++++++++---------
>   4 files changed, 35 insertions(+), 26 deletions(-)

> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 22b30249fbcb..0fe667875852 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -747,11 +747,12 @@ int inode_congested(struct inode *inode, int
cong_bits)
>           */
>          if (inode && inode_to_wb_is_valid(inode)) {
>                  struct bdi_writeback *wb;
> -               bool locked, congested;
> +               struct wb_lock_cookie lock_cookie = {};
> +               bool congested;

> -               wb = unlocked_inode_to_wb_begin(inode, &locked);
> +               wb = unlocked_inode_to_wb_begin(inode, &lock_cookie);
>                  congested = wb_congested(wb, cong_bits);
> -               unlocked_inode_to_wb_end(inode, locked);
> +               unlocked_inode_to_wb_end(inode, &lock_cookie);
>                  return congested;
>          }

> diff --git a/include/linux/backing-dev-defs.h
b/include/linux/backing-dev-defs.h
> index 140c29635069..a307c37c2e6c 100644
> --- a/include/linux/backing-dev-defs.h
> +++ b/include/linux/backing-dev-defs.h
> @@ -191,6 +191,11 @@ static inline void set_bdi_congested(struct
backing_dev_info *bdi, int sync)
>          set_wb_congested(bdi->wb.congested, sync);
>   }

> +struct wb_lock_cookie {
> +       bool locked;
> +       unsigned long flags;
> +};
> +
>   #ifdef CONFIG_CGROUP_WRITEBACK

>   /**
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 89d3de3e096b..361274ce5815 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -366,7 +366,7 @@ static inline struct bdi_writeback
*inode_to_wb(struct inode *inode)
>   /**
>    * unlocked_inode_to_wb_begin - begin unlocked inode wb access
transaction
>    * @inode: target inode
> - * @lockedp: temp bool output param, to be passed to the end function
> + * @cookie: output param, to be passed to the end function
>    *
>    * The caller wants to access the wb associated with @inode but isn't
>    * holding inode->i_lock, mapping->tree_lock or wb->list_lock.  This
> @@ -374,12 +374,12 @@ static inline struct bdi_writeback
*inode_to_wb(struct inode *inode)
>    * association doesn't change until the transaction is finished with
>    * unlocked_inode_to_wb_end().
>    *
> - * The caller must call unlocked_inode_to_wb_end() with *@lockdep
> - * afterwards and can't sleep during transaction.  IRQ may or may not be
> - * disabled on return.
> + * The caller must call unlocked_inode_to_wb_end() with *@cookie
afterwards and
> + * can't sleep during the transaction.  IRQs may or may not be disabled
on
> + * return.
>    */
>   static inline struct bdi_writeback *
> -unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
> +unlocked_inode_to_wb_begin(struct inode *inode, struct wb_lock_cookie
*cookie)
>   {
>          rcu_read_lock();

> @@ -387,10 +387,10 @@ unlocked_inode_to_wb_begin(struct inode *inode,
bool *lockedp)
>           * Paired with store_release in inode_switch_wb_work_fn() and
>           * ensures that we see the new wb if we see cleared I_WB_SWITCH.
>           */
> -       *lockedp = smp_load_acquire(&inode->i_state) & I_WB_SWITCH;
> +       cookie->locked = smp_load_acquire(&inode->i_state) & I_WB_SWITCH;

> -       if (unlikely(*lockedp))
> -               spin_lock_irq(&inode->i_mapping->tree_lock);
> +       if (unlikely(cookie->locked))
> +               spin_lock_irqsave(&inode->i_mapping->tree_lock,
cookie->flags);

>          /*
>           * Protected by either !I_WB_SWITCH + rcu_read_lock() or
tree_lock.
> @@ -402,12 +402,14 @@ unlocked_inode_to_wb_begin(struct inode *inode,
bool *lockedp)
>   /**
>    * unlocked_inode_to_wb_end - end inode wb access transaction
>    * @inode: target inode
> - * @locked: *@lockedp from unlocked_inode_to_wb_begin()
> + * @cookie: @cookie from unlocked_inode_to_wb_begin()
>    */
> -static inline void unlocked_inode_to_wb_end(struct inode *inode, bool
locked)
> +static inline void unlocked_inode_to_wb_end(struct inode *inode,
> +                                           struct wb_lock_cookie *cookie)
>   {
> -       if (unlikely(locked))
> -               spin_unlock_irq(&inode->i_mapping->tree_lock);
> +       if (unlikely(cookie->locked))
> +               spin_unlock_irqrestore(&inode->i_mapping->tree_lock,
> +                                      cookie->flags);

>          rcu_read_unlock();
>   }
> @@ -454,12 +456,13 @@ static inline struct bdi_writeback
*inode_to_wb(struct inode *inode)
>   }

>   static inline struct bdi_writeback *
> -unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
> +unlocked_inode_to_wb_begin(struct inode *inode, struct wb_lock_cookie
*cookie)
>   {
>          return inode_to_wb(inode);
>   }

> -static inline void unlocked_inode_to_wb_end(struct inode *inode, bool
locked)
> +static inline void unlocked_inode_to_wb_end(struct inode *inode,
> +                                           struct wb_lock_cookie *cookie)
>   {
>   }

> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 6d0dbde4503b..3309dbda7ffa 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2510,13 +2510,13 @@ void account_page_redirty(struct page *page)
>          if (mapping && mapping_cap_account_dirty(mapping)) {
>                  struct inode *inode = mapping->host;
>                  struct bdi_writeback *wb;
> -               bool locked;
> +               struct wb_lock_cookie cookie = {};

> -               wb = unlocked_inode_to_wb_begin(inode, &locked);
> +               wb = unlocked_inode_to_wb_begin(inode, &cookie);
>                  current->nr_dirtied--;
>                  dec_zone_page_state(page, NR_DIRTIED);
>                  dec_wb_stat(wb, WB_DIRTIED);
> -               unlocked_inode_to_wb_end(inode, locked);
> +               unlocked_inode_to_wb_end(inode, &cookie);
>          }
>   }
>   EXPORT_SYMBOL(account_page_redirty);
> @@ -2622,15 +2622,15 @@ void cancel_dirty_page(struct page *page)
>                  struct inode *inode = mapping->host;
>                  struct bdi_writeback *wb;
>                  struct mem_cgroup *memcg;
> -               bool locked;
> +               struct wb_lock_cookie cookie = {};

>                  memcg = mem_cgroup_begin_page_stat(page);
> -               wb = unlocked_inode_to_wb_begin(inode, &locked);
> +               wb = unlocked_inode_to_wb_begin(inode, &cookie);

>                  if (TestClearPageDirty(page))
>                          account_page_cleaned(page, mapping, memcg, wb);

> -               unlocked_inode_to_wb_end(inode, locked);
> +               unlocked_inode_to_wb_end(inode, &cookie);
>                  mem_cgroup_end_page_stat(memcg);
>          } else {
>                  ClearPageDirty(page);
> @@ -2663,7 +2663,7 @@ int clear_page_dirty_for_io(struct page *page)
>                  struct inode *inode = mapping->host;
>                  struct bdi_writeback *wb;
>                  struct mem_cgroup *memcg;
> -               bool locked;
> +               struct wb_lock_cookie cookie = {};

>                  /*
>                   * Yes, Virginia, this is indeed insane.
> @@ -2701,14 +2701,14 @@ int clear_page_dirty_for_io(struct page *page)
>                   * exclusion.
>                   */
>                  memcg = mem_cgroup_begin_page_stat(page);
> -               wb = unlocked_inode_to_wb_begin(inode, &locked);
> +               wb = unlocked_inode_to_wb_begin(inode, &cookie);
>                  if (TestClearPageDirty(page)) {
>                          mem_cgroup_dec_page_stat(memcg,
MEM_CGROUP_STAT_DIRTY);
>                          dec_zone_page_state(page, NR_FILE_DIRTY);
>                          dec_wb_stat(wb, WB_RECLAIMABLE);
>                          ret = 1;
>                  }
> -               unlocked_inode_to_wb_end(inode, locked);
> +               unlocked_inode_to_wb_end(inode, &cookie);
>                  mem_cgroup_end_page_stat(memcg);
>                  return ret;
>          }
> --
> 2.17.0.484.g0c8726318c-goog
