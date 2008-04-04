From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
Date: Fri, 4 Apr 2008 12:11:40 -0700
Message-ID: <6599ad830804041211r37848a6coaa900d8bdac40fbe@mail.gmail.com>
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain>
	 <6599ad830804040112q3dd5333aodf6a170c78e61dc8@mail.gmail.com>
	 <47F5E69C.9@linux.vnet.ibm.com>
	 <6599ad830804040150j4946cf92h886bb26000319f3b@mail.gmail.com>
	 <47F5F3FA.7060709@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760057AbYDDTMb@vger.kernel.org>
In-Reply-To: <47F5F3FA.7060709@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Fri, Apr 4, 2008 at 2:25 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  >>  For other controllers,
>  >>  they'll need to monitor exit() callbacks to know when the leader is dead :( (sigh).
>  >
>  > That sounds like a nightmare ...
>  >
>
>  Yes, it would be, but worth the trouble. Is it really critical to move a dead
>  cgroup leader to init_css_set in cgroup_exit()?

It struck me that this whole group leader optimization is broken as it
stands since there could (in strange configurations) be multiple
thread groups sharing the same mm.

I wonder if we can't just delay the exit_mm() call of a group leader
until all its threads have exited?

>
>  > As long as we find someone to pass the mm to quickly, it shouldn't be
>  > too bad - I think we're already optimized for that case. Generally the
>  > group leader's first child will be the new owner, and any subsequent
>  > times the owner exits, they're unlikely to have any children so
>  > they'll go straight to the sibling check and pass the mm to the
>  > parent's first child.
>  >
>  > Unless they all exit in strict sibling order and hence pass the mm
>  > along the chain one by one, we should be fine. And if that exit
>  > ordering does turn out to be common, then simply walking the child and
>  > sibling lists in reverse order to find a victim will minimize the
>  > amount of passing.
>  >
>
>
>  Finding the next mm might not be all that bad, but doing it each time a task
>  exits, can be an overhead, specially for large multi threaded programs.

Right, but we only have that overhead if we actually end up passing
the mm from one to another each time they exit. It would be
interesting to know what order the threads in a large multi-threaded
process exit typically (when the main process exits and all the
threads die).

I guess it's likely to be one of:

- in thread creation order (i.e. in order of parent->children list),
in which case we should try to throw the mm to the parent's last child
- in reverse creation order, in which case we should try to throw the
mm to the parent's first child
- in random order depending on which threads the scheduler runs first
(in which case we can expect that a small fraction of the threads will
have to throw the mm whichever end we start from)

>  This can
>  get severe if the new mm->owner belongs to a different cgroup, in which case we
>  need to use callbacks as well.
>
>  If half the threads belonged to a different cgroup and the new mm->owner kept
>  switching between cgroups, the overhead would be really high, with the callbacks
>  and the mm->owner changing frequently.

To me, it seems that setting up a *virtual address space* cgroup
hierarchy and then putting half your threads in one group and half in
the another is asking for trouble. We need to not break in that
situation, but I'm not sure it's a case to optimize for.

Paul
