Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE2DB6B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 16:23:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p2so23741167pfk.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 13:23:37 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u19si7546994pfg.51.2017.10.09.13.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 13:23:36 -0700 (PDT)
Subject: Re: [PATCH] page_alloc.c: inline __rmqueue()
References: <20171009054434.GA1798@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3a46edcf-88f8-e4f4-8b15-3c02620308e4@intel.com>
Date: Mon, 9 Oct 2017 13:23:34 -0700
MIME-Version: 1.0
In-Reply-To: <20171009054434.GA1798@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>

On 10/08/2017 10:44 PM, Aaron Lu wrote:
> __rmqueue() is called by rmqueue_bulk() and rmqueue() under zone->lock
> and that lock can be heavily contended with memory intensive applications.

What does "memory intensive" mean?  I'd probably just say: "The two
__rmqueue() call sites are in very hot page allocator paths."

> Since __rmqueue() is a small function, inline it can save us some time.
> With the will-it-scale/page_fault1/process benchmark, when using nr_cpu
> processes to stress buddy:

Please include a description of the test and a link to the source.

> On a 2 sockets Intel-Skylake machine:
>       base          %change       head
>      77342            +6.3%      82203        will-it-scale.per_process_ops

What's the unit here?  That seems ridiculously low for page_fault1.
It's usually in the millions.

> On a 4 sockets Intel-Skylake machine:
>       base          %change       head
>      75746            +4.6%      79248        will-it-scale.per_process_ops

It's probably worth noting the reason that this is _less_ beneficial on
a larger system.

I'd also just put this in text rather than wasting space in tables like
that.  It took me a few minutes to figure out what the table was trying
top say.  This is one of those places where LKP output is harmful.

Why not just say:

	This patch improved the benchmark by 6.3% on a 2-socket system
	and 4.6% on a 4-socket system.

> This patch adds inline to __rmqueue().

How much text bloat does this cost?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
