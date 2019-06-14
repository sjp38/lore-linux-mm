Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7769EC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 05:58:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D7292082C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 05:58:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X10iTjf2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D7292082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC5176B0005; Fri, 14 Jun 2019 01:58:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A755C6B0006; Fri, 14 Jun 2019 01:58:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93FB06B0008; Fri, 14 Jun 2019 01:58:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 742966B0005
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 01:58:48 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id r27so1487001iob.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 22:58:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=xfMl64b1l75nsr7xDRm1WoxO8Sbiny9xMn/Q+sskA88=;
        b=GMjq3uBIN75jsiKEw2ZDydxkHgIL9ouqsthe8jcPwlBZ0egHJS4Y8++KuTIy9AEw+1
         V+fW0wDZvqaL/2P6wNASAFknJYc7mTUioO+c2SfV6L5FieDXY/91xZt3B9U+2v9jKHCA
         B5zqwuWK3Muay8p+xot3vE/bmhkS1c5LChque7S0gJZhPaytj/vTJGBekj5d9OuaEf8u
         TyAshjE7RtmEGQUY7bB8gXMPvtVS6eW/ThY3fJIJoN22WTnikuuuw9DCymgGowUcX31o
         ATcgqdi9GEg+FX0ojVR3w9c7BrFPy5vOBnuqILKE4WoXD8ZY/bBp7JxbtEE8iE+63hua
         4QOg==
X-Gm-Message-State: APjAAAWtjuTRQbtyXB8iGZZczXryY2N3BPzbnHhoywq746td3dAQs+0e
	L4m1JI3ghTJvDG+GG9Wvb5acwqey33MNO8bvRbm+Of0ut0oQapXCTbZ4B0rnNOfgB8jPH3FXnXh
	eEtM8dz4drLXtksOTpvpZwez19TyLHvC6btP+NxHu0GgnkHbnizb/s+rHA7JDnvDY4A==
X-Received: by 2002:a5d:885a:: with SMTP id t26mr1375923ios.218.1560491928208;
        Thu, 13 Jun 2019 22:58:48 -0700 (PDT)
X-Received: by 2002:a5d:885a:: with SMTP id t26mr1375886ios.218.1560491927430;
        Thu, 13 Jun 2019 22:58:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560491927; cv=none;
        d=google.com; s=arc-20160816;
        b=N5gfYGmB12/76+mkzbQ3JpRcW+zsV5kpdE1haWKpZwFTMBb8tpok2vol2ZjPzjYhR7
         /pIxQM2NVc6dESSm/cL7pscLRmGP2K0BkNPdtSy9rpJ8o3GxVlPUblpDgWbylaNsCOQi
         eaubcUHc5xrbhlahWqW9n4yXVehaJIc4tiQhyKwjoWopXnz3/Jh7wNSr7ex9GDee0v0E
         Xy+LRfCqObp9E2kC9ROtkf33WMT6TG11PNIqFLBBtpotoVx8DcQnqDZzDRZYpe16XiU0
         HLvoGkdnSFjjeYKTJqsPsQxlHQoKut9hzEG+Lx4MPUj6ZfEpO96PiiWajlsafh/dDcnw
         rVGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=xfMl64b1l75nsr7xDRm1WoxO8Sbiny9xMn/Q+sskA88=;
        b=lJ4YKL2JDs+mehCg+/x/WcvQFL0LgEwJpkTYK+Yo9uypNARW8sbR56FN3On2k3JASD
         nKJWXd5xx3nkoXl+ZMsoiPbytC5Gw8C2WRynP/zP1x7d2WIRzbk64uJL1OTCdrJvtfw2
         eOYxKbY1nZrq8zQWMhTN2GGjZjGljiVneMoSBKA5k9Q6syqcrHGLaR2If3tENTEbda31
         L+9yzj1ZldJLkbwkLrXmI1g4xcriUrJoWyUZZ7SWSVLxiUfv/AbRrzYynPyA5MhQihW1
         7UjtvsrYXw1BnMYpacW4f+pnflimxk0tuR0DiYCOMK54yFS6dRKEl0RrdAgJDT+LEGSn
         InKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X10iTjf2;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q12sor1417543ioj.143.2019.06.13.22.58.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 22:58:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X10iTjf2;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xfMl64b1l75nsr7xDRm1WoxO8Sbiny9xMn/Q+sskA88=;
        b=X10iTjf2YAh/l8wNceM7dmieEfVyTVpJybUYZSp2dcBcDuUSwtgKjZIXAJvg6sUYat
         QaelgX0303nRzD6LZDEILXFJC+Uqj7VCwwzG8V1WcLuTsn53NnKYIe3HMAlaMfBRa1mg
         1PX9QYmx2R0cle9/dMfdqfdrPYs2F141+DMjtfFk844IL8MaTFfYctMKVfogCkKMMvgT
         uKK34ZYySqS1bzdm5ntqIzSpXPoi3n4b+TFnVz+MCxM+c9S9nhp04wMyEgKvnzrYBWo7
         +D+z2Xt0ULa9/lHzEFP2YL3XP6UmG9+RnNFgXia043kPqFVZemjE4FTRRdFVc0+oc9Xd
         aF6Q==
