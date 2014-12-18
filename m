Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9C96B006C
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 09:38:11 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id vb8so3525559obc.7
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 06:38:10 -0800 (PST)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id f6si4369706oej.66.2014.12.18.06.38.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 06:38:10 -0800 (PST)
Received: by mail-oi0-f44.google.com with SMTP id e131so453008oig.17
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 06:38:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1412170935480.2047@gentwo.org>
References: <20141210163017.092096069@linux.com>
	<20141215075933.GD4898@js1304-P5Q-DELUXE>
	<CAAmzW4NCpx5aJyW36fgOfu3EaDj6=uv6MUiBC+a0ggePWPXndQ@mail.gmail.com>
	<alpine.DEB.2.11.1412170935480.2047@gentwo.org>
Date: Thu, 18 Dec 2014 23:38:09 +0900
Message-ID: <CAAmzW4Oyw974Zg274C2-1BcOphEJY63gx7v2QTQuULOJBzknig@mail.gmail.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>

2014-12-18 0:36 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Wed, 17 Dec 2014, Joonsoo Kim wrote:
>
>> Ping... and I found another way to remove preempt_disable/enable
>> without complex changes.
>>
>> What we want to ensure is getting tid and kmem_cache_cpu
>> on the same cpu. We can achieve that goal with below condition loop.
>>
>> I ran Jesper's benchmark and saw 3~5% win in a fast-path loop over
>> kmem_cache_alloc+free in CONFIG_PREEMPT.
>>
>> 14.5 ns -> 13.8 ns
>>
>> See following patch.
>
> Good idea. How does this affect the !CONFIG_PREEMPT case?

One more this_cpu_xxx makes fastpath slow if !CONFIG_PREEMPT.
Roughly 3~5%.

We can deal with each cases separately although it looks dirty.

#ifdef CONFIG_PREEMPT
XXX
#else
YYY
#endif

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
