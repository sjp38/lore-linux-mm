Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EC17B6B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 17:58:47 -0400 (EDT)
Date: Thu, 1 Sep 2011 14:58:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v2 -mm] add extra free kbytes tunable
Message-Id: <20110901145819.4031ef7c.akpm@linux-foundation.org>
In-Reply-To: <20110901152650.7a63cb8b@annuminas.surriel.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, Seiji Aguchi <saguchi@redhat.com>, hughd@google.com, hannes@cmpxchg.org

On Thu, 1 Sep 2011 15:26:50 -0400
Rik van Riel <riel@redhat.com> wrote:

> Add a userspace visible knob

argh.  Fear and hostility at new knobs which need to be maintained for
ever, even if the underlying implementation changes.

Unfortunately, this one makes sense.

> to tell the VM to keep an extra amount
> of memory free, by increasing the gap between each zone's min and
> low watermarks.
> 
> This is useful for realtime applications that call system
> calls and have a bound on the number of allocations that happen
> in any short time period.  In this application, extra_free_kbytes
> would be left at an amount equal to or larger than than the
> maximum number of allocations that happen in any burst.

_is_ it useful?  Proof?

Who is requesting this?  Have they tested it?  Results?

> It may also be useful to reduce the memory use of virtual
> machines (temporarily?), in a way that does not cause memory
> fragmentation like ballooning does.

Maybe.  You need to alter the setting, then somehow persuade all the
targeted kswapd's to start running, then somehow determine that they've
done their thing, then unalter the /proc setting.  Not the best API
we've ever designed ;)

> ...
>  
> +extra_free_kbytes
> +
> +This parameter tells the VM to keep extra free memory between the threshold
> +where background reclaim (kswapd) kicks in, and the threshold where direct
> +reclaim (by allocating processes) kicks in.
> +
> +This is useful for workloads that require low latency memory allocations
> +and have a bounded burstiness in memory allocations, for example a
> +realtime application that receives and transmits network traffic
> +(causing in-kernel memory allocations) with a maximum total message burst
> +size of 200MB may need 200MB of extra free memory to avoid direct reclaim
> +related latencies.
> +
> +==============================================================

It's upsetting that the names min_free_kbytes and extra_free_kbytes
don't map onto the kernel variables (WMARK_MIN, WMARK_LOW, WMARK_HIGH)
and also that they just aren't very communicative.

Oh well, doesn't matter much.

> ...
> +/*
> + * Extra memory for the system to try freeing. Used to temporarily
> + * free memory, to make space for new workloads. Anyone can allocate
> + * down to the min watermarks controlled by min_free_kbytes above.
> + */

The comment isn't really complete, is it?  There are valid use cases
where an alteration here isn't temporary.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
