Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 4BD1D6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 06:20:50 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so1653614lbj.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 03:20:48 -0700 (PDT)
Message-ID: <4FD1D1F7.2090503@openvz.org>
Date: Fri, 08 Jun 2012 14:20:39 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [patch 12/12] mm: correctly synchronize rss-counters at exit/exec
References: <20120607212114.E4F5AA02F8@akpm.mtv.corp.google.com> <CA+55aFxOWR_h1vqRLAd_h5_woXjFBLyBHP--P8F7WsYrciXdmA@mail.gmail.com> <CA+55aFyQUBXhjVLJH6Fhz9xnpfXZ=9Mej5ujt6ss7VUqT1g9Jg@mail.gmail.com> <alpine.LSU.2.00.1206071759050.1291@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1206071759050.1291@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "markus@trippelsdorf.de" <markus@trippelsdorf.de>, "oleg@redhat.com" <oleg@redhat.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>

Hugh Dickins wrote:
> On Thu, 7 Jun 2012, Linus Torvalds wrote:
>
>> Ugh, looking more at the patch, I'm getting more and more convinces
>> that it is pure and utter garbage.
>>
>> It does "sync_mm_rss(mm);" in mmput(), _after_ it has done the
>> possibly final mmdrop(). WTF?
>>
>> This is crap, guys. Seriously. Stop playing russian rulette with this
>> code. I think we need to revert *all* of the crazy rss games, unless
>> Konstantin can show us some truly obviously correct fix.
>>
>> Sadly, I merged and pushed out the crap before I had rebooted and
>> noticed this problem, so now it's in the wild. Can somebody please
>> take a look at this asap?
>>
>>               Linus
>>
>> On Thu, Jun 7, 2012 at 5:17 PM, Linus Torvalds
>> <torvalds@linux-foundation.org>  wrote:
>>> This patch actually seems to have made the
>>>
>>>   BUG: Bad rss-counter state ..
>>>
>>> problem *much* worse. It triggers all the time for me now - I've got
>>> 408 of those messages on my macbook air within a minute of booting it.
>>>
>>> Not good. Especially not good when it's marked for stable too.
>
> I'm on the Cc, but I've not been following closely, I've not been able
> to reproduce the issue with Konstantin's commit in just now, and I've
> not even tried Oleg's version: so, don't trust me an inch.

Easiest way to reproduce this:

#define _GNU_SOURCE
#include <stdlib.h>
#include <sched.h>
#include <sys/mman.h>

int child(void *arg)
{
	return 0;
}

char stack[4096];

int main(int argc, char **argv)
{
	void *page;

	page = mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
	clone(child, stack + sizeof(stack), CLONE_VFORK | CLONE_VM | CLONE_CHILD_CLEARTID, NULL, NULL, NULL, page);
	return 0;
}

As result you can see "BUG: Bad rss-counter state mm:ffff88040783a680 idx:1 val:-1" in dmesg

There left only one problem: nobody calls sync_mm_rss() after put_user() in mm_release().

My patch is really messy, so please ignore it.
Oleg's http://marc.info/?l=linux-kernel&m=133848759505805 version much simpler and changes only sync_mm_rss() calls.

>
> But I was surprised that that patch went to you, I thought Konstantin
> and Oleg had just reached agreement that Oleg's version (reposted this
> morning in the "3.4-rc7: BUG: Bad rss-counter state" thread) was nicer.
>
> And it looks like it does not do anything offensive in mmput().
> Doing things after something called "mm_release" sounds equally
> bad, but IIRC that's not so.
>
> You probably want to revert Konstantin's, try out Oleg's on your Air,
> and maybe wait for Konstantin and Oleg to confirm the below.
>
> Offline for a few hours,
> Hugh
>
> [PATCH] correctly synchronize rss-counters at exit/exec
>
> From: Oleg Nesterov<oleg@redhat.com>
>
> A simplified version of Konstantin Khlebnikov's patch.
>
> do_exit() and exec_mmap() call sync_mm_rss() before mm_release()
> does put_user(clear_child_tid) which can update task->rss_stat
> and thus make mm->rss_stat inconsistent. This triggers the "BUG:"
> printk in check_mm().
>
> - Move the final sync_mm_rss() from do_exit() to exit_mm(), and
>    change exec_mmap() to call sync_mm_rss() after mm_release() to
>    make check_mm() happy.
>
>    Perhaps we should simply move it into mm_release() and call it
>    unconditionally to catch the "task->rss_stat != 0&&  !task->mm"
>    bugs.
>
> - Since taskstats_exit() is called before exit_mm(), add another
>    sync_mm_rss() into xacct_add_tsk() who actually uses rss_stat.
>
>    Probably we should also shift acct_update_integrals().
>
> Reported-by: Markus Trippelsdorf<markus@trippelsdorf.de>
> Tested-by: Martin Mokrejs<mmokrejs@fold.natur.cuni.cz>
> Signed-off-by: Oleg Nesterov<oleg@redhat.com>
> Acked-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
> ---
>   fs/exec.c       |    2 +-
>   kernel/exit.c   |    5 ++---
>   kernel/tsacct.c |    1 +
>   3 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/fs/exec.c b/fs/exec.c
> index 52c9e2f..e49e3c2 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -823,10 +823,10 @@ static int exec_mmap(struct mm_struct *mm)
>   	/* Notify parent that we're no longer interested in the old VM */
>   	tsk = current;
>   	old_mm = current->mm;
> -	sync_mm_rss(old_mm);
>   	mm_release(tsk, old_mm);
>
>   	if (old_mm) {
> +		sync_mm_rss(old_mm);
>   		/*
>   		 * Make sure that if there is a core dump in progress
>   		 * for the old mm, we get out and die instead of going
> diff --git a/kernel/exit.c b/kernel/exit.c
> index ab972a7..b3a84b5 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -655,6 +655,8 @@ static void exit_mm(struct task_struct * tsk)
>   	mm_release(tsk, mm);
>   	if (!mm)
>   		return;
> +
> +	sync_mm_rss(mm);
>   	/*
>   	 * Serialize with any possible pending coredump.
>   	 * We must hold mmap_sem around checking core_state
> @@ -965,9 +967,6 @@ void do_exit(long code)
>   				preempt_count());
>
>   	acct_update_integrals(tsk);
> -	/* sync mm's RSS info before statistics gathering */
> -	if (tsk->mm)
> -		sync_mm_rss(tsk->mm);
>   	group_dead = atomic_dec_and_test(&tsk->signal->live);
>   	if (group_dead) {
>   		hrtimer_cancel(&tsk->signal->real_timer);
> diff --git a/kernel/tsacct.c b/kernel/tsacct.c
> index 23b4d78..a64ee90 100644
> --- a/kernel/tsacct.c
> +++ b/kernel/tsacct.c
> @@ -91,6 +91,7 @@ void xacct_add_tsk(struct taskstats *stats, struct task_struct *p)
>   	stats->virtmem = p->acct_vm_mem1 * PAGE_SIZE / MB;
>   	mm = get_task_mm(p);
>   	if (mm) {
> +		sync_mm_rss(mm);
>   		/* adjust to KB unit */
>   		stats->hiwater_rss   = get_mm_hiwater_rss(mm) * PAGE_SIZE / KB;
>   		stats->hiwater_vm    = get_mm_hiwater_vm(mm)  * PAGE_SIZE / KB;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
