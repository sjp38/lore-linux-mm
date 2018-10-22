Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6F0A6B000D
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 10:01:19 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id s7-v6so12882539ljh.3
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 07:01:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m95-v6sor8196615lfi.17.2018.10.22.07.01.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 07:01:18 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
Date: Mon, 22 Oct 2018 16:01:08 +0200
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181022140108.jwahqbudbn4xiw43@pc636>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181019224432.GA616@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019224432.GA616@tower.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

On Fri, Oct 19, 2018 at 10:44:39PM +0000, Roman Gushchin wrote:
> On Fri, Oct 19, 2018 at 07:35:36PM +0200, Uladzislau Rezki (Sony) wrote:
> > Objective
> > ---------
> > Initiative of improving vmalloc allocator comes from getting many issues
> > related to allocation time, i.e. sometimes it is terribly slow. As a result
> > many workloads which are sensitive for long (more than 1 millisecond) preemption
> > off scenario are affected by that slowness(test cases like UI or audio, etc.).
> > 
> > The problem is that, currently an allocation of the new VA area is done over
> > busy list iteration until a suitable hole is found between two busy areas.
> > Therefore each new allocation causes the list being grown. Due to long list
> > and different permissive parameters an allocation can take a long time on
> > embedded devices(milliseconds).
> ...
> > 3) This one is related to PCPU allocator(see pcpu_alloc_test()). In that
> > stress test case i see that SUnreclaim(/proc/meminfo) parameter gets increased,
> > i.e. there is a memory leek somewhere in percpu allocator. It sounds like
> > a memory that is allocated by pcpu_get_vm_areas() sometimes is not freed.
> > Resulting in memory leaking or "Kernel panic":
> > 
> 
> Can you, please, try the following patch:
> 6685b357363b ("percpu: stop leaking bitmap metadata blocks") ?
>
I have tested that patch. It fixes the leak for sure. Thank you for a
good point.

> 
> BTW, with growing number of vmalloc users (per-cpu allocator and bpf stuff are
> big drivers), I find the patchset very interesting.
> 
> Thanks!
Thank you!

--
Vlad Rezki
