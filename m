Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 3F3156B0034
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 17:56:48 -0400 (EDT)
Date: Tue, 9 Jul 2013 14:56:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: mempolicy: fix mbind_range() && vma_adjust()
 interaction
Message-Id: <20130709145645.bd48e31c1a7d9e83d521b845@linux-foundation.org>
In-Reply-To: <20130708180501.GB6490@redhat.com>
References: <1372901537-31033-1-git-send-email-ccross@android.com>
	<20130704202232.GA19287@redhat.com>
	<CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com>
	<20130708180424.GA6490@redhat.com>
	<20130708180501.GB6490@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Colin Cross <ccross@android.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Hampson, Steven T" <steven.t.hampson@intel.com>, lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On Mon, 8 Jul 2013 20:05:01 +0200 Oleg Nesterov <oleg@redhat.com> wrote:

> vma_adjust() does vma_set_policy(vma, vma_policy(next)) and this
> is doubly wrong:
> 
> 1. This leaks vma->vm_policy if it is not NULL and not equal to
>    next->vm_policy.
> 
>    This can happen if vma_merge() expands "area", not prev (case 8).
> 
> 2. This sets the wrong policy if vma_merge() joins prev and area,
>    area is the vma the caller needs to update and it still has the
>    old policy.
> 
> Revert 1444f92c "mm: merging memory blocks resets mempolicy" which
> introduced these problems.
> 
> Change mbind_range() to recheck mpol_equal() after vma_merge() to
> fix the problem 1444f92c tried to address.
> 

So I assume the kernel still passes Steven's testcase from the
1444f92c changelog?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
