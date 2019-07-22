Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF854C76196
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 07:53:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8361E21911
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 07:53:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8361E21911
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E0946B0006; Mon, 22 Jul 2019 03:53:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06B746B0008; Mon, 22 Jul 2019 03:53:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9D536B000A; Mon, 22 Jul 2019 03:53:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF7D76B0006
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 03:53:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so23335847pfw.16
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 00:53:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=qYEjQIUXKnmIer9RQ7tvy8ZB3LufG5iVl43w8nguQ9A=;
        b=rkRRwv2C7gOewOiK52XYT0bcTymrf6BO6qH6LoEP4r4VQtvpJbD86UIs99S0AHxwc/
         OwK7fbQNQYvxAx8awwpqQw9nIMTLqlxBlSrp9jL6m6c17tNhs5FOEilraseC4/4P6iF7
         MrxPknlxkKWtQNzLwD4TAJZfQ3rCPdYeHfn9COmrMvYNzls8GjCM8HSbxPfS6f32Q07L
         oVkL78KkazkFPC/u417wVwHLeUt6IlH9YqUH1uaHdMkCNUm4SMpNxhYokftwV1gjtFI7
         nYEnE13U8vQyxwelgY3Jm0kF3FMtitjwaWp2C2ZQz+ZdLzzDNLxEjTIbTLwGE3zyxs/Q
         jIbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV1EZHMXUqsxJBIGk/xKr1O8wmp46Bg/4NX20zDFk5wWXQhHhhv
	TGlrZyNKKTPOAlQu7ARFhK9fotAFxOPXsQ4Uol8RdPWoTMvmH1lZb8xrb77bXuuV6NC7H7hJAfs
	guxq1oDwg76C6cacN/tsrAmUjKcDyvpDW5+2nYVn1YswJAHbTAfOcPOirXdzWrl/jAg==
X-Received: by 2002:a63:e14d:: with SMTP id h13mr70355870pgk.431.1563781985307;
        Mon, 22 Jul 2019 00:53:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLK5qAh+/krjOwPMgm+RPLFP0zL4z/hLf7aGYgCCgc4/U2YWvkSt4o39bBHIsF8h36wX3X
X-Received: by 2002:a63:e14d:: with SMTP id h13mr70355824pgk.431.1563781984541;
        Mon, 22 Jul 2019 00:53:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563781984; cv=none;
        d=google.com; s=arc-20160816;
        b=YX3sO54qe5iIwy06EW0uenjtEvI053iy45U4MQ5/3tQJUfdm0bwr1Y2ns9cEKlUGFA
         y+Mv/BFngV1epNFLDiB+GAzGOqiclCLzvJj9GHgedR/6bwRLAanfpzgTVzJIv9tg8jC8
         g0Z3hBr0tymm+F9bEdLSsMcCaQyQS/f6gq4+lI39czyJfbCnd4YQDdZproteFSqAPFtF
         znVX0AS0+qyPyoJ18Bf9vOpWl3zWpQBFiaDMXnf15JSeuulBd2yNnnYqjZmsTIIRDPmV
         6GQwow0kxS9gcQpHQwUpdYTSIuv18+B1EVI+RiSrFj9HZrWOFMUlI2bbOfvShl4t+MZt
         DViQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=qYEjQIUXKnmIer9RQ7tvy8ZB3LufG5iVl43w8nguQ9A=;
        b=zZc2M/bOrBB09z0msyP17DUe6yEqx/nm1A3FA0CHwRxWuft1aRCRERi5jHVU0Zf4f4
         do8KCymR95ZcMcIVy7lOdrxWYsfk+71lPeyXmA+ZHkWFDIOWQ4v0eyoOmNUnMTS/zrZ0
         nW0STxH9pKQwzIWtfswGE1HIaYJCsb1h4JRRXpuXRnnZzkcOqvA0CeoxS7oijl5W76Nd
         XnYyY8vx3SSInmS7OSQ0a5PTBiPXhV/4DB2zeFdo5HzYSKWnOXpyQn+WwNZ7pxKAkDEu
         6gkNj8iUdl8BrLSkoa2Y0kcu1hTOQVTBA5YDGIRJrHnkp6Sa/OY+ghOaGvNXgGYlTiq7
         KbNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e96si7820885plb.123.2019.07.22.00.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 00:53:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Jul 2019 00:53:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,294,1559545200"; 
   d="scan'208";a="180323256"
Received: from unknown (HELO yhuang-dev) ([10.239.159.29])
  by orsmga002.jf.intel.com with ESMTP; 22 Jul 2019 00:53:02 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: huang ying <huang.ying.caritas@gmail.com>,  Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,  <linux-mm@kvack.org>
Subject: Re: kernel BUG at mm/swap_state.c:170!
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
	<CAC=cRTMz5S636Wfqdn3UGbzwzJ+v_M46_juSfoouRLS1H62orQ@mail.gmail.com>
	<CABXGCsOo-4CJicvTQm4jF4iDSqM8ic+0+HEEqP+632KfCntU+w@mail.gmail.com>
Date: Mon, 22 Jul 2019 15:52:53 +0800
In-Reply-To: <CABXGCsOo-4CJicvTQm4jF4iDSqM8ic+0+HEEqP+632KfCntU+w@mail.gmail.com>
	(Mikhail Gavrilov's message of "Mon, 22 Jul 2019 12:31:36 +0500")
Message-ID: <878ssqbj56.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com> writes:

> On Mon, 22 Jul 2019 at 06:37, huang ying <huang.ying.caritas@gmail.com> wrote:
>>
>> I am trying to reproduce this bug.  Can you give me some information
>> about your test case?
>
> It not easy, but I try to explain:
>
> 1. I have the system with 32Gb RAM, 64GB swap and after boot, I always
> launch follow applications:
>     a. Google Chrome dev channel
>         Note: here you should have 3 windows full of tabs on my
> monitor 118 tabs in each window.
>         Don't worry modern Chrome browser is wise and load tabs only on demand.
>         We will use this feature later (on the last step).
>     b. Firefox Nightly ASAN this build with enabled address sanitizer.
>     c. Virtual Machine Manager (virt-manager) and start a virtual
> machine with Windows 10 (2048 MiB RAM allocated)
>     d. Evolution
>     e. Steam client
>     f. Telegram client
>     g. DeadBeef music player
>
> After all launched applications 15GB RAM should be allocated.
>
> 2. This step the most difficult, because we should by using Firefox
> allocated 27-28GB RAM.
>     I use the infinite scroll on sites Facebook, VK, Pinterest, Tumblr
> and open many tabs in Firefox as I could.
>     Note: our goal is 27-28GB allocated RAM in the system.
>
> 3. When we hit our goal in the second step now go to Google Chrome and
> click as fast as you can on all unloaded tabs.
>     As usual, after 60 tabs this issue usually happens. 100%
> reproducible for me.
>
> Of course, I tried to simplify my workflow case by using stress-ng but
> without success.
>
> I hope it will help to make autotests.

Yes.  This is quite complex.  Is the transparent huge page enabled in
your system?  You can check the output of

$ cat /sys/kernel/mm/transparent_hugepage/enabled

And, whether is the swap device you use a SSD or NVMe disk (not HDD)?

Best Regards,
Huang, Ying

> --
> Best Regards,
> Mike Gavrilov.

