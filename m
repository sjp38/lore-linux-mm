Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D55AC04AAA
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 17:44:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3772B20675
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 17:44:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WBoQMI8n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3772B20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 909876B0005; Fri,  3 May 2019 13:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B9A06B0006; Fri,  3 May 2019 13:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A8706B0007; Fri,  3 May 2019 13:44:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5302F6B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 13:44:52 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id k22so179818vsm.22
        for <linux-mm@kvack.org>; Fri, 03 May 2019 10:44:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Eb7/4hKFWccQPeYAcQ+tBEeG3Xuv86Wr0G2bXfLTgYY=;
        b=CYKFryN9z+GDYQVg3ZxrK4/pg4vQndMoP+v+c0850AZUtYHLe8rIv3vCTUA7YLJrgy
         gnWpY9jWsLN4WqatkW1Z+eVxyAMywPERhtwY7JeHi+fvZLBUwRa0DEP9/9euC7L5hQJx
         j+6ECRDyZOaK5VPeOvOHaYyt4cvB+pC0uAkVSwzsYuviPtzjyCtsJBRX0HjTG3W9oK0N
         2WNSdfgwzy3+czLJ1vCRSDJHoqCge4cztoKWW0fa1lD9LBGjDuSYie4DtElOn4m5BQzg
         irrBgbjN+s7r3CkoKGTZE3HzM7aEztpIrBz1fCmgaOzQ88tVGFjERqhR36Q+7b2LeKvE
         JAIA==
X-Gm-Message-State: APjAAAXctJU+NDnyCZBTDT3vfrAlOf/qa8SNQ1upF3ZhIdrKj9/CtGqO
	uHLaWgkFV7C3cfeWaZoYHk9yzvf6e8jfySba/Y9B3xFmptP97qV1zb/d5etLu2mefsX4oZilQ+3
	A6IPm9jzCE5gUPmEFNG8I/bFotPhnbj2mIhPSgvMyW2OtX7wjOq1K6F+5fiXyUKRWEA==
X-Received: by 2002:a1f:8f0d:: with SMTP id r13mr5895440vkd.63.1556905491916;
        Fri, 03 May 2019 10:44:51 -0700 (PDT)
X-Received: by 2002:a1f:8f0d:: with SMTP id r13mr5895401vkd.63.1556905491157;
        Fri, 03 May 2019 10:44:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556905491; cv=none;
        d=google.com; s=arc-20160816;
        b=pHq8/pJwPwaw9Rr1Lpes0nd7AvYzTWAWbRMS4A6cy5FrUOdkWHZRZP+mtVOWgr91yB
         kmyq9x9tuSxoJD8sjsJC+v5CBKmd6GJUTU9aQHDCWZRvQemXk1sK0eURIqvryeCN7+lw
         sryGGlq4TLVv1vsk8z012PQj71HzLaT6SifOzuxIWmCtA6sIWLCLbK6R3/ZQOXhPlQvp
         ftI5VDQEeJ7WL8JcT4a0aR9uhBlad3CDHDIC1nvp3XWywpyRovwlkBwD/hd4xpu97MXf
         EeegWxalq9x2UV7hGh1z3GCSr+od5tYMl1/HJHfLBOCgUJsl6J96QFY/xBLuQ/8UkuZ+
         h90g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Eb7/4hKFWccQPeYAcQ+tBEeG3Xuv86Wr0G2bXfLTgYY=;
        b=L0x0YHTybnTA+bx6GDZILx7FKFTIfEE5FcjG7DDmN3WqIBY3SkeEHbfInK/mgHASvC
         kWEwTe5MYtgFIof81SFxE93ZoVmhDMPVipDSnHVyCHUk2IY0U6s+Zl7QOGqOZUrpl3Vn
         KhCkZe03fHeR7GgEo/MBcAEy3e7kDTHMlBBq6QX79Q2A5cK9mRFw7oPxBwnB90f5S24v
         qNPknqqg1UMv2dnrIQStirkmuQJaRrRQbZGzAnqQm/uS8zVvnjB5kYSALu7XuRoC7MvB
         4lH/qMhc/1bBjXEXA4j1fk5TwZ+g9V3xmWx90627Rs5llDTNONN7Or6vmPTCaoYeR4AS
         F1zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WBoQMI8n;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h95sor1442862uad.60.2019.05.03.10.44.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 May 2019 10:44:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WBoQMI8n;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Eb7/4hKFWccQPeYAcQ+tBEeG3Xuv86Wr0G2bXfLTgYY=;
        b=WBoQMI8n76XRNG937wz4b3Y8tGCUDWk2dMzx/uAgPRb0VxD4EkI6s8+lIG09Cmi8x5
         31LHkXnacwbV63sA7h5+G8JK5I8Fn4svA6MdYZ34m7zomopY7XVsdLc96dS9/v45yxG+
         14gmaZ2fg8VkuB92sSIVGHMBYNQ4ofDqYMOuOjidm69R75p/p8LvuzzG44CZPI3UXlH4
         YlCoYtK+sYv1VYJAhwoZccPemh4yrM7ZxGYhPkAG1ClhzgiFhC4RL/TneekPWF4rAJ8H
         yXFikcjd36zXS2vUzWqltmwSSG7pjzOI9XrnCjkxK3Devm7LCw6X7ZKroc7M5rKjwASm
         DUHw==
