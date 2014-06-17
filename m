Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B09FD6B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 04:51:41 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so4878791pab.4
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 01:51:41 -0700 (PDT)
Received: from fgwmail2.fujitsu.co.jp (fgwmail2.fujitsu.co.jp. [164.71.1.135])
        by mx.google.com with ESMTPS id ag8si16518263pad.190.2014.06.17.01.51.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 01:51:40 -0700 (PDT)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail2.fujitsu.co.jp (Postfix) with ESMTP id 5CFE03EE0C8
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 17:51:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 6DD19AC0291
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 17:51:38 +0900 (JST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 12B611DB8038
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 17:51:38 +0900 (JST)
Message-ID: <53A0013A.1010100@jp.fujitsu.com>
Date: Tue, 17 Jun 2014 17:50:02 +0900
From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: xfs: two deadlock problems occur when kswapd writebacks XFS pages.
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org

I found two deadlock problems occur when kswapd writebacks XFS pages.
I detected these problems on RHEL kernel actually, and I suppose these
also happen on upstream kernel (3.16-rc1).

1.

A process (processA) has acquired read semaphore "xfs_cil.xc_ctx_lock"
at xfs_log_commit_cil() and it is waiting for the kswapd. Then, a
kworker has issued xlog_cil_push_work() and it is waiting for acquiring
the write semaphore. kswapd is waiting for acquiring the read semaphore
at xfs_log_commit_cil() because the kworker has been waiting before for
acquiring the write semaphore at xlog_cil_push(). Therefore, a deadlock
happens.

The deadlock flow is as follows.

  processA              | kworker                  | kswapd              
  ----------------------+--------------------------+----------------------
| xfs_trans_commit      |                          |
| xfs_log_commit_cil    |                          |
| down_read(xc_ctx_lock)|                          |
| xlog_cil_insert_items |                          |
| xlog_cil_insert_format_items                     |
| kmem_alloc            |                          |
| :                     |                          |
| shrink_inactive_list  |                          |
| congestion_wait       |                          |
| # waiting for kswapd..|                          |
|                       | xlog_cil_push_work       |
|                       | xlog_cil_push            |
|                       | xfs_trans_commit         |
|                       | down_write(xc_ctx_lock)  |
|                       | # waiting for processA...|
|                       |                          | shrink_page_list
|                       |                          | xfs_vm_writepage
|                       |                          | xfs_map_blocks
|                       |                          | xfs_iomap_write_allocate
|                       |                          | xfs_trans_commit
|                       |                          | xfs_log_commit_cil
|                       |                          | down_read(xc_ctx_lock)
V(time)                 |                          | # waiting for kworker...
  ----------------------+--------------------------+-----------------------

To fix this, should we up the read semaphore before calling kmem_alloc()
at xlog_cil_insert_format_items() to avoid blocking the kworker? Or,
should we the second argument of kmem_alloc() from KM_SLEEP|KM_NOFS
to KM_NOSLEEP to avoid waiting for the kswapd. Or...

2. 

A kworker (kworkerA), whish is a writeback thread, is waiting for
the XFS allocation thread (kworkerB) while it writebacks XFS pages.
kworkerB has started the allocation and it is waiting for kswapd to
allocate free pages. kswapd has started writeback XFS pages and
it is waiting for more log space. The reason why exhaustion of the
log space is both the writeback thread and kswapd are stuck, so
some processes, who have allocated the log space and are requesting
free pages, are also stuck.

The deadlock flow is as follows.

  kworkerA              | kworkerB                 | kswapd            
  ----------------------+--------------------------+-----------------------
| wb_writeback          |                          |
| :                     |                          |
| xfs_vm_writepage      |                          |
| xfs_map_blocks        |                          |
| xfs_iomap_write_allocate                         |
| xfs_bmapi_write       |                          |
| xfs_bmapi_allocate    |                          |
| wait_for_completion   |                          |
| # waiting for kworkerB...                        |
|                       | xfs_bmapi_allocate_worker|
|                       | :                        |
|                       | xfs_buf_get_map          |
|                       | xfs_buf_allocate_memory  |
|                       | alloc_pages_current      |
|                       | :                        |
|                       | shrink_inactive_list     |
|                       | congestion_wait          |
|                       | # waiting for kswapd...  |
|                       |                          | shrink_page_list
|                       |                          | xfs_vm_writepage
|                       |                          | :
|                       |                          | xfs_log_reserve
|                       |                          | :
|                       |                          | xlog_grant_head_check
|                       |                          | xlog_grant_head_wait
|                       |                          | # waiting for more
|                       |                          | # space...
V(time)                 |                          |
  ----------------------+--------------------------+-----------------------

I don't have any ideas to fix this...

Thanks,
Masayoshi Mizuma

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
