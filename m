Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B50FC10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:13:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F1B2206BA
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:13:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F1B2206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 892666B0005; Tue,  2 Apr 2019 12:13:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 818956B000D; Tue,  2 Apr 2019 12:13:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E2776B0010; Tue,  2 Apr 2019 12:13:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02CD46B0005
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 12:13:41 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id c21so3586055lji.18
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 09:13:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Uw79iZ7sAZkoCb17sWgbfAe/sIPibxyl+pAeQRTBWX0=;
        b=GoRo5kn8OUtdLwiX2lB4wvgsI8ipjEihj4k3gijkHhphPTqVOFA8V2aDkFnIjMFxqk
         OgGI7kx1HwaK8/M/Cbxb7oOwvAlsuobn4chObuQLTNHmcNMGnhYJhWPpuulbwzNURpRJ
         h9XRaB/YW1tGBQqVibtKZHjhkqQ8LvYPA6mPOdAZiuyVvFzw59pwjB1EsBKP0CwRghfM
         EGhOBHiOeATmAgwlcpgjOAMpPQseAP2JFlbCuxIVxUwVJp0/d+TbhA/wvtrOqn4drE5z
         Wn77pFlL52qtoLWvUjqfKgZ/mkq8UcGQS/WeFxfcOsbkICdigOOGt4u16Moqc9RtkxQA
         Ckhw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWpoaeHBZVebYTZaYlzhKnHLhJbwxBGPVXq5otmLA8Zr+p/DqzK
	rvHoMm0HE7dEXEerX8y3ZYI8+KskjasJS8t4ngOhUU/cJMdX+Dx/MU//jPnSGJNezceWKzSoBBm
	Zb0laoIeQp0SfEP+Xq1Szk9ndYPM/tk5EworNOSp3/tpgBjRzy2jQjGyjZ8s8EaZ/fg==
X-Received: by 2002:a2e:844a:: with SMTP id u10mr27836369ljh.41.1554221620244;
        Tue, 02 Apr 2019 09:13:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw311hm71JElsHXAw95w3CcVcTt4lm/KkGH+txKRcU4OjuRi0xtpnDsbcS4mqBcDHlouvCp
X-Received: by 2002:a2e:844a:: with SMTP id u10mr27836328ljh.41.1554221619361;
        Tue, 02 Apr 2019 09:13:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554221619; cv=none;
        d=google.com; s=arc-20160816;
        b=ZXBbsPOHuwOeJIUew8/+HcqUzIRGzpdVuEIh68zxex4+vb1TGKBCEGFmMhiZ7pxleO
         hgXyaXf9sUFAGqn/ynZxHv5SRpKNxalBhn0ADEqIjJ8nnofFFvdKlsjYY0rbRbVppnfP
         YJ4ywezD0iwXt6p5U9XCk0eBtD3JKTlCW+5mY8zq1tzogZHrJgEI1AaTS72NtYkO2kV8
         njgufulSrvE98t0wWS+Mkj/msWxFg5F3FfH+vrbZvMzTzv2ydDE15qiZ1sksy7cUJvmS
         6BFdhG1Up4jAa2Rdeesa8HbImdnpJvM9YT7bVNykecd390vSmGUtpDuL6wCjuH2cl10t
         kntQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Uw79iZ7sAZkoCb17sWgbfAe/sIPibxyl+pAeQRTBWX0=;
        b=FCr4ERjHBD+N4+xJcJolK7lRxp+uAsOW10/a1q7JoO7vogVFZCswUQcKpTo19UqFmO
         cs7Bi+m93UZhBdN/yOiQbdHZuSJQgSesacpoZOFHLtXBPbSgqveHB7R/SRqYiikUIqQn
         xHhKgB+1MU5NOGOPawUVZRPtmC1ntE93aP/J05eailW2+WgDFtI4spkF+tjb4He9Pgk8
         V1UKiKemEfnxj6BQQZPPnFPL2IMzJJy1PKSa1/7PUuX4KTE6LiRdxfmZPfgWAb7CIX/J
         CNf6/S9py8h6JfxCbZOjrPIyWipiU8Gvf/p7SHSdSwMX2D8ejvTdUspoGdgFzGvmUyMj
         iezg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id c20si9859103lja.0.2019.04.02.09.13.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 09:13:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hBM2U-00028a-GG; Tue, 02 Apr 2019 19:13:30 +0300
Subject: Re: [RFC PATCH v2 3/3] kasan: add interceptors for all string
 functions
To: Christophe Leroy <christophe.leroy@c-s.fr>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Daniel Axtens <dja@axtens.net>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com
References: <f13944c4e99ec2cef6d93d762e6b526e0335877f.1553785019.git.christophe.leroy@c-s.fr>
 <51a6d9d7185de310f37ccbd7e4ebfdd6c7e9791f.1553785020.git.christophe.leroy@c-s.fr>
 <3211b0f8-7b52-01b7-8208-65d746969248@c-s.fr>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ae9262e5-0917-b7c9-52c7-fe21db2ecacb@virtuozzo.com>
Date: Tue, 2 Apr 2019 19:14:02 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <3211b0f8-7b52-01b7-8208-65d746969248@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/2/19 12:43 PM, Christophe Leroy wrote:
> Hi Dmitry, Andrey and others,
> 
> Do you have any comments to this series ?
> 

I don't see justification for adding all these non-instrumented functions. We need only some subset of these functions
and only on powerpc so far. Arches that don't use str*() that early simply doesn't need not-instrumented __str*() variant.

Also I don't think that auto-replace str* to __str* for all not instrumented files is a good idea, as this will reduce KASAN coverage.
E.g. we don't instrument slub.c but there is no reason to use non-instrumented __str*() functions there.

And finally, this series make bug reporting slightly worse. E.g. let's look at strcpy():

+char *strcpy(char *dest, const char *src)
+{
+	size_t len = __strlen(src) + 1;
+
+	check_memory_region((unsigned long)src, len, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
+
+	return __strcpy(dest, src);
+}

If src is not-null terminated string we might not see proper out-of-bounds report from KASAN only a crash in __strlen().
Which might make harder to identify where 'src' comes from, where it was allocated and what's the size of allocated area.


> I'd like to know if this approach is ok or if it is better to keep doing as in https://patchwork.ozlabs.org/patch/1055788/
>
I think the patch from link is a better solution to the problem.

