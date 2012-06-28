Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id DDBD56B0068
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 06:55:15 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3323460dak.14
        for <linux-mm@kvack.org>; Thu, 28 Jun 2012 03:55:15 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 0/7] Per-cgroup page stat accounting
Date: Thu, 28 Jun 2012 18:54:45 +0800
Message-Id: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

This patch series provide the ability for each memory cgroup to have independent
dirty/writeback page stats. This can provide some information for per-cgroup direct
reclaim. Meanwhile, we add more detailed dump messages for memcg OOMs.

Three features are included in this patch series:
 (0).prepare patches for page accounting
  1. memcg dirty page accounting
  2. memcg writeback page accounting
  3. memcg OOMs dump info

In (0) prepare patches, we have reworked vfs set page dirty routines to make "modify
page info" and "dirty page accouting" stay in one function as much as possible for
the sake of memcg bigger lock.

These patches are cooked based on Andrew's akpm tree.

Sha Zhengju (7):
	memcg-update-cgroup-memory-document.patch
	memcg-remove-MEMCG_NR_FILE_MAPPED.patch
	Make-TestSetPageDirty-and-dirty-page-accounting-in-o.patch
	Use-vfs-__set_page_dirty-interface-instead-of-doing-.patch
	memcg-add-per-cgroup-dirty-pages-accounting.patch
	memcg-add-per-cgroup-writeback-pages-accounting.patch
	memcg-print-more-detailed-info-while-memcg-oom-happe.patch	

 Documentation/cgroups/memory.txt |    2 +
 fs/buffer.c                      |   36 +++++++++-----
 fs/ceph/addr.c                   |   20 +-------
 include/linux/buffer_head.h      |    2 +
 include/linux/memcontrol.h       |   27 +++++++---
 mm/filemap.c                     |    5 ++
 mm/memcontrol.c                  |   99 +++++++++++++++++++++++--------------
 mm/page-writeback.c              |   42 ++++++++++++++--
 mm/rmap.c                        |    4 +-
 mm/truncate.c                    |    6 ++
 10 files changed, 159 insertions(+), 84 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
