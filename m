Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 869D46B0032
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 14:44:25 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id l13so10259256iga.14
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 11:44:25 -0800 (PST)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id q15si4153670ics.106.2014.12.17.11.44.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 11:44:24 -0800 (PST)
Date: Wed, 17 Dec 2014 13:44:21 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
In-Reply-To: <alpine.DEB.2.11.1412170953280.8347@gentwo.org>
Message-ID: <alpine.DEB.2.11.1412171339450.29803@gentwo.org>
References: <20141210163017.092096069@linux.com> <20141215075933.GD4898@js1304-P5Q-DELUXE> <CAAmzW4NCpx5aJyW36fgOfu3EaDj6=uv6MUiBC+a0ggePWPXndQ@mail.gmail.com> <alpine.DEB.2.11.1412170953280.8347@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, 17 Dec 2014, Christoph Lameter wrote:

> On Wed, 17 Dec 2014, Joonsoo Kim wrote:
>
> > +       do {
> > +               tid = this_cpu_read(s->cpu_slab->tid);
> > +               c = this_cpu_ptr(s->cpu_slab);
> > +       } while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));

Here is another one without debugging:

   0xffffffff811d23bb <+59>:	mov    %gs:0x8(%r9),%rdx		tid(rdx) = this_cpu_read()
   0xffffffff811d23c0 <+64>:	mov    %r9,%r8
   0xffffffff811d23c3 <+67>:	add    %gs:0x7ee37d9d(%rip),%r8         c (r8) =
   0xffffffff811d23cb <+75>:	cmp    0x8(%r8),%rdx			c->tid == tid
   0xffffffff811d23cf <+79>:	jne    0xffffffff811d23bb <kmem_cache_alloc+59>

Actually that looks ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
