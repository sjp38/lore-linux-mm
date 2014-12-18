Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 815106B0032
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 07:11:33 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so1330589pdi.3
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 04:11:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ua2si9749624pab.180.2014.12.18.04.11.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 04:11:31 -0800 (PST)
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201412122254.AJJ57896.OLFOOJQHSMtFVF@I-love.SAKURA.ne.jp>
	<20141216124714.GF22914@dhcp22.suse.cz>
	<201412172054.CFJ78687.HFFLtVMOOJSQFO@I-love.SAKURA.ne.jp>
	<20141217130807.GB24704@dhcp22.suse.cz>
In-Reply-To: <20141217130807.GB24704@dhcp22.suse.cz>
Message-Id: <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
Date: Thu, 18 Dec 2014 21:11:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

Michal Hocko wrote:
> On Wed 17-12-14 20:54:53, Tetsuo Handa wrote:
> [...]
> > I'm not familiar with memcg.
>
> This check doesn't make any sense for this path because the task is part
> of the memcg, otherwise it wouldn't trigger charge for it and couldn't
> cause the OOM killer. Kernel threads do not have their address space
> they cannot trigger memcg OOM killer. As you provide NULL nodemask then
> this is basically a check for task being part of the memcg.

So !oom_unkillable_task(current, memcg, NULL) is always true for
mem_cgroup_out_of_memory() case, isn't it?

>                                                             The check
> for current->mm is not needed as well because task will not trigger a
> charge after exit_mm.

So current->mm != NULL is always true for mem_cgroup_out_of_memory()
case, isn't it?

>
> > But I think the condition whether TIF_MEMDIE
> > flag should be set or not should be same between the memcg OOM killer and
> > the global OOM killer, for a thread inside some memcg with TIF_MEMDIE flag
> > can prevent the global OOM killer from killing other threads when the memcg
> > OOM killer and the global OOM killer run concurrently (the worst corner case).
> > When a malicious user runs a memory consumer program which triggers memcg OOM
> > killer deadlock inside some memcg, it will result in the global OOM killer
> > deadlock when the global OOM killer is triggered by other user's tasks.
>
> Hope that the above exaplains your concerns here.
>

Thread1 in memcg1 asks for memory, and thread1 gets requested amount of
memory without triggering the global OOM killer, and requested amount of
memory is charged to memcg1, and the memcg OOM killer is triggered.
While the memcg OOM killer is searching for a victim from threads in
memcg1, thread2 in memcg2 asks for the memory. Thread2 fails to get
requested amount of memory without triggering the global OOM killer.
Now the global OOM killer starts searching for a victim from all threads
whereas the memcg OOM killer chooses thread1 in memcg1 and sets TIF_MEMDIE
flag on thread1 in memcg1. Then, the global OOM killer finds that thread1
in memcg1 already has TIF_MEMDIE flag set, and waits for thread1 in memcg1
to terminate than chooses another victim from all threads. However, when
thread1 in memcg1 cannot be terminated immediately for some reason, thread2
in memcg2 is blocked by thread1 in memcg1.

> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > index 481d550..01719d6 100644
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > [...]
> > > > @@ -649,8 +649,14 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> > > >       * If current has a pending SIGKILL or is exiting, then automatically
> > > >       * select it.  The goal is to allow it to allocate so that it may
> > > >       * quickly exit and free its memory.
> > > > +     *
> > > > +     * However, if current is calling out_of_memory() by doing memory
> > > > +     * allocation from e.g. exit_task_work() in do_exit() after PF_EXITING
> > > > +     * was set by exit_signals() and mm was released by exit_mm(), it is
> > > > +     * wrong to expect current to exit and free its memory quickly.
> > > >       */
> > > > -     if (fatal_signal_pending(current) || task_will_free_mem(current)) {
> > > > +     if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
> > > > +         current->mm && !oom_unkillable_task(current, NULL, nodemask)) {
> > > >            set_thread_flag(TIF_MEMDIE);
> > > >            return;
> > > >       }
> > >
> > > Calling oom_unkillable_task doesn't make much sense to me. Even if it made
> > > sense it should be in a separate patch, no?
> >
> > At least for the global OOM case, current may be a kernel thread, doesn't it?
>
> then mm would be NULL most of the time so current->mm check wouldn't
> give it TIF_MEMDIE and the task itself will be exluded later on during
> tasks scanning.
>
> > Such kernel thread can do memory allocation from exit_task_work(), and trigger
> > the global OOM killer, and disable the global OOM killer and prevent other
> > threads from allocating memory, can't it?
> >
> > We can utilize memcg for reducing the possibility of triggering the global
> > OOM killer.
>
> I do not get this. Memcg charge happens after the allocation is done so
> the global OOM killer would trigger before memcg one.

I mean, someone triggers the global OOM killer between somebody else triggered
the memcg OOM killer and the memcg OOM killer finishes.

