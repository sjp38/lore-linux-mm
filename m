Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 58B0A6B0068
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 18:11:44 -0400 (EDT)
Date: Wed, 17 Oct 2012 15:11:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 00/14] kmem controller for memcg.
Message-Id: <20121017151142.71e1f3c5.akpm@linux-foundation.org>
In-Reply-To: <1350382611-20579-1-git-send-email-glommer@parallels.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org

On Tue, 16 Oct 2012 14:16:37 +0400
Glauber Costa <glommer@parallels.com> wrote:

> ...
>
> A general explanation of what this is all about follows:
> 
> The kernel memory limitation mechanism for memcg concerns itself with
> disallowing potentially non-reclaimable allocations to happen in exaggerate
> quantities by a particular set of processes (cgroup). Those allocations could
> create pressure that affects the behavior of a different and unrelated set of
> processes.
> 
> Its basic working mechanism is to annotate some allocations with the
> _GFP_KMEMCG flag. When this flag is set, the current process allocating will
> have its memcg identified and charged against. When reaching a specific limit,
> further allocations will be denied.

The need to set _GFP_KMEMCG is rather unpleasing, and makes one wonder
"why didn't it just track all allocations".

Does this mean that over time we can expect more sites to get the
_GFP_KMEMCG tagging?  If so, are there any special implications, or do
we just go in, do the one-line patch and expect everything to work?  If
so, why don't we go in and do that tagging right now?

And how *accurate* is the proposed code?  What percentage of kernel
memory allocations are unaccounted, typical case and worst case?

All sorts of questions come to mind over this decision, but it was
unexplained.  It should be, please.  A lot!

>
> ...
> 
> Limits lower than
> the user limit effectively means there is a separate kernel memory limit that
> may be reached independently than the user limit. Values equal or greater than
> the user limit implies only that kernel memory is tracked. This provides a
> unified vision of "maximum memory", be it kernel or user memory.
>

I'm struggling to understand that text much at all.  Reading the
Documentation/cgroups/memory.txt patch helped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
