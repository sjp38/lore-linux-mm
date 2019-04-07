Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 517B6C282DA
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 00:43:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBEDA213A2
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 00:43:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mN0D6qW7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBEDA213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 045776B026D; Sat,  6 Apr 2019 20:43:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F38886B026E; Sat,  6 Apr 2019 20:43:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E264A6B026F; Sat,  6 Apr 2019 20:43:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 98DAE6B026D
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 20:43:39 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id a206so5964917wmh.2
        for <linux-mm@kvack.org>; Sat, 06 Apr 2019 17:43:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bNsqfdQNBfHjyXIGV8C12WgnaMuuVXlb2SSFxsHHfG8=;
        b=LZGK5KeKs13M+HRAuMN/sdsdZ0w6xjC/LUZjbAcR5Oyaom3MDVSkhwthIeePpski5L
         w9ReVlBAETawivYUffdlr5cy1d+IH5otauWEIoyHK02rZRPqHXfnMBw4kAw7zdXsGQhX
         tAzPU8Xv5gJMVHiVG8dIAImGWAjZ7Hs32s5DB3G1q0AMUebbtZulRkOLIx6TJSWP51LW
         0GKR/2H+ukn0zpWlSmAu3tsObteU4tTB/toJv+/MUxTxfE69j3ncvyeVyFGKtZWqP/dI
         zcbbm5nx6GMom4023XvXTC5v5Tyvce6pR8rTXeGDb9YwMjRqaPf//nfOkzQ9ZbOmkmA5
         dj9Q==
X-Gm-Message-State: APjAAAXxqb5ADU11psjxoISAqA6uhnb+KfLKhAFqEEhvBAHGdrwLE8ai
	0FF6jLByvt6/a1qopTJNYu4/DKc3innNgwmkT2yvUF7PGiY3Awgjj0wdPJQldscoOkogYdTQjD2
	64R3/ZTqLHlc9Y/cXNNK5ACD9niSHxnqMccU6fGHiC6OZs3rQlig/Acyr99F4wUJfNA==
X-Received: by 2002:a5d:494c:: with SMTP id r12mr13497543wrs.250.1554597818985;
        Sat, 06 Apr 2019 17:43:38 -0700 (PDT)
X-Received: by 2002:a5d:494c:: with SMTP id r12mr13497519wrs.250.1554597818111;
        Sat, 06 Apr 2019 17:43:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554597818; cv=none;
        d=google.com; s=arc-20160816;
        b=tbzQIAMgeFMwzOCVLC+n7d0Hi0/UoWZabUksXbSQ1JJ7gTaqZCg8UyFjV0EqW9tCun
         uK8SjWkui2f3tmz5jxzy+yfWrb6FA6fPcGZnZ+KccW6S12b5zVLX2gR6enzLItmKWqBy
         we1yulXhPUk5WiFXz3gREnMrqBYOrOSjfGJgK2PSG4WE8zbDufOhD+stfNuuZDwTREKB
         Nq0a2WiGHuZ51yUGIHJwjuzgPJO9KFnuAijsfWy7HL4PU2EeL151KwNv4tpk8BRnjlYx
         A1ahjRXgO6Bgw/GM8j77t7cTtntu3bBzJ0r76sq+fQH4G3r98ldHOvXRbwcMNuVtpVOj
         A4tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bNsqfdQNBfHjyXIGV8C12WgnaMuuVXlb2SSFxsHHfG8=;
        b=RjoQGYB9CVB/c3YZPZNrIZwnUBXM3XNQzn26tCSpguzxgeARO4OQlF9ECOqi21Nejt
         CB6HnbTsPau55Y9J8Qtro1dYFAKKtDy4YvLHo3ifr0FMOXW6LEQN5/wZqjqBc5CwNyGC
         WHjDs6kZxxyQknLGeMq6G7+KXcpcA5km1qUjW1gU7tgU/I+rmNNSbHHsBCwbO8m8uHV+
         da46/08sDUezC417l6ynixx432xei0MpuX/2nL5PgjWCg1cVp44Wkvv1P/ax/zOmzao4
         sOCXqwWdM6gvFk3EoQ3PY5+3RQLozzYmYbfJ5bnN8XMt1faeAg7iMWchQpHYjaP7wcJL
         wOjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mN0D6qW7;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o67sor3610205wma.12.2019.04.06.17.43.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Apr 2019 17:43:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mN0D6qW7;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bNsqfdQNBfHjyXIGV8C12WgnaMuuVXlb2SSFxsHHfG8=;
        b=mN0D6qW7g35is4a2WGB+jmFlKNC88Q6qdutNQHtkLf+TX5BIJWXmt4AbJLRxYybMlS
         EV+KP1TA2u8rlXQcwYk5K7ngg3HP3aVWgp0XY03oenL020WfomGRMzGV29YPol6cyUjR
         zPdcU9ystDG8p07xEtyWPir26zzORUFjGIaIvSIoPoxL4Ec+ibUo9HSZdq+ko8MihD6D
         Lx4PTDpDKmaq1gkJwtMkrgLqdBigGU450vfFKiI9KPLmzrKdEqzBL36EkLOeq0aG+l9g
         SMqKY4wJpBGU9azGiDF/DRVkLjSAVccK2B/55DRxmDDDLMUgiShCzTY/8s8Ao6ny9My7
         ScTg==
