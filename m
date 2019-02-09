Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7F0EC169C4
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 02:17:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2945220869
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 02:17:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="nlbo2XAF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2945220869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7523F8E00AC; Fri,  8 Feb 2019 21:17:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DAC58E00AB; Fri,  8 Feb 2019 21:17:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A4C08E00AC; Fri,  8 Feb 2019 21:17:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0BF8E00AB
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 21:17:17 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id v64so5503996qka.5
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 18:17:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WI9FXIZHc0w7+/QjGej42lgyR+YrOy8EMvOhQbjH4Qs=;
        b=c9og358w/LnvYjeCl7qbo3wXU/ttq0ZlAx8ExbbCqXdombKXZIoIt9xV/vUMTRZmh4
         rm+B9Obuq83+2inupSR4W2EGCQ6zJ5+Ry9vK6AlCtqOY1NourzhAj8T+OkoSCBysCcgD
         m07RaL2EHe/zIpykxpuM4W3iwBAOsRAtYvh760VlPDPIfgw/tsuF9ddY6SwV84JiiJQK
         erzO+UzBHsjKG1R5aRdRS/nD0CcnXiIE1orLRRc+bNtS4B5Od/DqOu0km8C5kReBMORR
         b/p40sJNxtDan4vxy6CAn4svrp445QjgGlTFOTiAqtbBvJorkpTX7GV7/B0+x4jWLiyd
         63kg==
X-Gm-Message-State: AHQUAuY1YKcYZs57g3kZBTVpAM08DMcoM1jVZ3SzuoDcECEFhX0uh7xH
	0+qGU4KytzZyYd3MUNVDZde/H3C3JxBw2+3P+pPr1lCRHWba/H0Emsb6M5uxw2Gd4o/p1WRu5At
	ni5K2lQanSQmYX2QT61SrUBtkmue3HrxEhJOh4+ynRnL39P+PTqHzk4xEF/epwIesmhnIDC6soa
	egUE0Q+5Oqm/iHpolpKU65eaFTb0KBSKnN03PwOrJ3QDzjB+kvYWnVcOF+jNUsWXzM0IV0IQpk+
	6inx+wvsbwjCA3IqdUnyNZAsrFSOGq4UBHlYaHOHjfVOl69bhXIGPuouRBhatzUctTueHeY9rJ5
	mzSQyERr1QUDkZ/Go408++zcA+l3xN2DbKP2YzanzNUenFYrQFNG/p5k8RuWTsa3EIsponFg9WU
	v
X-Received: by 2002:ac8:25d1:: with SMTP id f17mr522734qtf.38.1549678636909;
        Fri, 08 Feb 2019 18:17:16 -0800 (PST)
