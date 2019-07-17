Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F085C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:47:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96A7920818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:47:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96A7920818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=daenzer.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 312E36B0003; Wed, 17 Jul 2019 03:47:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C41D6B0005; Wed, 17 Jul 2019 03:47:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B2BC8E0001; Wed, 17 Jul 2019 03:47:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id C25776B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 03:47:06 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id 17so5807117wmj.3
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:47:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=hDfalh2JfGDD7R1Z5w3hD03aBb2dkB5KjpY4ZAS6toE=;
        b=lrfLQDBAM5F7Um8CPIFTZPSaZ4uT8Ka+pbwT0uSFp0irI3kZ+O7wl0RiIk9+b+sgak
         JIhmEmMGfBmFCo0W3MOYeXHAhOAdYyLA3nQVzTp0jbzscODHPzb6Ti8VBZj9m5RZQdxP
         GFFp3cXKiWvI9Xchj0SSDTAXMhj5icFXxxtmXMZ2TLE4xOJyO1L5Wx2o3MYabzSbLb2w
         QDzSFVnvYYU7QFI1Ye43yoLS/Lk0AHNMEekjniiqMYF+fjUMf6tXaQ3C+6ZznypESzJ7
         owXnYkvDQnSjFhVzYh1xSFazAj7CvPkmKxo3DXfPf4011ujJOQKFW62uvdxqxjd/5dKd
         xqMQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
X-Gm-Message-State: APjAAAWOXVl3HsBrJCFS2HjTljaDedWyXciFsNouZKnuEwo8FOBVUzWi
	rFfdtQUgP2LZU7cDGaUeZCmYSa1wnSxjKAq2sDb/huS/pqy75W1VV2iW0RVyzWTho9rBRowwmWw
	2Su/fPs9j8451058lmN+1heHQ3hda9lXYB5bP5FjP1jgBBG5FtU1M5LJiIa1H70w=
X-Received: by 2002:a1c:a997:: with SMTP id s145mr34019080wme.106.1563349626276;
        Wed, 17 Jul 2019 00:47:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWYcNEnF6bIkesTB0wMqdKJZ4tZNXuz0ksKl66M2eUP83wIY04vTSYRkjOwQRDT4k2yL2i
X-Received: by 2002:a1c:a997:: with SMTP id s145mr34018970wme.106.1563349625265;
        Wed, 17 Jul 2019 00:47:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563349625; cv=none;
        d=google.com; s=arc-20160816;
        b=Du4/82zOYQqGAemJHITIGosPf+csNC5w9EggTdh2w/11ICYty4WFp/zI0tXkUeHUWS
         EeDjQsLUGK5ZpfTAz13JQp/yx2CsufDm7EhCv9U31b8n4HYAdmFPRX3Mn/HOdQpDEFYo
         MuVy/zdFJzLvOymzwebtOE628N5Kzl8x2BWUr8iqJHn5dyJSOl5xIhy/ubTzaBYeymCI
         wCS9Eat+FqtrWdZ1IgC9+0sBXrifP5FyP5Bv4u8+kT5myzntKZzj1OejnbBg4njdf3zK
         BNCR6LcBASqvlb2KjDzZjdtyCziIyO9tuJ+AWm9OSQTcBCubjmNuelsUH6qLk7T5Slz0
         b2+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=hDfalh2JfGDD7R1Z5w3hD03aBb2dkB5KjpY4ZAS6toE=;
        b=bJLXzTRN6lwqvyvj9GGQXO9YLJ/njZ3GZfTzOksbeMm7gOJoKDiRsZ/B/SqLoDtT3D
         pIfOQOt5jLcq+t15ts+QuCJl8/FK01aQS2iXy363DExQPCcnM6SUWf8QPQHTSm58LAF5
         hrXW3ah/NZqG5w5wSrDUGiH7BPKPlTXOTMaHlgQKdZfzbrTk2Sd8paCReTWyYSBiw+Zu
         8eWmK76Yn/2agWcnOio2uyitVdWKiG9w4oPoJ9IoOaj50K78JtHC6+vigkyLNov7Kd3b
         2f1bKGtFW08ps3lWNbzqul0X4bpRlP92DxNPQ3ihqYbO31ontu2Vk+kKeIbfkXeB4O8G
         3wHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id t133si14796479wmt.36.2019.07.17.00.47.04
        for <linux-mm@kvack.org>;
        Wed, 17 Jul 2019 00:47:05 -0700 (PDT)
