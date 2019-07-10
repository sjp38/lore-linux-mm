Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56869C74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 20:38:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BFF720651
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 20:38:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="WQxhU6Uh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BFF720651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0BBB8E0094; Wed, 10 Jul 2019 16:38:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BC148E0032; Wed, 10 Jul 2019 16:38:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AB928E0094; Wed, 10 Jul 2019 16:38:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5520D8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 16:38:16 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h5so2126177pgq.23
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 13:38:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=yxd2CjVrpCt6cSQOgX0qW0qn9lapJT8fDpCXMhQ0cWw=;
        b=RuKTR8J+gbXCIrQS0POmA9GMhbU0Gizqt6Km3pqGFwTzWMpByUz9bmeJ1Ha42qyozW
         MeFGV/4gm9Si5IDswZblmVDEWhLkeOl6Frr4UZcXTiG+qs69OsKRiRP/eTMfg0hwL8qP
         nJ7plnuUBYapBs3/lVsNXo+myJrP0zOWA8nWkz/kphMGJbqIy6cFAH2hUGXfnF2rGkbR
         pjkkhmbuQJl87Wa4ntemJVcAPGVIqpkJQeqZtEhfSBrxh4EVUJnMNLbPe/y5ZZK1fOJv
         gloONGEahBCEq+Vqe/0UfqEUU8cxIbulmRngPRo3obmx/iOt9hsaZX4i6r2ryK6Sp7TO
         xVeQ==
X-Gm-Message-State: APjAAAXcE/N+klZ95GCyu73csIOChClnUZxjS4+vKgsgKqouZ8zZJ3W9
	9JdU1s1NlwRulCQwsUH0V0I0nTIBCcFQT8Sb1J6SBVrefx1ONAV/dhVBH1AdZ+nf68V3n4vbqAv
	o1OFhtR/QZMHojcIwqjonjFljGLuNkLyjlOSinI4IHJe49IBBodt3lZZGwszOCNmhXA==
X-Received: by 2002:a17:902:8649:: with SMTP id y9mr138181plt.289.1562791095852;
        Wed, 10 Jul 2019 13:38:15 -0700 (PDT)
X-Received: by 2002:a17:902:8649:: with SMTP id y9mr138140plt.289.1562791095129;
        Wed, 10 Jul 2019 13:38:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562791095; cv=none;
        d=google.com; s=arc-20160816;
        b=yyaXanoJhtWMdZauuBQD2/bG8WNuSym5Ti5vZpJstw6bvCY1lR+rpQIo/5qEXdCj+v
         0srkynJU5rR9esvZhefgUJQ8Na8DJD9pS7mcl5hGjgRgT5pY44MEFTXf4Hj5UAXbv/f3
         wwUQOKMbgG45pQb/KR0crtp/MeRPVOcjZSD28u5Hyjoo1o0SvWPi/4viDvdggYLbjjfD
         qYfkGYcTn6du/EOunRYQov6+AiPEZx9Y44xW+nLrRSxS4aIvfBw4iOiS9PiceteEqTbQ
         1R5zULOdsuGrffXMCjmbnokJ2nDlBFlYGvT94ejBdMfSS2tmFxqw/EtG7PfloiDwTr57
         G1dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yxd2CjVrpCt6cSQOgX0qW0qn9lapJT8fDpCXMhQ0cWw=;
        b=TaO2z+VCx0Zd3f+leaWNZUdxoXJybgtXr6pG9YMWGupC5L3TJyxbHjJtb5p6fWR4kp
         gdb7Sq37JCKU+emCMqYdAyZo9UWJSxrz63KJ+AexYn5XD043NVLZD3YIKXHmvHrWdb3f
         nd19DR7zgzd/h1FnLIWpyllVv7XFMOvnj/O53yC+xEdVQ9GiI//vUhjiNxdi8nhcibbQ
         lXNofAmWeuI9YdenSCc6a4QXYhWHyb7UgnnTxoWc7CjFW6t/WGmrxMUJze1EilrxZLQV
         crJVLuzLbN7Cpk3VxS38tixkd8IV9nbp1J3y4Fjvn9yTKhTVskBh4LH+109rBoEO0I3f
         kunQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=WQxhU6Uh;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o21sor4089665pll.8.2019.07.10.13.38.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 13:38:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=WQxhU6Uh;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yxd2CjVrpCt6cSQOgX0qW0qn9lapJT8fDpCXMhQ0cWw=;
        b=WQxhU6Uh46vlKY1ElEBjRF3o4MEC7HfCtitMhNNSkgxBPBwR05xfM6e3nEz/H3/mEr
         tgS50RM34t/OSubDYAx4KCnBiQOu2dRaFJ1rtylfM9ySuERVUOdVYJIKV6kSog8P9/6G
         2TVggjaZOyOosjq322YC8dPddLsHlUT9WdgCYCgHUZ8c02C1WGt5Drv/sbmKQjaFWKCt
         XJ3WIaAzCu1qM9SvMW7wwWSjsHzaLfl9xtED13oIj6epRrYsi7yBxCyRpsNdHdnrQWci
         TquJmV9r64SNGJmeB9FYAZ0FhLq4l9Rvqscmw7HIzVFtuX8/8w5oXlLGiDnp/LVhrnkK
         1+NQ==
