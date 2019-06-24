Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DC85C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:41:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24DA8212F5
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:41:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QEI4Ii/J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24DA8212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A21156B0003; Mon, 24 Jun 2019 08:41:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D0AD8E0003; Mon, 24 Jun 2019 08:41:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 898178E0002; Mon, 24 Jun 2019 08:41:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6AED96B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:41:23 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id i133so21744625ioa.11
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 05:41:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vT0IOmV5vKSiaiLLTDu0ytTER6gDYyMjplNs/Pum/5Q=;
        b=OEPREX0TLNWv5mmL6oNHzsrxOwvHDp0h+OP0UkEtZJCELUOnBNerPMSkg0v0ECvYr6
         oa/pKUJ6HRFGNl/H4dujMtwQI7uuwDCaGAWrq8+YvLq2oIY/KPOGYzYVdvTCx3C+DEyO
         aw5uWHS4BIUUrp0W3Tgy6LtwiR5RRQfOnY6DRsSosxGy6JQpfqGJNyEBjLzAqQP9/kk9
         spUVtMcIyTi/SXBGFVQmXUn+0Ty1lpKz94UwXYhxbox6UxbzUs9XaeFIdwizWe4FjYDa
         pAzOq6vmkZuHhuSgfqZ4BY8uRE776TXz60s8Xq8vy8BC+WrPQtLtixbii62kURn4IPHa
         WjNg==
X-Gm-Message-State: APjAAAVH6AcXCsUpDYfZZAOLeZa4r+6y0wC517Y5dNdVIDb3U9tHDzBY
	nUJUu1U7OKvFOoxdbo1S/fUWH7tnUsXDtYwKsHkJ3K41gTqcYp/Dfvnu2vRoMjbnNcTFfpG87wr
	mqjFqhe0cXUXtMLomCvN92erYDMh0cNaJqwvB9XhaJte2C8l7nHOeg+QSOPb9R1SW5g==
X-Received: by 2002:a5d:8b52:: with SMTP id c18mr36450937iot.89.1561380083223;
        Mon, 24 Jun 2019 05:41:23 -0700 (PDT)
X-Received: by 2002:a5d:8b52:: with SMTP id c18mr36450887iot.89.1561380082660;
        Mon, 24 Jun 2019 05:41:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561380082; cv=none;
        d=google.com; s=arc-20160816;
        b=bHtp9zT+zOvw8OMnq/ACdF0zPMVbQcluypYQwbAvDO8b8AhFPcA59UFfgw5MvrdDFZ
         X9bf+Gws3FSSvlflrROVjXbqpkWYRrkrlOpSm2Cz14PtpWAGe9oUibHFlrVmELE7oz/y
         p7YzNUy31CSUKebnPb5FCiklUpn9DCiEz00+PcJnuYAbKGZi7Pi1ZBu62Kf3oyNaq7fU
         CgGAe/NyWX8pNGahrlEJO7K3xkxNupF1eNcqSPZWqFZcEumnUctrLvZ7Np2pVu8cev5b
         vgIyDWtkIzke16W4kFOV5JSc4t5Jt+dK76qYFO+li/SYCkGhEEFNww6EG/LKVsGgxsVj
         Vzqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vT0IOmV5vKSiaiLLTDu0ytTER6gDYyMjplNs/Pum/5Q=;
        b=BhN6p0OAln+iVfRhKnMo1eSHKKJRfg6MPdewuyQUyto7XyOshK0D/Udk5TmUZQ5EOO
         ELEd2sstlYfX6umYHw1kauY4Fy2uNdD9efAe1tvh1ttywHN1qX9e/Rh5DZG39VD0JFTV
         vIt+f9JcO0cWAD9LaAEphdSs/Jpe7CqNkl8vxJF2bI8nkG39y036DhY0uPDAUdJci8gM
         RD9DT+5zLk3p4yUI6K55PIrF4Y4ogPeOuVeyNOwNo6ThH/gFYz4nJrz7T5q4Ro2clGlx
         +RTg+eL85F5qi/Wg/eSCvUTMOnb1sHTbP2F4SUIenBJ0OSicH6W2BGTRnvy+FncA2jgr
         NTlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="QEI4Ii/J";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor7554702iot.134.2019.06.24.05.41.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 05:41:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="QEI4Ii/J";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vT0IOmV5vKSiaiLLTDu0ytTER6gDYyMjplNs/Pum/5Q=;
        b=QEI4Ii/JgjYvV0arHUuvELncjGCeyEpAfm8BD4kAOTo6jkhiDH2Is13/npizKczz8K
         pRiPI0nJ6Hf6iJXiAS8+Xx9Hxc0aC0xCHPdu8QVyshmeak5abk92g+1vnKzamiGVfJXy
         Snjws+eyI90PMUAMdjkT+qwIoDTtvZJiaJ3vCiYpAOpPO7SPR1muO7yKv2SsNpSjOLqS
         ZzDNLMg58DKL/uF7XQmmeaKaKNsLPP2DckfFS4DsskD4Te9TxVAm7/VFPUo3Cvm1F/n9
         /2Zbac0CziSdLqpft3h9FXP9jD5iEV+gdkk9ia2S+E/XCg0HXr6QS/Jheoajjwe4okZE
         SGEQ==
