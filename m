Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F3C4C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 01:57:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00C1F20825
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 01:57:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YHW3wCZM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00C1F20825
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 591B76B0003; Mon, 15 Apr 2019 21:57:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53F7F6B0006; Mon, 15 Apr 2019 21:57:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42E586B0007; Mon, 15 Apr 2019 21:57:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC086B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 21:57:55 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id z130so14541397ywb.14
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 18:57:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9Z6Efxstusl8bv0MPNQb6LsZw7PMuW4dqsK1aSDA8tk=;
        b=CtCpm1Xq0cIBLmW+L/WQ/tk/gApn2xiSu+jBgggLei+s60UP9FMvC3rPSDR9vr7hPe
         +jVio5ZCSenRO1t+foo39vpdWHJ1G8DberP8MtqbNzcCmFxuwHt+eFmlyrZvTqSaG9Cr
         p5xtINCPzPUErQZpMNRH3/zbpgGua1rPmbQNzEt1aW+H9aU8FT6ha4DTcIqF4HkCci2w
         ft/gWhIOCgIoUVGsCBrobO1DHgzYHomi5ELzlAju5SlLmCJkjLJ5tPRCpKgBi6HK3yn6
         7MrJeEd2qznTdiemcTWraPBLxmdqTuCVeVOUehfc44J5d5F117XVY+NB705Gj09ZzXW9
         oEZw==
X-Gm-Message-State: APjAAAUTu40uBtF5dYCZ3ljWLeLzZfBvXr8A9pAD1Wz/jD38U5LVlMar
	rcdlEJA8MgxGks1ACK1zpqZGeuOUJMiizWaoPZocoH6EevXZvUPwDR6uc+Mq+O3tHD+a45qPZ2l
	jhxCfWX+FkEMhny/VB+5r15vy5x4jCKl65VoKXPb8gwQ0Uj/n5106d+QaboWg9Irxjw==
X-Received: by 2002:a81:9249:: with SMTP id j70mr61982345ywg.371.1555379874768;
        Mon, 15 Apr 2019 18:57:54 -0700 (PDT)
X-Received: by 2002:a81:9249:: with SMTP id j70mr61982298ywg.371.1555379873248;
        Mon, 15 Apr 2019 18:57:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555379873; cv=none;
        d=google.com; s=arc-20160816;
        b=LGmYIwVaSupk3yCb/jrVJYWmiRew7Q+F3TrhVCzI1O7lu4FE712taXmbI725t51owJ
         nxlyThnslSeWz92xIBsv0Go64dtXqQvfa044Li4QAoP7ECZ2iXiYfR4TLNKcm3qpthtu
         Ab4Q9Va/20uZ8zqJoPLpv68oMoJEBozSXs2RCsRG26GMoDjnxrrGctU7TszSv8S8oPdx
         KZsqPA//rk1onDRqj7JH7cuI3vf82cMzSQrPCaYedfGbT7SgFJ1uGF4Kgc3PK7cjaU0Z
         zyborbZLRcINL1S0exWEfCMBxPVVT7G6cSqtY7CgIE+AGuttWYUeD67deyHxWRcERX0U
         BdXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9Z6Efxstusl8bv0MPNQb6LsZw7PMuW4dqsK1aSDA8tk=;
        b=U5siw3NRSb6pUu1yY3I7sWyaKLpmahTl5xey6NYKnoFhJHtFa7qZCU1/4eSM1xe5/s
         KavJDtKDa6M6QjppzU7o5FTAwZLo3h2W4WIxrdC1RKwQdYLP5qj86zUWKNtlxeOcSlLb
         iJvUVtg8yuTlfLh8jQxTbnLme1XaulczBIMb3dRah7b5AXaSG0rlgvRBr/AfCVagKbGO
         NUEJ8CUKSMvIvalwaWUkxCWrHOQY/YCS3W6LQd51IcLnBGZMITRu77l5dwxJ/ypMTF3k
         ZwaRmoWDHER0ySVETN9v1BW6lFvkD1DETlE9PWB2RhQzHphz2/l31vUnYBlGM4xGMlGL
         /HZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YHW3wCZM;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 132sor27608058ybp.15.2019.04.15.18.57.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Apr 2019 18:57:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YHW3wCZM;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9Z6Efxstusl8bv0MPNQb6LsZw7PMuW4dqsK1aSDA8tk=;
        b=YHW3wCZMxdYPK+4h1+oUGGxChwMSC5UqBLlitvvx0/DbVrle74k8U2OlBXa+KWJ1cW
         DvGK3mm6RyFUnDwHlC6h2kn81UGUFXJ8dUnGKfGwhWg30UbuBoXBjC/KLKsqD/OXKq42
         vj98QNVSYVGWXlk6kcQIIjzsKVdfhlPGSRimNgCWS/3P8mmmA3xlcEYzDMKENzzZur61
         4b8Q3K8aPOEDxVMrY+cxSX666388la0JfJjHtJHUTh/WGNXa8mUXjkHOz5f//qMP1Jcz
         xSmb/lGZhTLgR96/d7ZIlxXJGWX2QM8wJgX600T2u9mwbYm1QWdpJdOw63ty7ilRJ79q
         YxWQ==
