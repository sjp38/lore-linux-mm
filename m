Return-Path: <SRS0=BwCX=U4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59BDCC4321A
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 16:45:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF4B120665
	for <linux-mm@archiver.kernel.org>; Sat, 29 Jun 2019 16:45:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF4B120665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=perches.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CC456B0003; Sat, 29 Jun 2019 12:45:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47D188E0003; Sat, 29 Jun 2019 12:45:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 392728E0002; Sat, 29 Jun 2019 12:45:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f205.google.com (mail-qk1-f205.google.com [209.85.222.205])
	by kanga.kvack.org (Postfix) with ESMTP id 1A55E6B0003
	for <linux-mm@kvack.org>; Sat, 29 Jun 2019 12:45:34 -0400 (EDT)
Received: by mail-qk1-f205.google.com with SMTP id c1so9771006qkl.7
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 09:45:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=mmNnrGJ4iPn/XNLkh36mhMegpzuq5dGijH4DxmwDTek=;
        b=iTe6E6GayYEQsavK0Af1+K11Tcr7fw67nKwsl/JSxBVmGCkW7kIg8Nq85kBPjRgLjr
         Mkn+nN5DV1vqZU5IiMXX2YZLypVBLsfxJueeF2dqKmpKW4rsdkhI/R4ROSAafIKGzVFm
         AhxSiVcAsN6++ZcksdEkEJhLb3BwzACwDR3BGvGVvm5Md4Yes8aNSXB4pwX1wdZabdTE
         COBiD/as4lRy81MbkvJ6syoZZN68hSa1TmDSSro0+PKX25E85sELzUNRCL0l04NxDOu5
         c/XFTpSfrBawRalKHI8OXvfWKKf2Lop2fvmcFS8h2hwgkFVvTKeyhVUoEs640ndMVAdN
         Q17A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 216.40.44.42 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
X-Gm-Message-State: APjAAAX7/dQnlstUIe55GhcktwGOrAt7rjG4UtvBSrR+T5cfxlAmHmMF
	XNZCIoyVyBcPpP0q4jq4yHo4jxFYFjAj06rOy3JKhxQkhUtlyTMVVlK/hzct894h57RXH76vnp8
	MwSDhde6rBfM/FsGgL0b9zwOLbjTdaGjc9wfstfvTRmukPCvdDPRMSOK2VJqSrLI=
X-Received: by 2002:a37:8604:: with SMTP id i4mr6577508qkd.255.1561826733857;
        Sat, 29 Jun 2019 09:45:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy35zStseaCFplSz+bmDReEO9Q7OwSosQuMWdC5gS5TixezjWCF5XV+QYFLA48TwVsP6b4x
X-Received: by 2002:a37:8604:: with SMTP id i4mr6577468qkd.255.1561826733156;
        Sat, 29 Jun 2019 09:45:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561826733; cv=none;
        d=google.com; s=arc-20160816;
        b=O/PXFIAmHVxG39hQ8Wb5GxDYcNLXI1T5HHa0ON/vIITyjcr1LUML3YFyCYnqqXqS1c
         Z9outV6KsYZbPDcYF2Jiybj8UkWlzksNAPG6x0w43DbO02mLXfSbNLGHlwF+ZfQOYXEM
         f77KwVvGU2NMmAN1Ol+YGmy4g0bbMhW5BPb/+VIm3l+0Dq86Zo9yKj8utMcG6QLcRtfd
         6H6alSBvy4HV+ORfDpPL37sLZnreYT3zV5eBED0zeML3/+Aki8H/NQZIWXGJle542/Cq
         YdAMkf9KOd7JIsP1xYiqy40SPVn66QeJiGJAl1j37Ay9gvUiusC5mzv77fYAIvGsXFdv
         dGwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=mmNnrGJ4iPn/XNLkh36mhMegpzuq5dGijH4DxmwDTek=;
        b=sjEnc6xJfDuDAyWi0EeFBSBzmJTS1LYzYOONvCueLy0UiL/Qxr28EVa9S6FJU/rbXb
         a1gziZsF61nfWv0ZC1nfWOsqAI59MLPuaoXl8ukxs8YySmfZCs/6BOGctc2q6gRkaVNU
         uAr4wy6KI+qsHTyko82p28EfD47xDv47eB13U5tITPPvGP38u6ByrVM/JEHgqpC3Gvzl
         0dOJlsrmv9XvHfRcjBhyOtkrxCo0Gbv26BTUvjuV66COmB/8BbUJ6rupjkCBbBEujnWx
         0rR4fPqDiGdO4W26LbxliJRqZT8WLBWvXL/0Y6Ng+tT+5HwHH2Giw/sSBXQ5GYA7VB8X
         ZhdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 216.40.44.42 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
