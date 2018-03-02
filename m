Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4A36B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 18:34:56 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id p2so7353961wre.19
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 15:34:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q21si5384177wrc.267.2018.03.02.15.34.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 15:34:55 -0800 (PST)
Date: Fri, 2 Mar 2018 15:34:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC v1] mm: add the preempt check into alloc_vmap_area()
Message-Id: <20180302153452.748892bd70bb23b9cee23691@linux-foundation.org>
In-Reply-To: <20180227130643.GA12781@bombadil.infradead.org>
References: <20180227102259.4629-1-urezki@gmail.com>
	<20180227130643.GA12781@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>

On Tue, 27 Feb 2018 05:06:43 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> On Tue, Feb 27, 2018 at 11:22:59AM +0100, Uladzislau Rezki (Sony) wrote:
> > During finding a suitable hole in the vmap_area_list
> > there is an explicit rescheduling check for latency reduction.
> > We do it, since there are workloads which are sensitive for
> > long (more than 1 millisecond) preemption off scenario.
> 
> I understand your problem, but this is a horrid solution.  If it takes
> us a millisecond to find a suitable chunk of free address space, something
> is terribly wrong.  On a 3GHz CPU, that's 3 million clock ticks!

Yup.

> I think our real problem is that we have no data structure that stores
> free VA space.  We have the vmap_area which stores allocated space, but no
> data structure to store free space.

I wonder if we can reuse free_vmap_cache as a quick fix: if
need_resched(), point free_vmap_cache at the current rb_node, drop the
lock, cond_resched, goto retry?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
