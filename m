Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A90B9C43612
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 20:17:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48D3A22342
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 20:17:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="K2mrC1he"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48D3A22342
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C315E8E012C; Sat,  5 Jan 2019 15:17:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB84F8E00F9; Sat,  5 Jan 2019 15:17:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A59C58E012C; Sat,  5 Jan 2019 15:17:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3053E8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 15:17:32 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id l12-v6so10617027ljb.11
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:17:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BRF36iWgYXCowecQCa4ahsuhW8PKhuB6aSQnN1znDbc=;
        b=CtgSaF0OBOB/2ZiCdlCB4S3m+qFnEguA7MKJtGzri/6yg6w/D5l9t/O+U0r0Oqipb0
         9LAN+KQ0xrrovB9CmfNTPBq9UBhhwzpydVqK1TYsxYC559Sr8CV5AurM0IZ6MrdRXP80
         Fm1Q0sRUguM7nzrs4sh4c+MbN7Nk4q6P608crWypsZXEIge2C8QYvLbdRQTwkZNqJbRm
         3lhq8y/ZRz53YMVolaLRlBcS69xm+ntu6Enedl1shXA97nUpvtM5dv62Hb0bpfPqH4Yv
         cPiCtHmvSLolf2Dxkwy6pVXOIKbypxWMCW7opOevnyiu53WPcbBbDEKr3m9d7u3hU2/H
         yyAQ==
X-Gm-Message-State: AA+aEWbTKXOYlHOIml4z9mHiJYAcTB3tgHQu9YZhzyZFJ1qAxfrm94Cf
	F/x78sXlP5WB/fIDd/oNvHFv38m5zwKeQMfv/Gpjex0bjMikzY9Tob8kpUtTji/ngQvL0v3+WoC
	bwJ4PHMvsqIFU3IkSOjgZ2FxSWEQEZj1H4QWMG9nj9PQvUS/AH3vTo4NbhGpAMwNhddjg81zaXT
	ADzyscDRzVslFPPEX3IjU13ZwcofFURJxIWaaHqaw4fn8fWApKTRINk2AeDW6YThDG/jh9gbM/M
	WyPEgAEbasTGEIg0HiZF2TmTVqIgXKCWN+S0Ov7DmDjFqTbwk1HYkd/A4JwZhNB1pGsDMEpkYiM
	RQUxWns88HNYAiVBUTcJq55LWjXvG//wI/zSSo1FtTW3fw18Fdhiszy74QwXnSr8mM6UmLf4fU4
	T
X-Received: by 2002:a2e:5356:: with SMTP id t22-v6mr29617629ljd.26.1546719451585;
        Sat, 05 Jan 2019 12:17:31 -0800 (PST)
