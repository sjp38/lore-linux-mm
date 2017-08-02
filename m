Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF7EC6B060D
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 14:05:23 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v11so4704123oif.2
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 11:05:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o83si11857055oia.61.2017.08.02.11.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 11:05:22 -0700 (PDT)
Message-ID: <1501697116.109555.9.camel@redhat.com>
Subject: Re: [PATCH] mm: ratelimit PFNs busy info message
From: Doug Ledford <dledford@redhat.com>
In-Reply-To: <499c0f6cc10d6eb829a67f2a4d75b4228a9b356e.1501695897.git.jtoppins@redhat.com>
References: 
	<499c0f6cc10d6eb829a67f2a4d75b4228a9b356e.1501695897.git.jtoppins@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 02 Aug 2017 14:05:16 -0400
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Toppins <jtoppins@redhat.com>, linux-mm@kvack.org
Cc: linux-rdma@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, open list <linux-kernel@vger.kernel.org>

On Wed, 2017-08-02 at 13:44 -0400, Jonathan Toppins wrote:
> The RDMA subsystem can generate several thousand of these messages
> per
> second eventually leading to a kernel crash. Ratelimit these messages
> to prevent this crash.
> 
> Signed-off-by: Jonathan Toppins <jtoppins@redhat.com>
> Reviewed-by: Doug Ledford <dledford@redhat.com>
> Tested-by: Doug Ledford <dledford@redhat.com>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d30e914afb6..07b7d3060b21 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7666,7 +7666,7 @@ int alloc_contig_range(unsigned long start,
> unsigned long end,
>  
>  	/* Make sure the range is really isolated. */
>  	if (test_pages_isolated(outer_start, end, false)) {
> -		pr_info("%s: [%lx, %lx) PFNs busy\n",
> +		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
>  			__func__, outer_start, end);
>  		ret = -EBUSY;
>  		goto done;


FWIW, I've been carrying a version of this for several kernel versions.
 I don't remember when they started, but we have one (and only one)
class of machines: Dell PE R730xd, that generate these errors.  When it
happens, without a rate limit, we get rcu timeouts and kernel oopses. 
With the rate limit, we just get a lot of annoying kernel messages but
the machine continues on, recovers, and eventually the memory
operations all succeed.

-- 
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
