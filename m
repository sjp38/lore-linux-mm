Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48F28C5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 04:28:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD82C2085A
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 04:28:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d+s/TFwx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD82C2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0511E6B0003; Wed,  3 Jul 2019 00:28:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0012B8E0003; Wed,  3 Jul 2019 00:28:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0A468E0001; Wed,  3 Jul 2019 00:28:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id C0EC56B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 00:28:00 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id m26so1134839ioh.17
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 21:28:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=d80tB5vk/g0WMCXuJgkvhpG+W/B6ZghkR/JiRF3I5y4=;
        b=JN9eVhBaDDs6Fswp5OIs2cunXnhsTV5Hv8LLBaqcmSOKpZ1ApbMArB/+b1ya1MmQEx
         9ZnMyN7O5AGeN+8NsfenOGMMAHtjitmnVOq0HrYBe430Hx2LkM7WRBdSjG/xlzvBqoBO
         2eWq0lQZEFAFHAqrFKki0lN8900KkFDbg0q1qN06sM9xamuRSHA9//Oy7ArY1smlz41q
         ChYogoVv+WMBymrf/i4tynLnjeDua74bfoHvcdXGPRIMhfaXC+HVU9e5kxFdOA55OcCl
         Hhp3o0mBSnoZ/xbkzNN640HESDHbhXwHWw9hZa57B1oREZHTAaBaZeRBPT5IiF7jlyuj
         NGLQ==
X-Gm-Message-State: APjAAAXOhTJSvFDxzNRbwZyBaznkDllyXXD5BHSJ39IkkyPVa0hgSBnr
	wo+zY+tSm5Uhc2YAlKrmDVzYHCCQuh6N/zlYeqL+GAZ0hS1vMVTLhqbcWGsy213D6iJfNL+hXdm
	q+ooTwh/JDiLUowpEZmV/rG3Cmg+UoIALVZyKJ3z5sjMCzfNMOi69yOzX6rMV6f17MQ==
X-Received: by 2002:a5d:885a:: with SMTP id t26mr8682915ios.218.1562128080410;
        Tue, 02 Jul 2019 21:28:00 -0700 (PDT)
X-Received: by 2002:a5d:885a:: with SMTP id t26mr8682875ios.218.1562128079809;
        Tue, 02 Jul 2019 21:27:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562128079; cv=none;
        d=google.com; s=arc-20160816;
        b=F+LnJEZQ70uHv8QzejEQpWK/JssvYLHy4/IV7wGxBhM9jT5TZVK3Ru07VxxTNPV9VQ
         JbHyZUpVYdadED2FLWTk6Pa8Exm99I4GEovMkt9F/5iieVphDKDassWzkQJurY8zXPIS
         GmXzLkbWFZU2FqVMmlo+OKyyG1Ay/Spciem3MUnOAlKLgb1lp47XlBcfKjdk9jj1iMEh
         QTlTJSANvrDcdvLM7TSs4LX+l1qmp8Ap2qpPhXOrODZ4B5eL5ExCnvgp/LDyR37J/YGR
         MetfSSTQ9nIVnBbOshCe4B/ORyoO2QJ8OuvwF6TNXRYLSWrQBUicrdYXNvb6P87QkI3e
         9JWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=d80tB5vk/g0WMCXuJgkvhpG+W/B6ZghkR/JiRF3I5y4=;
        b=djA9dYW6uJ708tWhDrDohCS9sHChTBoOO5eQWv0wQvbpsuTyevVy7WrvOoElqfUBYE
         N2xs8s6uvKiaTEaw2L7f04vBV2y+5vb6sskXN61202FcouaMZCXEAjDhl2KnuoPGZW7l
         /1iLGMGmDtxEbssmkSU/ZBwdNZBOK8JZGjA/6uONvKli7eFQTnnojiO5qRe/trGpFJvB
         GvCwvLCFwkBbP6/o5TNvCHVj4N4ENyI7Ut8loBbdb8sLhsyisXO6rYda1LVM1IEy1i0v
         0H4UTl7Bf52JoxlqJPvv9Xgd5Qne1UiTGH9RL3LeELUCU2dm/+LNSGS7eKxB6H2YsX4U
         EZfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="d+s/TFwx";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u7sor2298818jam.9.2019.07.02.21.27.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 21:27:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="d+s/TFwx";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=d80tB5vk/g0WMCXuJgkvhpG+W/B6ZghkR/JiRF3I5y4=;
        b=d+s/TFwxI9dKwBOhxw5fioCxOcZ43s2Lj4Gu2/KmVFPVdNsHxGhGFARkmmn/l+Li/Y
         hQsRsFItetjhjLuAaNBodZHARML8Lb8u06Q3a/FH9fgxmH1SaNPZ+FGyLgSdV/c/TFoS
         N53gdgVM9reJhpvJhVTdKymCgiAusoJeOgCEfMvOyJQGCAY/bS6BraELR/kLgNUpHfhR
         HZBOtbS2+KJdwvxr26RXV1Spo4hx7ATJ+4rPHKMK65bns9S4rf5Cy12g0S6+OuyGXB5q
         zBilPGxPeUVqNoJN+qaXpntjlg5gOuYwbdkWHLHEMVycnL5Nzkalks1/ewZdUeK626a5
         xsJg==
