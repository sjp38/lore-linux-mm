Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB15A6B0003
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 05:19:46 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id f4so1383113plr.14
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 02:19:46 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0105.outbound.protection.outlook.com. [104.47.0.105])
        by mx.google.com with ESMTPS id j63si6696644pgc.591.2018.02.06.02.19.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Feb 2018 02:19:45 -0800 (PST)
Subject: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 06 Feb 2018 13:19:29 +0300
Message-ID: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Recent times kvmalloc() begun widely be used in kernel.
Some of such memory allocations have to be freed after
rcu grace period, and this patchset introduces a generic
primitive for doing this.

Actually, everything is made in [1/2]. Patch [2/2] is just
added to make new kvfree_rcu() have the first user.

The patch [1/2] transforms kfree_rcu(), its sub definitions
and its sub functions into kvfree_rcu() form. The most
significant change is in __rcu_reclaim(), where kvfree()
is used instead of kfree(). Since kvfree() is able to
have a deal with memory allocated via kmalloc(), vmalloc()
and kvmalloc(); kfree_rcu() and vfree_rcu() may simply
be defined through this new kvfree_rcu().

---

Kirill Tkhai (2):
      rcu: Transform kfree_rcu() into kvfree_rcu()
      mm: Use kvfree_rcu() in update_memcg_params()


 include/linux/rcupdate.h   |   31 +++++++++++++++++--------------
 include/linux/rcutiny.h    |    4 ++--
 include/linux/rcutree.h    |    2 +-
 include/trace/events/rcu.h |   12 ++++++------
 kernel/rcu/rcu.h           |    8 ++++----
 kernel/rcu/tree.c          |   14 +++++++-------
 kernel/rcu/tree_plugin.h   |   10 +++++-----
 mm/slab_common.c           |   10 +---------
 8 files changed, 43 insertions(+), 48 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
