Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB5EEC0651F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 04:09:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63B6321852
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 04:09:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="b1jq75dx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63B6321852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B271F6B0003; Fri,  5 Jul 2019 00:09:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB0E58E0003; Fri,  5 Jul 2019 00:09:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 929598E0001; Fri,  5 Jul 2019 00:09:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 58EDC6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 00:09:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u4so4804979pgb.20
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 21:09:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=EpLpp6d5ev9UdUsgMU6f1l10/dE3Pg2qZg1140QaSWM=;
        b=AqlME51tIYOv8bkLw/lYcQHxtyrAJyHsxuhxU27dr/QXh6T0sWCWZfolvkFNl+PXX2
         n1RMPGcAXhE0wMcA/B5wzf82xUUW82rqEZbhgjvJpEnXpvIWBkCcbytLMVQSrHPqdN/w
         a+znhk7xOrvkpqIEArVcwwybI/GIaoCUzFb9u+I16bGmAnEV68gBfxuFWPgDD4/Yykqy
         tluBB1PVpTBOdvxDCvfv7sd996JhYuBBGOTy3zg3Hmu0oFoKAlocQnItzprdobkn2Gos
         cvceUKERzdDGOaa2MF3MaqCp0Flh7UE9XaMNbr96UzBL2Tn5y5aOzJ2aQvX979mBasvn
         VznA==
X-Gm-Message-State: APjAAAWrnHLhogbYjXD5dzrV+PPAKw5the4VJKZx/fSyBaqb47jbwMmJ
	njfO7pSX5l07gZMLNgUI/q7TY56lR2sILB9NRMLkhREqO3x3MitPJjc6d4wWOcgaQQVdxugIJuh
	R+PGSUSlnTdFuhrIgbNFd3sQSOpJr/05uAeN9+6qE+fggRMUDjLId0V9iWLRI5z56IA==
X-Received: by 2002:a17:90a:5288:: with SMTP id w8mr1997997pjh.61.1562299763975;
        Thu, 04 Jul 2019 21:09:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiyn1YJxWyqVunj/pif/rn5YkV9+SRJ8Facu2uuicDMTamebMuO7PjcNmd3jUbrCuzHqUS
X-Received: by 2002:a17:90a:5288:: with SMTP id w8mr1997941pjh.61.1562299763306;
        Thu, 04 Jul 2019 21:09:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562299763; cv=none;
        d=google.com; s=arc-20160816;
        b=0nVMTvrKBTvBNKp9gLX0baSQ4TGVszVIxLVXk1YS+T82HGpjllS7Ka1PARKMi0tme/
         2EScyb/3l3ruHOBlRHoQcHUvglR9LKuXmE2P6re9nBf/YGZzEVixdip9GjB7dCPJEJUB
         Fh88DV3J6iIQDxMNoTewVLILqIAb6zF24PvOziYWLZ33NO1qx1n4Sd/DdvnJsIA1xluH
         ylAXd2IcRND0YnNQjg1YhrqxpWezGbbOP0yfu8fpGskMG+ejH/TwEOwOJTUVFbXCsadF
         FxjqmlM2dQI7xn5UzalwIHHb4rlIJWAn7z/XZ9o9UF0kDIVLKxxjC5EkxebTdMsKLEoe
         DTaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=EpLpp6d5ev9UdUsgMU6f1l10/dE3Pg2qZg1140QaSWM=;
        b=QAISJL+g2RxmEu+IXCG7KViCEzM5kQvaHh21AO+DpLtTjaSK6IqOdwT0I94ndBWpjM
         NoiaUQHkYoH6e+s18q0IUJ2f+UAZnx7MCOYtAw264/4gpNmN6U3wXfWZw7Gk1A81B2kw
         adtNiFJkEcilTFg7xi0SDTIAojCwS2dsc79YJKI21AjXJMiPCTuKJ65DjSCNGiZwNID2
         Wq/E68Ihjwj98Rb6ieIeTeJl0atkWqAL+PcTK5T4CdZAwvfppseoUJ2bFBADxfs0sgZ6
         i00AApbmySKVE+eiQCOQUr2RvNb9PkZ7MHxoYfiA6emLp3GuWOYymqZaZYhlHp792a5m
         9qGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=b1jq75dx;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d12si7292748pla.121.2019.07.04.21.09.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 04 Jul 2019 21:09:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=b1jq75dx;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=EpLpp6d5ev9UdUsgMU6f1l10/dE3Pg2qZg1140QaSWM=; b=b1jq75dxQbtB+7a65u6Rylo1L
	01T+/tPNKG4kAsias6gKT+e74KMYqsNVmHNpVUoATOVU43k0Q/oYEhbxb7uASluBzw9t31DXxOL4F
	VX9z+yb05Q+x9j+UVT6qB5SgP2QBi4gKgLvzIk7PpgKOFDOM75PF44vgjqpqzs1tXlSKHC82n/NJR
	mcjMdya35Mmn8wRdnCrJX1ijkuZzv7v7xGKF4UDt8ePkXqFbZInlYET+gWKS5rEU+CyZuoTWm3XSc
	Hk7S9UcSvq651qhTErC6lu0KudmoNoOKgrdnKQPc+r9geI20Fp6U2sgvPOInrz+2PZxT+v0SZsNyA
	uxb8DneeQ==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjFXC-0007w4-C8; Fri, 05 Jul 2019 04:09:18 +0000
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Brown
 <broonie@kernel.org>, linux-fsdevel@vger.kernel.org,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, Linux-Next Mailing List <linux-next@vger.kernel.org>,
 mhocko@suse.cz, mm-commits@vger.kernel.org,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 dri-devel <dri-devel@lists.freedesktop.org>
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
 <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
 <CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
 <CAK7LNASLfyreDPvNuL1svvHPC0woKnXO_bsNku4DMK6UNn4oHw@mail.gmail.com>
 <5e5353e2-bfab-5360-26b2-bf8c72ac7e70@infradead.org>
 <CAK7LNATF+D5TgTZijG3EPBVON5NmN+JcwmCBvnvkMFyR+3wF2A@mail.gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <8868b3fc-ba16-2b01-4ebb-4bdefc2f9e18@infradead.org>
