Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 805EA6B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 07:37:26 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id bb5-v6so1063557plb.22
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 04:37:26 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0093.outbound.protection.outlook.com. [104.47.0.93])
        by mx.google.com with ESMTPS id 14-v6si12786717plb.444.2018.03.07.04.37.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Mar 2018 04:37:24 -0800 (PST)
Subject: Re: [PATCH v2] kasan, slub: fix handling of kasan_slab_free hook
References: <a62759a2545fddf69b0c034547212ca1eb1b3ce2.1520359686.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4e0eb106-1b1e-93ba-af4f-6714413422c3@virtuozzo.com>
Date: Wed, 7 Mar 2018 15:36:59 +0300
MIME-Version: 1.0
In-Reply-To: <a62759a2545fddf69b0c034547212ca1eb1b3ce2.1520359686.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>



On 03/06/2018 09:18 PM, Andrey Konovalov wrote:
> The kasan_slab_free hook's return value denotes whether the reuse of a
> slab object must be delayed (e.g. when the object is put into memory
> qurantine).
> 
> The current way SLUB handles this hook is by ignoring its return value
> and hardcoding checks similar (but not exactly the same) to the ones
> performed in kasan_slab_free, which is prone to making mistakes.
> 
> The main difference between the hardcoded checks and the ones in
> kasan_slab_free is whether we want to perform a free in case when an
> invalid-free or a double-free was detected (we don't).
> 
> This patch changes the way SLUB handles this by:
> 1. taking into account the return value of kasan_slab_free for each of
>    the objects, that are being freed;
> 2. reconstructing the freelist of objects to exclude the ones, whose
>    reuse must be delayed.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
