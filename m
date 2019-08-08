Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9525EC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 08:13:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55E9A2187F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 08:13:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55E9A2187F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=daenzer.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7D7E6B0003; Thu,  8 Aug 2019 04:13:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2D386B0006; Thu,  8 Aug 2019 04:13:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C43286B0007; Thu,  8 Aug 2019 04:13:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE9E6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 04:13:02 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id k10so2048109wru.23
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 01:13:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ht+cKz/ZavS5MqjrNKDCdafFyHie5jHNrzKYloHpxhg=;
        b=nxXlS5pi53mz3Khp8HCkEao5eBDMpiW+lEXjYHaKLTIuODIngMjn1VCN1FQwpPI+Bu
         peqxybkqDsNN5p0EJhRvpU92qjE6TFi8o+bOwqdOt+lHlWbzF4qjxh2cGoWpG1xh2kiR
         csaL8spNjwKBHVqcVyYtqxIds586u7Uq4n2Jphh5BctTtYLMwnBJ22gxElbiWlboZu+6
         ETJOjbF6cSjbObSXnL1CjBvveMrGFQ9MuSv46IxKqnoFHGSSpnDpOZlKw5FXeuQtqE4a
         YtEEHp3PQxb6iC3lRrKzgkCCa/YRQy7o1lDdISQe9Nvkc0Iz/VtZ1bAYAYglic5xqiDg
         t7Qw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
X-Gm-Message-State: APjAAAXGNFQlIEWYlhRTNSiPsg9Psa/1HsGdO7s26vbUAwPr2gsqOUZ9
	rt7JnK3tBmceiwETZ7vYAw9iahuGHm45Dcfjgc0DZXPGuM7TrzVmbik6BTcC5QP3c2socdKpuLw
	NFIp+8FQiRXMI3i0QIXMhCSrox7D8CXE/IpZB4JZgopFOIxHglAZo8AokfdfYaGo=
X-Received: by 2002:adf:dd88:: with SMTP id x8mr5453346wrl.331.1565251982040;
        Thu, 08 Aug 2019 01:13:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBsKKOIx1ZQgfcpAxllEDV9191/p/cAw1R/hDlvLkDowiQ/vlPXZWqxShTRViGvMfSFfHL
X-Received: by 2002:adf:dd88:: with SMTP id x8mr5453272wrl.331.1565251981407;
        Thu, 08 Aug 2019 01:13:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565251981; cv=none;
        d=google.com; s=arc-20160816;
        b=z/43LRCSHc7gCo3WLPZjGv3UDk09wy0QXhLFd9z/NFGQEJ7dWrFi+NS24W1H9fzvPX
         gEv4ceBUAoDgfFXyA0K8JBpSXab8alBMK80YYCpL5AmNJRYAJ+HdEm2hzak9sSP7p7cV
         s7aGyXWZjFPDhOQIfR3shr7Uyl0CSqFu8cpuDqNksVsIO3fCBO5ujQI+KsnNcF9qE8CI
         LEaE4z1/GyZ9A9glAutZqaegatJmhIoLjVsi6Eg4Rz0ke2BDv1MVN2/ekM1xbUM4sEsT
         /p9lVCFgEuvCcJPlh3oQ5OCie0cr3AtNkNWClDy378WLc1uJGK18Et3XfZ1HoD8xz5Ok
         dmXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=ht+cKz/ZavS5MqjrNKDCdafFyHie5jHNrzKYloHpxhg=;
        b=XawW7t43zdB78F3RCfgcZi+9V0QRTIuZ5zJUNmzTRM0bz8XIpNfvYL3wdKkK5u+93J
         zh7JYxBJwifLpUZo8VZ1qe3/pOSaF51t9adTYYyS7kgKACz1HPiMumY9zdUuCVUUp7cc
         9lMvIQiRu0yzl8y927wlX2TBEieKwLiFhlgUbVbEBrLqDzw62O6vgvR6+oLLBal3LoPD
         MW69mpQEI2r/3OV+aqekL3Qiqeu/HdHA/JmS38dCVK9VsUIG4+O+Fd1EsPaf3JiKJQ7M
         e2tktTfnRgO4X50q/l6lMk5vlSCQMRyr8p1kfJDdBeV+5e6LkUHcMuKRk37mMriB9eGw
         pVJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id e4si4421993wrw.104.2019.08.08.01.13.01
        for <linux-mm@kvack.org>;
        Thu, 08 Aug 2019 01:13:01 -0700 (PDT)