Received: from smtprelay.hostedemail.com (smtprelay0042.hostedemail.com. [216.40.44.42])
        by mx.google.com with ESMTPS id s43si3881052qtk.69.2019.06.29.09.45.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Jun 2019 09:45:33 -0700 (PDT)
Received-SPF: neutral (google.com: 216.40.44.42 is neither permitted nor denied by best guess record for domain of joe@perches.com) client-ip=216.40.44.42;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 216.40.44.42 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
	by smtprelay08.hostedemail.com (Postfix) with ESMTP id 72872182CF666;
	Sat, 29 Jun 2019 16:45:32 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: wood26_67b7f2b025644
X-Filterd-Recvd-Size: 3038
Received: from XPS-9350 (cpe-23-242-196-136.socal.res.rr.com [23.242.196.136])
	(Authenticated sender: joe@perches.com)
	by omf01.hostedemail.com (Postfix) with ESMTPA;
	Sat, 29 Jun 2019 16:45:12 +0000 (UTC)
Message-ID: <c3b83ba7f9b003dd4fb9cad885461ce93165dc04.camel@perches.com>
Subject: Re: [PATCH V2] include: linux: Regularise the use of FIELD_SIZEOF
 macro
From: Joe Perches <joe@perches.com>
To: Alexey Dobriyan <adobriyan@gmail.com>, Andreas Dilger <adilger@dilger.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shyam Saini
 <shyam.saini@amarulasolutions.com>, kernel-hardening@lists.openwall.com, 
 linux-kernel@vger.kernel.org, keescook@chromium.org, 
 linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org, 
 intel-gvt-dev@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, 
 dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, linux-ext4
 <linux-ext4@vger.kernel.org>, devel@lists.orangefs.org, linux-mm@kvack.org,
  linux-sctp@vger.kernel.org, bpf@vger.kernel.org, kvm@vger.kernel.org, 
 mayhs11saini@gmail.com
Date: Sat, 29 Jun 2019 09:45:10 -0700
In-Reply-To: <20190629142510.GA10629@avx2>
References: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
	 <20190611134831.a60c11f4b691d14d04a87e29@linux-foundation.org>
	 <6DCAE4F8-3BEC-45F2-A733-F4D15850B7F3@dilger.ca>
	 <20190629142510.GA10629@avx2>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2019-06-29 at 17:25 +0300, Alexey Dobriyan wrote:
> On Tue, Jun 11, 2019 at 03:00:10PM -0600, Andreas Dilger wrote:
> > On Jun 11, 2019, at 2:48 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > On Wed, 12 Jun 2019 01:08:36 +0530 Shyam Saini <shyam.saini@amarulasolutions.com> wrote:
> > I did a check, and FIELD_SIZEOF() is used about 350x, while sizeof_field()
> > is about 30x, and SIZEOF_FIELD() is only about 5x.
> > 
> > That said, I'm much more in favour of "sizeof_field()" or "sizeof_member()"
> > than FIELD_SIZEOF().  Not only does that better match "offsetof()", with
> > which it is closely related, but is also closer to the original "sizeof()".
> > 
> > Since this is a rather trivial change, it can be split into a number of
> > patches to get approval/landing via subsystem maintainers, and there is no
> > huge urgency to remove the original macros until the users are gone.  It
> > would make sense to remove SIZEOF_FIELD() and sizeof_field() quickly so
> > they don't gain more users, and the remaining FIELD_SIZEOF() users can be
> > whittled away as the patches come through the maintainer trees.
> 
> The signature should be
> 
> 	sizeof_member(T, m)
> 
> it is proper English,
> it is lowercase, so is easier to type,
> it uses standard term (member, not field),
> it blends in with standard "sizeof" operator,

yes please.

Also, a simple script conversion applied
immediately after an rc1 might be easiest
rather than individual patches.


