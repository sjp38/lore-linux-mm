Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17BCEC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:30:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB57B213F2
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:30:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB57B213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 312AB6B0003; Tue, 18 Jun 2019 10:30:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29D1C8E0002; Tue, 18 Jun 2019 10:30:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18BD08E0001; Tue, 18 Jun 2019 10:30:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id A7AF66B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 10:30:01 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id l10so2687346ljj.10
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 07:30:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hBJ+NpZhxOYKRrCNDnK4rIykmHUYap4lZr8Y18iy/+0=;
        b=HiITG0dKFplZjfyU9Ll7x3gzL+wVDzQ9xlWs8iQD0xjucKEr5uvJirQgRtzM/3O+id
         /dY15fAr/m5AfWCQx9mw5DeOvaa2J2SwRrV8f1XpDzaaeb8b1j1c99jPZdRbrPNRhGGM
         fGQhMFrBqb+XGuY9grIng6i1YAgbG3ojzKntXztHfOFoODeF/BWjx4d6CcNra2xhCs/2
         AyDopefzgBIFwcSM/UnYnWQmh1e826GW9Ha0y0Cj8PL6RE1lk+zWpCzxbttFB7NCxIUM
         XjBU1ReilxB3Ga31e6Na1KvvVrR6cp5+UmVjJIsVxs8+SZevA/d/VD+sDlneDmqmQtbS
         j7Rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXN2/thW0N9wrda2Q4gMSPNBJyeLW7nVPT13q9vyGs6hMb74czo
	n2qdMzDTN2RT5WOHglkIKNHDRLtY9onmnc6Gx8WRBbIX7nDwVE8UnDDV3Tm2tAKIGwYBhuC5gn/
	/dcOVD5Du6y+ZF4iCHVi4RuLsTLnBAQ9GZJ4npniT3Fn8BMinwqUmfFXNUAlXPH9f9Q==
X-Received: by 2002:a2e:9d09:: with SMTP id t9mr12770076lji.151.1560868201129;
        Tue, 18 Jun 2019 07:30:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjJ0IgVg/gRSBwRpPPfKO1TFnI2Ouv2Lzd6JFZTSOoFHil98Os0PU4rypsbO/J2rwHNMRZ
X-Received: by 2002:a2e:9d09:: with SMTP id t9mr12770046lji.151.1560868200402;
        Tue, 18 Jun 2019 07:30:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560868200; cv=none;
        d=google.com; s=arc-20160816;
        b=nlkzD5y+h8m+RzaaBo795uQMSx6PXHZgzRxBAtYr9HekQzfOA5tzXKoqm9tWKUNWTA
         R3AzfXfHCu1caBw0ho+CYvrEb4yLpT6Y2V60PsF0wl+z0eb6weg/Dr9U7/FHtaI5/H+4
         Vx4Ug85ucMnyaj4qSZseU23x99BUg9/VNx0VZ+tnxHoO+Dhto79JBo6+xfs5coklzdq9
         jQFwscg7XyV91nM5b48uzZD2Ru80UHCSE29G7yeGZcXc80C4o/PnNelhmAs11lV++Eob
         27BTnyQGGTPPHJ3nEzAf45PNRwhpOH2GjdpX+SLJegwABNMZfxM5X5lUAFIE3pm7rQi5
         vpDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=hBJ+NpZhxOYKRrCNDnK4rIykmHUYap4lZr8Y18iy/+0=;
        b=Ko4c2prVn7tX3z4CfloeNeIJAGBsHGDY99avta1gZ+iUZrTeBBxEgOZ4QOwkYAA9MO
         cACCnBykMLBY09HxoL0bBZIfrKvzVdJgZWYNjSpH5ZzUNgMGUs23Yx30HOiLBieVFbuX
         +1TNpxFz6R3rZwzOsd5kP3DEzhKmoVLxGe7NVz7LLfA765jxf1k+GQdhtOFtPdcLW39x
         hLpqgrAj5qpViqW1SzGKRuhFI3Hob9KkisGDPZ7W/HPvqW1AzpwIm07Z/Tz23hyQHTQ/
         UdqZacGlQVGV6859Ce65W3LodoMweSKVyEbOGaiXDr6f2RA2T43JgU5cS+qbMKwhPNKv
         ch+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id k19si13832408lje.62.2019.06.18.07.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 07:30:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hdF7P-00025K-Kt; Tue, 18 Jun 2019 17:29:51 +0300
Subject: Re: [PATCH] [v2] page flags: prioritize kasan bits over last-cpuid
To: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>,
 Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, Andrey Konovalov <andreyknvl@google.com>,
 Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>,
 Mark Rutland <mark.rutland@arm.com>,
 Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org
References: <20190618095347.3850490-1-arnd@arndb.de>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5ac26e68-8b75-1b06-eecd-950987550451@virtuozzo.com>
Date: Tue, 18 Jun 2019 17:30:02 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190618095347.3850490-1-arnd@arndb.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/18/19 12:53 PM, Arnd Bergmann wrote:
> ARM64 randdconfig builds regularly run into a build error, especially
> when NUMA_BALANCING and SPARSEMEM are enabled but not SPARSEMEM_VMEMMAP:
> 
>  #error "KASAN: not enough bits in page flags for tag"
> 
> The last-cpuid bits are already contitional on the available space,
> so the result of the calculation is a bit random on whether they
> were already left out or not.
> 
> Adding the kasan tag bits before last-cpuid makes it much more likely
> to end up with a successful build here, and should be reliable for
> randconfig at least, as long as that does not randomize NR_CPUS
> or NODES_SHIFT but uses the defaults.
> 
> In order for the modified check to not trigger in the x86 vdso32 code
> where all constants are wrong (building with -m32), enclose all the
> definitions with an #ifdef.
> 

Why not keep "#error "KASAN: not enough bits in page flags for tag"" under "#ifdef CONFIG_KASAN_SW_TAGS" ?

