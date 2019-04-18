Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90750C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 10:40:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D4562083D
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 10:40:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D4562083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B6BB6B0010; Thu, 18 Apr 2019 06:40:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 164576B0266; Thu, 18 Apr 2019 06:40:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 005EC6B0269; Thu, 18 Apr 2019 06:40:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89E3D6B0010
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:40:03 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id v20so347932ljk.7
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 03:40:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wAlg1KOiSqebwGJaG9t1DzfCFJrSdBxkcX0xApPz9Zc=;
        b=XpcAraT9r0fEB1jUP3TR6VcpLmbfd6ptmy76GLUIkvEnlnFgj+PN0vM04OoakXVR8M
         qkRY/tkjNUrQK+5Pm68CP63AGJwgtzrNTA3K2N79u1yy2BToGrUL5vEbyl2qrJ/V5mOy
         karf8ZMq47SIX5Qqr5h8ga+EsT8XJaNoNUeFyFF6gbMhIzCDjkCMv1dyTf1lCIAVMu2K
         STd4L7tfyJz2uJoQT1C/YUm++9NoZsDenp5tNUlr7Q/MoTwqktwndPJw3tKPQW3VVlEq
         4FCmIVhwRmoIfYCz0pBCW8r+oUTs1Y/tO6ie07VH90Wt79TLVI+jBCErzTJd6bflcMx6
         Ja6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXyQ/8rrA1Ms4BsDPMa1B+4V1GI333NtTuFuckanjqsAz6gahKH
	j5S3msHzemvrRqoQ0A4VkgrmDoA7vBzhRth/bLdhS3EM6vAAKIpZn+fg/Lk4Y1bstIubQFs1uAc
	Y1P5svCDGxHc3JSVxkVtJgN6Ry89b9XZ2pylgpM2jLC8uIfVoVfkG14VRVyFu3oyrVQ==
X-Received: by 2002:a19:e30b:: with SMTP id a11mr40113717lfh.4.1555584002853;
        Thu, 18 Apr 2019 03:40:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+oNjVoyY4++SIy2BVutajGenQ7Y5f7JO138N5jjUedz4Z89i1xUgilVv0QbSPfT0Bp9s4
X-Received: by 2002:a19:e30b:: with SMTP id a11mr40113650lfh.4.1555584001567;
        Thu, 18 Apr 2019 03:40:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555584001; cv=none;
        d=google.com; s=arc-20160816;
        b=cFrr/AwNklRSAaXVHnpL2Ergmqa+LcjtPhedrPE7hd9fqms9T+IDBtUEPJJmtaKAHX
         FGcN4KYfS1E+3WZpBi7Xxtmh9m/1Naoiu8ethY7hXoP7pWA59pkEA0BA1SnlnK7jyMTE
         m3WSAYK6HT0RN+XJu8rwwPEkyLXkFX7qsYDlIz6Cvk9TZmZPuQyEoHMiz4F4Zw5NtwtB
         uWSS9tj8WPtswLPkmJaa73kykq4OrN2UaDRPyOFSYg5xrUcj3wu4Da3rqSU21YQR3say
         /y46DV5kxkBpxiFx5f5FN+mncL9xbVuA09WevEkUEfRRBEGrnIyQgwSeaL7HkrASoH8X
         AVqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=wAlg1KOiSqebwGJaG9t1DzfCFJrSdBxkcX0xApPz9Zc=;
        b=Z/Rxwohf5YMjhDQ/LioAEvfdKwIVTqhsorMgEl9cgGF/d6hsgHOTccQFj0Bdbnnf8+
         cAa+Ha3Tm0FlOGhR2C+qNm0inuH2UbLmLOYKo2zdfh7RiNNbL65fEBPFTETJn/O/PQuD
         LchNCndr7Lc4KqMw+KWJ6SnABBCdZN+v7a4g37wDH/uwlgeU9zNTk6O9GgoEJ1hvjRBT
         nWGGTy94EJ+qPav6VBqz4J1KC3vqZqJpYK0Jr7ygOrRxYA+t9A1KzeVQut24W5VUgimm
         nrIj+3i4Kjlz82MvnMNV/UruZFh93B01PTKQsYPlaw+yuKgScsCu12lptzDCMjCA5fq0
         yiwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id k21si1358345ljj.204.2019.04.18.03.40.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 03:40:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hH4Rp-0002dq-HX; Thu, 18 Apr 2019 13:39:17 +0300
Subject: Re: [patch V2 09/29] mm/kasan: Simplify stacktrace handling
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
 Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 kasan-dev@googlegroups.com, linux-mm@kvack.org,
 Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg
 <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Christoph Lameter <cl@linux.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org,
 Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>,
 Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
 linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
References: <20190418084119.056416939@linutronix.de>
 <20190418084253.903603121@linutronix.de>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <5b77992a-52b6-807e-f77d-9cf3e648c71f@virtuozzo.com>
Date: Thu, 18 Apr 2019 13:39:45 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418084253.903603121@linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 11:41 AM, Thomas Gleixner wrote:
> Replace the indirection through struct stack_trace by using the storage
> array based interfaces.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Acked-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-mm@kvack.org

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

>  
>  static inline depot_stack_handle_t save_stack(gfp_t flags)
>  {
>  	unsigned long entries[KASAN_STACK_DEPTH];
> -	struct stack_trace trace = {
> -		.nr_entries = 0,
> -		.entries = entries,
> -		.max_entries = KASAN_STACK_DEPTH,
> -		.skip = 0
> -	};
> +	unsigned int nr_entries;
>  
> -	save_stack_trace(&trace);
> -	filter_irq_stacks(&trace);
> -
> -	return depot_save_stack(&trace, flags);
> +	nr_entries = stack_trace_save(entries, ARRAY_SIZE(entries), 0);
> +	nr_entries = filter_irq_stacks(entries, nr_entries);
> +	return stack_depot_save(entries, nr_entries, flags);

Suggestion for further improvement:

stack_trace_save() shouldn't unwind beyond irq entry point so we wouldn't need filter_irq_stacks().
Probably all call sites doesn't care about random stack above irq entry point, so it doesn't
make sense to spend resources on unwinding non-irq stack from interrupt first an filtering out it later.

It would improve performance of stack_trace_save() called from interrupt and fix page_owner which feed unfiltered
stack to stack_depot_save(). Random non-irq part kills the benefit of using the stack_deopt_save().

