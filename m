Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 41D6A6B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 06:07:25 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id ma3so4818528pbc.25
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:07:24 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 0/6] memcg: bypass root memcg page stat accounting
Date: Tue, 12 Mar 2013 18:06:13 +0800
Message-Id: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@parallels.com, akpm@linux-foundation.org, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

Hi,

As we all know, if memcg is enabled but without any non-root memcgs,
all allocated pages belong to root memcg and go through root memcg
statistic routines which brings some overheads.

In this pathset we try to give up accounting stats of root memcg
including CACHE/RSS/SWAP/FILE_MAPPED/PGFAULT/PGMAJFAULT(First attempt
can be found here: https://lkml.org/lkml/2012/12/25/103). But we need
to pay special attention while showing these root memcg numbers in
memcg_stat_show(): as we don't account root memcg stats
anymore, the root_mem_cgroup->stat numbers are actually 0. But we can
fake these figures by using stats of global state and all other memcgs.
Take CACHE stats for example, that is for root memcg:

	nr(MEM_CGROUP_STAT_CACHE) = global_page_state(NR_FILE_PAGES) -
                              sum_of_all_memcg(MEM_CGROUP_STAT_CACHE);

On a 4g memory and 4-core i5 CPU machine, we run Mel's pft test for
performance numbers:

nomemcg  : memcg compile disabled.
vanilla  : memcg enabled, patch not applied.
optimized: memcg enabled, with patch applied.

             optimized    vanilla 
User          405.15      431.27 
System         71.71       73.00 
Elapsed       483.23      510.00 

             optimized    nomemcg 
User          405.15      390.68 
System         71.71       67.21 
Elapsed       483.23      466.15 

Note that elapsed time reduce considerably from 510 to 483 after pathes
have been applied(about ~5%). But there is still some gap between the
patched and memcg-disabled kernel, and we can also do some further works
here(the left-over stats like PGPGIN/PGPGOUT).

I split the patchset to several parts mainly based on their accounting
entry function for the convenience of review:

Sha Zhengju (6):
	memcg: use global stat directly for root memcg usage
	memcg: Don't account root memcg CACHE/RSS stats
	memcg: Don't account root memcg MEM_CGROUP_STAT_FILE_MAPPED stats
	memcg: Don't account root memcg swap stats
	memcg: Don't account root memcg PGFAULT/PGMAJFAULT
	memcg: disable memcg page stat accounting

 include/linux/memcontrol.h |   23 +++++++
 mm/memcontrol.c            |  149 +++++++++++++++++++++++++++++++++++++-------
 2 files changed, 149 insertions(+), 23 deletions(-) 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
