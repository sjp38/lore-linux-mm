Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 925B96B002C
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:38:02 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f4-v6so10259720plm.12
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:38:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d92-v6si3348503pld.195.2018.04.10.13.38.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 13:38:01 -0700 (PDT)
Date: Tue, 10 Apr 2018 13:37:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] writeback: safer lock nesting
Message-Id: <20180410133759.8ffd3170e5aaa7eb7eddcba6@linux-foundation.org>
In-Reply-To: <20180410005908.167976-1-gthelen@google.com>
References: <201804080259.VS5U0mKT%fengguang.wu@intel.com>
	<20180410005908.167976-1-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Wang Long <wanglong19@meituan.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, npiggin@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon,  9 Apr 2018 17:59:08 -0700 Greg Thelen <gthelen@google.com> wrote:

> lock_page_memcg()/unlock_page_memcg() use spin_lock_irqsave/restore() if
> the page's memcg is undergoing move accounting, which occurs when a
> process leaves its memcg for a new one that has
> memory.move_charge_at_immigrate set.
> 
> unlocked_inode_to_wb_begin,end() use spin_lock_irq/spin_unlock_irq() if the
> given inode is switching writeback domains.  Switches occur when enough
> writes are issued from a new domain.
> 
> This existing pattern is thus suspicious:
>     lock_page_memcg(page);
>     unlocked_inode_to_wb_begin(inode, &locked);
>     ...
>     unlocked_inode_to_wb_end(inode, locked);
>     unlock_page_memcg(page);
> 
> If both inode switch and process memcg migration are both in-flight then
> unlocked_inode_to_wb_end() will unconditionally enable interrupts while
> still holding the lock_page_memcg() irq spinlock.  This suggests the
> possibility of deadlock if an interrupt occurs before
> unlock_page_memcg().
> 
>     truncate
>     __cancel_dirty_page
>     lock_page_memcg
>     unlocked_inode_to_wb_begin
>     unlocked_inode_to_wb_end
>     <interrupts mistakenly enabled>
>                                     <interrupt>
>                                     end_page_writeback
>                                     test_clear_page_writeback
>                                     lock_page_memcg
>                                     <deadlock>
>     unlock_page_memcg
> 
> Due to configuration limitations this deadlock is not currently possible
> because we don't mix cgroup writeback (a cgroupv2 feature) and
> memory.move_charge_at_immigrate (a cgroupv1 feature).
> 
> If the kernel is hacked to always claim inode switching and memcg
> moving_account, then this script triggers lockup in less than a minute:
>   cd /mnt/cgroup/memory
>   mkdir a b
>   echo 1 > a/memory.move_charge_at_immigrate
>   echo 1 > b/memory.move_charge_at_immigrate
>   (
>     echo $BASHPID > a/cgroup.procs
>     while true; do
>       dd if=/dev/zero of=/mnt/big bs=1M count=256
>     done
>   ) &
>   while true; do
>     sync
>   done &
>   sleep 1h &
>   SLEEP=$!
>   while true; do
>     echo $SLEEP > a/cgroup.procs
>     echo $SLEEP > b/cgroup.procs
>   done
> 
> Given the deadlock is not currently possible, it's debatable if there's
> any reason to modify the kernel.  I suggest we should to prevent future
> surprises.
> 
> ...
>
> Changelog since v2:
> - explicitly initialize wb_lock_cookie to silence compiler warnings.

But only in some places.  What's up with that?

>
> ...
>
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -346,7 +346,7 @@ static inline struct bdi_writeback *inode_to_wb(const struct inode *inode)
>  /**
>   * unlocked_inode_to_wb_begin - begin unlocked inode wb access transaction
>   * @inode: target inode
> - * @lockedp: temp bool output param, to be passed to the end function
> + * @cookie: output param, to be passed to the end function
>   *
>   * The caller wants to access the wb associated with @inode but isn't
>   * holding inode->i_lock, mapping->tree_lock or wb->list_lock.  This
> @@ -354,12 +354,11 @@ static inline struct bdi_writeback *inode_to_wb(const struct inode *inode)
>   * association doesn't change until the transaction is finished with
>   * unlocked_inode_to_wb_end().
>   *
> - * The caller must call unlocked_inode_to_wb_end() with *@lockdep
> - * afterwards and can't sleep during transaction.  IRQ may or may not be
> - * disabled on return.
> + * The caller must call unlocked_inode_to_wb_end() with *@cookie afterwards and
> + * can't sleep during transaction.  IRQ may or may not be disabled on return.
>   */

Grammar is a bit awkward here,

>
> ...
>
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2501,13 +2501,13 @@ void account_page_redirty(struct page *page)
>  	if (mapping && mapping_cap_account_dirty(mapping)) {
>  		struct inode *inode = mapping->host;
>  		struct bdi_writeback *wb;
> -		bool locked;
> +		struct wb_lock_cookie cookie = {0};

Trivia: it's better to use "= {}" here.  That has the same effect and
it doesn't assume that the first field is a scalar.  And indeed, the
first field is a bool so it should be {false}!


So...


--- a/include/linux/backing-dev.h~writeback-safer-lock-nesting-fix
+++ a/include/linux/backing-dev.h
@@ -355,7 +355,8 @@ static inline struct bdi_writeback *inod
  * unlocked_inode_to_wb_end().
  *
  * The caller must call unlocked_inode_to_wb_end() with *@cookie afterwards and
- * can't sleep during transaction.  IRQ may or may not be disabled on return.
+ * can't sleep during the transaction.  IRQs may or may not be disabled on
+ * return.
  */
 static inline struct bdi_writeback *
 unlocked_inode_to_wb_begin(struct inode *inode, struct wb_lock_cookie *cookie)
--- a/mm/page-writeback.c~writeback-safer-lock-nesting-fix
+++ a/mm/page-writeback.c
@@ -2501,7 +2501,7 @@ void account_page_redirty(struct page *p
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
-		struct wb_lock_cookie cookie = {0};
+		struct wb_lock_cookie cookie = {};
 
 		wb = unlocked_inode_to_wb_begin(inode, &cookie);
 		current->nr_dirtied--;
@@ -2613,7 +2613,7 @@ void __cancel_dirty_page(struct page *pa
 	if (mapping_cap_account_dirty(mapping)) {
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
-		struct wb_lock_cookie cookie = {0};
+		struct wb_lock_cookie cookie = {};
 
 		lock_page_memcg(page);
 		wb = unlocked_inode_to_wb_begin(inode, &cookie);
@@ -2653,7 +2653,7 @@ int clear_page_dirty_for_io(struct page
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
-		struct wb_lock_cookie cookie = {0};
+		struct wb_lock_cookie cookie = {};
 
 		/*
 		 * Yes, Virginia, this is indeed insane.

But I wonder about the remaining uninitialized wb_lock_cookies?