X-Google-Smtp-Source: APXvYqxrRTp1t2axXfEQaqztzgCLboJlJ5RdFCisW+UOCEfYvD9hFXfy3YyCkQnf74bf25MayislxGDYdVd89/a7yac=
X-Received: by 2002:a6b:8dcf:: with SMTP id p198mr4665574iod.46.1561380082421;
 Mon, 24 Jun 2019 05:41:22 -0700 (PDT)
MIME-Version: 1.0
References: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
 <1561112086-6169-3-git-send-email-laoar.shao@gmail.com> <d919ea73-daea-8a77-da0a-d1dc6089fd92@virtuozzo.com>
 <CALOAHbCYgky01_LZF+JGq-ooQY-W=S9SE6yc_MmsmnqG5mmmVg@mail.gmail.com> <abcc5922-3d58-f9a3-b040-2871d384ab07@virtuozzo.com>
In-Reply-To: <abcc5922-3d58-f9a3-b040-2871d384ab07@virtuozzo.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 24 Jun 2019 20:40:46 +0800
Message-ID: <CALOAHbD9F-ON04uX+Von3EZ113K5ROA239Vo9Eo6dPtMLL1q1w@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/vmscan: calculate reclaimed slab caches in all
 reclaim paths
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 8:33 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> On 24.06.2019 15:30, Yafang Shao wrote:
> > On Mon, Jun 24, 2019 at 4:53 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> >>
> >> On 21.06.2019 13:14, Yafang Shao wrote:
> >>> There're six different reclaim paths by now,
> >>> - kswapd reclaim path
> >>> - node reclaim path
> >>> - hibernate preallocate memory reclaim path
> >>> - direct reclaim path
> >>> - memcg reclaim path
> >>> - memcg softlimit reclaim path
> >>>
> >>> The slab caches reclaimed in these paths are only calculated in the above
> >>> three paths.
> >>>
> >>> There're some drawbacks if we don't calculate the reclaimed slab caches.
> >>> - The sc->nr_reclaimed isn't correct if there're some slab caches
> >>>   relcaimed in this path.
> >>> - The slab caches may be reclaimed thoroughly if there're lots of
> >>>   reclaimable slab caches and few page caches.
> >>>   Let's take an easy example for this case.
> >>>   If one memcg is full of slab caches and the limit of it is 512M, in
> >>>   other words there're approximately 512M slab caches in this memcg.
> >>>   Then the limit of the memcg is reached and the memcg reclaim begins,
> >>>   and then in this memcg reclaim path it will continuesly reclaim the
> >>>   slab caches until the sc->priority drops to 0.
> >>>   After this reclaim stops, you will find there're few slab caches left,
> >>>   which is less than 20M in my test case.
> >>>   While after this patch applied the number is greater than 300M and
> >>>   the sc->priority only drops to 3.
> >>>
> >>> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> >>> ---
> >>>  mm/vmscan.c | 7 +++++++
> >>>  1 file changed, 7 insertions(+)
> >>>
> >>> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >>> index 18a66e5..d6c3fc8 100644
> >>> --- a/mm/vmscan.c
> >>> +++ b/mm/vmscan.c
> >>> @@ -3164,11 +3164,13 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> >>>       if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
> >>>               return 1;
> >>>
> >>> +     current->reclaim_state = &sc.reclaim_state;
> >>>       trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
> >>>
> >>>       nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> >>>
> >>>       trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
> >>> +     current->reclaim_state = NULL;
> >>
> >> Shouldn't we remove reclaim_state assignment from __perform_reclaim() after this?
> >>
> >
> > Oh yes. We should remove it. Thanks for pointing out.
> > I will post a fix soon.
>
> With the change above, feel free to add my Reviewed-by: to all of the series.
>

Sure, thanks for your review.

Thanks
Yafang

