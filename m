Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59EF3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:04:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 191AB2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:04:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="H0IFfx5I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 191AB2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90AC98E0019; Wed, 20 Feb 2019 09:04:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BAA38E0002; Wed, 20 Feb 2019 09:04:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 784AF8E0019; Wed, 20 Feb 2019 09:04:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CCDD8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 09:04:51 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id q11so1282565qtj.16
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 06:04:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=vUS0w4HZER/7vU1o3TeXFsL51VGLF3ky6o3uMQAO1dI=;
        b=K3AA1R7Ue8VpgqneM6Kus6YLNsebaDIBaPrhzcX0yxjdNHmQV7vdA1ojKVAirqa4T7
         NrRfBRbX8FO0HH5te+40dd3xpQnxd+IJbGEVcEB2+JMGE2jeVuo5jfUu8wEIegmXRh6O
         0dfV+MhK9q/4rHN5kB+UhR8zRlO0nUdNUO4nm5ODGLxktgkH56x+XIffHK9u5/CGJUJa
         Omj8V0Yq8zjjdorpOI9wdOxoSs9VK7HcZJk0Osm8TWyIbIdXsPMESgdl651anUU53yPf
         yWwBiXi94z2rSlmcDUwiFno62TROZLO2/bD1arheKde6d2sHD72PlToKg9Wj5h2jo/JB
         Xemw==
X-Gm-Message-State: AHQUAub9rf6XrrhLAS2O3TzazaR42g1FG/cyWwGJmbpZbNqoVFZ9vcxZ
	i7exyXF32R60nkM7V5c1uuqVVKf0AnIRuzhXACNCzVsHxdeo9x8L/h5BEe4vynUvPyL6GIFfWke
	31eM0YG/3D5e8dLvvlOiLMtpdXf9hBp05cnlr9YZuy3+CkE/8rz3XtgA3ft5OJZQ166g6pGaN9f
	7SG86RPZPrdAUA5StL2qKF18ftzClLC5KooNvi+aABotpWPODjhwwYM6g7iWGnPqMSCOi2zJ/dy
	Qiygtlu6ZfDsDz5n83GLX6VqFulkCXhgUDqoGpj9x1VJQ//H+z4SU1fedYbNE1269SeaYnWcugg
	hF9/heJCvruQZULmWvuIyyiLvyuajgdEoSvgF/hDMmQqMJVttaLe7B9grLZHMnamh27B/nYXnMS
	c
X-Received: by 2002:a0c:d24f:: with SMTP id o15mr25173817qvh.145.1550671490836;
        Wed, 20 Feb 2019 06:04:50 -0800 (PST)
X-Received: by 2002:a0c:d24f:: with SMTP id o15mr25173767qvh.145.1550671490325;
        Wed, 20 Feb 2019 06:04:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550671490; cv=none;
        d=google.com; s=arc-20160816;
        b=YGPtqNA2Sm56J7IhU5aUhtTlrbLWXKuTQl96GMfcl3SwoCwK5GURL0cqTzliaN/rzd
         5kFh/UNupkvkQyDQLkp3Rwjq+lLTJhz+ySJS3g0kLk1/uNL0wonMjNfViug3+xR/AaaV
         1PTLnAUdKkexS8ibquLiO6iO9VjNU3ocZm/OrhjSx4iVyJ8qlp1lUwV0CPfuFZ59IoV9
         ogck73hSAdcanxxdushcqKPThq8ZeWOl9T+0AODucHUTY2ld2MkLuyGlMCuVCutgEJnN
         iiIXXwif57hdcZQA/kXtyyX1inIL8iHoy8euckrUQye+UMc1dE8mWO9DIB+/5aRq79Cr
         aYrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=vUS0w4HZER/7vU1o3TeXFsL51VGLF3ky6o3uMQAO1dI=;
        b=eSWSf1xfoYAQ0QD6L/PBGcBw/IqNXD3PswWOJPeRnVQzLEaCgVuzjqNFcJKEcPcg5n
         D502ECtZGUkigN7scjUytvpglBsEYS/oTHm6em6ZwIruZ1DuxSdwqHNndAXABsMg6asj
         4ial2rFUM326A0C6ijBRdM2FJVwKfren1b3F6+kmEY4q34TjVhILjJcd2gZsnkZgtW8B
         jElnRdkbNHwfCADtxp4U4qgF+Yau3nC3fcAETyu4M9mEim7ZEveBYt0tV/0XKbBYBYME
         NC4FerGjQVnn1ny2fj8qvhsQn917WUkUNZorEv///x7CSE6uqIW0otWj0DT71lxFRsCk
         1U7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=H0IFfx5I;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l11sor22006798qvr.48.2019.02.20.06.04.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 06:04:50 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=H0IFfx5I;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=vUS0w4HZER/7vU1o3TeXFsL51VGLF3ky6o3uMQAO1dI=;
        b=H0IFfx5IA0SwX6RGoO+INsRy2pLUroLphF9hbWRPVLMSJWZrGBJnhsMHi050h0oTuN
         m8MDV/4YR2kzQb1N6qBOj8op2Vo9lQA1tGStjsaK67BpopJmae40iCwHCXGs2Re+guQM
         Sca3L1jdKGIhQ3TI3hGinBqX1zl4NpISW4y2mRrlqKYRpWfMA3j90157H/nkjI35bTIU
         k21YkGlxt6Eurx+heIFLuU11STlR9JM9mvQ1p2UyMTB8NOD/tD9CaWFoM/kgo60hgqA2
         5sooFW2+yJqUz9hye2jJ0oeNf0brXkBK+iFYCvJqYKWbIAK80KJpCKJLzjPGDqF3GC62
         18tg==
X-Google-Smtp-Source: AHgI3IZpSNv4wgvr9AekEnTUGVfBAo+cWathJ+gH2WTvPj+9QbBuy1OHVE7/M+fhmVmkV5ud6v0v+g==
X-Received: by 2002:a0c:c687:: with SMTP id d7mr26088549qvj.86.1550671489884;
        Wed, 20 Feb 2019 06:04:49 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id x32sm10190915qtj.32.2019.02.20.06.04.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 06:04:48 -0800 (PST)
Subject: Re: [PATCH 1/4] kasan: prevent tracing of tags.c
To: Andrey Konovalov <andreyknvl@google.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>,
 Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>
References: <9c4c3ce5ccfb894c7fe66d91de7c1da2787b4da4.1550602886.git.andreyknvl@google.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <b058e23d-8950-5cb1-b60f-6f4055b876fd@lca.pw>
Date: Wed, 20 Feb 2019 09:04:47 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <9c4c3ce5ccfb894c7fe66d91de7c1da2787b4da4.1550602886.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/20/19 7:45 AM, Andrey Konovalov wrote:
> Similarly to 0d0c8de8 ("kasan: mark file common so ftrace doesn't trace
> it") add the -pg flag to mm/kasan/tags.c to prevent conflicts with
> tracing.
> 
> Reported-by: Qian Cai <cai@lca.pw>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Tested-by: Qian Cai <cai@lca.pw>

