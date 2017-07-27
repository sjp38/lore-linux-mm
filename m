Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4222D6B04C3
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 15:48:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z48so34267546wrc.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:48:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g83si2086497wmf.233.2017.07.27.12.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 12:48:58 -0700 (PDT)
Date: Thu, 27 Jul 2017 12:48:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] cpuset: fix a deadlock due to incomplete patching of
 cpusets_enabled()
Message-Id: <20170727124855.aeb97ea9f74af2d3e47e1787@linux-foundation.org>
In-Reply-To: <20170727164608.12701-1-dmitriyz@waymo.com>
References: <alpine.DEB.2.20.1707261158560.9311@nuc-kabylake>
	<20170727164608.12701-1-dmitriyz@waymo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dima Zavin <dmitriyz@waymo.com>
Cc: Christopher Lameter <cl@linux.com>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Cliff Spradlin <cspradlin@waymo.com>, Mel Gorman <mgorman@techsingularity.net>

On Thu, 27 Jul 2017 09:46:08 -0700 Dima Zavin <dmitriyz@waymo.com> wrote:

> In codepaths that use the begin/retry interface for reading
> mems_allowed_seq with irqs disabled, there exists a race condition that
> stalls the patch process after only modifying a subset of the
> static_branch call sites.
> 
> This problem manifested itself as a dead lock in the slub
> allocator, inside get_any_partial. The loop reads
> mems_allowed_seq value (via read_mems_allowed_begin),
> performs the defrag operation, and then verifies the consistency
> of mem_allowed via the read_mems_allowed_retry and the cookie
> returned by xxx_begin. The issue here is that both begin and retry
> first check if cpusets are enabled via cpusets_enabled() static branch.
> This branch can be rewritted dynamically (via cpuset_inc) if a new
> cpuset is created. The x86 jump label code fully synchronizes across
> all CPUs for every entry it rewrites. If it rewrites only one of the
> callsites (specifically the one in read_mems_allowed_retry) and then
> waits for the smp_call_function(do_sync_core) to complete while a CPU is
> inside the begin/retry section with IRQs off and the mems_allowed value
> is changed, we can hang. This is because begin() will always return 0
> (since it wasn't patched yet) while retry() will test the 0 against
> the actual value of the seq counter.
> 
> The fix is to cache the value that's returned by cpusets_enabled() at the
> top of the loop, and only operate on the seqcount (both begin and retry) if
> it was true.

Tricky.  Hence we should have a nice code comment somewhere describing
all of this.

> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -16,6 +16,11 @@
>  #include <linux/mm.h>
>  #include <linux/jump_label.h>
>  
> +struct cpuset_mems_cookie {
> +	unsigned int seq;
> +	bool was_enabled;
> +};

At cpuset_mems_cookie would be a good site - why it exists, what it
does, when it is used and how.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
