Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5B61F6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 22:51:09 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so21665799pab.4
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 19:51:09 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.225])
        by mx.google.com with ESMTP id gz10si4041533pbd.94.2015.01.15.19.51.07
        for <linux-mm@kvack.org>;
        Thu, 15 Jan 2015 19:51:08 -0800 (PST)
Date: Thu, 15 Jan 2015 22:51:30 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by
 removing preemption on/off
Message-ID: <20150115225130.00c0c99a@grimm.local.home>
In-Reply-To: <alpine.DEB.2.11.1501152126300.13976@gentwo.org>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20150115171634.685237a4.akpm@linux-foundation.org>
	<20150115203045.00e9fb73@grimm.local.home>
	<alpine.DEB.2.11.1501152126300.13976@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Thu, 15 Jan 2015 21:27:14 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> 
> The %gs register is not used since the address of the per cpu area is
> available as one of the first fields in the per cpu areas.

Have you disassembled your code?

Looking at put_cpu_partial() from 3.19-rc3 where it does:

		oldpage = this_cpu_read(s->cpu_slab->partial);

I get:

		mov    %gs:0x18(%rax),%rdx

Looks to me that %gs is used.


I haven't done benchmarks in a while, so perhaps accessing the %gs
segment isn't as expensive as I saw it before. I'll have to profile
function tracing on my i7 and see where things are slow again.


-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
