Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 0BD566B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 12:57:56 -0400 (EDT)
Date: Fri, 5 Jul 2013 18:52:26 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
Message-ID: <20130705165226.GA17120@redhat.com>
References: <1372901537-31033-1-git-send-email-ccross@android.com> <87txkaq600.fsf@xmission.com> <CAMbhsRTKQM1xF7syiy2aFwuqMEuJPPVYzL+Zhu-YKAfDQDRPgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMbhsRTKQM1xF7syiy2aFwuqMEuJPPVYzL+Zhu-YKAfDQDRPgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On 07/03, Colin Cross wrote:
>
> On Wed, Jul 3, 2013 at 9:54 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> > Colin Cross <ccross@android.com> writes:
> >
> > What is the advantage of this?  It looks like it is going to add cache
> > line contention (atomic_inc/atomic_dec) to every vma operation
> > especially in the envision use case of heavy vma_name sharing.
> >
> > I would expect this will result in a bloated vm_area_struct and a slower
> > mm subsystem.
>
> The advantage is better tracking of the impact of various userspace
> allocations on the overall system.  Userspace could track allocations
> on its own, but it cannot track things like physical memory usage or
> Kernel SamePage Merging per allocation.

What I can't understand completely is why do you need the string to
mark the vma's.

Just make it "unsigned long vm_id" and avoid all these complications
with get/put and "struct vma_name". And afaics you can avoid other
complications too, the new argumnent for vma_merge() is not really
needed. This patch would be trivial.

> I expect "hand break" is overstating the impact.

The code complexity (and even size) does matter too ;) It is not clear
if this new feature worth the trouble.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
