Date: Tue, 8 Apr 2003 06:01:52 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.67-mm1
Message-ID: <20030408130152.GS993@holomorphy.com>
References: <20030408042239.053e1d23.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030408042239.053e1d23.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 08, 2003 at 04:22:39AM -0700, Andrew Morton wrote:
> +remove-nr_reverse_maps.patch
>  Remove /proc/meminfo:ReverseMaps.   It is measurably expensive.

This is fine. The changelog comment doesn't look right though. It says
it's inferrable from slabinfo; it's meant to measure the number of
reverse mappings performed, or aggregate faulted-in virtualspace on the
system, or the number of PTE's pointing at userspace data.

The internal fragmentation within slabs is a separate notion.
pte_chains carry more than a single pointer, so the net utilization and
internal fragmentation of the things allocated can be computed from
nr_reverse_maps/(#pte_chains * NR_PTE), and is very different from the
internal fragmentation of slabs (there is no relationship whatsoever).

This stuff has been disturbed on several occasions, and effectively
lost whatever meaning it had left after PG_direct anyway, regardless
of who changed it to mean what, as the accounting was never adjusted to
remove PG_direct reverse mappings (the actions, not any kind of space)
from the count due to not being able to identify the notion that would
be measured by it. nr_shared_reverse_maps? It's dead, kill it.

-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
