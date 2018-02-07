Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2428A6B02B4
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 21:17:01 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id h138so3234555qke.8
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 18:17:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y68si402821qkb.292.2018.02.06.18.16.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 18:17:00 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w172GHSw067239
	for <linux-mm@kvack.org>; Tue, 6 Feb 2018 21:16:59 -0500
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fyqhgj3wu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Feb 2018 21:16:58 -0500
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 6 Feb 2018 21:16:57 -0500
Date: Tue, 6 Feb 2018 18:17:03 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] rcu: Transform kfree_rcu() into kvfree_rcu()
Reply-To: paulmck@linux.vnet.ibm.com
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
Message-Id: <20180207021703.GC3617@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com, rao.shoaib@oracle.com

On Tue, Feb 06, 2018 at 01:19:29PM +0300, Kirill Tkhai wrote:
> Recent times kvmalloc() begun widely be used in kernel.
> Some of such memory allocations have to be freed after
> rcu grace period, and this patchset introduces a generic
> primitive for doing this.
> 
> Actually, everything is made in [1/2]. Patch [2/2] is just
> added to make new kvfree_rcu() have the first user.
> 
> The patch [1/2] transforms kfree_rcu(), its sub definitions
> and its sub functions into kvfree_rcu() form. The most
> significant change is in __rcu_reclaim(), where kvfree()
> is used instead of kfree(). Since kvfree() is able to
> have a deal with memory allocated via kmalloc(), vmalloc()
> and kvmalloc(); kfree_rcu() and vfree_rcu() may simply
> be defined through this new kvfree_rcu().

Interesting.

So it is OK to kvmalloc() something and pass it to either kfree() or
kvfree(), and it had better be OK to kvmalloc() something and pass it
to kvfree().

Is it OK to kmalloc() something and pass it to kvfree()?

If so, is it really useful to have two different names here, that is,
both kfree_rcu() and kvfree_rcu()?

Also adding Jesper and Rao on CC for their awareness.

							Thanx, Paul

> ---
> 
> Kirill Tkhai (2):
>       rcu: Transform kfree_rcu() into kvfree_rcu()
>       mm: Use kvfree_rcu() in update_memcg_params()
> 
> 
>  include/linux/rcupdate.h   |   31 +++++++++++++++++--------------
>  include/linux/rcutiny.h    |    4 ++--
>  include/linux/rcutree.h    |    2 +-
>  include/trace/events/rcu.h |   12 ++++++------
>  kernel/rcu/rcu.h           |    8 ++++----
>  kernel/rcu/tree.c          |   14 +++++++-------
>  kernel/rcu/tree_plugin.h   |   10 +++++-----
>  mm/slab_common.c           |   10 +---------
>  8 files changed, 43 insertions(+), 48 deletions(-)
> 
> --
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
