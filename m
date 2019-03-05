Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06584C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 21:52:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FF6C2075B
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 21:52:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FF6C2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gmx.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 249A48E0003; Tue,  5 Mar 2019 16:52:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CE9A8E0001; Tue,  5 Mar 2019 16:52:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 070E78E0003; Tue,  5 Mar 2019 16:52:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A073F8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 16:52:10 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id o6so6197681wrm.2
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 13:52:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=opDYyNsAU6Od9Y6mgauFqS0O+9sv1SrOAfuPswGTE8Y=;
        b=Sger609GDSfNaoN78QLp/ECsCdey/2xuzvmxzeeV+G0wqg4O7B9YgJFHC2KxgcuoBh
         J0+p4unXs9X5QJ+9nYE0w3q79bTnXmH8zOLQk5k8Bk5/PK/zjik2vdVPeHn27Gavn2M8
         +sCY4OKcguckiVnytweYN2lpwJEFhv443uLe7Bk/DpJvu/grYBslgyZsrQq0X9wf4Hpx
         lFNLycYwzXHTcJ3gKdLUvJPFkZl6yo0dg3Mj5SDwHgKpK521HyV1G+bAVY4ZrMMK655c
         B/1HMDcGY2ztNeMCGeSRpJ8Hp1yyukKTheIZy3Ue4WqM1idqEQkK2qwLJ4rUKL+bPs/w
         kO0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of deller@gmx.de designates 212.227.15.15 as permitted sender) smtp.mailfrom=deller@gmx.de
X-Gm-Message-State: APjAAAXGCudBjRBh/1pce6Y03wuJPpCRRUfGOxfO86KUmTf2X+tLWOQr
	Q27E37MHUB2qQ1Kgxt/qCb13B7/90S9S8QcOpd050XYclibijpdBDiU3j2UOPxRvT0FoXPKAsDr
	nNmbjKF8wPTrE6zkMqGvCpObcPQw9zgcihJGrZFZhwslGhF3BYPxbW7kd4TS35ybkXg==
X-Received: by 2002:a5d:4e44:: with SMTP id r4mr611374wrt.228.1551822730211;
        Tue, 05 Mar 2019 13:52:10 -0800 (PST)
X-Google-Smtp-Source: APXvYqzyK93upv5inPW6Vhet2JvnYgwuj3TEpqCkgWjkZeyTaOJ75tHzAUOyOGFzmq1cOCOeM3YG
X-Received: by 2002:a5d:4e44:: with SMTP id r4mr611356wrt.228.1551822729432;
        Tue, 05 Mar 2019 13:52:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551822729; cv=none;
        d=google.com; s=arc-20160816;
        b=TaAhApNVqQDGXJyK56ZkY8k+4Juh99NpnaX9qJsrCCotfgVYRIxF37MTr2DpjMK6i+
         NS9NhfksJjr5laakI9+e3IoDifa7v6Rc4ZdoQ7Oaq4cluJQ1XIDyhMqLCImmc46+jWRg
         J2iy4YFmYXk9wSLl93qEt9cNELqlfGrnV0YsmjONLdOYryf3Dx9hYFh/9zMZ7+pHvwe0
         mkEnpI770rAvYDNIJ7xJXUgeFCbRAjCuidO3IdyLUFgdLAnz9g/rDXtE5idP0vDEExI6
         QlyFySONCjnmTULv8uId0awRMLJm1QEvEfOTRAjtpAWtYJYrVawBhXEAbUdf/PI0aqoM
         LGdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=opDYyNsAU6Od9Y6mgauFqS0O+9sv1SrOAfuPswGTE8Y=;
        b=lsZqbr4AYMH4k24I+fpbVplG4+moAYkUQH/otyW1EwIjF65JXQxY6i0Z6rDap05Ajm
         L2hNmQwydaOFle4YTX1k6huG4M0M4KlCdTQe42oZf+DfSeXIuJRtkYoP6gvB7b410YGN
         /zYlarP7kRU/VbxNfnIKi5BKVN7huABEn59MJKof9f4vv2E9HL75y+dNEbaKLpr/1JQB
         khYn0nnCIn9AcR1QLgI7CNte4f7oCI4E44yGsdiYbV1MyD3ltyvrmAyGYibBnLDbVw6U
         x/DmyPyElvm8Z52G8lA0F8BKpsI4MWER0y1ECHgL/eIea+fATd0LZEeAdehNG1NJeeq/
         OXTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of deller@gmx.de designates 212.227.15.15 as permitted sender) smtp.mailfrom=deller@gmx.de
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id s197si338318wme.169.2019.03.05.13.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 13:52:09 -0800 (PST)
Received-SPF: pass (google.com: domain of deller@gmx.de designates 212.227.15.15 as permitted sender) client-ip=212.227.15.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of deller@gmx.de designates 212.227.15.15 as permitted sender) smtp.mailfrom=deller@gmx.de
Received: from [192.168.20.60] ([92.116.130.110]) by mail.gmx.com (mrgmx002
 [212.227.17.190]) with ESMTPSA (Nemesis) id 0MRo6b-1gYr0x3lqj-00StVO; Tue, 05
 Mar 2019 22:45:59 +0100
