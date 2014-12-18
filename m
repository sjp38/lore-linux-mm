Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id EA0CE6B0070
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 09:41:37 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id wo20so3496580obc.13
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 06:41:37 -0800 (PST)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id dx2si4403004oeb.23.2014.12.18.06.41.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 06:41:36 -0800 (PST)
Received: by mail-ob0-f170.google.com with SMTP id wp18so3577450obc.1
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 06:41:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1412170953280.8347@gentwo.org>
References: <20141210163017.092096069@linux.com>
	<20141215075933.GD4898@js1304-P5Q-DELUXE>
	<CAAmzW4NCpx5aJyW36fgOfu3EaDj6=uv6MUiBC+a0ggePWPXndQ@mail.gmail.com>
	<alpine.DEB.2.11.1412170953280.8347@gentwo.org>
Date: Thu, 18 Dec 2014 23:41:35 +0900
Message-ID: <CAAmzW4PkfyUpUzwq7=hpzU3d_A431oMWi3+u6hrCb_Md3dAScw@mail.gmail.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>

2014-12-18 1:10 GMT+09:00 Christoph Lameter <cl@linux.com>:
> On Wed, 17 Dec 2014, Joonsoo Kim wrote:
>
>> +       do {
>> +               tid = this_cpu_read(s->cpu_slab->tid);
>> +               c = this_cpu_ptr(s->cpu_slab);
>> +       } while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
>
>
> Assembly code produced is a bit weird. I think the compiler undoes what
> you wanted to do:

I checked my compiled code and it seems to be no problem.
gcc (Ubuntu 4.8.2-19ubuntu1) 4.8.2

Thanks.

>  46fb:       49 8b 1e                mov    (%r14),%rbx                         rbx = c =s->cpu_slab?
>     46fe:       65 4c 8b 6b 08          mov    %gs:0x8(%rbx),%r13               r13 = tid
>     4703:       e8 00 00 00 00          callq  4708 <kmem_cache_alloc+0x48>     ??
>     4708:       89 c0                   mov    %eax,%eax                        ??
>     470a:       48 03 1c c5 00 00 00    add    0x0(,%rax,8),%rbx                ??
>     4711:       00
>     4712:       4c 3b 6b 08             cmp    0x8(%rbx),%r13                   tid == c->tid
>     4716:       49 89 d8                mov    %rbx,%r8
>     4719:       75 e0                   jne    46fb <kmem_cache_alloc+0x3b>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
