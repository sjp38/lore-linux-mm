Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74176C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 07:17:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DF212133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 07:17:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DF212133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B9496B0005; Thu, 11 Apr 2019 03:17:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 768636B0006; Thu, 11 Apr 2019 03:17:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 658846B0007; Thu, 11 Apr 2019 03:17:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 16DCF6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 03:17:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s6so2583613edr.21
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 00:17:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=r2zr0dkkseZ4YwG+4x5cG1AgJqCY9BJpepDcOBgMdDo=;
        b=Rh0frU5G/dOemWZAuKr05mUXH8YkkGPoeNJ1P5iaMGtexEAd+MA5IFVzo1jkcETRfy
         ekQuIBfm2Wo2LFL/ab05MrcZPnwY3Ry2zHx3J6jmOMPlauogEO4PRWXY/tu/nwW4qjLD
         KPZn7aVTYJ2SWVqlD455DljmZR0My3wLVc8gZkS8g3PYms7aLgPlD2sNObxtXFKEy9lt
         OnQbu7IdGZWMcM4VOqKLTE3vVg+ddEcUdo7h7ysPD3XKYh1ZvOAVHxO0dMuG12KYoXxR
         ObBQz283sxx1D9Q96oT6QY0Rf27KvrmIjwjXy5CIMumj615ft459ypVMQWU2kF/bmocL
         VgVQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVdsruys+spSaEDTPw9/MwJ5LX3AlIRHTiGxUCbOzdlq16vqbrL
	fqEA9toVIBGoxhdS4mpmG8Lb2EdrXymlNY1/4cgmDb0S6Hzm7RhJ2OIXeYQ4L40b5RXg72Nl+kC
	3HucMMPzFd6PkGR5NMuUR3Lg2S9iaMyt4FqH5EVzR9Rc/3C3WNx9Iz7SclMiLyzs=
X-Received: by 2002:a17:906:1347:: with SMTP id x7mr26530048ejb.64.1554967030445;
        Thu, 11 Apr 2019 00:17:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAXtO2KihLPTrdHGwPGs2rNRJa/ewjoBhc/zDCkiySOlxcbtKksiq+MU2muN3v6wWp78Xb
X-Received: by 2002:a17:906:1347:: with SMTP id x7mr26530001ejb.64.1554967029486;
        Thu, 11 Apr 2019 00:17:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554967029; cv=none;
        d=google.com; s=arc-20160816;
        b=LXza/kccVUlI/4sKZODm3lDaskcVRAAqcxC/uuHYk56ea+xDWRMiTNQ3F0lxgW/f5l
         8IkeHfh2CJCVnJ//8wMSs0W6QsiC9vFjcbDoTI/hxri924f/OV6REfzQlMWkR5MVVpjf
         QQy4zBIHS6Wu1cw0iuW2Bc9nlcrWbJChjL9ERRQVrTwRlkt1JG4rTEbeXGqwHFmZQD84
         cJnBWBxxqVnIW/aO95HqMIyzARdj25gnZtgJX+Z5AojTYtpA5Ii81aC+FVOEm5oHHCZZ
         PbP6vJLwe1mHA124qttaDkV1cFUSFDvpaYAlg4xRXeWN4c5jhroDW4wr8sJ76PERL/OZ
         /xcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=r2zr0dkkseZ4YwG+4x5cG1AgJqCY9BJpepDcOBgMdDo=;
        b=pFMUPVNIn1NsDH7VgxvTkFUkhehWYzNT+ZyP707wU1+r6e3hMe7Qsp9pVcYPp/xDXg
         E0/TnnRe42o7RQc2tag5JsGEgDUT3qrqFZS45qDfEY3vzmIY2b+wikrxfTQXFowAcDqF
         iv3O/fcdr1geNLc2x8pc7/5s1cC69A/TRPBHBdl2Jx6Mj1x9uUkDvT7lRPGlLtjntpce
         M0ewiEpg5nrLfd1bpyAj4/3pFn2T0y4bamcEnqCGk9L9J6tsL24dfhuDGPt4vsUx9xlV
         8qMYAmSQKqQs+YrQXelDv9mUE7p38zSZ3wTIsnXg22gcyOjuFFEwhAEevdplUWirtp4X
         WcYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id g9si2983811edq.352.2019.04.11.00.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 00:17:09 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id A0D7EFF80C;
	Thu, 11 Apr 2019 07:17:05 +0000 (UTC)
Subject: Re: [PATCH v2 2/5] arm64, mm: Move generic mmap layout functions to
 mm
To: Kees Cook <keescook@chromium.org>
Cc: Albert Ou <aou@eecs.berkeley.edu>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>,
 Linux-MM <linux-mm@kvack.org>, Paul Burton <paul.burton@mips.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>, linux-mips@vger.kernel.org,
 linux-riscv@lists.infradead.org,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 Luis Chamberlain <mcgrof@kernel.org>
References: <20190404055128.24330-1-alex@ghiti.fr>
 <20190404055128.24330-3-alex@ghiti.fr> <20190410065908.GC2942@infradead.org>
 <8d482fd0-b926-6d11-0554-a0f9001d19aa@ghiti.fr>
 <CAGXu5jKt8f7=DKrvcPg-NUJGbc-vanMNojfDsEiBt3vP05G4oQ@mail.gmail.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <4c498b2b-e916-3389-209f-aa4cc7b523ff@ghiti.fr>
Date: Thu, 11 Apr 2019 09:16:09 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKt8f7=DKrvcPg-NUJGbc-vanMNojfDsEiBt3vP05G4oQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/10/2019 08:27 PM, Kees Cook wrote:
> On Wed, Apr 10, 2019 at 12:33 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>> On 04/10/2019 08:59 AM, Christoph Hellwig wrote:
>>> On Thu, Apr 04, 2019 at 01:51:25AM -0400, Alexandre Ghiti wrote:
>>>> - fix the case where stack randomization should not be taken into
>>>>     account.
>>> Hmm.  This sounds a bit vague.  It might be better if something
>>> considered a fix is split out to a separate patch with a good
>>> description.
>> Ok, I will move this fix in another patch.
> Yeah, I think it'd be best to break this into a few (likely small) patches:
> - update the compat case in the arm64 code
> - fix the "not randomized" case
> - move the code to mm/ (line-for-line identical for easy review)
>
> That'll make it much easier to review (at least for me).
>
> Thanks!
>

Sorry about that, I'm working on it.

Thanks,

Alex