Received-SPF: neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) client-ip=148.251.143.178;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from localhost (localhost [127.0.0.1])
	by netline-mail3.netline.ch (Postfix) with ESMTP id A066B2AA173;
	Wed, 17 Jul 2019 09:47:04 +0200 (CEST)
X-Virus-Scanned: Debian amavisd-new at netline-mail3.netline.ch
Received: from netline-mail3.netline.ch ([127.0.0.1])
	by localhost (netline-mail3.netline.ch [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id DmMfATDHPivo; Wed, 17 Jul 2019 09:47:04 +0200 (CEST)
Received: from thor (116.245.63.188.dynamic.wline.res.cust.swisscom.ch [188.63.245.116])
	by netline-mail3.netline.ch (Postfix) with ESMTPSA id AD78C2AA0DA;
	Wed, 17 Jul 2019 09:47:03 +0200 (CEST)
Received: from localhost ([::1])
	by thor with esmtp (Exim 4.92)
	(envelope-from <michel@daenzer.net>)
	id 1hneeU-0003ZR-FM; Wed, 17 Jul 2019 09:47:02 +0200
Subject: Re: HMM related use-after-free with amdgpu
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>,
 Jason Gunthorpe <jgg@mellanox.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
References: <9a38f48b-3974-a238-5987-5251c1343f6b@daenzer.net>
 <20190715172515.GA5043@mellanox.com>
 <823db68e-6601-bb3a-0c1f-bfc5169cb7c9@daenzer.net>
 <20190716163545.GF29741@mellanox.com>
 <cc010b8d-0018-783a-648f-01099fc63352@daenzer.net>
 <7b5daece-10ea-e96e-5e75-f6fa4e589d5e@amd.com>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Openpgp: preference=signencrypt
Autocrypt: addr=michel@daenzer.net; prefer-encrypt=mutual; keydata=
 mQGiBDsehS8RBACbsIQEX31aYSIuEKxEnEX82ezMR8z3LG8ktv1KjyNErUX9Pt7AUC7W3W0b
 LUhu8Le8S2va6hi7GfSAifl0ih3k6Bv1Itzgnd+7ZmSrvCN8yGJaHNQfAevAuEboIb+MaVHo
 9EMJj4ikOcRZCmQWw7evu/D9uQdtkCnRY9iJiAGxbwCguBHtpoGMxDOINCr5UU6qt+m4O+UD
 /355ohBBzzyh49lTj0kTFKr0Ozd20G2FbcqHgfFL1dc1MPyigej2gLga2osu2QY0ObvAGkOu
 WBi3LTY8Zs8uqFGDC4ZAwMPoFy3yzu3ne6T7d/68rJil0QcdQjzzHi6ekqHuhst4a+/+D23h
 Za8MJBEcdOhRhsaDVGAJSFEQB1qLBACOs0xN+XblejO35gsDSVVk8s+FUUw3TSWJBfZa3Imp
 V2U2tBO4qck+wqbHNfdnU/crrsHahjzBjvk8Up7VoY8oT+z03sal2vXEonS279xN2B92Tttr
 AgwosujguFO/7tvzymWC76rDEwue8TsADE11ErjwaBTs8ZXfnN/uAANgPLQjTWljaGVsIERh
 ZW56ZXIgPG1pY2hlbEBkYWVuemVyLm5ldD6IXgQTEQIAHgUCQFXxJgIbAwYLCQgHAwIDFQID
 AxYCAQIeAQIXgAAKCRBaga+OatuyAIrPAJ9ykonXI3oQcX83N2qzCEStLNW47gCeLWm/QiPY
 jqtGUnnSbyuTQfIySkK5AQ0EOx6FRRAEAJZkcvklPwJCgNiw37p0GShKmFGGqf/a3xZZEpjI
 qNxzshFRFneZze4f5LhzbX1/vIm5+ZXsEWympJfZzyCmYPw86QcFxyZflkAxHx9LeD+89Elx
 bw6wT0CcLvSv8ROfU1m8YhGbV6g2zWyLD0/naQGVb8e4FhVKGNY2EEbHgFBrAAMGA/0VktFO
 CxFBdzLQ17RCTwCJ3xpyP4qsLJH0yCoA26rH2zE2RzByhrTFTYZzbFEid3ddGiHOBEL+bO+2
 GNtfiYKmbTkj1tMZJ8L6huKONaVrASFzLvZa2dlc2zja9ZSksKmge5BOTKWgbyepEc5qxSju
 YsYrX5xfLgTZC5abhhztpYhGBBgRAgAGBQI7HoVFAAoJEFqBr45q27IAlscAn2Ufk2d6/3p4
 Cuyz/NX7KpL2dQ8WAJ9UD5JEakhfofed8PSqOM7jOO3LCA==
Message-ID: <037ca75c-8aac-65a2-2f8d-6b2103089537@daenzer.net>
Date: Wed, 17 Jul 2019 09:47:02 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <7b5daece-10ea-e96e-5e75-f6fa4e589d5e@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-17 12:10 a.m., Kuehling, Felix wrote:
> On 2019-07-16 1:04 p.m., Michel Dänzer wrote:
>> On 2019-07-16 6:35 p.m., Jason Gunthorpe wrote:
>>> On Tue, Jul 16, 2019 at 06:31:09PM +0200, Michel Dänzer wrote:
>>>> On 2019-07-15 7:25 p.m., Jason Gunthorpe wrote:
>>>>> On Mon, Jul 15, 2019 at 06:51:06PM +0200, Michel Dänzer wrote:
>>>>>> With a KASAN enabled kernel built from amd-staging-drm-next, the
>>>>>> attached use-after-free is pretty reliably detected during a piglit gpu run.
>>>>> Does this branch you are testing have the hmm.git merged? I think from
>>>>> the name it does not?
>>>> Indeed, no.
>>>>
>>>>
>>>>> Use after free's of this nature were something that was fixed in
>>>>> hmm.git..
>>>>>
>>>>> I don't see an obvious way you can hit something like this with the
>>>>> new code arrangement..
>>>> I tried merging the hmm-devmem-cleanup.4 changes[0] into my 5.2.y +
>>>> drm-next for 5.3 kernel. While the result didn't hit the problem, all
>>>> GL_AMD_pinned_memory piglit tests failed, so I suspect the problem was
>>>> simply avoided by not actually hitting the HMM related functionality.
>>>>
>>>> It's possible that I made a mistake in merging the changes, or that I
>>>> missed some other required changes. But it's also possible that the HMM
>>>> changes broke the corresponding user-pointer functionality in amdgpu.
>>> Not sure, this was all Tested by the AMD team so it should work, I
>>> hope.
>> It can't, due to the issue pointed out by Linus in the "drm pull for
>> 5.3-rc1" thread: DRM_AMDGPU_USERPTR still depends on ARCH_HAS_HMM, which
>> no longer exists, so it can't be enabled.
> 
> As far as I can tell, Linus fixed this up in his merge commit 
> be8454afc50f43016ca8b6130d9673bdd0bd56ec.

Ah! That's the piece I was missing, since I had merged the drm-next
changes before Linus did. Thanks Felix.

Note that AFAICT it was basically luck that Linus noticed this and fixed
it up. It would be better not to push our luck like this. :)


-- 
Earthling Michel Dänzer               |              https://www.amd.com
Libre software enthusiast             |             Mesa and X developer

