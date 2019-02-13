Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EC22C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:53:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A8A2222BB
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 11:53:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jNm8iNg4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A8A2222BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E44FF8E0002; Wed, 13 Feb 2019 06:53:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF5118E0001; Wed, 13 Feb 2019 06:53:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0A438E0002; Wed, 13 Feb 2019 06:53:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id A2B608E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:53:42 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id 32so1742559ots.15
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:53:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jvq0Zkpr6j163wiU3p6fHAaRG9FV/q6Hd6SR6mC03RY=;
        b=YOiB6WRF8fxewzdcx0MPsL6Qt/6oe78NijbIKZE7DOgbFGZrNt3BeFcz6Lgyz47wV9
         jga5Okn2MDYpGGUe73/UpD8XTgT1ZVuVmG+vjOLg3R7LHHHb/MuV5vXHqmbu2c/kISvE
         B9ZktOJ5Lvhz5/e4pGsJb7V1fZrTSM6VGUG8yjPYynu5/+PsndW0hOpTZQIFU4brVXmT
         yX35u/l6+giTJfeIw4pZ8FlNf6kgUSfBHa3kPdzhRfHtrNLKjaHfkylmfLkpL1Zfl6Pn
         DvPWf8bd9iCbqmXD4Q9U/WrdhNuVOTTwyKE7IThwFWkxlCIUYFOt0hyliBrp0QIa1gLD
         nx+g==
X-Gm-Message-State: AHQUAubHGpNEILiGjiOxlusDHrAfgGaNtmYpHM/TtZfKgUj4lXytgJ5z
	CWxt7u/y39g+JsLIvdQ0NJTgiRF4714m0FRDE+71bzufCNQcUnV6eon4adKKGPA45Z9+4vBTXTo
	ae1qzRuh/hRdL61ZlS+NjWEVRtY6IwJhlhSUrasbi+79IB1hTwVnMU+1QMAzrL1STrHwFsvOnss
	rChontnncRQ8ZqgeluPVwQONz2Bu5SLZgYpTULv7wTnsFDuAzsFMwApXUySzb2du+UTmVlSzeiW
	2CFkVHz+quWb8+oY95aQMuK8nM5ILznS+MGk+TEHWjXRhskRhV1+rtCl5ana+8coDb0Ki5VZeA+
	/s3WWp5JDjqx/M7E8639lc86tgxO7a1ZjuqWnXjcVUU09IX3bSCsOBjzcV2x2p51MtNhW45zYrb
	F
X-Received: by 2002:aca:3c83:: with SMTP id j125mr26119oia.34.1550058822273;
        Wed, 13 Feb 2019 03:53:42 -0800 (PST)