> > But if we failed to prevent the global OOM killer from triggering,
> > the global OOM killer is responsible for solving the OOM condition than keeping
> > the system stalled for presumably forever. Panic on TIF_MEMDIE timeout can act
> > like /proc/sys/vm/panic_on_oom only when the OOM killer chose (by chance or
> > by a trap) an unkillable (due to e.g. lock dependency loop) task. Of course,
> > for those who prefer the system kept stalled over the OOM condition solved,
> > such action should be optional and thus I'm happy to propose sysctl-tunable
> > version.
>
> You are getting offtopic again (which is pretty annoying to be honest as
> it is going all over again and again). Please focus on a single thing at
> a time.
>

I think focusing on only mm-less case makes no sense, for with-mm case
ruins efforts made for mm-less case. My question is quite simple.
How can we avoid memory allocation stalls when

  System has 2048MB of RAM and no swap.
  Memcg1 for task1 has quota 512MB and 400MB in use.
  Memcg2 for task2 has quota 512MB and 400MB in use.
  Memcg3 for task3 has quota 512MB and 400MB in use.
  Memcg4 for task4 has quota 512MB and 400MB in use.
  Memcg5 for task5 has quota 512MB and 1MB in use.

and task5 launches below memory consumption program which would trigger
the global OOM killer before triggering the memcg OOM killer?

---------- XFS + OOM killer dependency stall reproducer start ----------
#define _GNU_SOURCE
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <sched.h>

static int file_writer(void *unused)
{
	static char buf[4096];
	const int fd = open("file", O_CREAT | O_WRONLY, 0600);
	while (write(fd, buf, sizeof(buf)) == sizeof(buf))
		fsync(fd);
	close(fd);
	return 0;
}

int main(int argc, char *argv[])
{
	int i;
	unsigned long size;
	const int fd = open("/dev/zero", O_RDONLY);
	char *buf = NULL;
	if (fd == -1)
		return 1;
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp)
			break;
		buf = cp;
	}
	for (i = 0; i < 128; i++) {
		char *cp = malloc(4096);
		if (!cp || clone(file_writer, cp + 4096,
				 CLONE_SIGHAND | CLONE_VM, NULL) == -1)
			break;
	}
	read(fd, buf, size);
	return 0;
}
---------- XFS + OOM killer dependency stall reproducer end ----------

The global OOM killer will try to kill this program because this program
will be using 400MB+ of RAM by the time the global OOM killer is triggered.
But sometimes this program cannot be terminated by the global OOM killer
due to XFS lock dependency.

You can see what is happening from OOM traces after uptime > 320 seconds of
http://I-love.SAKURA.ne.jp/tmp/serial-20141213.txt.xz though memcg is not
configured on this program.

Trying to apply quota using memcg for safeguard is fine. But don't forget
to prepare for the global OOM killer. And please don't reject with "use
memcg and never over-commit", for my proposal is for analyzing/avoiding

  stalls caused by not only a malicious user's attacks but bugs in
  enterprise applications or kernel modules

and/or

  stalls of servers where coordination with userspace is impossible

.

> > I think that
> >
> >     if (!task->mm && test_tsk_thread_flag(task, TIF_MEMDIE))
> >         return true;
> >
> > check should be added to oom_unkillable_task() because mm-less thread can
> > release little memory (except invisible memory if any).
>
> Why do you think this makes more sense than handling this very special
> case in out_of_memory? I really do not see any reason to to make
> oom_unkillable_task more complicated.

Because everyone can safely skip victim threads who don't have mm.
Handling setting of TIF_MEMDIE in the caller is racy. Somebody may set
TIF_MEMDIE at oom_kill_process() even if we avoided setting TIF_MEMDIE at
out_of_memory(). There will be more locations where TIF_MEMDIE is set; even
out-of-tree modules might set TIF_MEMDIE.

Nonetheless, I don't think

    if (!task->mm && test_tsk_thread_flag(task, TIF_MEMDIE))
        return true;

check is perfect because we anyway need to prepare for both mm-less and
with-mm cases.

My concern is not "whether TIF_MEMDIE flag should be set or not". My concern
is not "whether task->mm is NULL or not". My concern is "whether threads with
TIF_MEMDIE flag retard other process' memory allocation or not".
Above-mentioned program is an example of with-mm threads retarding
other process' memory allocation.

I know you don't like timeout approach, but adding

    if (sysctl_memdie_timeout_secs && test_tsk_thread_flag(task, TIF_MEMDIE) &&
        time_after(jiffies, task->memdie_start + sysctl_memdie_timeout_secs * HZ))
        return true;

check to oom_unkillable_task() will take care of both mm-less and with-mm
cases because everyone can safely skip the TIF_MEMDIE victim threads who
cannot be terminated immediately for some reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
