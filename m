Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 381306B00A5
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 22:03:27 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so30010786pad.37
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 19:03:27 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id j2si86636616pdo.128.2015.01.05.19.03.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 19:03:25 -0800 (PST)
Message-ID: <1420513392.24290.2.camel@stgolabs.net>
Subject: Re: [PATCH 1/2] mm/slub: optimize alloc/free fastpath by removing
 preemption on/off
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 05 Jan 2015 19:03:12 -0800
In-Reply-To: <1420421765-3209-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1420421765-3209-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>

On Mon, 2015-01-05 at 10:36 +0900, Joonsoo Kim wrote:
> -	preempt_disable();
> -	c = this_cpu_ptr(s->cpu_slab);
> +	do {
> +		tid = this_cpu_read(s->cpu_slab->tid);
> +		c = this_cpu_ptr(s->cpu_slab);
> +	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> +	barrier();

I don't see the compiler reodering the object/page stores below, since c
is updated in the loop anyway. Is this really necessary (same goes for
slab_free)? The generated code by gcc 4.8 looks correct without it.
Additionally, the implied barriers for preemption control aren't really
the same semantics used here (if that is actually the reason why you are
using them).

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
