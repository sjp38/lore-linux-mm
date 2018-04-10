Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06B236B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 04:15:20 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c3-v6so9248650itc.4
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 01:15:20 -0700 (PDT)
Received: from mx02.meituan.com (mx-fe5-210.meituan.com. [103.37.138.210])
        by mx.google.com with ESMTPS id z84-v6si941320ita.39.2018.04.10.01.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 01:15:18 -0700 (PDT)
Subject: Re: [PATCH v3] writeback: safer lock nesting
References: <201804080259.VS5U0mKT%fengguang.wu@intel.com>
 <20180410005908.167976-1-gthelen@google.com>
From: Wang Long <wanglong19@meituan.com>
Message-ID: <55efb2c6-04c5-d2bb-738e-8308aa0eaf8f@meituan.com>
Date: Tue, 10 Apr 2018 16:14:25 +0800
MIME-Version: 1.0
In-Reply-To: <20180410005908.167976-1-gthelen@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>
Cc: npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> lock_page_memcg()/unlock_page_memcg() use spin_lock_irqsave/restore() i=
f
> the page's memcg is undergoing move accounting, which occurs when a
> process leaves its memcg for a new one that has
> memory.move_charge_at_immigrate set.
>
> unlocked_inode_to_wb_begin,end() use spin_lock_irq/spin_unlock_irq() if=
 the
> given inode is switching writeback domains.  Switches occur when enough
> writes are issued from a new domain.
>
> This existing pattern is thus suspicious:
>      lock_page_memcg(page);
>      unlocked_inode_to_wb_begin(inode, &locked);
>      ...
>      unlocked_inode_to_wb_end(inode, locked);
>      unlock_page_memcg(page);
>
> If both inode switch and process memcg migration are both in-flight the=
n
> unlocked_inode_to_wb_end() will unconditionally enable interrupts while
> still holding the lock_page_memcg() irq spinlock.  This suggests the
> possibility of deadlock if an interrupt occurs before
> unlock_page_memcg().
>
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
>
> Due to configuration limitations this deadlock is not currently possibl=
e
> because we don't mix cgroup writeback (a cgroupv2 feature) and
> memory.move_charge_at_immigrate (a cgroupv1 feature).
>
> If the kernel is hacked to always claim inode switching and memcg
> moving_account, then this script triggers lockup in less than a minute:
>    cd /mnt/cgroup/memory
>    mkdir a b
>    echo 1 > a/memory.move_charge_at_immigrate
>    echo 1 > b/memory.move_charge_at_immigrate
>    (
>      echo $BASHPID > a/cgroup.procs
>      while true; do
>        dd if=3D/dev/zero of=3D/mnt/big bs=3D1M count=3D256
>      done
>    ) &
>    while true; do
>      sync
>    done &
>    sleep 1h &
>    SLEEP=3D$!
>    while true; do
>      echo $SLEEP > a/cgroup.procs
>      echo $SLEEP > b/cgroup.procs
>    done
>
> Given the deadlock is not currently possible, it's debatable if there's
> any reason to modify the kernel.  I suggest we should to prevent future
> surprises.
This deadlock occurs three times in our environment=EF=BC=8C

this deadlock occurs three times in our environment. It is better to cc s=
table kernel and
backport it.

Acked-by: Wang Long <wanglong19@meituan.com>

thanks

