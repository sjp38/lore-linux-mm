Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE4F6B0253
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 14:49:23 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v186so1178143wma.9
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 11:49:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x1si16514141wrd.29.2017.11.15.11.49.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 11:49:22 -0800 (PST)
Date: Wed, 15 Nov 2017 11:49:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-Id: <20171115114919.3aed1018c705347126d16075@linux-foundation.org>
In-Reply-To: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yasu.isimatu@gmail.com, koki.sanagi@us.fujitsu.com

On Wed, 15 Nov 2017 08:55:56 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> Yasuaki Ishimatsu reported a premature OOM when trace_buf_size=100m was
> specified on a machine with many CPUs. The kernel tried to allocate 38.4GB
> but only 16GB was available due to deferred memory initialisation.
> 
> The allocation context is within smp_init() so there are no opportunities
> to do the deferred meminit earlier. Furthermore, the partial initialisation
> of memory occurs before the size of the trace buffers is set so there is
> no opportunity to adjust the amount of memory that is pre-initialised. We
> could potentially catch when memory is low during system boot and adjust the
> amount that is initialised serially but it's a little clumsy as it would
> require a check in the failure path of the page allocator.  Given that
> deferred meminit is basically a minor optimisation that only benefits very
> large machines and trace_buf_size is somewhat specialised, it follows that
> the most straight-forward option is to go back to serialised meminit if
> trace_buf_size is specified.

Patch is rather messy.

I went cross-eyed trying to work out how tracing allocates that buffer,
but I assume it ends up somewhere in the page allocator.  If the page
allocator is about to fail an allocation request and sees that memory
initialization is still ongoing, surely the page allocator should just
wait?  That seems to be the most general fix?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
