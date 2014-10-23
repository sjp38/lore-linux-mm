Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 764756B0080
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:18:32 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id m20so439822qcx.16
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:18:32 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id y104si3022570qgd.126.2014.10.23.07.18.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 07:18:31 -0700 (PDT)
Date: Thu, 23 Oct 2014 09:18:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/4] [RFC] slub: Fastpath optimization (especially for
 RT)
In-Reply-To: <20141023080942.GA7598@js1304-P5Q-DELUXE>
Message-ID: <alpine.DEB.2.11.1410230916090.19494@gentwo.org>
References: <20141022155517.560385718@linux.com> <20141023080942.GA7598@js1304-P5Q-DELUXE>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Thu, 23 Oct 2014, Joonsoo Kim wrote:

> Preemption disable during very short code would cause large problem for RT?

This is the hotpath and preempt enable/disable adds a significant number
of cycles.

> And, if page_address() and virt_to_head_page() remain as current patchset
> implementation, this would work worse than before.

Right.

> I looked at the patchset quickly and found another idea to remove
> preemption disable. How about just retrieving s->cpu_slab->tid first,
> before accessing s->cpu_slab, in slab_alloc() and slab_free()?
> Retrieved tid may ensure that we aren't migrated to other CPUs so that
> we can remove code for preemption disable.

You cannot do any of these things because you need the tid from the right
cpu and the scheduler can prempt you and reschedule you on another
processor at will. tid and c may be from different per cpu areas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
