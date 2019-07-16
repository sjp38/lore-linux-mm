Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99AD6C7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 16:31:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E973F206C2
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 16:31:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E973F206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=daenzer.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71F926B0005; Tue, 16 Jul 2019 12:31:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D0F48E0005; Tue, 16 Jul 2019 12:31:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BF028E0003; Tue, 16 Jul 2019 12:31:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 089296B0005
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 12:31:14 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id t9so10813541wrx.9
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 09:31:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=kn6KcW/zFcrpya+PYa7sOEVDbnX2D/hsH0Sa5ZCsJUo=;
        b=Ay4E5Z1sD1fMXaddE2TPOOD0WAB7wOYYO02W43IRwPnc5IBazoznZbfzaBDoq5f1VR
         5hEnUhR3geJktF8joND4f023Rg9SefHsNRnwx0KgOxKVVeyGQrP4Q53rT4uRZeRae/UB
         DHm/zL4BWoYRe8GlMb2tnsFeukaz+2Db/j1ymCMH8Q+O0m7/cEPf2BLCx3ZUlDPVQxZB
         d4e0QbWp7vbIxttGVEqtsG7UxiIDV3NH4qkHeKv1unTa1FCtGNWNVuluIBURjOdiMKWe
         bHR0kr+i/M+LoEjxAX4DB49NRn6jR7jvG3qlM8RTXKTkuR0zc2ODzrj42gQNuOWM/Mas
         qabw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
X-Gm-Message-State: APjAAAUHeWzSJar1cthmXlmV2FsLQSZNjOQL8dktTFs/jhWwpEmSgoDf
	uI82G3y98arsg2474awaGWjkOp4q4ljVHJvNjWAsJGS+6X8npwQ1Y3tswIENvzPhN+3XrttZ8Si
	5NCWAPUizm5AFjidd0DfzYyoizbPNbjzQBy9AZnrcqJi4xa2M8uQWa5zotNZiMMs=
X-Received: by 2002:adf:db50:: with SMTP id f16mr23081991wrj.214.1563294673536;
        Tue, 16 Jul 2019 09:31:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzU4/wxpTkNTXhTfGmfLZ6l1mwflg6gpSitvBwGcZSHXA3qQR3wbFrx6Vxairv72lRDyhzb
X-Received: by 2002:adf:db50:: with SMTP id f16mr23081943wrj.214.1563294672744;
        Tue, 16 Jul 2019 09:31:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563294672; cv=none;
        d=google.com; s=arc-20160816;
        b=X/dno0Kz5+YUlpeG0y46uuuAN4C9/2Lw8s14c2WAiCxJwmG5Dys3f6KkJG/Xpfn4nR
         /FX6r8cfSdta4k0l9FRxzRWF/y4EsJJHqxyawH8aGM6av0rJuBSCIwWYJv78QhVkNkMI
         voJ6VyZy/NnhF0UsU2o4N9w7qFhH5ohEjfn/PEQkaMV55y6N03E+b6YoNu9uK0LtpB+p
         7cDRX2zx2X0068hVijh3PBQEtj1tYBelfmYkbeMPzU37jfa+LVDDgHXmaysVaMMPO1O/
         ZsUfZyzw8EL8UMZFiUaiuvsBUulWw8IYK34na2ah/OFLyGmvPEDEstOgTBUxwGfvtFRy
         XfsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=kn6KcW/zFcrpya+PYa7sOEVDbnX2D/hsH0Sa5ZCsJUo=;
        b=hBllAxFIC57PAhItvO9eeaO+J54YiKdS9tpChB46RthtDX4LBceOOYa43czlUqM/Aw
         x3Gs9K2kvEwNNXK+QWwS/al7tVodMu/A2kR+lzLy9/QK5PlGCyUjE69hwtBQfeM7A4sH
         O7N3EDE7zSJBQMsabnSYAmlvZYY+9LEQDvpu7UNgeHZA29AGx83cN0iGXnbsTOtmA74m
         l28OB2Wuhr1dY+sZGK1Q74SojyNDPS4LpiW6/rWZXZf/S8R/YndL9l6z4F5V5Hh/PL4t
         yw2nklj7qyXEz99YZyVthd6iQGGR95f9gvo1Ez5k2xCHDkp5Y9IeZ0Ukdpisc+y6M5a2
         W95Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id x5si17921316wmk.191.2019.07.16.09.31.12
        for <linux-mm@kvack.org>;
        Tue, 16 Jul 2019 09:31:12 -0700 (PDT)
Received-SPF: neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) client-ip=148.251.143.178;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from localhost (localhost [127.0.0.1])
	by netline-mail3.netline.ch (Postfix) with ESMTP id 0BAD92AA12C;
	Tue, 16 Jul 2019 18:31:12 +0200 (CEST)
X-Virus-Scanned: Debian amavisd-new at netline-mail3.netline.ch
Received: from netline-mail3.netline.ch ([127.0.0.1])
	by localhost (netline-mail3.netline.ch [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id 4LY9cStXNEwq; Tue, 16 Jul 2019 18:31:11 +0200 (CEST)
Received: from thor (116.245.63.188.dynamic.wline.res.cust.swisscom.ch [188.63.245.116])
	by netline-mail3.netline.ch (Postfix) with ESMTPSA id 46A712AA0E9;
	Tue, 16 Jul 2019 18:31:11 +0200 (CEST)
Received: from localhost ([::1])
	by thor with esmtp (Exim 4.92)
	(envelope-from <michel@daenzer.net>)
	id 1hnQMA-0007Rn-1z; Tue, 16 Jul 2019 18:31:10 +0200
Subject: Re: HMM related use-after-free with amdgpu
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
References: <9a38f48b-3974-a238-5987-5251c1343f6b@daenzer.net>
 <20190715172515.GA5043@mellanox.com>
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
Message-ID: <823db68e-6601-bb3a-0c1f-bfc5169cb7c9@daenzer.net>
Date: Tue, 16 Jul 2019 18:31:09 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190715172515.GA5043@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-15 7:25 p.m., Jason Gunthorpe wrote:
> On Mon, Jul 15, 2019 at 06:51:06PM +0200, Michel Dänzer wrote:
>>
>> With a KASAN enabled kernel built from amd-staging-drm-next, the
>> attached use-after-free is pretty reliably detected during a piglit gpu run.
> 
> Does this branch you are testing have the hmm.git merged? I think from
> the name it does not?

Indeed, no.


> Use after free's of this nature were something that was fixed in
> hmm.git..
> 
> I don't see an obvious way you can hit something like this with the
> new code arrangement..

I tried merging the hmm-devmem-cleanup.4 changes[0] into my 5.2.y +
drm-next for 5.3 kernel. While the result didn't hit the problem, all
GL_AMD_pinned_memory piglit tests failed, so I suspect the problem was
simply avoided by not actually hitting the HMM related functionality.

It's possible that I made a mistake in merging the changes, or that I
missed some other required changes. But it's also possible that the HMM
changes broke the corresponding user-pointer functionality in amdgpu.


[0] Specifically, the following (ranges of) commits:

9ffbe8ac05dbb4ab4a4836a55a47fc6be945a38f (-> lockdep_assert_held_write)
e1bfa87399e372446454ecbaeba2800f0a385733..5da04cc86d1215fd9fe0e5c88ead6e8428a75e56
fec88ab0af9706b2201e5daf377c5031c62d11f7^..fec88ab0af9706b2201e5daf377c5031c62d11f7

-- 
Earthling Michel Dänzer               |              https://www.amd.com
Libre software enthusiast             |             Mesa and X developer

