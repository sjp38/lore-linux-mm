Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09AA2C3A59B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 03:34:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92F8521019
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 03:34:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Kf9pb5KB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92F8521019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BDDD6B0007; Fri, 16 Aug 2019 23:34:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 047496B000A; Fri, 16 Aug 2019 23:34:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E50376B000C; Fri, 16 Aug 2019 23:34:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0135.hostedemail.com [216.40.44.135])
	by kanga.kvack.org (Postfix) with ESMTP id BE7FC6B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 23:34:32 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6860D180AD80F
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:34:32 +0000 (UTC)
X-FDA: 75830502384.18.line79_7ee8023593133
X-HE-Tag: line79_7ee8023593133
X-Filterd-Recvd-Size: 5814
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:34:31 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id t3so10214098ioj.12
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 20:34:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Nun2JfC7ez1tC7LAJQflPI3bnSU4+ToyXIlxSOxQrz4=;
        b=Kf9pb5KBMGYwgI+0kzbxt2Tw9l6jQWED1EcMLYyVY9p34X5qI//6NfdUJ85bl7UOut
         s1N3104WhhoYDJvZFKiKARuM87iDLNA4pJuptcvX3bGp/zAfRIuCUa4tAdo074Gq613V
         tglnLRUXVHX8JtqjPJCijkaatL+EPounGC6BYhLQupL9WRhwWXRcZL0i+ZezrRkfKN+T
         PIPDD1tCGtkTa8zYTSrFkUoBuqhW+V6di30HWLUuRb+iDI3lIsoER3611C9RIdxarQnM
         IFo1RFast19nI6unyTFpAhrOD8obVtGWU/r2hJUiGxGaKTy+lnm+IERqecSNwfOHOsW8
         +vSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Nun2JfC7ez1tC7LAJQflPI3bnSU4+ToyXIlxSOxQrz4=;
        b=K6s1/U3PUuKjUKljdBNB4Tq6WGKMwOALLBzODv0PvhGZLQyLCM9WGI1Dng9p/BTJzu
         AOH9kwYoyc782AdJSZjF2blfkmtFtMrrrEczu/H4x7PUM0lde3IAWDxEmSdgaWDB/0pM
         JKBE7whrWcg2yhzrfgatMtIaNVyfE7tiyfpBjfuHfuHQ067UQdgsEGwVUn5QTPr+ZSOW
         qtgmXpvySxAYKGqPBfmkm9KU7eQHYaRsapG6NJkp0oJ6a/dnWM0xzZ1pfSaFLnkgO7b5
         /Kmb/D0RsWg8UrYnAachDAzRvknqYwwE5dofTfmkp4lghCbJnywT+XYYa92qooUfNKIn
         GsGQ==
X-Gm-Message-State: APjAAAXlFSJiiI03XMDXdRHtS/iH9oH2dSuOakkGP2W35wQaRVwBo93R
	5jHpqfRVE7vYhwJVFiZibbIVS3PTxTvafxtdxFM=
X-Google-Smtp-Source: APXvYqwKthZbb7+MUn8RPnltggGx9a7JJBQSw9zRiBoG31/estvuzXvHwglOzdIzPIn//6QYp4qH7ybz63LJFbuNxdQ=
X-Received: by 2002:a02:54c1:: with SMTP id t184mr15032478jaa.10.1566012871360;
 Fri, 16 Aug 2019 20:34:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190817004726.2530670-1-guro@fb.com>
In-Reply-To: <20190817004726.2530670-1-guro@fb.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 17 Aug 2019 11:33:57 +0800
Message-ID: <CALOAHbBsMNLN6jZn83zx6EWM_092s87zvDQ7p-MZpY+HStk-1Q@mail.gmail.com>
Subject: Re: [PATCH] Partially revert "mm/memcontrol.c: keep local VM counters
 in sync with the hierarchical ones"
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 17, 2019 at 8:47 AM Roman Gushchin <guro@fb.com> wrote:
>
> Commit 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync
> with the hierarchical ones") effectively decreased the precision of
> per-memcg vmstats_local and per-memcg-per-node lruvec percpu counters.
>
> That's good for displaying in memory.stat, but brings a serious regression
> into the reclaim process.
>
> One issue I've discovered and debugged is the following:
> lruvec_lru_size() can return 0 instead of the actual number of pages
> in the lru list, preventing the kernel to reclaim last remaining
> pages. Result is yet another dying memory cgroups flooding.
> The opposite is also happening: scanning an empty lru list
> is the waste of cpu time.
>
> Also, inactive_list_is_low() can return incorrect values, preventing
> the active lru from being scanned and freed. It can fail both because
> the size of active and inactive lists are inaccurate, and because
> the number of workingset refaults isn't precise. In other words,
> the result is pretty random.
>
> I'm not sure, if using the approximate number of slab pages in
> count_shadow_number() is acceptable, but issues described above
> are enough to partially revert the patch.
>
> Let's keep per-memcg vmstat_local batched (they are only used for
> displaying stats to the userspace), but keep lruvec stats precise.
> This change fixes the dead memcg flooding on my setup.
>

That will make some misunderstanding if the local counters are not in
sync with the hierarchical ones
(someone may doubt whether there're something leaked.).
If we have to do it like this, I think we should better document this behavior.

> Fixes: 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones")
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Yafang Shao <laoar.shao@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 249187907339..3429340adb56 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -746,15 +746,13 @@ void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
>         /* Update memcg */
>         __mod_memcg_state(memcg, idx, val);
>
> +       /* Update lruvec */
> +       __this_cpu_add(pn->lruvec_stat_local->count[idx], val);
> +
>         x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
>         if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
>                 struct mem_cgroup_per_node *pi;
>
> -               /*
> -                * Batch local counters to keep them in sync with
> -                * the hierarchical ones.
> -                */
> -               __this_cpu_add(pn->lruvec_stat_local->count[idx], x);
>                 for (pi = pn; pi; pi = parent_nodeinfo(pi, pgdat->node_id))
>                         atomic_long_add(x, &pi->lruvec_stat[idx]);
>                 x = 0;
> --
> 2.21.0
>

