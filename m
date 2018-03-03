Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E42E16B0007
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 16:18:25 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id d77so3943015lfg.11
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 13:18:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 87sor2181502ljr.12.2018.03.03.13.18.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Mar 2018 13:18:24 -0800 (PST)
From: Uladzislau Rezki <urezki@gmail.com>
Date: Sat, 3 Mar 2018 22:18:05 +0100
Subject: Re: [RFC v1] mm: add the preempt check into alloc_vmap_area()
Message-ID: <20180303211805.gadu4eg5bd63hvrs@pc636>
References: <20180227102259.4629-1-urezki@gmail.com>
 <20180227130643.GA12781@bombadil.infradead.org>
 <20180302153452.748892bd70bb23b9cee23691@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180302153452.748892bd70bb23b9cee23691@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>

On Fri, Mar 02, 2018 at 03:34:52PM -0800, Andrew Morton wrote:
> On Tue, 27 Feb 2018 05:06:43 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > On Tue, Feb 27, 2018 at 11:22:59AM +0100, Uladzislau Rezki (Sony) wrote:
> > > During finding a suitable hole in the vmap_area_list
> > > there is an explicit rescheduling check for latency reduction.
> > > We do it, since there are workloads which are sensitive for
> > > long (more than 1 millisecond) preemption off scenario.
> > 
> > I understand your problem, but this is a horrid solution.  If it takes
> > us a millisecond to find a suitable chunk of free address space, something
> > is terribly wrong.  On a 3GHz CPU, that's 3 million clock ticks!
> 
> Yup.
> 
> > I think our real problem is that we have no data structure that stores
> > free VA space.  We have the vmap_area which stores allocated space, but no
> > data structure to store free space.
> 
> I wonder if we can reuse free_vmap_cache as a quick fix: if
> need_resched(), point free_vmap_cache at the current rb_node, drop the
> lock, cond_resched, goto retry?
> 
It sounds like we can. But there is a concern if that potentially can
introduce a degrade of search time due to changing a starting point
for our search.

--
Vlad Rezki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