> Reported-by: Wang Long <wanglong19@meituan.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Change-Id: Ibb773e8045852978f6207074491d262f1b3fb613
> ---
> Changelog since v2:
> - explicitly initialize wb_lock_cookie to silence compiler warnings.
>
> Changelog since v1:
> - add wb_lock_cookie to record lock context.
>
>   fs/fs-writeback.c                |  7 ++++---
>   include/linux/backing-dev-defs.h |  5 +++++
>   include/linux/backing-dev.h      | 30 ++++++++++++++++--------------
>   mm/page-writeback.c              | 18 +++++++++---------
>   4 files changed, 34 insertions(+), 26 deletions(-)
>
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 1280f915079b..f4b2f6625913 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -745,11 +745,12 @@ int inode_congested(struct inode *inode, int cong=
_bits)
>   	 */
>   	if (inode && inode_to_wb_is_valid(inode)) {
>   		struct bdi_writeback *wb;
> -		bool locked, congested;
> +		struct wb_lock_cookie lock_cookie;
> +		bool congested;
>  =20
> -		wb =3D unlocked_inode_to_wb_begin(inode, &locked);
> +		wb =3D unlocked_inode_to_wb_begin(inode, &lock_cookie);
>   		congested =3D wb_congested(wb, cong_bits);
> -		unlocked_inode_to_wb_end(inode, locked);
> +		unlocked_inode_to_wb_end(inode, &lock_cookie);
>   		return congested;
>   	}
>  =20
> diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-d=
ev-defs.h
> index bfe86b54f6c1..0bd432a4d7bd 100644
> --- a/include/linux/backing-dev-defs.h
> +++ b/include/linux/backing-dev-defs.h
> @@ -223,6 +223,11 @@ static inline void set_bdi_congested(struct backin=
g_dev_info *bdi, int sync)
>   	set_wb_congested(bdi->wb.congested, sync);
>   }
>  =20
> +struct wb_lock_cookie {
> +	bool locked;
> +	unsigned long flags;
> +};
> +
>   #ifdef CONFIG_CGROUP_WRITEBACK
>  =20
>   /**
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 3e4ce54d84ab..1d744c61d996 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -346,7 +346,7 @@ static inline struct bdi_writeback *inode_to_wb(con=
st struct inode *inode)
>   /**
>    * unlocked_inode_to_wb_begin - begin unlocked inode wb access transa=
ction
>    * @inode: target inode
> - * @lockedp: temp bool output param, to be passed to the end function
> + * @cookie: output param, to be passed to the end function
>    *
>    * The caller wants to access the wb associated with @inode but isn't
>    * holding inode->i_lock, mapping->tree_lock or wb->list_lock.  This
> @@ -354,12 +354,11 @@ static inline struct bdi_writeback *inode_to_wb(c=
onst struct inode *inode)
>    * association doesn't change until the transaction is finished with
>    * unlocked_inode_to_wb_end().
>    *
> - * The caller must call unlocked_inode_to_wb_end() with *@lockdep
> - * afterwards and can't sleep during transaction.  IRQ may or may not =
be
> - * disabled on return.
> + * The caller must call unlocked_inode_to_wb_end() with *@cookie after=
wards and
> + * can't sleep during transaction.  IRQ may or may not be disabled on =
return.
>    */
>   static inline struct bdi_writeback *
> -unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
> +unlocked_inode_to_wb_begin(struct inode *inode, struct wb_lock_cookie =
*cookie)
>   {
>   	rcu_read_lock();
>  =20
> @@ -367,10 +366,10 @@ unlocked_inode_to_wb_begin(struct inode *inode, b=
ool *lockedp)
>   	 * Paired with store_release in inode_switch_wb_work_fn() and
>   	 * ensures that we see the new wb if we see cleared I_WB_SWITCH.
>   	 */
> -	*lockedp =3D smp_load_acquire(&inode->i_state) & I_WB_SWITCH;
> +	cookie->locked =3D smp_load_acquire(&inode->i_state) & I_WB_SWITCH;
>  =20
> -	if (unlikely(*lockedp))
> -		spin_lock_irq(&inode->i_mapping->tree_lock);
> +	if (unlikely(cookie->locked))
> +		spin_lock_irqsave(&inode->i_mapping->tree_lock, cookie->flags);
>  =20
>   	/*
>   	 * Protected by either !I_WB_SWITCH + rcu_read_lock() or tree_lock.
> @@ -382,12 +381,14 @@ unlocked_inode_to_wb_begin(struct inode *inode, b=
ool *lockedp)
>   /**
>    * unlocked_inode_to_wb_end - end inode wb access transaction
>    * @inode: target inode
> - * @locked: *@lockedp from unlocked_inode_to_wb_begin()
> + * @cookie: @cookie from unlocked_inode_to_wb_begin()
>    */
> -static inline void unlocked_inode_to_wb_end(struct inode *inode, bool =
locked)
> +static inline void unlocked_inode_to_wb_end(struct inode *inode,
> +					    struct wb_lock_cookie *cookie)
>   {
> -	if (unlikely(locked))
> -		spin_unlock_irq(&inode->i_mapping->tree_lock);
> +	if (unlikely(cookie->locked))
> +		spin_unlock_irqrestore(&inode->i_mapping->tree_lock,
> +				       cookie->flags);
>  =20
>   	rcu_read_unlock();
>   }
> @@ -434,12 +435,13 @@ static inline struct bdi_writeback *inode_to_wb(s=
truct inode *inode)
>   }
>  =20
>   static inline struct bdi_writeback *
> -unlocked_inode_to_wb_begin(struct inode *inode, bool *lockedp)
> +unlocked_inode_to_wb_begin(struct inode *inode, struct wb_lock_cookie =
*cookie)
>   {
>   	return inode_to_wb(inode);
>   }
>  =20
> -static inline void unlocked_inode_to_wb_end(struct inode *inode, bool =
locked)
> +static inline void unlocked_inode_to_wb_end(struct inode *inode,
> +					    struct wb_lock_cookie *cookie)
>   {
>   }
>  =20
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 586f31261c83..bc38a2a7a597 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2501,13 +2501,13 @@ void account_page_redirty(struct page *page)
>   	if (mapping && mapping_cap_account_dirty(mapping)) {
>   		struct inode *inode =3D mapping->host;
>   		struct bdi_writeback *wb;
> -		bool locked;
> +		struct wb_lock_cookie cookie =3D {0};
>  =20
> -		wb =3D unlocked_inode_to_wb_begin(inode, &locked);
> +		wb =3D unlocked_inode_to_wb_begin(inode, &cookie);
>   		current->nr_dirtied--;
>   		dec_node_page_state(page, NR_DIRTIED);
>   		dec_wb_stat(wb, WB_DIRTIED);
> -		unlocked_inode_to_wb_end(inode, locked);
> +		unlocked_inode_to_wb_end(inode, &cookie);
>   	}
>   }
>   EXPORT_SYMBOL(account_page_redirty);
> @@ -2613,15 +2613,15 @@ void __cancel_dirty_page(struct page *page)
>   	if (mapping_cap_account_dirty(mapping)) {
>   		struct inode *inode =3D mapping->host;
>   		struct bdi_writeback *wb;
> -		bool locked;
> +		struct wb_lock_cookie cookie =3D {0};
>  =20
>   		lock_page_memcg(page);
> -		wb =3D unlocked_inode_to_wb_begin(inode, &locked);
> +		wb =3D unlocked_inode_to_wb_begin(inode, &cookie);
>  =20
>   		if (TestClearPageDirty(page))
>   			account_page_cleaned(page, mapping, wb);
>  =20
> -		unlocked_inode_to_wb_end(inode, locked);
> +		unlocked_inode_to_wb_end(inode, &cookie);
>   		unlock_page_memcg(page);
>   	} else {
>   		ClearPageDirty(page);
> @@ -2653,7 +2653,7 @@ int clear_page_dirty_for_io(struct page *page)
>   	if (mapping && mapping_cap_account_dirty(mapping)) {
>   		struct inode *inode =3D mapping->host;
>   		struct bdi_writeback *wb;
> -		bool locked;
> +		struct wb_lock_cookie cookie =3D {0};
>  =20
>   		/*
>   		 * Yes, Virginia, this is indeed insane.
> @@ -2690,14 +2690,14 @@ int clear_page_dirty_for_io(struct page *page)
>   		 * always locked coming in here, so we get the desired
>   		 * exclusion.
>   		 */
> -		wb =3D unlocked_inode_to_wb_begin(inode, &locked);
> +		wb =3D unlocked_inode_to_wb_begin(inode, &cookie);
>   		if (TestClearPageDirty(page)) {
>   			dec_lruvec_page_state(page, NR_FILE_DIRTY);
>   			dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
>   			dec_wb_stat(wb, WB_RECLAIMABLE);
>   			ret =3D 1;
>   		}
> -		unlocked_inode_to_wb_end(inode, locked);
> +		unlocked_inode_to_wb_end(inode, &cookie);
>   		return ret;
>   	}
>   	return TestClearPageDirty(page);
