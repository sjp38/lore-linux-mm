Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3C56C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 03:30:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FAC120881
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 03:30:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="TwT4I/7f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FAC120881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B06D06B0003; Fri, 21 Jun 2019 23:30:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB7148E0002; Fri, 21 Jun 2019 23:30:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A5A58E0001; Fri, 21 Jun 2019 23:30:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E8726B0003
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 23:30:17 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bb9so4662374plb.2
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:30:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=13aQR0rtJwsTsrE1gvurTxUZ6jXPrhWfGB/kZJhaY0A=;
        b=ZzbMKP9sZf2K+R4iF6wWdI1H/n1d70tB30hKyFHF3MmegY6cywwRABvxJ4yn9jlaX6
         e3qOfX6YVHU04+hJcv9KzHpHFTQKJ1YkEq3r9uJR0GAVJnIJs+bCmKb9CGI/D843U31U
         ADA7T2S7e+/CbMkTXxRgZXxETnUVzBnju/ht2lVJdeOIL511SQuF5sUhS8HgOsx7PB9M
         Asx1Xpgx7mYOYZLSBtU7asKIt7NJKe8mySvXGak1UliifRckCm1+ZTlE9styTzwUetlN
         7eTj1Ii+asc76/ASJ0M1eB9irutLbJd5W6VD0sLOduA9TkB6tZJDwY7eLfr2AAW0Tw6M
         ML/w==
X-Gm-Message-State: APjAAAUWqaoRacfjmHDzx6BHstGcQlrWjt90s0jK82p7Kx/gZmhAac8E
	1JJkaceL9P094j8zDM+3E5sjjm6rfunmCIsubgWwTzCly9kkd4RtXZTSlqBzDLf2iVj8RU2Bt8j
	dK4ILGfu6joVOsRfJox6Qh5T5ArnngYEmrQBLXDI5/DbjMtHoWqUxEqH7qIniyZ/6cQ==
X-Received: by 2002:a17:90a:b883:: with SMTP id o3mr10682264pjr.50.1561174216897;
        Fri, 21 Jun 2019 20:30:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdy64+57A4JKst59pZHVEYaf1/0BxkA9pqWe59FUsoLQC0dTeWrxELyeWCRcvlKDgMrRLy
X-Received: by 2002:a17:90a:b883:: with SMTP id o3mr10682181pjr.50.1561174215956;
        Fri, 21 Jun 2019 20:30:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561174215; cv=none;
        d=google.com; s=arc-20160816;
        b=wosYvuEesWFg2kqpTNhL8OxLGLDu5t2xa4IYilfelyaS/3cL6hAsVpM7t6xrv3SXBv
         mZqKHBDtR1nrjqr3CRFoRiDBKSNG8O/Nf4wGCM3tHwzmMXY8M2v3K8N3mYtRwJzQVfKz
         nOu60ZAC/cA9JwGPzdE+uzEVAKqt21ChgU0ilqzhBtPNaHpxSVIWON3Ve5RGZYJfdmui
         uFaw0kyTcPn9TrZhg/qhj5Bw8QmRoghpQS4RNwJivzgCixKcmUpPvlBfK4e7c8iq58oU
         QtdxDVGJFkRxOUx/z7DOmtpdylvyYjwiU+c3YZBG8gpHEmeDgWKd8JTALxapAkFPO7UJ
         9+Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=13aQR0rtJwsTsrE1gvurTxUZ6jXPrhWfGB/kZJhaY0A=;
        b=CT1q2YuV5C3zB48wipkFjdOuwosYDbvIPzzvXuS7GQmSuCC0iZD+EDl4z4l4RTYHWE
         V4INmmmbc+dqLPg3JKOd1qTt10xCmhVVmVjP8r0EtRgEpD3i2dshYFH4UmVTFS/XTK69
         2dJEepARybQMnCqjUsYe6mkB97v+5aALGQFwfnbY/He0NMmiwOmDlLbpFC5eG6lIDBJE
         2ZeREgyTslGzCTKWuYyEonnQJE62SARw/TKDu26FLL+EIZHOUgkyyq4ad0AD2yj+0zTO
         D4HuEKgPJMyNLvY8Pv0oxH9ZmZO17XJnCHBeucAgQbV8M1DKX+6bRFziGo0Hwoi4vkcB
         30gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="TwT4I/7f";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 64si4287533plw.379.2019.06.21.20.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 20:30:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="TwT4I/7f";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2D68620821;
	Sat, 22 Jun 2019 03:30:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561174215;
	bh=Gg8tL0vZKl4cioDaEJQ08yFQTi4g/SsbASQt55tLIQo=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=TwT4I/7fD2dSwxKJiFJ4MT3hdcC3oFvdGixXvvKBKXctBjHi1ra/jlhQ/QWp6igab
	 wQJyaEQ3hPYxgUncHh6NFkw8EdJUgvqB2KmGbWuv/eoZStACCM20k1mz5DQtAkUqZ1
	 bYZwe9LXibYyOHl7mYbdLuxcKLNA8BCDJXZpBJVc=
