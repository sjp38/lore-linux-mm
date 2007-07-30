Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6UDhgXQ4898910
	for <linux-mm@kvack.org>; Mon, 30 Jul 2007 23:43:42 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6UDj8UG185160
	for <linux-mm@kvack.org>; Mon, 30 Jul 2007 23:45:08 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6UDfYUG010820
	for <linux-mm@kvack.org>; Mon, 30 Jul 2007 23:41:35 +1000
Date: Mon, 30 Jul 2007 19:07:58 +0530
From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: [-mm PATCH 6/9] Memory controller add per container LRU and
	reclaim (v4)
Message-ID: <20070730133758.GB22952@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
References: <20070727200937.31565.78623.sendpatchset@balbir-laptop> <20070727201041.31565.14803.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070727201041.31565.14803.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>, Gautham Shenoy <ego@in.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Balbir,

> diff -puN mm/memcontrol.c~mem-control-lru-and-reclaim mm/memcontrol.c
> --- linux-2.6.23-rc1-mm1/mm/memcontrol.c~mem-control-lru-and-reclaim	2007-07-28 01:12:50.000000000 +0530
> +++ linux-2.6.23-rc1-mm1-balbir/mm/memcontrol.c	2007-07-28 01:12:50.000000000 +0530
 
>  /*
>   * The memory controller data structure. The memory controller controls both
> @@ -51,6 +54,10 @@ struct mem_container {
>  	 */
>  	struct list_head active_list;
>  	struct list_head inactive_list;
> +	/*
> +	 * spin_lock to protect the per container LRU
> +	 */
> +	spinlock_t lru_lock;
>  };

The spinlock is not annotated by lockdep. The following patch should do
it.

Signed-off-by: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Signed-off-by: Gautham Shenoy R <ego@in.ibm.com>


Index: linux-2.6.23-rc1/mm/memcontrol.c
===================================================================
--- linux-2.6.23-rc1.orig/mm/memcontrol.c	2007-07-30 17:27:24.000000000 +0530
+++ linux-2.6.23-rc1/mm/memcontrol.c	2007-07-30 18:43:40.000000000 +0530
@@ -501,6 +501,9 @@
 
 static struct mem_container init_mem_container;
 
+/* lockdep should know about lru_lock */
+static struct lock_class_key lru_lock_key;
+
 static struct container_subsys_state *
 mem_container_create(struct container_subsys *ss, struct container *cont)
 {
@@ -519,6 +522,7 @@
 	INIT_LIST_HEAD(&mem->active_list);
 	INIT_LIST_HEAD(&mem->inactive_list);
 	spin_lock_init(&mem->lru_lock);
+	lockdep_set_class(&mem->lru_lock, &lru_lock_key);
 	mem->control_type = MEM_CONTAINER_TYPE_ALL;
 	return &mem->css;
 }
-- 
regards,
Dhaval

I would like to change the world but they don't give me the source code!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
