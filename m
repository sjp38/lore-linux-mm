Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF666B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:56:01 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id f9so12816455wra.2
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 03:56:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10si1152719eda.449.2017.11.15.03.55.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 03:56:00 -0800 (PST)
Date: Wed, 15 Nov 2017 12:55:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yasu.isimatu@gmail.com, koki.sanagi@us.fujitsu.com

On Wed 15-11-17 08:55:56, Mel Gorman wrote:
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

Can we instead do a smaller trace buffer in the early stage and then
allocate the rest after the whole memory is initialized? The early
memory init code is quite complex to make it even more so for something
that looks like a borderline useful usecase. Seriously, who is going
need 100M trace buffer _per cpu_ during early boot?

> Reported-and-tested-by: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
