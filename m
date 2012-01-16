Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 48D296B0085
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 07:55:07 -0500 (EST)
Date: Mon, 16 Jan 2012 14:55:26 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC] [PATCH 3/7 v2] memcg: remove PCG_MOVE_LOCK flag from
 pc->flags
Message-ID: <20120116125526.GB25981@shutemov.name>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120113174019.8dff3fc1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri, Jan 13, 2012 at 05:40:19PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> From 1008e84d94245b1e7c4d237802ff68ff00757736 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 12 Jan 2012 15:53:24 +0900
> Subject: [PATCH 3/7] memcg: remove PCG_MOVE_LOCK flag from pc->flags.
> 
> PCG_MOVE_LOCK bit is used for bit spinlock for avoiding race between
> memcg's account moving and page state statistics updates.
> 
> Considering page-statistics update, very hot path, this lock is
> taken only when someone is moving account (or PageTransHuge())
> And, now, all moving-account between memcgroups (by task-move)
> are serialized.
> 
> So, it seems too costly to have 1bit per page for this purpose.
> 
> This patch removes PCG_MOVE_LOCK and add hashed rwlock array
> instead of it. This works well enough. Even when we need to
> take the lock, we don't need to disable IRQ in hot path because
> of using rwlock.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

...

> +#define NR_MOVE_ACCOUNT_LOCKS	(NR_CPUS)
> +#define move_account_hash(page) ((page_to_pfn(page) % NR_MOVE_ACCOUNT_LOCKS))

You still tend to add too many parentheses into macros ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
