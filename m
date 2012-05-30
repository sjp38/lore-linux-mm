Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id F2D546B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 05:54:04 -0400 (EDT)
Message-ID: <4FC5EE3A.8010805@fold.natur.cuni.cz>
Date: Wed, 30 May 2012 11:54:02 +0200
From: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
MIME-Version: 1.0
Subject: Re: 3.4-rc7: BUG: Bad rss-counter state mm:ffff88040b56f800 idx:1
 val:-59
References: <4FBC1618.5010408@fold.natur.cuni.cz> <20120522162835.c193c8e0.akpm@linux-foundation.org> <20120522162946.2afcdb50.akpm@linux-foundation.org> <20120523172146.GA27598@redhat.com>
In-Reply-To: <20120523172146.GA27598@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, khlebnikov@openvz.org, markus@trippelsdorf.de, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org



Oleg Nesterov wrote:
> On 05/22, Andrew Morton wrote:
>>
>> Also, I have a note here that Oleg was unhappy with the patch.  Oleg
>> happiness is important.  Has he cheered up yet?
> 
> Well, yes, I do not really like this patch ;) Because I think there is
> a more simple/straightforward fix, see below. In my opinion it also
> makes the original code simpler.
> 
> But. Obviously this is subjective, I can't prove my patch is "better",
> and I didn't try to test it.
> 
> So I won't argue with Konstantin who dislikes my patch, although I
> would like to know the reason.
> 
> Oleg.
> 
> 
> --- a/kernel/tsacct.c
> +++ b/kernel/tsacct.c
> @@ -91,6 +91,7 @@ void xacct_add_tsk(struct taskstats *sta
>  	stats->virtmem = p->acct_vm_mem1 * PAGE_SIZE / MB;
>  	mm = get_task_mm(p);
>  	if (mm) {
> +		sync_mm_rss(mm);
>  		/* adjust to KB unit */
>  		stats->hiwater_rss   = get_mm_hiwater_rss(mm) * PAGE_SIZE / KB;
>  		stats->hiwater_vm    = get_mm_hiwater_vm(mm)  * PAGE_SIZE / KB;
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -643,6 +643,8 @@ static void exit_mm(struct task_struct *
>  	mm_release(tsk, mm);
>  	if (!mm)
>  		return;
> +
> +	sync_mm_rss(mm);
>  	/*
>  	 * Serialize with any possible pending coredump.
>  	 * We must hold mmap_sem around checking core_state
> @@ -960,9 +962,6 @@ void do_exit(long code)
>  				preempt_count());
>  
>  	acct_update_integrals(tsk);
> -	/* sync mm's RSS info before statistics gathering */
> -	if (tsk->mm)
> -		sync_mm_rss(tsk->mm);
>  	group_dead = atomic_dec_and_test(&tsk->signal->live);
>  	if (group_dead) {
>  		hrtimer_cancel(&tsk->signal->real_timer);
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -823,10 +823,10 @@ static int exec_mmap(struct mm_struct *m
>  	/* Notify parent that we're no longer interested in the old VM */
>  	tsk = current;
>  	old_mm = current->mm;
> -	sync_mm_rss(old_mm);
>  	mm_release(tsk, old_mm);
>  
>  	if (old_mm) {
> +		sync_mm_rss(old_mm);
>  		/*
>  		 * Make sure that if there is a core dump in progress
>  		 * for the old mm, we get out and die instead of going
> 
> 

Tested-by: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>

This patch works equally well for me as the other patch proposed earlier by Konstantin
Khlebnikov.

Would both patches have some debug printk() showing the code really did kick
in I would have been more assured it had a chance to really do their job. But
in both cases I made the system use up all RAM and start to swap so if that was
enough to trigger the situation as you said earlier then they are both fine.

Finally, I went to re-test again the patch from Konstantin because the several
minutes long delay in shutdown puzzled me and I did not get it with this patch
from Oleg. I conclude it was probably related to my initial attempts to also copy
/home/blah to /tmp (I thought it is in-memory filesystem so I can easily drain
memory resources but seems I was wrong). Maybe this was the reason while the
shutdown took so long. I am still not sure because init.d/ scritps cleanup /tmp
on startup on Gentoo ... but I was not able to reproduce the long delay on second
attempt with using purely python to eat my memory to record some huge lists.

For those wondering as well why the long delay on shutdown happened here are my
mounts:

# mount
rootfs on / type rootfs (rw)
/dev/root on / type ext3 (rw,noatime,commit=0)
devtmpfs on /dev type devtmpfs (rw,relatime,size=8184896k,nr_inodes=2046224,mode=755)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
tmpfs on /run type tmpfs (rw,nosuid,nodev,relatime,mode=755)
rc-svcdir on /lib64/rc/init.d type tmpfs (rw,nosuid,nodev,noexec,relatime,size=1024k,mode=755)
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
debugfs on /sys/kernel/debug type debugfs (rw,nosuid,nodev,noexec,relatime)
configfs on /sys/kernel/config type configfs (rw,nosuid,nodev,noexec,relatime)
cgroup_root on /sys/fs/cgroup type tmpfs (rw,nosuid,nodev,noexec,relatime,size=10240k,mode=755)
openrc on /sys/fs/cgroup/openrc type cgroup (rw,nosuid,nodev,noexec,relatime,release_agent=/lib64/rc/sh/cgroup-release-agent.sh,name=openrc)
cpu on /sys/fs/cgroup/cpu type cgroup (rw,nosuid,nodev,noexec,relatime,cpu)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
shm on /dev/shm type tmpfs (rw,nosuid,nodev,noexec,relatime)
binfmt_misc on /proc/sys/fs/binfmt_misc type binfmt_misc (rw,noexec,nosuid,nodev)
#

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
