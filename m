Date: Fri, 26 Sep 2008 14:36:55 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] mm owner: fix race between swapoff and exit
In-Reply-To: <48DCC068.30706@gmail.com>
Message-ID: <Pine.LNX.4.64.0809261344190.27666@blonde.site>
References: <Pine.LNX.4.64.0809250117220.26422@blonde.site> <48DCC068.30706@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jiri Slaby <jirislaby@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyuki@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008, Jiri Slaby wrote:
> Hugh Dickins napsal(a):
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > The fix is to notify the subsystem via mm_owner_changed callback(),
> > if no new owner is found, by specifying the new task as NULL.
> > 
> > Jiri Slaby:
> > mm->owner was set to NULL prior to calling cgroup_mm_owner_callbacks(), but
> > must be set after that, so as not to pass NULL as old owner causing oops.
> > 
> > Daisuke Nishimura:
> > mm_update_next_owner() may set mm->owner to NULL, but mem_cgroup_from_task()
> > and its callers need to take account of this situation to avoid oops.
> 
> What about
> memrlimit-setup-the-memrlimit-controller-mm_owner-fix
> ? It adds check for `old' being NULL.

Good question, thanks for noticing that.

The true answer is that I didn't even notice that one.
In order to fix the oops I was seeing on 2.6.27-rc6,
Balbir pointed me to 2.6.27-rc5-mm1's
mm-owner-fix-race-between-swap-and-exit.patch
and I immediately added in your
mm-owner-fix-race-between-swap-and-exit-fix.patch
but those weren't enough, it needed Daisuke-san's
mm-owner-fix-race-between-swap-and-exit-fix-fix.patch
from mmotm, and then lockdep and hang showed me
memrlimit-cgroup-mm-owner-callback-changes-to-add-task-info.patch
also needed.  At which point we seemed to be in the clear: phew!

But let's pretend that I had noticed the one you're indicating,
rather than hurriedly looking at it now you've pointed it out ;)

It isn't necessary for 2.6.27 because actually the whole of the
cgroup_mm_owner_callbacks stuff is irrelevant to 2.6.27 - there's
nothing in 2.6.27 to set need_mm_owner_callback, so it will never
hit the code which the first hunk modifies.  memrlimits would set
it, but they remain in -mm not in mainline.

This work has been poorly factored: I think the story is that
mm->owner was invented for memrlimit, then got used in memcgroup,
that use went forward into 2.6.26 but memrlimit has stayed behind;
yet the mm->owner work in 2.6.26 and 2.6.27 contains callback code
which only makes sense if memrlimit (or something else) were there.

When putting together the posted patch from its constituents, I did
briefly wonder whether to rip out all the cgroup_mm_owner_callbacks
stuff, but decided it's safer at this stage to stick with known and
tested patches from -mm.  I guess I could have omitted your patch
from the mix, on the same grounds that I've just cited (2.6.27 never
reaches the affected code), but it looks a lot more sensible with
yours in there.  2.6.27 should be okay with the patch I posted.

> BTW there is also mm->owner = NULL; movement in the patch to the line before
> the callbacks are invoked which I don't understand much (why to inform
> anybody about NULL->NULL change?), but the first hunk seems reasonable to me.

You draw attention to the second hunk of
memrlimit-setup-the-memrlimit-controller-mm_owner-fix
(shown below).  It's just nonsense, isn't it, reverting the fix you
already made?  Perhaps it's not the patch Balbir and Zefan actually
submitted, but a mismerge of that with the fluctuating state of
all these accumulated fixes in the mm tree, and nobody properly
tested the issue in question on the resulting tree.

Or is the whole patch pointless, the first hunk just an attempt
to handle the nonsense of the second hunk?

I wish there were a lot more care and a lot less churn in this area.

Hugh

> From: Balbir Singh <balbir@linux.vnet.ibm.com> and
>       Li Zefan <lizf@cn.fujitsu.com>
> 
> This patch allows mm->owner to be NULL when mm_owner callback is called.
> Without this patch, (for example) you can see panic while you do migrate
> a set of task, which calls fork/exit.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> Tested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  kernel/cgroup.c |    5 +++--
>  kernel/exit.c   |    2 +-
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff -puN kernel/cgroup.c~memrlimit-setup-the-memrlimit-controller-mm_owner-fix kernel/cgroup.c
> --- a/kernel/cgroup.c~memrlimit-setup-the-memrlimit-controller-mm_owner-fix
> +++ a/kernel/cgroup.c
> @@ -2761,13 +2761,14 @@ void cgroup_fork_callbacks(struct task_s
>   */
>  void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
>  {
> -	struct cgroup *oldcgrp, *newcgrp = NULL;
> +	struct cgroup *oldcgrp = NULL, *newcgrp = NULL;
>  
>  	if (need_mm_owner_callback) {
>  		int i;
>  		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>  			struct cgroup_subsys *ss = subsys[i];
> -			oldcgrp = task_cgroup(old, ss->subsys_id);
> +			if (old)
> +				oldcgrp = task_cgroup(old, ss->subsys_id);
>  			if (new)
>  				newcgrp = task_cgroup(new, ss->subsys_id);
>  			if (oldcgrp == newcgrp)
> diff -puN kernel/exit.c~memrlimit-setup-the-memrlimit-controller-mm_owner-fix kernel/exit.c
> --- a/kernel/exit.c~memrlimit-setup-the-memrlimit-controller-mm_owner-fix
> +++ a/kernel/exit.c
> @@ -641,8 +641,8 @@ retry:
>  	 * the callback and take action
>  	 */
>  	down_write(&mm->mmap_sem);
> -	cgroup_mm_owner_callbacks(mm->owner, NULL);
>  	mm->owner = NULL;
> +	cgroup_mm_owner_callbacks(mm->owner, NULL);
>  	up_write(&mm->mmap_sem);
>  	return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