Subject: Re: [PATCH v3 15/34] parisc: mm: Add p?d_large() definitions
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
 Andy Lutomirski <luto@kernel.org>, Ard Biesheuvel
 <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>,
 James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 Mark Rutland <Mark.Rutland@arm.com>, "Liang, Kan"
 <kan.liang@linux.intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>,
 linux-parisc@vger.kernel.org
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-16-steven.price@arm.com>
 <fa3072ba-f02b-fee5-dc16-d575a5308d4b@gmx.de>
 <20190301221213.snm7cwowr67pdifs@kshutemo-mobl1>
From: Helge Deller <deller@gmx.de>
Openpgp: preference=signencrypt
Autocrypt: addr=deller@gmx.de; keydata=
 xsBNBFDPIPYBCAC6PdtagIE06GASPWQJtfXiIzvpBaaNbAGgmd3Iv7x+3g039EV7/zJ1do/a
 y9jNEDn29j0/jyd0A9zMzWEmNO4JRwkMd5Z0h6APvlm2D8XhI94r/8stwroXOQ8yBpBcP0yX
 +sqRm2UXgoYWL0KEGbL4XwzpDCCapt+kmarND12oFj30M1xhTjuFe0hkhyNHkLe8g6MC0xNg
 KW3x7B74Rk829TTAtj03KP7oA+dqsp5hPlt/hZO0Lr0kSAxf3kxtaNA7+Z0LLiBqZ1nUerBh
 OdiCasCF82vQ4/y8rUaKotXqdhGwD76YZry9AQ9p6ccqKaYEzWis078Wsj7p0UtHoYDbABEB
 AAHNHEhlbGdlIERlbGxlciA8ZGVsbGVyQGdteC5kZT7CwJIEEwECADwCGwMGCwkIBwMCBhUI
 AgkKCwQWAgMBAh4BAheAFiEE9M/0wAvkPPtRU6Boh8nBUbUeOGQFAlrHzIICGQEACgkQh8nB
 UbUeOGT1GAgAt+EeoHB4DbAx+pZoGbBYp6ZY8L6211n8fSi7wiwgM5VppucJ+C+wILoPkqiU
 +ZHKlcWRbttER2oBUvKOt0+yDfAGcoZwHS0P+iO3HtxR81h3bosOCwek+TofDXl+TH/WSQJa
 iaitof6iiPZLygzUmmW+aLSSeIAHBunpBetRpFiep1e5zujCglKagsW78Pq0DnzbWugGe26A
 288JcK2W939bT1lZc22D9NhXXRHfX2QdDdrCQY7UsI6g/dAm1d2ldeFlGleqPMdaaQMcv5+E
 vDOur20qjTlenjnR/TFm9tA1zV+K7ePh+JfwKc6BSbELK4EHv8J8WQJjfTphakYLVM7ATQRQ
 zyD2AQgA2SJJapaLvCKdz83MHiTMbyk8yj2AHsuuXdmB30LzEQXjT3JEqj1mpvcEjXrX1B3h
 +0nLUHPI2Q4XWRazrzsseNMGYqfVIhLsK6zT3URPkEAp7R1JxoSiLoh4qOBdJH6AJHex4CWu
 UaSXX5HLqxKl1sq1tO8rq2+hFxY63zbWINvgT0FUEME27Uik9A5t8l9/dmF0CdxKdmrOvGMw
 T770cTt76xUryzM3fAyjtOEVEglkFtVQNM/BN/dnq4jDE5fikLLs8eaJwsWG9k9wQUMtmLpL
 gRXeFPRRK+IT48xuG8rK0g2NOD8aW5ThTkF4apznZe74M7OWr/VbuZbYW443QQARAQABwsBf
 BBgBAgAJBQJQzyD2AhsMAAoJEIfJwVG1HjhkNTgH/idWz2WjLE8DvTi7LvfybzvnXyx6rWUs
 91tXUdCzLuOtjqWVsqBtSaZynfhAjlbqRlrFZQ8i8jRyJY1IwqgvHP6PO9s+rIxKlfFQtqhl
 kR1KUdhNGtiI90sTpi4aeXVsOyG3572KV3dKeFe47ALU6xE5ZL5U2LGhgQkbjr44I3EhPWc/
 lJ/MgLOPkfIUgjRXt0ZcZEN6pAMPU95+u1N52hmqAOQZvyoyUOJFH1siBMAFRbhgWyv+YE2Y
 ZkAyVDL2WxAedQgD/YCCJ+16yXlGYGNAKlvp07SimS6vBEIXk/3h5Vq4Hwgg0Z8+FRGtYZyD
 KrhlU0uMP9QTB5WAUvxvGy8=
