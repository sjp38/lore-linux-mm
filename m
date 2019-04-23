Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C86F2C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:12:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8434720645
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:12:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="THAV1y8l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8434720645
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B8EC6B026A; Tue, 23 Apr 2019 13:12:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 368826B026B; Tue, 23 Apr 2019 13:12:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 281756B026C; Tue, 23 Apr 2019 13:12:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 076786B026A
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:12:59 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id j14so6643485ywb.2
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:12:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=V0yM1FnfaFTMPVX+ABUhKFlqtNuMTvQ1TPfOVdXitDM=;
        b=nuaxibOSx52z2I/BQGYnw8OHrs6m0feLY+nmaCZljSpkAYMwp9+jZKJTOHocrZYeLK
         +4RR+T9n5rcCKOdwnnCPsqp1KvAZdN8+L7+iOBb6H/yr5srtDSGbJ67VlKZsbE1qt/H+
         8IXEZmNu+sKQCG83GztOPzaifMntG8hp2w/X3jPmY1VXHK8cJeDlObvF9H+lo0N+hzKh
         pFMagnKNS26uPnIbp65335mtqPP8vg2xt3XNQSgZUewUgMqhcneudId5N/ct83LUBQB/
         iM1eMU6cOzi5GinFP+p7OMy3TTfkoJJy9rmSvtzdeEoOLW5jLV2CEwHqS4PbhxS6JWln
         diDw==
X-Gm-Message-State: APjAAAVqUGWU9Fyd4eziggekWVY/PkOT166SHU/2/H+A7gkgV0rmfMeL
	ZYvPkRVSPsSTxFXuXAMjTdsGJl70JcRvumkjZYhDhYdMiBD1TPpy+OMf0TeMOapo4SeFCwH8v0S
	OnIpnvLZanlL42Kejl+hB4H8UCVd6OVv88wqz4esQ871+41B+STULKw7M8ItKO9L9kg==
X-Received: by 2002:a81:23d7:: with SMTP id j206mr15358987ywj.392.1556039578759;
        Tue, 23 Apr 2019 10:12:58 -0700 (PDT)
X-Received: by 2002:a81:23d7:: with SMTP id j206mr15358941ywj.392.1556039578196;
        Tue, 23 Apr 2019 10:12:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556039578; cv=none;
        d=google.com; s=arc-20160816;
        b=Wghzk9Gw2Er36OvrenyjvL6s2YbdBmfDIBkuPYxwi8Z5CaydX5w2TmU/4SERK/tJM2
         k91u5hGf3iQaRDWsk3XZvzSGJNwl7bT0Be9iXJ8fCyy7Z5s9oyJL9XYSNXavuwPucnts
         vB9A3p9pjBiRCyHCqqKwkhqeXoQ/wDtrb9MJ7QML7n3D1aXlPzJqvqQevcqQNF+XF11z
         bwrkJMLzgO55muKtnW/sFhMnoxiAnhL8+lmFBSLTboYPXW0x6vI2rXmJC4xdne2bKGI1
         F8dX4flCzjW8nbv3z20jAy+PCO5Voq7D9BoOAl4l6YRQYdf6ZcRL/OcwTZE+iVwbJoaq
         gVWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=V0yM1FnfaFTMPVX+ABUhKFlqtNuMTvQ1TPfOVdXitDM=;
        b=g06SaJeEgiP4r1W4XbM5G4YFUPnPWy/273awvHk04sH3IUwZiiXphC4M3Eq94Ep47j
         +hCRWDnxs8JnVnz3MJccq2G6JeUp8SLguuuYRl9I4MNMHSYxshj8q3J8X9NrEYLLuxUq
         P0nh1w14SEOa1Q/OFbJk8win3fEH9vxEppHeUGN4TdbKp75XlI39ovCm1imeEDUjmSiD
         /JlPetxuKQ5ExPK8Bfm1p5m9YZpI6qn/JJ7dglWYDX15WkhumP1RqlFeHSv2IZvsHJIG
         msv3V0VtR1hs6wzowLpVO70DOO04ZD3ea06nqfTTmGidPVU38BtIhM5Fd0btuwzgf8rZ
         hXfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=THAV1y8l;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 126sor7527574ybo.51.2019.04.23.10.12.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 10:12:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=THAV1y8l;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=V0yM1FnfaFTMPVX+ABUhKFlqtNuMTvQ1TPfOVdXitDM=;
        b=THAV1y8lrZRNyQxfOM3322woOIRyrKZSPUKNDBondJZ+VQkGLik+WI2fOBhamoZKzT
         8OHu/HheWS4/qNds+gJ25cErNfvhZiqHWi4Il2xxoyufT5lqk+qgFPNmCy84LKYitZsu
         iwEqOMHWqwHMNq3bOyOnqZJ0cy9KHhH5uP/kHZ345dQXCXDAW9hBHwU/n1CO1U+qyOJQ
         nndiGqnmKVRh7Btx0h2dwU5vm3E0uMTrXWQrkaXZq248yFm/E0mYW9c1GpNHlbEPw521
         bbvg7oxc31AqMNrFivcjgCP3duihLbNp6yx+vpSkk2bFpnRliyWXpGVhtH41pa0VL+iL
         ysCA==
X-Google-Smtp-Source: APXvYqw9vt4omiLUCJ9P8CPlRqsBR6mOkpfgAAdmB5gJL54fg0XmxKXeg72QO3Zp3h5Fy/Ci+2jRjKQuZNiYMC3qdQg=
X-Received: by 2002:a25:664f:: with SMTP id z15mr21363261ybm.496.1556039577484;
 Tue, 23 Apr 2019 10:12:57 -0700 (PDT)
MIME-Version: 1.0
References: <CALvZod4V+56pZbPkFDYO3+60Xr0_ZjiSgrfJKs_=Bd4AjdvFzA@mail.gmail.com>
 <20190423155827.GR18914@techsingularity.net> <CALvZod7-_RgMiA-X2MdmrizWiPf3L4CtJdcbCFWiy9ZDFEc+Sw@mail.gmail.com>
 <CAHbLzkp1HY0+x6ug8d43rpyQZqB9-Vh_vgbVF5-pcM=3FVVsWA@mail.gmail.com>
In-Reply-To: <CAHbLzkp1HY0+x6ug8d43rpyQZqB9-Vh_vgbVF5-pcM=3FVVsWA@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 23 Apr 2019 10:12:46 -0700
Message-ID: <CALvZod5X7d38BO4byaWaKScibsJJPEj8KZx6t5Od1EXRvn_aOg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Proactive Memory Reclaim
To: Yang Shi <shy828301@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, lsf-pc@lists.linux-foundation.org, 
	Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 9:50 AM Yang Shi <shy828301@gmail.com> wrote:
>
> Hi Shakeel,
>
> This sounds interesting. Actually, we have something similar designed
> in-house (called "cold" page reclaim). But, we mainly targeted to cold
> page cache rather than anonymous page for the time being, and it does
> in cgroup scope. We are extending it to anonymous page now.
>
> Look forward to discussing with you.
>

Hi Yang,

Thanks for the info. Is this per-cgroup "cold page reclaim" is
triggered by the job themselves? Are the jobs trying to avoid memcg
limit reclaim by proactively reclaiming their own memory?

Shakeel