Received-SPF: neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) client-ip=148.251.143.178;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.251.143.178 is neither permitted nor denied by best guess record for domain of michel@daenzer.net) smtp.mailfrom=michel@daenzer.net
Received: from localhost (localhost [127.0.0.1])
	by netline-mail3.netline.ch (Postfix) with ESMTP id D93432B200C;
	Thu,  8 Aug 2019 10:13:00 +0200 (CEST)
X-Virus-Scanned: Debian amavisd-new at netline-mail3.netline.ch
Received: from netline-mail3.netline.ch ([127.0.0.1])
	by localhost (netline-mail3.netline.ch [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id HMzk0c21TQZi; Thu,  8 Aug 2019 10:13:00 +0200 (CEST)
Received: from thor (116.245.63.188.dynamic.wline.res.cust.swisscom.ch [188.63.245.116])
	by netline-mail3.netline.ch (Postfix) with ESMTPSA id 3C3C12AA0BD;
	Thu,  8 Aug 2019 10:13:00 +0200 (CEST)
Received: from localhost ([::1])
	by thor with esmtp (Exim 4.92)
	(envelope-from <michel@daenzer.net>)
	id 1hvdXf-0005ZI-Rb; Thu, 08 Aug 2019 10:12:59 +0200
Subject: Re: The issue with page allocation 5.3 rc1-rc2 (seems drm culprit
 here)
To: Alex Deucher <alexdeucher@gmail.com>,
 Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Hillf Danton <hdanton@sina.com>, Harry Wentland <harry.wentland@amd.com>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 dri-devel <dri-devel@lists.freedesktop.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 amd-gfx list <amd-gfx@lists.freedesktop.org>,
 "Deucher, Alexander" <Alexander.Deucher@amd.com>,
 Dave Airlie <airlied@gmail.com>, "Koenig, Christian"
 <Christian.Koenig@amd.com>
References: <20190806014830.7424-1-hdanton@sina.com>
 <CABXGCsMRGRpd9AoJdvZqdpqCP3QzVGzfDPiX=PzVys6QFBLAvA@mail.gmail.com>
 <CADnq5_O08v3_NUZ_zUZJFYwv_tUY7TFFz2GGudqgWEX6nh5LFA@mail.gmail.com>
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
Message-ID: <6d5110ab-6539-378d-f643-0a1d4cf0ff73@daenzer.net>
Date: Thu, 8 Aug 2019 10:12:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <CADnq5_O08v3_NUZ_zUZJFYwv_tUY7TFFz2GGudqgWEX6nh5LFA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-08-08 7:31 a.m., Alex Deucher wrote:
> On Wed, Aug 7, 2019 at 11:49 PM Mikhail Gavrilov
> <mikhail.v.gavrilov@gmail.com> wrote:
>>
>> Unfortunately error "gnome-shell: page allocation failure: order:4,
>> mode:0x40cc0(GFP_KERNEL|__GFP_COMP),
>> nodemask=(null),cpuset=/,mems_allowed=0" still happens even with
>> applying this patch.
> 
> I think we can just drop the kmalloc altogether.  How about this patch?

Memory allocated by kvz/malloc needs to be freed with kvfree.


-- 
Earthling Michel Dänzer               |              https://www.amd.com
Libre software enthusiast             |             Mesa and X developer

