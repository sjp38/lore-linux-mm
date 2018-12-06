Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 902B66B7976
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 05:26:06 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id q23so23546966ior.6
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 02:26:06 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n129si13662169iof.2.2018.12.06.02.26.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Dec 2018 02:26:05 -0800 (PST)
Date: Thu, 6 Dec 2018 11:25:59 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Number of arguments in vmalloc.c
Message-ID: <20181206102559.GG13538@hirez.programming.kicks-ass.net>
References: <20181128140136.GG10377@bombadil.infradead.org>
 <3264149f-e01e-faa2-3bc8-8aa1c255e075@suse.cz>
 <20181203161352.GP10377@bombadil.infradead.org>
 <4F09425C-C9AB-452F-899C-3CF3D4B737E1@gmail.com>
 <20181203224920.GQ10377@bombadil.infradead.org>
 <C377D9EF-A0F4-4142-8145-6942DC29A353@gmail.com>
 <EB579DAE-B25F-4869-8529-8586DF4AECFF@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <EB579DAE-B25F-4869-8529-8586DF4AECFF@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>

On Thu, Dec 06, 2018 at 12:28:26AM -0800, Nadav Amit wrote:
> [ +Peter ]
> 
> So I dug some more (I’m still not done), and found various trivial things
> (e.g., storing zero extending u32 immediate is shorter for registers,
> inlining already takes place).
> 
> *But* there is one thing that may require some attention - patch
> b59167ac7bafd ("x86/percpu: Fix this_cpu_read()”) set ordering constraints
> on the VM_ARGS() evaluation. And this patch also imposes, it appears,
> (unnecessary) constraints on other pieces of code.
> 
> These constraints are due to the addition of the volatile keyword for
> this_cpu_read() by the patch. This affects at least 68 functions in my
> kernel build, some of which are hot (I think), e.g., finish_task_switch(),
> smp_x86_platform_ipi() and select_idle_sibling().
> 
> Peter, perhaps the solution was too big of a hammer? Is it possible instead
> to create a separate "this_cpu_read_once()” with the volatile keyword? Such
> a function can be used for native_sched_clock() and other seqlocks, etc.

No. like the commit writes this_cpu_read() _must_ imply READ_ONCE(). If
you want something else, use something else, there's plenty other
options available.

There's this_cpu_op_stable(), but also __this_cpu_read() and
raw_this_cpu_read() (which currently don't differ from this_cpu_read()
but could).