X-Google-Smtp-Source: APXvYqzMsI5jkgYOJ2BTgSLY2XZsUO2QwusIqpjK6aiNgcfQl4UawI5zb8oF9r5SjZrgDQN7dMQ9qstaODnlqfQ+gK8=
X-Received: by 2002:a05:600c:2118:: with SMTP id u24mr12728182wml.24.1554597817349;
 Sat, 06 Apr 2019 17:43:37 -0700 (PDT)
MIME-Version: 1.0
References: <1554343303-11880-1-git-send-email-huangzhaoyang@gmail.com>
In-Reply-To: <1554343303-11880-1-git-send-email-huangzhaoyang@gmail.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Sat, 6 Apr 2019 17:43:26 -0700
Message-ID: <CAJuCfpEWG19-7HYjasmRXZV0Q+AnFNPB--qtAXSDCk97k7DRVg@mail.gmail.com>
Subject: Re: [PATCH] mm:workingset use real time to judge activity of the file page
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Pavel Tatashin <pasha.tatashin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>, 
	Matthew Wilcox <mawilcox@microsoft.com>, linux-mm <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 3, 2019 at 7:03 PM Zhaoyang Huang <huangzhaoyang@gmail.com> wrote:
>
> From: Zhaoyang Huang <Zhaoyang Huang@unisoc.com>
>
> In previous implementation, the number of refault pages is used
> for judging the refault period of each page, which is not precised.
> We introduce the timestamp into the workingset's entry to measure
> the file page's activity.
>
> The patch is tested on an Android system, which can be described as
> comparing the launch time of an application between a huge memory
> consumption. The result is launch time decrease 50% and the page fault
> during the test decrease 80%.
>
> Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
> ---
>  include/linux/mmzone.h |  2 ++
>  mm/workingset.c        | 24 +++++++++++++++++-------
>  2 files changed, 19 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 32699b2..c38ba0a 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -240,6 +240,8 @@ struct lruvec {
>         atomic_long_t                   inactive_age;
>         /* Refaults at the time of last reclaim cycle */
>         unsigned long                   refaults;
> +       atomic_long_t                   refaults_ratio;
> +       atomic_long_t                   prev_fault;
>  #ifdef CONFIG_MEMCG
>         struct pglist_data *pgdat;
>  #endif
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 40ee02c..6361853 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -159,7 +159,7 @@
>                          NODES_SHIFT +  \
>                          MEM_CGROUP_ID_SHIFT)
>  #define EVICTION_MASK  (~0UL >> EVICTION_SHIFT)
> -
> +#define EVICTION_JIFFIES (BITS_PER_LONG >> 3)
>  /*
>   * Eviction timestamps need to be able to cover the full range of
>   * actionable refaults. However, bits are tight in the radix tree
> @@ -175,18 +175,22 @@ static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
>         eviction >>= bucket_order;
>         eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
>         eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
> +       eviction = (eviction << EVICTION_JIFFIES) | (jiffies >> EVICTION_JIFFIES);
>         eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
>
>         return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
>  }
>
>  static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
> -                         unsigned long *evictionp)
> +                         unsigned long *evictionp, unsigned long *prev_jiffp)
>  {
>         unsigned long entry = (unsigned long)shadow;
>         int memcgid, nid;
> +       unsigned long prev_jiff;
>
>         entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
> +       entry >>= EVICTION_JIFFIES;
> +       prev_jiff = (entry & ((1UL << EVICTION_JIFFIES) - 1)) << EVICTION_JIFFIES;
>         nid = entry & ((1UL << NODES_SHIFT) - 1);
>         entry >>= NODES_SHIFT;
>         memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
> @@ -195,6 +199,7 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
>         *memcgidp = memcgid;
>         *pgdat = NODE_DATA(nid);
>         *evictionp = entry << bucket_order;
> +       *prev_jiffp = prev_jiff;
>  }
>
>  /**
> @@ -242,8 +247,12 @@ bool workingset_refault(void *shadow)
>         unsigned long refault;
>         struct pglist_data *pgdat;
>         int memcgid;
> +       unsigned long refault_ratio;
> +       unsigned long prev_jiff;
> +       unsigned long avg_refault_time;
> +       unsigned long refault_time;
>
> -       unpack_shadow(shadow, &memcgid, &pgdat, &eviction);
> +       unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &prev_jiff);
>
>         rcu_read_lock();
>         /*
> @@ -288,10 +297,11 @@ bool workingset_refault(void *shadow)
>          * list is not a problem.
>          */
>         refault_distance = (refault - eviction) & EVICTION_MASK;
> -
>         inc_lruvec_state(lruvec, WORKINGSET_REFAULT);
> -
> -       if (refault_distance <= active_file) {
> +       lruvec->refaults_ratio = atomic_long_read(&lruvec->inactive_age) / jiffies;

I also wonder how many times the division above yields a 0...

> +       refault_time = jiffies - prev_jiff;
> +       avg_refault_time = refault_distance / lruvec->refaults_ratio;

and then used here as a denominator.

> +       if (refault_time <= avg_refault_time) {
>                 inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
>                 rcu_read_unlock();
>                 return true;
> @@ -521,7 +531,7 @@ static int __init workingset_init(void)
>          * some more pages at runtime, so keep working with up to
>          * double the initial memory by using totalram_pages as-is.
>          */
> -       timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
> +       timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT - EVICTION_JIFFIES;
>         max_order = fls_long(totalram_pages - 1);
>         if (max_order > timestamp_bits)
>                 bucket_order = max_order - timestamp_bits;
> --
> 1.9.1
>

