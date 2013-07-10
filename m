Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 6BEC76B0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 19:20:56 -0400 (EDT)
Message-ID: <51DDEC52.7010005@intel.com>
Date: Wed, 10 Jul 2013 16:20:50 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
References: <1372901537-31033-1-git-send-email-ccross@android.com> <20130704085604.GI18898@dyad.programming.kicks-ass.net> <CAMbhsRTD0GKTwLaF8q4_A9qq0VjFL_uDv75=qGt3p5LmX3TN5w@mail.gmail.com>
In-Reply-To: <CAMbhsRTD0GKTwLaF8q4_A9qq0VjFL_uDv75=qGt3p5LmX3TN5w@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: Peter Zijlstra <peterz@infradead.org>, lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Oleg Nesterov <oleg@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, open@kvack.org, list@kvack.org, DOCUMENTATION <linux-doc@vger.kernel.org>open@kvack.orglist@kvack.org, MEMORY MANAGEMENT <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On 07/05/2013 01:25 PM, Colin Cross wrote:
> On Thu, Jul 4, 2013 at 1:56 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>> On Wed, Jul 03, 2013 at 06:31:56PM -0700, Colin Cross wrote:
>>> Userspace processes often have multiple allocators that each do
>>> anonymous mmaps to get memory.  When examining memory usage of
>>> individual processes or systems as a whole, it is useful to be
>>> able to break down the various heaps that were allocated by
>>> each layer and examine their size, RSS, and physical memory
>>> usage.
>>
>> So why not 'abuse' deleted files?
>>
> That's effectively what ashmem does for this use case, but it has its
> issues when allocators ask the kernel for memory multiple times.
> There are two ways to implement it in userspace, either reusing the
> same fd or using a new fd for every allocation.

Does mremap() help for expanding/shrinking the mappings?  If you
mmap()'d the middle of a large, deleted tmpfs file, you should be able
to expand the VMA either up or down by quite a bit.

> Reusing the same fd fundamentally changes the semantics of the memory.
>  It requires the allocator to keep a global fd and offset variable,
> and extend the file and map the new region to get the kernel to merge
> the mappings.

The checkpoint/restart folks had some patches to let you get access to
file descriptors which were closed but were used to mmap() something.  I
don't know where those went, but you'd be able to turn a mmap()'d
address in to a fd with them, I believe.

> This inherently ties the memory together - AFAICT the
> kernel will not reclaim any of the memory until either the whole file
> is unmapped and the fd is closed, or userspace manually calls
> MADV_REMOVE.

Huh?  The kernel can reclaim mapped userspace memory just fine whether
it's anonymous (or tmpfs) or file-backed.  tmpfs is treated very
similarly to swappable anonymous memory in this respect.

> It's not immediately clear from the madvise man page
> what would happen after a fork if one process calls MADV_REMOVE on
> MAP_PRIVATE tmpfs memory, but if it really goes directly to the
> backing store won't those pages disappear for both processes?

MAP_PRIVATE means "divorced from the backing store".  MADV_REMOVE only
affects the caller's address space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
