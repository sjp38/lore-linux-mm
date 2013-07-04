Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id F1A6E6B0036
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 02:32:52 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id oz10so786150veb.19
        for <linux-mm@kvack.org>; Wed, 03 Jul 2013 23:32:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87txkaq600.fsf@xmission.com>
References: <1372901537-31033-1-git-send-email-ccross@android.com>
	<87txkaq600.fsf@xmission.com>
Date: Wed, 3 Jul 2013 23:32:51 -0700
Message-ID: <CAMbhsRTKQM1xF7syiy2aFwuqMEuJPPVYzL+Zhu-YKAfDQDRPgQ@mail.gmail.com>
Subject: Re: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, Oleg Nesterov <oleg@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On Wed, Jul 3, 2013 at 9:54 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Colin Cross <ccross@android.com> writes:
>
>> Userspace processes often have multiple allocators that each do
>> anonymous mmaps to get memory.  When examining memory usage of
>> individual processes or systems as a whole, it is useful to be
>> able to break down the various heaps that were allocated by
>> each layer and examine their size, RSS, and physical memory
>> usage.
>
> What is the advantage of this?  It looks like it is going to add cache
> line contention (atomic_inc/atomic_dec) to every vma operation
> especially in the envision use case of heavy vma_name sharing.
>
> I would expect this will result in a bloated vm_area_struct and a slower
> mm subsystem.

The advantage is better tracking of the impact of various userspace
allocations on the overall system.  Userspace could track allocations
on its own, but it cannot track things like physical memory usage or
Kernel SamePage Merging per allocation.

The disadvantage is one pointer per vma struct, which would increase
the size on an allnoconfig x86_64 kernel from 176 to 184, which puts
the vm_name pointer in the same cache line as vm_file.  For non-named
vmas there is no other cost.  For named vmas there will be some
cacheline contention, but no more than caused by the vm_file refcount.
 The refcounting happens at the same time as the vm_file refcounting,
and I expect most uses of vm_name to be on anonymous memory, so in
general it will make the cost of named anonymous mappings the same as
file mappings.

> Have you done any benchmarks that stress the mm subsystem?

Not yet, but it's on my list.

> How can adding glittler to /proc/<pid>/maps and /proc/<pid>/smaps
> justify putting a hand break on the linux kernel?

I expect "hand break" is overstating the impact.  I could put it
behind a CONFIG_DEBUG_NAMED_VMAS option, but that seems unnecessary
since the impact for systems that choose not to use MADV_NAME will be
tiny.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