Date: Fri, 21 Jun 2019 20:30:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: ktkhai@virtuozzo.com, mhocko@suse.com, hannes@cmpxchg.org,
 vdavydov.dev@gmail.com, mgorman@techsingularity.net, linux-mm@kvack.org
Subject: Re: [PATCH 2/2] mm/vmscan: calculate reclaimed slab caches in all
 reclaim paths
Message-Id: <20190621203014.fff2b968b6f9c2e23ebf4eef@linux-foundation.org>
In-Reply-To: <1561112086-6169-3-git-send-email-laoar.shao@gmail.com>
References: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
	<1561112086-6169-3-git-send-email-laoar.shao@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jun 2019 18:14:46 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:

> There're six different reclaim paths by now,
> - kswapd reclaim path
> - node reclaim path
> - hibernate preallocate memory reclaim path
> - direct reclaim path
> - memcg reclaim path
> - memcg softlimit reclaim path
> 
> The slab caches reclaimed in these paths are only calculated in the above
> three paths.
> 
> There're some drawbacks if we don't calculate the reclaimed slab caches.
> - The sc->nr_reclaimed isn't correct if there're some slab caches
>   relcaimed in this path.
> - The slab caches may be reclaimed thoroughly if there're lots of
>   reclaimable slab caches and few page caches.
>   Let's take an easy example for this case.
>   If one memcg is full of slab caches and the limit of it is 512M, in
>   other words there're approximately 512M slab caches in this memcg.
>   Then the limit of the memcg is reached and the memcg reclaim begins,
>   and then in this memcg reclaim path it will continuesly reclaim the
>   slab caches until the sc->priority drops to 0.
>   After this reclaim stops, you will find there're few slab caches left,
>   which is less than 20M in my test case.
>   While after this patch applied the number is greater than 300M and
>   the sc->priority only drops to 3.

I got a bit exhausted checking that none of these six callsites can
scribble on some caller's value of current->reclaim_state.

How about we do it at runtime?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/vmscan.c: add checks for incorrect handling of current->reclaim_state

Six sites are presently altering current->reclaim_state.  There is a risk
that one function stomps on a caller's value.  Use a helper function to
catch such errors.

Cc: Yafang Shao <laoar.shao@gmail.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |   37 ++++++++++++++++++++++++-------------
 1 file changed, 24 insertions(+), 13 deletions(-)