Date: Thu, 4 Jul 2019 21:09:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <CAK7LNATF+D5TgTZijG3EPBVON5NmN+JcwmCBvnvkMFyR+3wF2A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/4/19 8:44 PM, Masahiro Yamada wrote:
> On Fri, Jul 5, 2019 at 12:23 PM Randy Dunlap <rdunlap@infradead.org> wrote:
>>
>> On 7/4/19 8:09 PM, Masahiro Yamada wrote:
>>> On Fri, Jul 5, 2019 at 12:05 PM Masahiro Yamada
>>> <yamada.masahiro@socionext.com> wrote:
>>>>
>>>> On Fri, Jul 5, 2019 at 10:09 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>>>>>
>>>>> On 7/4/19 3:01 PM, akpm@linux-foundation.org wrote:
>>>>>> The mm-of-the-moment snapshot 2019-07-04-15-01 has been uploaded to
>>>>>>
>>>>>>    http://www.ozlabs.org/~akpm/mmotm/
>>>>>>
>>>>>> mmotm-readme.txt says
>>>>>>
>>>>>> README for mm-of-the-moment:
>>>>>>
>>>>>> http://www.ozlabs.org/~akpm/mmotm/
>>>>>
>>>>> I get a lot of these but don't see/know what causes them:
>>>>>
>>>>> ../scripts/Makefile.build:42: ../drivers/gpu/drm/i915/oa/Makefile: No such file or directory
>>>>> make[6]: *** No rule to make target '../drivers/gpu/drm/i915/oa/Makefile'.  Stop.
>>>>> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915/oa' failed
>>>>> make[5]: *** [drivers/gpu/drm/i915/oa] Error 2
>>>>> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915' failed
>>>>>
>>>>
>>>> I checked next-20190704 tag.
>>>>
>>>> I see the empty file
>>>> drivers/gpu/drm/i915/oa/Makefile
>>>>
>>>> Did someone delete it?
>>>>
>>>
>>>
>>> I think "obj-y += oa/"
>>> in drivers/gpu/drm/i915/Makefile
>>> is redundant.
>>
>> Thanks.  It seems to be working after deleting that line.
> 
> 
> Could you check whether or not
> drivers/gpu/drm/i915/oa/Makefile exists in your source tree?

It does not.

> Your build log says it was missing.
> 
> But, commit 5ed7a0cf3394 ("drm/i915: Move OA files to separate folder")
> added it.  (It is just an empty file)
> 
> I am just wondering why.

I am not using any git tree(s) for this.  Just patches.

That Makefile is in patch-v5.2-rc7-next-20190704.xz.

I don't know how Andrew generates the linux-next.patch file for mmotm,
but I don't see that Makefile anywhere in mmotm, although the rest of
the i915/oa/ files seems to be there.

Maybe diff skips empty files unless told to save them?

-- 
~Randy

