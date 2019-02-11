Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEA3EC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:08:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 273E721B68
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:08:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="j6UoFsN7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 273E721B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE0078E0137; Mon, 11 Feb 2019 14:08:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C66CB8E0134; Mon, 11 Feb 2019 14:08:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2FDA8E0137; Mon, 11 Feb 2019 14:08:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAEB8E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:08:25 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id l14so9815ybq.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:08:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=udO/CAGWaZzJg7wtfE9Irj4YqoOL3OpYf/G/zEavsIE=;
        b=H6UUcFD+ajwqv1W4RvxTRX+PRyjPoYlthhP8bo5WHDeZnXp5rPVEhafeQbr3ZNwAPt
         clNPk2rknVGM5+nmvd+a6qEJFmEvTrQ7gawlJcZ3i0v3tCL84CCjb72iDuNUDJHyAAAN
         yqzxeZh0h7/S+IQ4TZIjJZ0XHQcC38GHJ0+GzJSyRUcI7SCpZvs3aMAjCUY+XeA61u52
         +CgCQ0oPX1z+5cP9DSOBD+4WaCBa6rOmeUCag03njgZCEs6E2PpdWz1FuRpO67YDoJp9
         4kK7G8zECrkrZxZeQO51iy07uVpEVAqCyNmU3UzMtgkEuX/hXp3UV9ZdjlQsElQ9vFBV
         15Og==
X-Gm-Message-State: AHQUAuZBth06ni8mBMzn5iaR7ZfubDB81iQF/4JJZC9LFUpEWmkCrJmV
	Is/rl9FD7VjcYYTp6rbhp3vE56iSdw0j5+0p/Nnw1xxBbVpR8OuZ9dI/UGeCxTeiv+a31i3FiPO
	dvPnEEmnckS03wjgncNwf+2xtVZc2bb9ulcW6DHCrM9Dtr20pq4R14in3rGHfLWTnsbeZNWEVju
	XTjoBEo4gs91fRn/oCYMaluSJJCNGWl5sF5DEWnmOKp9f/e73sNYCw8ri/qIwsVRLPsy7Yp1PQz
	shjXT/VMkkNf7gZTpvU/Q+099lyybVA8vov0KI/09HQi/qq5GNCbVx+PvHPbuALjFba7lxKxyND
	Z/3SDLK6VEc4+cs45YB2sv1C7t/EL0IshvFsAFw6pjpsXPQTVnRnPEnKnu5lJjhmoYS0UWZR3kU
	i
X-Received: by 2002:a25:38f:: with SMTP id 137mr12639516ybd.490.1549912105286;
        Mon, 11 Feb 2019 11:08:25 -0800 (PST)