X-Google-Smtp-Source: APXvYqwIbxN7WucWp7b16bGNTTpbspz9lSquj+IOu70jTyanHE1pCxWGyApPrM+HcIiROGci9/b+hDS9Z/rOir3oIuo=
X-Received: by 2002:a02:c519:: with SMTP id s25mr38095307jam.11.1562128079586;
 Tue, 02 Jul 2019 21:27:59 -0700 (PDT)
MIME-Version: 1.0
References: <1562116978-19539-1-git-send-email-laoar.shao@gmail.com> <CALvZod68TeAJ_CRgZ0fwh6HhHOwrZ9B4kwMHK+kycPmhR4O46w@mail.gmail.com>
In-Reply-To: <CALvZod68TeAJ_CRgZ0fwh6HhHOwrZ9B4kwMHK+kycPmhR4O46w@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Wed, 3 Jul 2019 12:27:23 +0800
Message-ID: <CALOAHbBOKxZKfZSf3-JhNOvM_m9gmYbMT+kNTBCdedOg4=kmLw@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol: fix wrong statistics in memory.stat
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 3, 2019 at 11:50 AM Shakeel Butt <shakeelb@google.com> wrote:
>
> +Johannes Weiner
>
> On Tue, Jul 2, 2019 at 6:23 PM Yafang Shao <laoar.shao@gmail.com> wrote:
> >
> > When we calculate total statistics for memcg1_stats and memcg1_events, we
> > use the the index 'i' in the for loop as the events index.
> > Actually we should use memcg1_stats[i] and memcg1_events[i] as the
> > events index.
> >
> > Fixes: 8de7ecc6483b ("memcg: reduce memcg tree traversals for stats collection")
>
> Actually it fixes 42a300353577 ("mm: memcontrol: fix recursive
> statistics correctness & scalabilty").
>

Hi Shakeel,

In 8de7ecc6483b, this code was changed from memcg_page_state(mi,
memcg1_stats[i]) to acc.stat[i].

-               for_each_mem_cgroup_tree(mi, memcg)
-                       val += memcg_page_state(mi, memcg1_stats[i]) *
-                       PAGE_SIZE;
-               seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i], val);
+               seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
+                          (u64)acc.stat[i] * PAGE_SIZE);

In 42a300353577, this code was changed from acc.vmstats[i] to
memcg_events(memcg, i).
-                          (u64)acc.vmstats[i] * PAGE_SIZE);
+                          (u64)memcg_page_state(memcg, i) * PAGE_SIZE);

So seems this issue was introduced in 8de7ecc6483b, isn't it ?


> > Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> > Cc: Shakeel Butt <shakeelb@google.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Yafang Shao <shaoyafang@didiglobal.com>
> > ---
> >  mm/memcontrol.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 3ee806b..2ad94d0 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3528,12 +3528,13 @@ static int memcg_stat_show(struct seq_file *m, void *v)
> >                 if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
> >                         continue;
> >                 seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
> > -                          (u64)memcg_page_state(memcg, i) * PAGE_SIZE);
> > +                          (u64)memcg_page_state(memcg, memcg1_stats[i]) *
> > +                          PAGE_SIZE);
>
> It seems like I made the above very subtle in 8de7ecc6483b and
> Johannes missed this subtlety in 42a300353577 (and I missed it in the
> review).
>
> >         }
> >
> >         for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
> >                 seq_printf(m, "total_%s %llu\n", memcg1_event_names[i],
> > -                          (u64)memcg_events(memcg, i));
> > +                          (u64)memcg_events(memcg, memcg1_events[i]));
> >
> >         for (i = 0; i < NR_LRU_LISTS; i++)
> >                 seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i],
> > --
> > 1.8.3.1
> >
>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