X-Received: by 2002:a2e:5356:: with SMTP id t22-v6mr29617620ljd.26.1546719450780;
        Sat, 05 Jan 2019 12:17:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546719450; cv=none;
        d=google.com; s=arc-20160816;
        b=JS5xzsXxYqm9d9ITUIWzYM+UkDaztpKq3j1BmApEkAddZWCDPwgXMj2p6Dlx0MkRZu
         vWFO5DZ2inpQcAH6r7mKQSSfkZp7PIyZAWD+dlvktGR01fpwXvmgvylpVj4CjtgxjkSo
         VHsx+GD0s00lAF/9nmYcEfgHiFmGxonu7Fw4d2ZRWeAKS1Aa3fi2OrSBdjzL8TE8xmuz
         rpdTQw+/Mv2EcMBDaGN/QEzSIMN6U1roQ2tdiiBAbyO3n2rJbQTJC/9AJ1qXCHW8uagG
         aZspJ5yYbMKbpo60DkVAST7KdevZ242Hxrg6du6QgjACrbetu94od0fjaKOmP2QI3K/G
         YYlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BRF36iWgYXCowecQCa4ahsuhW8PKhuB6aSQnN1znDbc=;
        b=NVgC6KhLeDEt7YSK4r4bSwLf+uifLEKf3BLrYiRkfjh/7jOX9dw5buEuA+cV6vwKmd
         BvCOgXiBfHXnXQzF0X28YZFugQ88LYDQgGjmzVuxcZvJsb/46QZvMzlnqMIHuoHVBtw+
         tFb1hPdRasr+REOTs/kQSgwu0JqZ6f5sXIjsIyG5R+21j//sU1bFCL2gBvm6HsPgP5Og
         pC/1jBjoCPHidgHJsB6NImBL5INSNf+X+Gx9yDBHE7tyIPo8SB8yy4cn/OdTa+zrR7YM
         SywX/H6F3Vbarcd2ev31F74hwdl4FmYF/amGXUyeHtR2YlSSUPpBHpLZGRApBmQgffq2
         C8Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=K2mrC1he;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o26-v6sor34356856ljj.36.2019.01.05.12.17.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 12:17:30 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=K2mrC1he;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BRF36iWgYXCowecQCa4ahsuhW8PKhuB6aSQnN1znDbc=;
        b=K2mrC1helUL4L325HY2NrT1I4s0DGh5TZeQoHqBCb4EiGtuS6OMSSMFj/IXj91AApP
         0WIe+9z7ZKrZaj/QnItuCV8+QYEkOSxpr6DSt8xIIp314eWRJzAXpHNi0YCE6TpH5LnR
         EZ7lEPWEqoE21UAsTku9cUmNgSynPP2Ll+JaI=
X-Google-Smtp-Source: ALg8bN6x8bAIzbF378h5FV4sppffw62emlIPJ84xhiV5CS6U9rFnxMRzf4wyL/vmVhM+ezo2w4y70Q==
X-Received: by 2002:a2e:c41:: with SMTP id o1-v6mr31463336ljd.152.1546719449900;
        Sat, 05 Jan 2019 12:17:29 -0800 (PST)
Received: from mail-lj1-f174.google.com (mail-lj1-f174.google.com. [209.85.208.174])
        by smtp.gmail.com with ESMTPSA id c203sm11862130lfe.95.2019.01.05.12.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 12:17:28 -0800 (PST)
Received: by mail-lj1-f174.google.com with SMTP id v15-v6so35085615ljh.13
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 12:17:28 -0800 (PST)
X-Received: by 2002:a2e:95c6:: with SMTP id y6-v6mr10266322ljh.59.1546719448269;
 Sat, 05 Jan 2019 12:17:28 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com> <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 12:17:12 -0800
X-Gmail-Original-Message-ID: <CAHk-=whGmE4QVr6NbgHnrVGVENfM3s1y6GNbsfh8PcOg=6bpqw@mail.gmail.com>
Message-ID:
 <CAHk-=whGmE4QVr6NbgHnrVGVENfM3s1y6GNbsfh8PcOg=6bpqw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105201712.-qTXxiq1Dxg8b_7oJjLnIAKTkbIhOoGIkOPYQ8OVTxU@z>

[ Crossed emails ]

On Sat, Jan 5, 2019 at 12:12 PM Jiri Kosina <jikos@kernel.org> wrote:
>
> I am still not completely sure what to return in such cases though; we can
> either blatantly lie and always pretend that the pages are resident

That's what my untested patch did. Or maybe just claim they are all
not present?

And again, that patch was entirely untested, so it may be garbage and
have some fundamental problem. I also don't know exactly what rule
might make most sense, but "you can write to the file" certainly to me
implies that you also could know what parts of it are in-core.

Who actually _uses_ mincore()? That's probably the best guide to what
we should do. Maybe they open the file read-only even if they are the
owner, and we really should look at file ownership instead.

I tried to make that "can_do_mincore()" function easy to understand
and easy to just modify to some sane state.

Again, my patch is meant as a "perhaps something like this?" rather
than some "this is _exactly_ how it must be done". Take the patch as a
quick suggestion, not some final answer.

              Linus