X-Received: by 2002:a25:38f:: with SMTP id 137mr12639468ybd.490.1549912104609;
        Mon, 11 Feb 2019 11:08:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549912104; cv=none;
        d=google.com; s=arc-20160816;
        b=aKYMkW0VeQGrCM/JXoKCD36/gATQS8YgllvXJ0k20y2GmtKBGGvAynrM6a24emGnjy
         EPCiHe/k2JzqYBCw1RCrSF2Q+xFJVmle/ut7MEpflxiCqTi10tpV6tH/jY78sqASlwJ6
         9LCMON0mL+gO3tSRSKRYjr0x4tZUXwiOCQfuss9XNTLNEzRUQZibSQuOAwcsScy10j9q
         ugaL7rhqUARjaIVzxX9m+HPtW+bi7c+/cLwQfsqBjUW/DNuxWaXfjehzxSAUQ9JJCfuT
         lpWbLUXTAyHpoWznLRk/UOQqntJsAILTuI+eteUK6MIb6HTbsZAmZaH3gS47nTBhfYnu
         yl3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=udO/CAGWaZzJg7wtfE9Irj4YqoOL3OpYf/G/zEavsIE=;
        b=oZ3k6F7noB+7oMnKY6aU0Or3/5IXsk4tcNbeNEHZ9/SKzyVADpcs+vckzI0dUys2WM
         +UDbyPfH/c/dYQaTTOYwXSYsgGWoR4b7scWns5TAY9YfzsiIhz1lUfyXTraOL4/MurzU
         LWzWAlcvcCOBD0PVxHX/2SiRWNpaUmbiVc2RRub+poaYy6/jvPgjmcpo0XA32dHCHCpT
         JVw1/KTQWohwZjdw35LZd8Vf1fLRRyEglKj0Pg5UlUROWHfAiqePkmKd2XgKK1cnDkGh
         2oeI79ee30eyvTis1BtDKpQk2fXnySMYCYAvv2OdUOt6T0RSINiK/xGUlF/VHsstCB7o
         G1+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=j6UoFsN7;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o131sor5519989ybb.23.2019.02.11.11.08.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 11:08:24 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=j6UoFsN7;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=udO/CAGWaZzJg7wtfE9Irj4YqoOL3OpYf/G/zEavsIE=;
        b=j6UoFsN7aS17EQdpvoIwl3GmHKJPT9x0KBUHG/lcN55cD57f7aGYEPbpO4lglC8BpM
         Eln0inWNeahjKWHTKbGF/ZJUgoYQFxyZ2HJ6xB4wL3Y1FXeO/t+hlRFAb0ChHAki5ZxB
         t7+BidMid3Pq/EanAvvb7J5zWr156RypfhJNbEEfIhRN5z/trpBjWQDMWRCYkLUOlg46
         ECrTCBk4FPnLdfvNqB0Eu7wAa32ZXHQWNByHdDNSyDqhQmxavEUarPHUvuccNn8ZU5wE
         rAHz1aPyQ6XNyK0puQDt1u8NTPqVFDz/T3i/D3JDsokEUQOnYvt2t2MjDxMdQ0U/YT9G
         a+FQ==
X-Google-Smtp-Source: AHgI3IbJVWvvHfQxjFYRfbjQtGMyT/wbgVp6ZciqD9On+75HOuIbku0rWi0uxMnuB+3SaB8uOGQinA==
X-Received: by 2002:a5b:947:: with SMTP id x7mr12939985ybq.116.1549912103883;
        Mon, 11 Feb 2019 11:08:23 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::5:6e5])
        by smtp.gmail.com with ESMTPSA id 127sm4136207ywl.1.2019.02.11.11.08.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 11:08:23 -0800 (PST)
Date: Mon, 11 Feb 2019 14:08:22 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, Roman Gushchin <guro@fb.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] vmalloc enhancements
Message-ID: <20190211190822.GA14443@cmpxchg.org>
References: <20181219173751.28056-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219173751.28056-1-guro@fb.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These slipped through the cracks. +CC Andrew directly.
Andrew, if it's not too late yet, could you consider them for 5.1?

On Wed, Dec 19, 2018 at 09:37:48AM -0800, Roman Gushchin wrote:
> The patchset contains few changes to the vmalloc code, which are
> leading to some performance gains and code simplification.
> 
> Also, it exports a number of pages, used by vmalloc(),
> in /proc/meminfo.
> 
> Patch (1) removes some redundancy on __vunmap().
> Patch (2) separates memory allocation and data initialization
>   in alloc_vmap_area()
> Patch (3) adds vmalloc counter to /proc/meminfo.
> 
> RFC->v1:
>   - removed bogus empty lines (suggested by Matthew Wilcox)
>   - made nr_vmalloc_pages static (suggested by Matthew Wilcox)
>   - dropped patch 3 from RFC patchset, will post later with
>   some other changes
>   - dropped RFC
> 
> Roman Gushchin (3):
>   mm: refactor __vunmap() to avoid duplicated call to find_vm_area()
>   mm: separate memory allocation and actual work in alloc_vmap_area()
>   mm: show number of vmalloc pages in /proc/meminfo
> 
>  fs/proc/meminfo.c       |   2 +-
>  include/linux/vmalloc.h |   2 +
>  mm/vmalloc.c            | 107 ++++++++++++++++++++++++++--------------
>  3 files changed, 73 insertions(+), 38 deletions(-)
> 
> -- 
> 2.19.2
> 

