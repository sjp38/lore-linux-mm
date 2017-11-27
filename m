Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB70D6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:46:58 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j6so15645624wre.16
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 21:46:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g9si6559487edi.99.2017.11.26.21.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Nov 2017 21:46:57 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAR5i1KV116266
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:46:56 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2egawdcjmr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:46:55 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 27 Nov 2017 05:46:54 -0000
Subject: Re: [PATCH] mm: Do not stall register_shrinker
References: <1511481899-20335-1-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 27 Nov 2017 11:16:46 +0530
MIME-Version: 1.0
In-Reply-To: <1511481899-20335-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <cb35065d-b100-533b-04c1-1188a75220a2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On 11/24/2017 05:34 AM, Minchan Kim wrote:
> Shakeel Butt reported, he have observed in production system that
> the job loader gets stuck for 10s of seconds while doing mount
> operation. It turns out that it was stuck in register_shrinker()
> and some unrelated job was under memory pressure and spending time
> in shrink_slab(). Machines have a lot of shrinkers registered and
> jobs under memory pressure has to traverse all of those memcg-aware
> shrinkers and do affect unrelated jobs which want to register their
> own shrinkers.
> 
> To solve the issue, this patch simply bails out slab shrinking
> once it found someone want to register shrinker in parallel.
> A downside is it could cause unfair shrinking between shrinkers.
> However, it should be rare and we can add compilcated logic once
> we found it's not enough.
> 
> Link: http://lkml.kernel.org/r/20171115005602.GB23810@bbox
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Reported-and-tested-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/vmscan.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6a5a72baccd5..6698001787bd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -486,6 +486,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  			sc.nid = 0;
>  
>  		freed += do_shrink_slab(&sc, shrinker, priority);
> +		/*
> +		 * bail out if someone want to register a new shrinker to
> +		 * prevent long time stall by parallel ongoing shrinking.
> +		 */
> +		if (rwsem_is_contended(&shrinker_rwsem)) {
> +			freed = freed ? : 1;
> +			break;
> +		}

This is similar to when it aborts for not being able to grab the
shrinker_rwsem at the beginning.

if (!down_read_trylock(&shrinker_rwsem)) {
	/*
	 * If we would return 0, our callers would understand that we
	 * have nothing else to shrink and give up trying. By returning
	 * 1 we keep it going and assume we'll be able to shrink next
	 * time.
	 */
	freed = 1;
	goto out;
}

Right now, shrink_slab() is getting called from three places. Twice in
shrink_node() and once in drop_slab_node(). But the return value from
shrink_slab() is checked only inside drop_slab_node() and it has some
heuristics to decide whether to keep on scanning over available memcg
shrinkers registered.

The question is does aborting here will still guarantee forward progress
for all the contexts which might be attempting to allocate memory and had
eventually invoked shrink_slab() ? Because may be the memory allocation
request has more priority than a context getting bit delayed while being
stuck waiting on shrinker_rwsem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