X-Received: by 2002:aca:3c83:: with SMTP id j125mr26096oia.34.1550058821687;
        Wed, 13 Feb 2019 03:53:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550058821; cv=none;
        d=google.com; s=arc-20160816;
        b=Kl+ywLuKtMS2beTC2lNTRAPyEAZSpLqTpUxOxmjDOMULNHtlHyDCV9O0vJUBnrwj2J
         PVnYQdlz5bMPuSjt7FvgWvidlDMQqirlv6XauugM9C5lguQWJn00Cg8te16eZa2GaIMM
         JucK7X1E2ccDutZfUowY8rUCvktxjftvo1/uB34cWj5jQt5SIEei/27Zoosg9CaFiQix
         YPIeELMeeFjYEANtTiVhNbLvHN7qceu3L6puRCnoYXWJF++ev6AiRrEtcgGK/iCULJXa
         xguGfE702wo8p52PxixqJuWtpIXpjhHsrgRI4UvWf2ZgcR+oxcAagA/k4XGUQjq01Rcj
         pc4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jvq0Zkpr6j163wiU3p6fHAaRG9FV/q6Hd6SR6mC03RY=;
        b=Pv7frNAZJF9uT9QGi4haKGydqKE2SeJMSEtYaUAGEoZYdgWu/53dmMSMbtkpOvO9zC
         zPt3hFxwUH1U0Oee1joXZTomtd752X/rqCips4YVqUgPV7eB5wxSeIN6k1VX7mDatWiX
         q6jCWT+B8Xi7lQlsNLNugfdhgQCzn9bfTwRwvTFVICZxGul2UlcDBjcd8aMHtKFdESdn
         gHBB4Z92G+xaK8yUFdRZYVZJD/8mmgu8IGJB8jKozYrA1D+7CxXtwjAn5JGTuUF89z2f
         4dT7M19hlY+AOitvTnO5KJAm9pSDxUblUoDY6sTHIN3DZqQS9XUzX1DrWxCT0yirz8Vs
         ojVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jNm8iNg4;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h81sor3931902oia.0.2019.02.13.03.53.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 03:53:41 -0800 (PST)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jNm8iNg4;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jvq0Zkpr6j163wiU3p6fHAaRG9FV/q6Hd6SR6mC03RY=;
        b=jNm8iNg4jboakWKdoucYa4FBmesPTI9dGUAybzUyC8cBSMhWxVXkXpwnVw/gtkyW+5
         Ue+DSfd8BYEHAgQKNNZ7Ecrid2RPTRkaZdlSL44e5mt0YnQ/jvs8TxEMTEPJlkte6VL5
         wr928XiRtsy55VRRO9WMvfu9EQAegm5OudjmRGx0D0cW23FLwNsgTu2Ph5bxmE4GwWXi
         zO527a8oPSkyTVJh6tkDL4xUM79BpblsWTBpmYWghLbyLWRPx20srjD2BRcrSj1Mi2bi
         VZ5oLvNA2swlDljB4xH3nFL9uguGMSXnrXfhB6o6IhpJ80Yc43NfL2w84yeuZ4IqfuvD
         bFTA==
X-Google-Smtp-Source: AHgI3IZer9r+oLg0pnb5FtgPSF/BOrOyzTptJoZaLqs5K+lbuVPKJBdtSB8oDjq5VnGK5m6MEerbmTB904E61JiT9xU=
X-Received: by 2002:aca:e003:: with SMTP id x3mr3538oig.39.1550058820973; Wed,
 13 Feb 2019 03:53:40 -0800 (PST)
MIME-Version: 1.0
References: <20190211163203.33477-1-jannh@google.com> <20190213114724.GA4525@dhcp22.suse.cz>
In-Reply-To: <20190213114724.GA4525@dhcp22.suse.cz>
From: Jann Horn <jannh@google.com>
Date: Wed, 13 Feb 2019 12:53:15 +0100
Message-ID: <CAG48ez2-Y-QuYOHvcEiBcgFq46C-ZeCqZg9+7KRaOhE-AmQ4mw@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: fix description of treatment of the hint
To: Michal Hocko <mhocko@kernel.org>
Cc: Michael Kerrisk-manpages <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 12:47 PM Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 11-02-19 17:32:03, Jann Horn wrote:
> > The current manpage reads to me as if the kernel will always pick a free
> > space close to the requested address, but that's not the case:
> >
> > mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
> > -1, 0) = 0x600000000000
> > mmap(0x600000000000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
> > -1, 0) = 0x7f5042859000
> >
> > You can also see this in the various implementations of
> > ->get_unmapped_area() - if the specified address isn't available, the
> > kernel basically ignores the hint (apart from the 5level paging hack).
> >
> > Clarify how this works a bit.
>
> Do we really want to be that specific? What if a future implementation
> would like to ignore the mapping even if there is no colliding mapping
> already? E.g. becuase of fragmentation avoidance or whatever other
> reason. If we are explicit about the current implementation we might
> give a receipt to userspace to depend on that behavior.

You have a point. So I guess we want something like this?

"If another mapping already exists there, the kernel picks a new
address that may or may not depend on the hint."

Unless someone can come up with a nicer wording for this?