X-Received: by 2002:ac8:25d1:: with SMTP id f17mr522711qtf.38.1549678636368;
        Fri, 08 Feb 2019 18:17:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549678636; cv=none;
        d=google.com; s=arc-20160816;
        b=kUK68M7xkd6Rn+4sqHDhwlUm364v6e5So818pAWqU7TAtYWRJoY5NMBNrpw2pGrZhB
         Ueh3U0mxtGvlhhAph/WGtT7Inc2G4q0rM2c86WPIfNjIHAKekvs/J6SpQj/JbmkGxC/A
         EaRZWz7RHaWa2PkuNZINnyUe1bVEmUEjI7HSmWv9fseop+Ou2ZJwkYRxcGF5+ljttAS1
         92MpN9itT3Utfhh5SvZjQuz5K3GGPrXnoP+3i31/TPERP50AnyCfYLT/wJhVd1eG2/T4
         88kiHcyGW+nmt7ju6rimRHShsbcC9/nTvqgFQk4pKhM/pix1jCgxozDjgi16//xggsxO
         bZRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=WI9FXIZHc0w7+/QjGej42lgyR+YrOy8EMvOhQbjH4Qs=;
        b=wPHxHfb3Jc4WMs3d0UKCHgdJ2HuwCyys2fjBQSMM3TJngj12/BWJ0MeR4QzJi0wOaN
         3OEUdE+HQobwA+70AlYCXIE0s8R3wdjZ1m1o762B5fiVvb03bc5sqqTlCAM52TJ819Sw
         aQKJFxafU/NGO+CaCSPG4H0xEml09PMYWNF9bZghOhItBPltdIaRc4kNqFS2cv6SvKhi
         jsKzjUWLWkzGvpQ7w510mJqo19+cKnLdd29QDsRX7Kyw+ERHCljTf5pNWLrq5BfEsPG1
         ZJd03YA/kS7iHAvsUcKXAAzcivY3WKjaIDogIm6BMOVcA3NwVLn8rLTsiTT82fVeyKRx
         4anQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=nlbo2XAF;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p7sor2033251qkj.77.2019.02.08.18.17.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 18:17:16 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=nlbo2XAF;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.41 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=WI9FXIZHc0w7+/QjGej42lgyR+YrOy8EMvOhQbjH4Qs=;
        b=nlbo2XAFTfoNs5KyXR6TfbWtLUMHX6Hcu9RdVsycwVo5Jt/5wVuisHShw3vrIaAYQ5
         MiI+ty1L3SW4EryEGA/qDERwsR4yiEMRHLz3SfHTq9gE7B011fRAcGk2NKQsngydq2Ky
         +ygWeR4DtqtvENbKOOIQKm0Q9E3/eSaF2KHwmOpyIiV5vuagFhgY9O0lmMEoDFAieZzz
         Y9+mYj55vCzvHvk2cnGAbW7XG2TetlsJEEluH47ey33Wv/NGS/ZBS3urPuaJmHEeHOxr
         l6h7GDhPgttMgFmXY14ADgV/MMwmpMtGeR/6BYMuYQCgPSsBZKI7ZNW4nSClzGK3Mk0x
         2ccQ==
X-Google-Smtp-Source: AHgI3IbRu/Eb7OCV5IafR8R9EUYmOuKWbynRlLse1KB3hhqvHvj9Vwuo4KDPGGCru6HK/FygXbaHKg==
X-Received: by 2002:a37:a546:: with SMTP id o67mr7348379qke.42.1549678636100;
        Fri, 08 Feb 2019 18:17:16 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id w123sm9658999qkw.80.2019.02.08.18.17.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 18:17:15 -0800 (PST)
Subject: Re: CONFIG_KASAN_SW_TAGS=y not play well with kmemleak
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 kasan-dev <kasan-dev@googlegroups.com>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Linux-MM <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>
References: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw>
 <CAAeHK+yzHbLbFe7mtruEG-br9V-LZRC-n6dkq5+mmvLux0gSbg@mail.gmail.com>
 <89b343eb-16ff-1020-2efc-55ca58fafae7@lca.pw>
 <CAAeHK+zxxk8K3WjGYutmPZr_mX=u7KUcCUYXHi+OgRYMfcvLTg@mail.gmail.com>
 <d8cdc634-0f7d-446e-805a-c5d54e84323a@lca.pw>
 <59db8d6b-4224-2ec9-09de-909c4338b67a@lca.pw>
 <CAAeHK+wsULxYXnGJnQXx9HjZMiU-5jb5ZKC+TuGQihc9L386Xg@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <cb64bf1f-9291-23f6-75bc-baae844d057c@lca.pw>
Date: Fri, 8 Feb 2019 21:17:13 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <CAAeHK+wsULxYXnGJnQXx9HjZMiU-5jb5ZKC+TuGQihc9L386Xg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/8/19 12:15 PM, Andrey Konovalov wrote:
> Yeah, the issue is that kmemleak performs a bunch of pointer
> comparisons that break when pointers are tagged. Try the attached
> patch, it should fix the issue. I don't like the way this patch does
> it though, I'll see if I can come up with something better.

The patch works great!

