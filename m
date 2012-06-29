Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 88BD16B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 04:26:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6129A3EE0C3
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:25:59 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 47D7A45DE7E
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:25:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C89545DEAD
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:25:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 065C51DB8041
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:25:59 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AFFEE1DB803E
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:25:58 +0900 (JST)
Message-ID: <4FED6604.9080603@jp.fujitsu.com>
Date: Fri, 29 Jun 2012 17:23:32 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] Per-cgroup page stat accounting
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

(2012/06/28 19:54), Sha Zhengju wrote:
> This patch series provide the ability for each memory cgroup to have independent
> dirty/writeback page stats. This can provide some information for per-cgroup direct
> reclaim. Meanwhile, we add more detailed dump messages for memcg OOMs.
> 
> Three features are included in this patch series:
>   (0).prepare patches for page accounting
>    1. memcg dirty page accounting
>    2. memcg writeback page accounting
>    3. memcg OOMs dump info
> 
> In (0) prepare patches, we have reworked vfs set page dirty routines to make "modify
> page info" and "dirty page accouting" stay in one function as much as possible for
> the sake of memcg bigger lock.
> 
> These patches are cooked based on Andrew's akpm tree.
> 

Thank you !, it seems good in general. I'll review in detail, later.

Do you have any performance comparison between before/after the series ?
I mean, set_page_dirty() is the hot-path and we should be careful to add a new accounting.

Thanks,
-Kame



> Sha Zhengju (7):
> 	memcg-update-cgroup-memory-document.patch
> 	memcg-remove-MEMCG_NR_FILE_MAPPED.patch
> 	Make-TestSetPageDirty-and-dirty-page-accounting-in-o.patch
> 	Use-vfs-__set_page_dirty-interface-instead-of-doing-.patch
> 	memcg-add-per-cgroup-dirty-pages-accounting.patch
> 	memcg-add-per-cgroup-writeback-pages-accounting.patch
> 	memcg-print-more-detailed-info-while-memcg-oom-happe.patch	
> 
>   Documentation/cgroups/memory.txt |    2 +
>   fs/buffer.c                      |   36 +++++++++-----
>   fs/ceph/addr.c                   |   20 +-------
>   include/linux/buffer_head.h      |    2 +
>   include/linux/memcontrol.h       |   27 +++++++---
>   mm/filemap.c                     |    5 ++
>   mm/memcontrol.c                  |   99 +++++++++++++++++++++++--------------
>   mm/page-writeback.c              |   42 ++++++++++++++--
>   mm/rmap.c                        |    4 +-
>   mm/truncate.c                    |    6 ++
>   10 files changed, 159 insertions(+), 84 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