--- a/mm/vmscan.c~mm-vmscanc-add-checks-for-incorrect-handling-of-current-reclaim_state
+++ a/mm/vmscan.c
@@ -177,6 +177,18 @@ unsigned long vm_total_pages;
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
+static void set_task_reclaim_state(struct task_struct *task,
+				   struct reclaim_state *rs)
+{
+	/* Check for an overwrite */
+	WARN_ON_ONCE(rs && task->reclaim_state);
+
+	/* Check for the nulling of an already-nulled member */
+	WARN_ON_ONCE(!rs && !task->reclaim_state);
+
+	task->reclaim_state = rs;
+}
+
 #ifdef CONFIG_MEMCG_KMEM
 
 /*
@@ -3194,13 +3206,13 @@ unsigned long try_to_free_pages(struct z
 	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
 		return 1;
 
-	current->reclaim_state = &sc.reclaim_state;
+	set_task_reclaim_state(current, &sc.reclaim_state);
 	trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
 	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
-	current->reclaim_state = NULL;
+	set_task_reclaim_state(current, NULL);
 
 	return nr_reclaimed;
 }
@@ -3223,7 +3235,7 @@ unsigned long mem_cgroup_shrink_node(str
 	};
 	unsigned long lru_pages;
 
-	current->reclaim_state = &sc.reclaim_state;
+	set_task_reclaim_state(current, &sc.reclaim_state);
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
@@ -3245,7 +3257,7 @@ unsigned long mem_cgroup_shrink_node(str
 					cgroup_ino(memcg->css.cgroup),
 					sc.nr_reclaimed);
 
-	current->reclaim_state = NULL;
+	set_task_reclaim_state(current, NULL);
 	*nr_scanned = sc.nr_scanned;
 
 	return sc.nr_reclaimed;
@@ -3274,7 +3286,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.may_shrinkslab = 1,
 	};
 
-	current->reclaim_state = &sc.reclaim_state;
+	set_task_reclaim_state(current, &sc.reclaim_state);
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
 	 * take care zof from where we get pages. So the node where we start the
@@ -3299,7 +3311,7 @@ unsigned long try_to_free_mem_cgroup_pag
 	trace_mm_vmscan_memcg_reclaim_end(
 				cgroup_ino(memcg->css.cgroup),
 				nr_reclaimed);
-	current->reclaim_state = NULL;
+	set_task_reclaim_state(current, NULL);
 
 	return nr_reclaimed;
 }
@@ -3501,7 +3513,7 @@ static int balance_pgdat(pg_data_t *pgda
 		.may_unmap = 1,
 	};
 
-	current->reclaim_state = &sc.reclaim_state;
+	set_task_reclaim_state(current, &sc.reclaim_state);
 	psi_memstall_enter(&pflags);
 	__fs_reclaim_acquire();
 
@@ -3683,7 +3695,7 @@ out:
 	snapshot_refaults(NULL, pgdat);
 	__fs_reclaim_release();
 	psi_memstall_leave(&pflags);
-	current->reclaim_state = NULL;
+	set_task_reclaim_state(current, NULL);
 
 	/*
 	 * Return the order kswapd stopped reclaiming at as
@@ -3945,17 +3957,16 @@ unsigned long shrink_all_memory(unsigned
 		.hibernation_mode = 1,
 	};
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
-	struct task_struct *p = current;
 	unsigned long nr_reclaimed;
 	unsigned int noreclaim_flag;
 
 	fs_reclaim_acquire(sc.gfp_mask);
 	noreclaim_flag = memalloc_noreclaim_save();
-	p->reclaim_state = &sc.reclaim_state;
+	set_task_reclaim_state(current, &sc.reclaim_state);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
-	p->reclaim_state = NULL;
+	set_task_reclaim_state(current, NULL);
 	memalloc_noreclaim_restore(noreclaim_flag);
 	fs_reclaim_release(sc.gfp_mask);
 
@@ -4144,7 +4155,7 @@ static int __node_reclaim(struct pglist_
 	 */
 	noreclaim_flag = memalloc_noreclaim_save();
 	p->flags |= PF_SWAPWRITE;
-	p->reclaim_state = &sc.reclaim_state;
+	set_task_reclaim_state(p, &sc.reclaim_state);
 
 	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
 		/*
@@ -4156,7 +4167,7 @@ static int __node_reclaim(struct pglist_
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
-	p->reclaim_state = NULL;
+	set_task_reclaim_state(p, NULL);
 	current->flags &= ~PF_SWAPWRITE;
 	memalloc_noreclaim_restore(noreclaim_flag);
 	fs_reclaim_release(sc.gfp_mask);
_