X-Google-Smtp-Source: APXvYqxamoszhEeZGFDQbhqdlQRL8JyJroe+oY3XpgUvhB35g65vyOOePJr+S+/dNXsiyFXyg+ZAlb+Ftx4QmRfgS00=
X-Received: by 2002:a25:1e57:: with SMTP id e84mr64070144ybe.184.1555379872551;
 Mon, 15 Apr 2019 18:57:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190412144438.2645-1-hannes@cmpxchg.org>
In-Reply-To: <20190412144438.2645-1-hannes@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 15 Apr 2019 18:57:41 -0700
Message-ID: <CALvZod57YYGJHBvMpbdmysuDPzdEAsv+JM5tK8Qfxgrsb=T-pw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix inactive list balancing between NUMA nodes and cgroups
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Team <kernel-team@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 7:44 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> During !CONFIG_CGROUP reclaim, we expand the inactive list size if
> it's thrashing on the node that is about to be reclaimed. But when
> cgroups are enabled, we suddenly ignore the node scope and use the
> cgroup scope only. The result is that pressure bleeds between NUMA
> nodes depending on whether cgroups are merely compiled into Linux.
> This behavioral difference is unexpected and undesirable.
>
> When the refault adaptivity of the inactive list was first introduced,
> there were no statistics at the lruvec level - the intersection of
> node and memcg - so it was better than nothing.
>
> But now that we have that infrastructure, use lruvec_page_state() to
> make the list balancing decision always NUMA aware.
>
> Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  mm/vmscan.c | 29 +++++++++--------------------
>  1 file changed, 9 insertions(+), 20 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 347c9b3b29ac..c9f8afe61ae3 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2138,7 +2138,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
>   *   10TB     320        32GB
>   */
>  static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
> -                                struct mem_cgroup *memcg,
>                                  struct scan_control *sc, bool actual_reclaim)
>  {
>         enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
> @@ -2159,16 +2158,12 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
>         inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
>         active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
>
> -       if (memcg)
> -               refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
> -       else
> -               refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
> -
>         /*
>          * When refaults are being observed, it means a new workingset
>          * is being established. Disable active list protection to get
>          * rid of the stale workingset quickly.
>          */
> +       refaults = lruvec_page_state(lruvec, WORKINGSET_ACTIVATE);
>         if (file && actual_reclaim && lruvec->refaults != refaults) {
>                 inactive_ratio = 0;
>         } else {
> @@ -2189,12 +2184,10 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
>  }
>
>  static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
> -                                struct lruvec *lruvec, struct mem_cgroup *memcg,
> -                                struct scan_control *sc)
> +                                struct lruvec *lruvec, struct scan_control *sc)
>  {
>         if (is_active_lru(lru)) {
> -               if (inactive_list_is_low(lruvec, is_file_lru(lru),
> -                                        memcg, sc, true))
> +               if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
>                         shrink_active_list(nr_to_scan, lruvec, sc, lru);
>                 return 0;
>         }
> @@ -2293,7 +2286,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>                          * anonymous pages on the LRU in eligible zones.
>                          * Otherwise, the small LRU gets thrashed.
>                          */
> -                       if (!inactive_list_is_low(lruvec, false, memcg, sc, false) &&
> +                       if (!inactive_list_is_low(lruvec, false, sc, false) &&
>                             lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
>                                         >> sc->priority) {
>                                 scan_balance = SCAN_ANON;
> @@ -2311,7 +2304,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>          * lruvec even if it has plenty of old anonymous pages unless the
>          * system is under heavy pressure.
>          */
> -       if (!inactive_list_is_low(lruvec, true, memcg, sc, false) &&
> +       if (!inactive_list_is_low(lruvec, true, sc, false) &&
>             lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
>                 scan_balance = SCAN_FILE;
>                 goto out;
> @@ -2515,7 +2508,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
>                                 nr[lru] -= nr_to_scan;
>
>                                 nr_reclaimed += shrink_list(lru, nr_to_scan,
> -                                                           lruvec, memcg, sc);
> +                                                           lruvec, sc);
>                         }
>                 }
>
> @@ -2582,7 +2575,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
>          * Even if we did not try to evict anon pages at all, we want to
>          * rebalance the anon lru active/inactive ratio.
>          */
> -       if (inactive_list_is_low(lruvec, false, memcg, sc, true))
> +       if (inactive_list_is_low(lruvec, false, sc, true))
>                 shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
>                                    sc, LRU_ACTIVE_ANON);
>  }
> @@ -2985,12 +2978,8 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
>                 unsigned long refaults;
>                 struct lruvec *lruvec;
>
> -               if (memcg)
> -                       refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
> -               else
> -                       refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
> -
>                 lruvec = mem_cgroup_lruvec(pgdat, memcg);
> +               refaults = lruvec_page_state_local(lruvec, WORKINGSET_ACTIVATE);
>                 lruvec->refaults = refaults;
>         } while ((memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
>  }
> @@ -3346,7 +3335,7 @@ static void age_active_anon(struct pglist_data *pgdat,
>         do {
>                 struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
>
> -               if (inactive_list_is_low(lruvec, false, memcg, sc, true))
> +               if (inactive_list_is_low(lruvec, false, sc, true))
>                         shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
>                                            sc, LRU_ACTIVE_ANON);
>
> --
> 2.21.0
>

