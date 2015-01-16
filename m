Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2036B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 20:30:26 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id r10so19535093pdi.9
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 17:30:26 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.229])
        by mx.google.com with ESMTP id ut9si3776132pac.59.2015.01.15.17.30.24
        for <linux-mm@kvack.org>;
        Thu, 15 Jan 2015 17:30:25 -0800 (PST)
Date: Thu, 15 Jan 2015 20:30:45 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by
 removing preemption on/off
Message-ID: <20150115203045.00e9fb73@grimm.local.home>
In-Reply-To: <20150115171634.685237a4.akpm@linux-foundation.org>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20150115171634.685237a4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Thu, 15 Jan 2015 17:16:34 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> > I saw roughly 5% win in a fast-path loop over kmem_cache_alloc/free
> > in CONFIG_PREEMPT. (14.821 ns -> 14.049 ns)
> 
> I'm surprised.  preempt_disable/enable are pretty fast.  I wonder why
> this makes a measurable difference.  Perhaps preempt_enable()'s call
> to preempt_schedule() added pain?

profiling function tracing I discovered that accessing preempt_count
was actually quite expensive, even just to read. But it may not be as
bad since Peter Zijlstra converted preempt_count to a per_cpu variable.
Although, IIRC, the perf profiling showed the access to the %gs
register was where the time consuming was happening, which is what
I believe per_cpu variables still use.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
