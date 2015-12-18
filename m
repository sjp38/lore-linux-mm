Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A60EA6B0003
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 17:40:08 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id jx14so38065426pad.2
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 14:40:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m70si15838135pfi.74.2015.12.18.14.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Dec 2015 14:40:07 -0800 (PST)
Date: Fri, 18 Dec 2015 14:40:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: memcontrol: fix possible memcg leak due to
 interrupted reclaim
Message-Id: <20151218144004.6ec6189817b64e04d9405001@linux-foundation.org>
In-Reply-To: <20151218162405.GU28521@esperanza>
References: <1450182697-11049-1-git-send-email-vdavydov@virtuozzo.com>
	<20151217150217.a02c264ce9b5335b02bae888@linux-foundation.org>
	<20151218153202.GS28521@esperanza>
	<20151218160041.GA4201@cmpxchg.org>
	<20151218162405.GU28521@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, stable@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 18 Dec 2015 19:24:05 +0300 Vladimir Davydov <vdavydov@virtuozzo.com> wrote:

> 
> OK, got it, thanks. Here goes the incremental patch (it should also fix
> the warning regarding unused cmpxchg returned value):
> ---
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fc25dc211eaf..908c075e04eb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -864,7 +864,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>  			 * might block it. So we clear iter->position right
>  			 * away.
>  			 */
> -			cmpxchg(&iter->position, pos, NULL);
> +			(void)cmpxchg(&iter->position, pos, NULL);

No, this doesn't actually squish the __must_check warning.


Can anyone think of anything smarter than this?

--- a/mm/memcontrol.c~mm-memcontrol-fix-possible-memcg-leak-due-to-interrupted-reclaim-fix-fix
+++ a/mm/memcontrol.c
@@ -851,6 +851,9 @@ static struct mem_cgroup *get_mem_cgroup
 	return memcg;
 }
 
+/* Move this to compiler.h if it proves worthy */
+#define defeat_must_check(expr) do { if (expr) ; } while (0)
+
 /**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
@@ -915,7 +918,7 @@ struct mem_cgroup *mem_cgroup_iter(struc
 			 * might block it. So we clear iter->position right
 			 * away.
 			 */
-			(void)cmpxchg(&iter->position, pos, NULL);
+			defeat_must_check(cmpxchg(&iter->position, pos, NULL));
 		}
 	}
 
@@ -967,7 +970,7 @@ struct mem_cgroup *mem_cgroup_iter(struc
 		 * thread, so check that the value hasn't changed since we read
 		 * it to avoid reclaiming from the same cgroup twice.
 		 */
-		(void)cmpxchg(&iter->position, pos, memcg);
+		defeat_must_check(cmpxchg(&iter->position, pos, memcg));
 
 		/*
 		 * pairs with css_tryget when dereferencing iter->position
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