Message-ID: <6d2bc08b-d336-1b1a-2408-6259dafff995@gmx.de>
Date: Tue, 5 Mar 2019 22:45:55 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190301221213.snm7cwowr67pdifs@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:LdLxPVii8ZtTFSzQTHGX/xHJKUnsknfi5/X+gB/PzHjktFyjw4X
 qKKtlrR+3kluRrRkObR/s+jd+5A00AT3VdqIHUj3NAuH7L23fRp4hj2q4b6uXoYSv7gCg37
 9+bmlps0QIP0hHILRXnGjB53IQG26fmh22jSuDvpR9+XdUgQltKRTxWKrHQdMyo6dLC9uCl
 e/V2AkiGVtdD2CAE7+CUA==
X-UI-Out-Filterresults: notjunk:1;V03:K0:irbHxkZxFQo=:Y1LCKgOume5iWrxqYdKz/o
 IzHkwPi5QzkiKT4avVPgosX84Vn4p4A0brYV3DJMZaU8c9rwEbpWGlHjkmrlt7tKnmDWtw0+z
 bP7MekaITNCENyA3Hmx5F/p1DXbCyrHna00/6qRHwR0zXuhthFJaLOS+hWo5Yny2AlKKcRXIx
 NotFrxuHbdiI0+rOas6YekCiIX5SofHWjSiF/bZwcaz8T7y1aSEYbQefGEf40pgoqgi7Y+07S
 SMjDHTiyLjukT4RQvLB+yJe93lc8geCH659bGF1QKCY8YRbQjEbgjr0ZLen1np4lUZvg5LEBB
 UYcvMlQs4fp593x27eDzo/HrnnL38/+j+55WBNWi+99sYaVIsNsCKDrYMfspn1k6BLAKPDc7Y
 DAMUzwKAYQgzO1Q/1+8qJJb1x9URytqMmlQDhwZ3SOwaTWsx24ravKDIJl/zg57gRYMlV6Kbl
 6wiA6TrInin08KNw7Y0EAP1y9UGtes/KfBmymCTloL/EKJzdyQSfl17JsveF3/s3zKLey7GMu
 lUpsdYupt6LWeQ8bTmIrfFmyzYG6FBRRFtpXEdzuwI4OHZicv8nyeNJT9UCd+1tKO4G4vnovJ
 jM9kij6C/RhACK5OAqGoZFTh6aLasob0fuV30uOcV5z96Xn5lRkDcYNjOLagY34w0lD+THdVF
 m+k1Tbue3TEoNT4sMgZV29mhiCA0+3a+Raa2Y5WuzHwskuhsssec0fqQZpRrvhrSEaCl0AMhm
 miJqIGjginWkcryHbZeuGbU2bE0YOwz0iNEyVE+txGQQkq9DgjfH7eWnGMvtMoeormA9JipcN
 Ha5EfsWRyAWBoOHGd80sbxDJ7JYNRkW8XKWlX/VjSdVChb/GebTRkorj5LuakbumVnBrz0f+M
 JvBez3gjXcW4wSSdMFabV4SXQSGZSFHttS2q9x6I1/ItFC4+KZHuQQ15nRauV5IbCQjhMo/mW
 iHb1oL/u3+09gySia5j80y7K5+nEf9FPO+ZrJMr41FnDCMXRyQHCxIJ7IkrIDbu88Nx+ZEUPw
 VFxYm4hD8aSP9IBh9o/lsz5bYKKJRWc8hocdJc6Wo8PbWO7s710XEg2tQGF5N0xcDToxNivdN
 yz0GN39JxhMN0Hk75ps2plmO3DO1sWN4BHr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.03.19 23:12, Kirill A. Shutemov wrote:
> On Wed, Feb 27, 2019 at 07:54:22PM +0100, Helge Deller wrote:
>> On 27.02.19 18:05, Steven Price wrote:
>>> walk_page_range() is going to be allowed to walk page tables other than
>>> those of user space. For this it needs to know when it has reached a
>>> 'leaf' entry in the page tables. This information is provided by the
>>> p?d_large() functions/macros.
>>>
>>> For parisc, we don't support large pages, so add stubs returning 0.
>>
>> We do support huge pages on parisc, but not yet on those levels.
> 
> Just curious, what level do parisc supports huge pages on?
> AFAICS, it can have 2- or 3- level paging and the patch defines helpers
> for two level: pgd and pmd. Hm?

You are correct.
My comment was misleading and meant to say that we do support generic
huge pages for applications.

Helge

