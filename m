Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id B87B26B0036
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 16:25:46 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id oz10so2100249veb.19
        for <linux-mm@kvack.org>; Fri, 05 Jul 2013 13:25:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130704085604.GI18898@dyad.programming.kicks-ass.net>
References: <1372901537-31033-1-git-send-email-ccross@android.com>
	<20130704085604.GI18898@dyad.programming.kicks-ass.net>
Date: Fri, 5 Jul 2013 13:25:45 -0700
Message-ID: <CAMbhsRTD0GKTwLaF8q4_A9qq0VjFL_uDv75=qGt3p5LmX3TN5w@mail.gmail.com>
Subject: Re: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Oleg Nesterov <oleg@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On Thu, Jul 4, 2013 at 1:56 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Wed, Jul 03, 2013 at 06:31:56PM -0700, Colin Cross wrote:
>> Userspace processes often have multiple allocators that each do
>> anonymous mmaps to get memory.  When examining memory usage of
>> individual processes or systems as a whole, it is useful to be
>> able to break down the various heaps that were allocated by
>> each layer and examine their size, RSS, and physical memory
>> usage.
>
> So why not 'abuse' deleted files?
>

That's effectively what ashmem does for this use case, but it has its
issues when allocators ask the kernel for memory multiple times.
There are two ways to implement it in userspace, either reusing the
same fd or using a new fd for every allocation.

Using a new fd results in mappings that cannot be merged.  In one
example process in Android (system_server) this resulted in doubling
the number of vmas used, which is far more expensive than the single
pointer and refcounting added by this patch, and in another process
(GLBenchmark) resulted in 16000 individual mappings, each with
assocated vma, struct file, and refcounting.

Reusing the same fd fundamentally changes the semantics of the memory.
 It requires the allocator to keep a global fd and offset variable,
and extend the file and map the new region to get the kernel to merge
the mappings.  This inherently ties the memory together - AFAICT the
kernel will not reclaim any of the memory until either the whole file
is unmapped and the fd is closed, or userspace manually calls
MADV_REMOVE.  It's not immediately clear from the madvise man page
what would happen after a fork if one process calls MADV_REMOVE on
MAP_PRIVATE tmpfs memory, but if it really goes directly to the
backing store won't those pages disappear for both processes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
