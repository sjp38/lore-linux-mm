Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id DE9746B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 01:04:03 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id rp2so1426355pbb.22
        for <linux-mm@kvack.org>; Sun, 12 May 2013 22:04:03 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V2 0/3] memcg: simply lock of page stat accounting
Date: Mon, 13 May 2013 13:03:30 +0800
Message-Id: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hughd@google.com, gthelen@google.com, Sha Zhengju <handai.szj@taobao.com>

Hi,

This is my second attempt to make memcg page stat lock simpler, the
first version: http://www.spinics.net/lists/linux-mm/msg50037.html.

In this version I investigate the potential race conditions among
page stat, move_account, charge, uncharge and try to prove it race
safe of my proposing lock scheme. The first patch is the basis of
the patchset, so if I've made some stupid mistake please do not
hesitate to point it out.

Change log:
v2 <- v1:
   * rewrite comments on race condition
   * split orignal large patch to two parts
   * change too heavy try_get_mem_cgroup_from_page() to rcu_read_lock
     to hold memcg alive

Sha Zhengju (3):
   memcg: rewrite the comment about race condition of page stat accounting
   memcg: alter mem_cgroup_{update,inc,dec}_page_stat() args to memcg pointer
   memcg: simplify lock of memcg page stat account	

 include/linux/memcontrol.h |   14 ++++++-------
 mm/memcontrol.c            |   16 ++++++---------
 mm/rmap.c                  |   49 +++++++++++++++++++++++++++++++++-----------
 3 files changed, 50 insertions(+), 29 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
