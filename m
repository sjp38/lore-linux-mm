Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 635BE6B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 07:44:17 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id c41-v6so317559plj.10
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 04:44:17 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50106.outbound.protection.outlook.com. [40.107.5.106])
        by mx.google.com with ESMTPS id 62si11357012pgd.45.2018.03.07.04.44.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Mar 2018 04:44:16 -0800 (PST)
Subject: Re: [PATCH] kasan, slub: fix handling of kasan_slab_free hook
References: <083f58501e54731203801d899632d76175868e97.1519400992.git.andreyknvl@google.com>
 <26dd94c5-19ca-dca6-07b8-7103f53c0130@virtuozzo.com>
 <CAAeHK+y4hze8CUDMJ_G6W+diBO88+WYu892SK9QAt36y8nbZYQ@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <c7249bc3-8488-00c9-666a-8d31fb3feb83@virtuozzo.com>
Date: Wed, 7 Mar 2018 15:43:51 +0300
MIME-Version: 1.0
In-Reply-To: <CAAeHK+y4hze8CUDMJ_G6W+diBO88+WYu892SK9QAt36y8nbZYQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Kostya Serebryany <kcc@google.com>



On 03/06/2018 08:42 PM, Andrey Konovalov wrote:

>>> -     if (s->flags & SLAB_KASAN && !(s->flags & SLAB_TYPESAFE_BY_RCU))
>>> -             return;
>>> -     do_slab_free(s, page, head, tail, cnt, addr);
>>> +     slab_free_freelist_hook(s, &head, &tail);
>>> +     if (head != NULL)
>>
>> That's an additional branch in non-debug fast-path. Find a way to avoid this.
> 
> Hm, there supposed to be a branch here. We either have objects that we
> need to free, or we don't, and we need to do different things in those
> cases. Previously this was done with a hardcoded "if (s->flags &
> SLAB_KASAN && ..." statement, not it's a different "if (head !=
> NULL)".
> 

They are different. "if (s->flags & SLAB_KASAN && ..." can be optimized away by compiler when CONFIG_KASAN=n,
"if (head != NULL)" - can not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