X-Google-Smtp-Source: APXvYqy6Umi3GZnui/w256oSDLamokEgeN1ctBgmNjhN0Q/krHayWTf4sb9TeI7LGBIrQklVFLC6neUM0d06yZ+xXtI=
X-Received: by 2002:ab0:1410:: with SMTP id b16mr5072449uae.1.1556905490552;
 Fri, 03 May 2019 10:44:50 -0700 (PDT)
MIME-Version: 1.0
References: <CACDBo57s_ZxmxjmRrCSwaqQzzO5r0SadzMhseeb9X0t0mOwJZA@mail.gmail.com>
 <11029.1556774479@turing-police>
In-Reply-To: <11029.1556774479@turing-police>
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Fri, 3 May 2019 23:14:39 +0530
Message-ID: <CACDBo54xXk-68MTsxw2K12gD0eGO0Xpq0rw60E3AX+2OEi3igw@mail.gmail.com>
Subject: Re: Page Allocation Failure and Page allocation stalls
To: =?UTF-8?Q?Valdis_Kl=C4=93tnieks?= <valdis.kletnieks@vt.edu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	kernelnewbies@kernelnewbies.org, Vlastimil Babka <vbabka@suse.cz>, 
	Michal Hocko <mhocko@kernel.org>, minchan@kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 2, 2019 at 10:51 AM Valdis Kl=C4=93tnieks
<valdis.kletnieks@vt.edu> wrote:
>
> On Thu, 02 May 2019 04:56:05 +0530, Pankaj Suryawanshi said:
>
> > Please help me to decode the error messages and reason for this errors.
>
> > [ 3205.818891] HwBinder:1894_6: page allocation failure: order:7, mode:=
0x14040c0(GFP_KERNEL|__GFP_COMP), nodemask=3D(null)
>
> Order 7 - so it wants 2**7 contiguous pages.  128 4K pages.
>
kmalloc fails to allocate 2**7

> > [ 3205.967748] [<802186cc>] (__alloc_from_contiguous) from [<80218854>]=
 (cma_allocator_alloc+0x44/0x4c)
>
> And that 3205.nnn tells me the system has been running for almost an hour=
. Going
> to be hard finding that much contiguous free memory.
>
> Usually CMA is called right at boot to avoid this problem - why is this
> triggering so late?
>
The use case for late triggering is someone try to play video after an
hour, and video memory from CMA area, maybe its due to fragmentation.
> > [  671.925663] kworker/u8:13: page allocation stalls for 10090ms, order=
:1, mode:0x15080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO), nodemask=3D(null)
>
> That's.... a *really* long stall.
>
Yes very long any pointers to block this warnings/errors.

> > [  672.031702] [<8021e800>] (copy_process.part.5) from [<802203b0>] (_d=
o_fork+0xd0/0x464)
> > [  672.039617]  r10:00000000 r9:00000000 r8:9d008400 r7:00000000 r6:812=
16588 r5:9b62f840
> > [  672.047441]  r4:00808111
> > [  672.049972] [<802202e0>] (_do_fork) from [<802207a4>] (kernel_thread=
+0x38/0x40)
> > [  672.057281]  r10:00000000 r9:81422554 r8:9d008400 r7:00000000 r6:9d0=
04500 r5:9b62f840
> > [  672.065105]  r4:81216588
> > [  672.067642] [<8022076c>] (kernel_thread) from [<802399b4>] (call_use=
rmodehelper_exec_work+0x44/0xe0)
>
> First possibility that comes to mind is that a usermodehelper got launche=
d, and
> it then tried to fork with a very large active process image.  Do we have=
 any
> clues what was going on?  Did a device get hotplugged?

Yes,The system is android and it tries to allocate memory for video
player from CMA reserved memory using custom octl call for dma apis.

Please let me know how to overcome this issues, or how to reduce
fragmentation of memory so that higher order allocation get suuceed ?

Thanks

