Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDDF2C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 14:04:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 988282173E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 14:04:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 988282173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EEE08E0003; Mon,  1 Jul 2019 10:04:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A0268E0002; Mon,  1 Jul 2019 10:04:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 167CB8E0003; Mon,  1 Jul 2019 10:04:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id BE9498E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 10:04:36 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id b33so16845526edc.17
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 07:04:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VT2epvKVE0YN6pZ3f9gcT8fF8272T/apqXmry1qq8C4=;
        b=hF+4XwlhEn6OFZK02Mc/bn5uEV7fya8Y45nBIAJT15LqgOXVMNN9tjsMNL+qsWomd5
         BLZDI6bEBIkl+OsLT1iapICWLr/z4/qXvxJZBLqBAQcjEZ94rhIPhnvvG+1t6O/tSK1D
         k6MMmVtoLfCjEq6zzQ7vl73+YlRpIvx6JBcv8kbNVRqOl6TwLk24QnBxzBEG33428vbm
         M6J7qAxdPaiq/U7gmAA/MsInsFyVEX6ZAGG//p7uI7gICjpmk/mg9B8JWrnMzhsUJpv8
         IewumzMAZc1x7BsxPgEBFP8BIGNESjoc/Ew3mAnZa+/IML1cCx/xE8w7K2YJ+yfs00bG
         LG0Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU09uI98v0d4ILlYv33i3I9JWJ1wdUK0zZ6m/lPbn3WNtyMZWLz
	MWYYhQsfyWNLPsjyKhI3UB1LU9Cl8eWxMizwJuD1GcUZ3khVt1k4ZLYBJtluK4xjZhQFVI6slbz
	0soo2Ie4zXuUBY5k7D04d43dSrUg+19USevPibzllrrXlP283A4LL2ulhJHIKRPY=
X-Received: by 2002:a50:b362:: with SMTP id r31mr29932003edd.14.1561989876313;
        Mon, 01 Jul 2019 07:04:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyRNyBxtRaRLD3M9GelWcsLCDp2BRrQBI21wbHsjQ1JosF6DJDEBvMhLHXp0js2VrY9fZG
X-Received: by 2002:a50:b362:: with SMTP id r31mr29931889edd.14.1561989875474;
        Mon, 01 Jul 2019 07:04:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561989875; cv=none;
        d=google.com; s=arc-20160816;
        b=fbAL1PX18QppJxr3d3M4wW/otT/qR2krc8L/Hh7NYKWKEP54JfNaU9kV+b4Sg5Y62O
         mfBp8GWlYgQlyfAfh1NtxhYjM2JF4kkjfyUYcnBDwDgv8LyDKpZaZv6+6atuq4Y2kiqz
         KUTbCTmsUkc0RJFwDTKPK1i8r3I+6WYHBAcjhZMvQcH7jPbFhAw/GDa0z7gDdaODMBGz
         oxXbLSF9b/CGTcw3yImShQr1F/FQYx896caSLlIRhEJxkqUzd3865eS6Oaqvo+7lMl/2
         Af1kMP9udPRfOn0ln1+wzcUd2RQQSt2/AkTIGnjbMCJGWxDY5S9/8R2jl6Lv2c2PNu2t
         h92A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VT2epvKVE0YN6pZ3f9gcT8fF8272T/apqXmry1qq8C4=;
        b=0R7GDL8JBfPAvRP3AsfKwBD64KHkg8hRPpUN1ojkryWxDuAdJb7TEfMUaQ/xLSYEY3
         rUP9JwQJ29SZ07fsLxO5E2pP3vVsM8RgbqDeOSq4kP4am1IfHQOA+lA1GXXoF6rdmF5g
         p2kF+pBM2I7qrmezqQ2WCvwcEYjKwsuF2eu0MFtmmDSUD08iElcQbmgnX2forheeFk6o
         Gj6tzyZ18jyB6PaXTaSqSXraOZ5dj2cyET1cc2o7jKUa/11r5yayBu84VigPUiYVwTo/
         7bM+lJsXMNT8D78fMAaSrmmWHPm6asZLyUPVqLXdhBrwNZa8uWR2NvVdOMocWJtP2c5V
         Wmbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d52si8699164edb.161.2019.07.01.07.04.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 07:04:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D7AEBB016;
	Mon,  1 Jul 2019 14:04:34 +0000 (UTC)
Date: Mon, 1 Jul 2019 16:04:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
Subject: Re: [PATCH] mm: mempolicy: don't select exited threads as OOM victims
Message-ID: <20190701140434.GA6376@dhcp22.suse.cz>
References: <1561807474-10317-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190701111708.GP6376@dhcp22.suse.cz>
 <15099126-5d0f-51eb-7134-46c5c2db3bf0@i-love.sakura.ne.jp>
 <20190701131736.GX6376@dhcp22.suse.cz>
 <ecc63818-701f-403e-4d15-08c3f8aea8fb@i-love.sakura.ne.jp>
 <20190701134859.GZ6376@dhcp22.suse.cz>
 <a78dbba0-262e-87c5-e278-9e17cf9a63f7@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a78dbba0-262e-87c5-e278-9e17cf9a63f7@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 22:56:12, Tetsuo Handa wrote:
> On 2019/07/01 22:48, Michal Hocko wrote:
> > On Mon 01-07-19 22:38:58, Tetsuo Handa wrote:
> >> On 2019/07/01 22:17, Michal Hocko wrote:
> >>> On Mon 01-07-19 22:04:22, Tetsuo Handa wrote:
> >>>> But I realized that this patch was too optimistic. We need to wait for mm-less
> >>>> threads until MMF_OOM_SKIP is set if the process was already an OOM victim.
> >>>
> >>> If the process is an oom victim then _all_ threads are so as well
> >>> because that is the address space property. And we already do check that
> >>> before reaching oom_badness IIRC. So what is the actual problem you are
> >>> trying to solve here?
> >>
> >> I'm talking about behavioral change after tsk became an OOM victim.
> >>
> >> If tsk->signal->oom_mm != NULL, we have to wait for MMF_OOM_SKIP even if
> >> tsk->mm == NULL. Otherwise, the OOM killer selects next OOM victim as soon as
> >> oom_unkillable_task() returned true because has_intersects_mems_allowed() returned
> >> false because mempolicy_nodemask_intersects() returned false because all thread's
> >> mm became NULL (despite tsk->signal->oom_mm != NULL).
> > 
> > OK, I finally got your point. It was not clear that you are referring to
> > the code _after_ the patch you are proposing. You are indeed right that
> > this would have a side effect that an additional victim could be
> > selected even though the current process hasn't terminated yet. Sigh,
> > another example how the whole thing is subtle so I retract my Ack and
> > request a real life example of where this matters before we think about
> > a proper fix and make the code even more complex.
> > 
> 
> Instead of checking for mm != NULL, can we move mpol_put_task_policy() from
> do_exit() to __put_task_struct() ? That change will (if it is safe to do)
> prevent exited threads from setting mempolicy = NULL (and confusing
> mempolicy_nodemask_intersects() due to mempolicy == NULL).

I am sorry but I would have to study it much more and I am not convinced
the time spent on it would be well spent.

-- 
Michal Hocko
SUSE Labs

