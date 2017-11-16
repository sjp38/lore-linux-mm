Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C75128025F
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 03:39:43 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y41so672992wrc.22
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 00:39:43 -0800 (PST)
Received: from outbound-smtp20.blacknight.com (outbound-smtp20.blacknight.com. [46.22.139.247])
        by mx.google.com with ESMTPS id j64si804108edc.432.2017.11.16.00.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 00:39:41 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp20.blacknight.com (Postfix) with ESMTPS id 3669B1C1FC4
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 08:39:41 +0000 (GMT)
Date: Thu, 16 Nov 2017 08:39:05 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171116083905.7plphxqyvm6fxyas@techsingularity.net>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115114919.3aed1018c705347126d16075@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171115114919.3aed1018c705347126d16075@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yasu.isimatu@gmail.com, koki.sanagi@us.fujitsu.com

On Wed, Nov 15, 2017 at 11:49:19AM -0800, Andrew Morton wrote:
> On Wed, 15 Nov 2017 08:55:56 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > Yasuaki Ishimatsu reported a premature OOM when trace_buf_size=100m was
> > specified on a machine with many CPUs. The kernel tried to allocate 38.4GB
> > but only 16GB was available due to deferred memory initialisation.
> > 
> > The allocation context is within smp_init() so there are no opportunities
> > to do the deferred meminit earlier. Furthermore, the partial initialisation
> > of memory occurs before the size of the trace buffers is set so there is
> > no opportunity to adjust the amount of memory that is pre-initialised. We
> > could potentially catch when memory is low during system boot and adjust the
> > amount that is initialised serially but it's a little clumsy as it would
> > require a check in the failure path of the page allocator.  Given that
> > deferred meminit is basically a minor optimisation that only benefits very
> > large machines and trace_buf_size is somewhat specialised, it follows that
> > the most straight-forward option is to go back to serialised meminit if
> > trace_buf_size is specified.
> 
> Patch is rather messy.
> 
> I went cross-eyed trying to work out how tracing allocates that buffer,
> but I assume it ends up somewhere in the page allocator. 

Basic path is

[ ]  __alloc_pages_slowpath+0x9a6/0xba7
[ ]  __alloc_pages_nodemask+0x26a/0x290
[ ]  new_slab+0x297/0x500
[ ]  ___slab_alloc+0x335/0x4a0
[ ]  __slab_alloc+0x40/0x66
[ ]  __kmalloc_node+0xbd/0x270
[ ]  __rb_allocate_pages+0xae/0x180
[ ]  rb_allocate_cpu_buffer+0x204/0x2f0
[ ]  trace_rb_cpu_prepare+0x7e/0xc5
[ ]  cpuhp_invoke_callback+0x3ea/0x5c0
[ ]  _cpu_up+0xbc/0x190
[ ]  do_cpu_up+0x87/0xb0
[ ]  cpu_up+0x13/0x20
[ ]  smp_init+0x69/0xca
[ ]  kernel_init_freeable+0x115/0x244

Note that it's during smp_init and part of the CPU onlining which is before
deferred meminit can start.

> If the page
> allocator is about to fail an allocation request and sees that memory
> initialization is still ongoing, surely the page allocator should just
> wait?  That seems to be the most general fix?
> 

In other contexts yes, but as deferred meminit has not started, there is
nothing to wait for yet.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