X-Google-Smtp-Source: APXvYqzaQi3CocQJKKKC+kLD0gjwexch9vLNaX2TcAYrgaOKwf3+Vj1MzFZyVc/gtKXN+jUu/n3a/sSW9G4Tx9wv3rY=
X-Received: by 2002:a6b:3b4d:: with SMTP id i74mr21644007ioa.207.1560491927200;
 Thu, 13 Jun 2019 22:58:47 -0700 (PDT)
MIME-Version: 1.0
References: <1560434150-13626-1-git-send-email-laoar.shao@gmail.com> <20190613185640.GA1405@dhcp22.suse.cz>
In-Reply-To: <20190613185640.GA1405@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 14 Jun 2019 13:58:11 +0800
Message-ID: <CALOAHbB=sd0y53Tr6b7C41-bF+k1v292ULss64BrdCEySxTRiA@mail.gmail.com>
Subject: Re: [PATCH] mm/oom_kill: set oc->constraint in constrained_alloc()
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	yuzhoujian <yuzhoujian@didichuxing.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 2:56 AM Michal Hocko <mhocko@suse.com> wrote:
>
> On Thu 13-06-19 21:55:50, Yafang Shao wrote:
> > In dump_oom_summary() oc->constraint is used to show
> > oom_constraint_text, but it hasn't been set before.
> > So the value of it is always the default value 0.
> > We should set it in constrained_alloc().
>
> Thanks for catching that.
>
> > Bellow is the output when memcg oom occurs,
> >
> > before this patch:
> > [  133.078102] oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),
> > cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=7997,uid=0
> >
> > after this patch:
> > [  952.977946] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),
> > cpuset=/,mems_allowed=0,oom_memcg=/foo,task_memcg=/foo,task=bash,pid=13681,uid=0
> >
>
> unless I am missing something
> Fixes: ef8444ea01d7 ("mm, oom: reorganize the oom report in dump_header")
>
> The patch looks correct but I think it is more complicated than it needs
> to be. Can we do the following instead?
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5a58778c91d4..f719b64741d6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -987,8 +987,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  /*
>   * Determines whether the kernel must panic because of the panic_on_oom sysctl.
>   */
> -static void check_panic_on_oom(struct oom_control *oc,
> -                              enum oom_constraint constraint)
> +static void check_panic_on_oom(struct oom_control *oc)
>  {
>         if (likely(!sysctl_panic_on_oom))
>                 return;
> @@ -998,7 +997,7 @@ static void check_panic_on_oom(struct oom_control *oc,
>                  * does not panic for cpuset, mempolicy, or memcg allocation
>                  * failures.
>                  */
> -               if (constraint != CONSTRAINT_NONE)
> +               if (oc->constraint != CONSTRAINT_NONE)
>                         return;
>         }
>         /* Do not panic for oom kills triggered by sysrq */
> @@ -1035,7 +1034,6 @@ EXPORT_SYMBOL_GPL(unregister_oom_notifier);
>  bool out_of_memory(struct oom_control *oc)
>  {
>         unsigned long freed = 0;
> -       enum oom_constraint constraint = CONSTRAINT_NONE;
>
>         if (oom_killer_disabled)
>                 return false;
> @@ -1071,10 +1069,10 @@ bool out_of_memory(struct oom_control *oc)
>          * Check if there were limitations on the allocation (only relevant for
>          * NUMA and memcg) that may require different handling.
>          */
> -       constraint = constrained_alloc(oc);
> -       if (constraint != CONSTRAINT_MEMORY_POLICY)
> +       oc->constraint = constrained_alloc(oc);
> +       if (oc->constraint != CONSTRAINT_MEMORY_POLICY)
>                 oc->nodemask = NULL;
> -       check_panic_on_oom(oc, constraint);
> +       check_panic_on_oom(oc);
>
>         if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
>             current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
>
> I guess the current confusion comes from the fact that we have
> constraint both in the oom_control and a local variable so I would
> rather remove that. What do you think?

Remove the local variable is fine by me.

Thanks
Yafang