X-Google-Smtp-Source: APXvYqw1FrVFv10U20xJ1uHXU+HR/h2gyHWBg1a6BeEeekyMWO5m2hXxebgWIM4hj0gKT2WVWZrl5w==
X-Received: by 2002:a17:902:6a88:: with SMTP id n8mr213817plk.70.1562791093357;
        Wed, 10 Jul 2019 13:38:13 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:5b9d])
        by smtp.gmail.com with ESMTPSA id w187sm3188090pfb.4.2019.07.10.13.38.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 13:38:12 -0700 (PDT)
Date: Wed, 10 Jul 2019 16:38:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm/memcontrol: make the local VM stats consistent with
 total stats
Message-ID: <20190710203811.GA16153@cmpxchg.org>
References: <1562750823-2762-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562750823-2762-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2019 at 05:27:03AM -0400, Yafang Shao wrote:
> After commit 815744d75152 ("mm: memcontrol: don't batch updates of local VM stats and events"),
> the local VM stats is not consistent with total VM stats.
>
> Bellow is one example on my server (with 8 CPUs),
> 	inactive_file 3567570944
> 	total_inactive_file 3568029696
> 
> We can find that the deviation is very great, that is because the 'val' in
> __mod_memcg_state() is in pages while the effective value
> in memcg_stat_show() is in bytes.
> So the maximum of this deviation between local VM stats and total VM
> stats can be (32 * number_of_cpu * PAGE_SIZE), that may be an unacceptable
> great value.
> 
> We should make the local VM stats consistent with the total stats.
> Although the deviation between local VM events and total events are not
> great, I think we'd better make them consistent with each other as well.

Ha - the local stats are not percpu-fuzzy enough... But I guess that
is a valid complaint.

> ---
>  mm/memcontrol.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ba9138a..a9448c3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -691,12 +691,12 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
>  	if (mem_cgroup_disabled())
>  		return;
>  
> -	__this_cpu_add(memcg->vmstats_local->stat[idx], val);
>  
>  	x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
>  	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
>  		struct mem_cgroup *mi;
>  
> +		__this_cpu_add(memcg->vmstats_local->stat[idx], x);
>  		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
>  			atomic_long_add(x, &mi->vmstats[idx]);
>  		x = 0;
> @@ -773,12 +773,12 @@ void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
>  	if (mem_cgroup_disabled())
>  		return;
>  
> -	__this_cpu_add(memcg->vmstats_local->events[idx], count);
>  
>  	x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
>  	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
>  		struct mem_cgroup *mi;
>  
> +		__this_cpu_add(memcg->vmstats_local->events[idx], x);
>  		for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
>  			atomic_long_add(x, &mi->vmevents[idx]);
>  		x = 0;

Please also update __mod_lruvec_state() to keep this behavior the same
across counters, to make sure we won't have any surprises when
switching between them.

And please add comments explaining that we batch local counters to
keep them in sync with the hierarchical ones. Because it does look a
little odd without explanation.

