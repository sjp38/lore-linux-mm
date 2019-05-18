Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7000FC04E87
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 09:47:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C3BA2087E
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 09:47:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C3BA2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 858866B0005; Sat, 18 May 2019 05:47:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8089B6B0006; Sat, 18 May 2019 05:47:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71F936B0007; Sat, 18 May 2019 05:47:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26B2B6B0005
	for <linux-mm@kvack.org>; Sat, 18 May 2019 05:47:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r5so14908799edd.21
        for <linux-mm@kvack.org>; Sat, 18 May 2019 02:47:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=71Z2Z+j4OH7JUdBedNdHvl//zj7ZXton9MM81kWr6SE=;
        b=cp4oH0hAWb5RBN1RIVSFTNjyhN4mB9IOLtQNLIRb8j5dPpnAroDBmLCgGR+TqlWPz8
         N8qU2KgNNR9Gzj0dcJptxxibqit2WCdRvzhmBCApVNkl3T23rfeHBDv7C6fQfSzzL4/a
         Hvf4gu8yMgklcIuKhhtXJ0r9xFbZLx305pJjiUUbx1anQSAVeaEP77VrRtZeEXxfnNYs
         lIN8rcvq2200Kc/biUKjnwCRDErZhT9FYlG5+luS3QPmgELJ+g/KGsVP97qwX3Fc3g4J
         HVbaa9Rva6s3DFSm0z24P2pQOprCPLS5VgTe3dqDurwnYb16la/AswpdKwOxDpkBK2nX
         wnXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVj7GbMTcwoK8nvO/DcSca1tc1U160Q82ON7ULBVThvo88dHR45
	HxH4qdTs9eOjI6fpqeBbS5mQPBJRmOelk+JinHIKAW3I0+esRJbRE3utbkIxy7/O9NK72yHzkcM
	3JxJV4FcjxDawK+yKFb0FktybhHMRO3mEtgO0f4jdXVWqRShCSJu6XCapSeszJMQuAA==
X-Received: by 2002:a17:906:13cb:: with SMTP id g11mr44601232ejc.195.1558172846667;
        Sat, 18 May 2019 02:47:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeuldVrBaAAr4FKPseExue9e47K3jAvW6eAgX4ZzQax6j3PX/a+J+an22TT5yy9+jR3DF0
X-Received: by 2002:a17:906:13cb:: with SMTP id g11mr44601191ejc.195.1558172845811;
        Sat, 18 May 2019 02:47:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558172845; cv=none;
        d=google.com; s=arc-20160816;
        b=waTQwxLIVhahFsNl5/9sYANYyCr3/f7OSH7W7EkcmQeUIFrrsy8dN1RsyWJVNxC9DS
         VSxnsPS5wsKM/UsXDJDtWKqOz7icjd29jKtVwL/6agFt2lubg6fQbW5G15uWa4Oq7QQP
         ZLwPrJNw7tTMjd9Xff1xEkSA7DCWa6iK/tUBF5GQCWX5s/ncRvqCwQwJ0s+hqfqzwXUE
         5Dhsi1esAm/3odFESTVGsQFIujl6WWBAnTH0MS8n805u+br+1IJGj75oiDr/reSitwHv
         j35s9L4yatddiPY5IHq7NzW/U6N3wx/M/qjXrAlXEsJASVkoexJMAjlVIaMZLNbGQLz+
         uuTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=71Z2Z+j4OH7JUdBedNdHvl//zj7ZXton9MM81kWr6SE=;
        b=HhsdjtF5ImWBgtolwuebqYyqGVnbXvOaWZFFseKGqOq4apSYRIUFAFQogkXlbx0lk8
         7aoFsxvHpxd91hxXA25uZhocyIRL+HiAHBdXYJCkga1B9CNzwMJs9Qx/LRx+ea+dUU22
         YyC5mPqA5AsVWXKn3xmpzfIJugaNEMdJy/qhfya8+hgnSD2I8yFOMTVoENopLCLFUow4
         PSOyHi4EjhwVU8PKFatJ806SM6yWsdVyCsVymCbnUxcJyYm/YCc9BVwlOTtbfiRQ7eBy
         wIVotsUnyQ7yZs+5xOwgflIOnSPEYyQsJcSCPJ5pqR2gAIxnaQreMqZLR6vI+ViHPLdC
         VvsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o21si805324ejm.141.2019.05.18.02.47.25
        for <linux-mm@kvack.org>;
        Sat, 18 May 2019 02:47:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9AE37341;
	Sat, 18 May 2019 02:47:24 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6D64A3F703;
	Sat, 18 May 2019 02:47:23 -0700 (PDT)
Date: Sat, 18 May 2019 10:47:20 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Dmitry Vyukov <dvyukov@gmail.com>, Linux-MM <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] kmemleak: fix check for softirq context
Message-ID: <20190518094719.gyvhbdrwmcv4diax@mbp>
References: <20190517171507.96046-1-dvyukov@gmail.com>
 <20190517143746.2157a759f65b4cbc73321124@linux-foundation.org>
 <CACT4Y+aee_Kvezo8zeD77RwBi2-Csd9cE8vtGCmaTGYxr=iK5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+aee_Kvezo8zeD77RwBi2-Csd9cE8vtGCmaTGYxr=iK5A@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 18, 2019 at 09:10:59AM +0200, Dmitry Vyukov wrote:
> On Fri, May 17, 2019 at 11:37 PM Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Fri, 17 May 2019 19:15:07 +0200 Dmitry Vyukov <dvyukov@gmail.com> wrote:
> >
> > > From: Dmitry Vyukov <dvyukov@google.com>
> > >
> > > in_softirq() is a wrong predicate to check if we are in a softirq context.
> > > It also returns true if we have BH disabled, so objects are falsely
> > > stamped with "softirq" comm. The correct predicate is in_serving_softirq().
> > >
> > > ...
> > >
> > > --- a/mm/kmemleak.c
> > > +++ b/mm/kmemleak.c
> > > @@ -588,7 +588,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
> > >       if (in_irq()) {
> > >               object->pid = 0;
> > >               strncpy(object->comm, "hardirq", sizeof(object->comm));
> > > -     } else if (in_softirq()) {
> > > +     } else if (in_serving_softirq()) {
> > >               object->pid = 0;
> > >               strncpy(object->comm, "softirq", sizeof(object->comm));
> > >       } else {
> >
> > What are the user-visible runtime effects of this change?
> 
> If user does cat from /sys/kernel/debug/kmemleak previously they would
> see this, which is clearly wrong, this is system call context (see the
> comm):

Indeed, with your patch you get the correct output.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

Thanks.

-- 
Catalin

