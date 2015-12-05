Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 577166B0258
	for <linux-mm@kvack.org>; Sat,  5 Dec 2015 07:34:06 -0500 (EST)
Received: by oixx65 with SMTP id x65so79587655oix.0
        for <linux-mm@kvack.org>; Sat, 05 Dec 2015 04:34:06 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id xe2si16348657oeb.57.2015.12.05.04.34.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 05 Dec 2015 04:34:04 -0800 (PST)
Subject: Re: [RFC PATCH -v2] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
	<1448640772-30147-1-git-send-email-mhocko@kernel.org>
	<201511281339.JHH78172.SLOQFOFHVFOMJt@I-love.SAKURA.ne.jp>
	<201511290110.FJB87096.OHJLVQOSFFtMFO@I-love.SAKURA.ne.jp>
	<20151201132927.GG4567@dhcp22.suse.cz>
In-Reply-To: <20151201132927.GG4567@dhcp22.suse.cz>
Message-Id: <201512052133.IAE00551.LSOQFtMFFVOHOJ@I-love.SAKURA.ne.jp>
Date: Sat, 5 Dec 2015 21:33:47 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sun 29-11-15 01:10:10, Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > > Users of mmap_sem which need it for write should be carefully reviewed
> > > > to use _killable waiting as much as possible and reduce allocations
> > > > requests done with the lock held to absolute minimum to reduce the risk
> > > > even further.
> > > 
> > > It will be nice if we can have down_write_killable()/down_read_killable().
> > 
> > It will be nice if we can also have __GFP_KILLABLE.
> 
> Well, we already do this implicitly because OOM killer will
> automatically do mark_oom_victim if it has fatal_signal_pending and then
> __alloc_pages_slowpath fails the allocation if the memory reserves do
> not help to finish the allocation.

I don't think so because !__GFP_FS && !__GFP_NOFAIL allocations do not do
mark_oom_victim() even if fatal_signal_pending() is true because
out_of_memory() is not called.

Also, __GFP_KILLABLE is helpful even before the kernel declares OOM because
users can give up earlier when memory allocation is slashing (i.e. allow
users who recognized that memory allocation is too slow to wait to kill
processes before the kernel declares OOM).
I'm willing to use __GFP_KILLABLE from TOMOYO security module because we are
using GFP_NOFS allocations for checking permissions for access requests from
user space (because some LSM hooks are GFP_KERNEL unsafe) where failing
GFP_NOFS allocations without invoking the OOM killer can result in
unrecoverable failure (e.g. unexpected termination of critical processes).

Anyway, __GFP_KILLABLE is outside of this thread, so I stop here for now.



> > Although currently it can't
> > be perfect because reclaim functions called from __alloc_pages_slowpath() use
> > unkillable waits, starting from just bail out as with __GFP_NORETRY when
> > fatal_signal_pending(current) is true will be helpful.
> > 
> > So far I'm hitting no problem with testers except the one using mmap()/munmap().
> > 
> > I think that cmpxchg() was not needed.
> 
> It is not needed right now but I would rather not depend on the oom
> mutex here. This is not a hot path where an atomic would add an
> overhead.

Current patch can allow oom_reaper() to call mmdrop(mm) before
wake_oom_reaper() calls atomic_inc(&mm->mm_count) because sequence like

  oom_reaper() (a realtime thread)         wake_oom_reaper() (current thread)         Current OOM victim

  oom_reap_vmas(mm); /* mm = Previous OOM victim */
  WRITE_ONCE(mm_to_reap, NULL);
                                           old_mm = cmpxchg(&mm_to_reap, NULL, mm); /* mm = Current OOM victim */
                                           if (!old_mm) {
  wait_event_freezable(oom_reaper_wait, (mm = READ_ONCE(mm_to_reap)));
  oom_reap_vmas(mm); /* mm = Current OOM victim, undo atomic_inc(&mm->mm_count) done by oom_kill_process() */
  WRITE_ONCE(mm_to_reap, NULL);
                                                                                      exit and release mm
                                           atomic_inc(&mm->mm_count); /* mm = Current OOM victim */
                                           wake_up(&oom_reaper_wait);

  wait_event_freezable(oom_reaper_wait, (mm = READ_ONCE(mm_to_reap))); /* mm = Next OOM victim */

is possible.

If you are serious about execution ordering, we should protect mm_to_reap
using smp_mb__after_atomic_inc(), rcu_assign_pointer()/rcu_dereference() etc.
in addition to my patch.



But what I don't like is that current patch cannot handle a trap explained
below. What about marking current OOM victim unkillable by updating
victim->signal->oom_score_adj to OOM_SCORE_ADJ_MIN and clearing victim's
TIF_MEMDIE flag when the victim is still alive for a second after
oom_reap_vmas() completed? In this way, my worry (2) at
http://lkml.kernel.org/r/201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp
(though this trap is not a mmap_sem livelock) will be gone. That is,
holding a victim's task_struct than a victim's mm will do better things.

---------- oom-write.c start ----------
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	unsigned long size;
	char *buf = NULL;
	unsigned long i;
	for (i = 0; i < 10; i++) {
		if (fork() == 0) {
			close(1);
			open("/tmp/file", O_WRONLY | O_CREAT | O_APPEND, 0600);
			execl("./write", "./write", NULL);
			_exit(1);
		}
	}
	for (size = 1048576; size < 512UL * (1 << 30); size <<= 1) {
		char *cp = realloc(buf, size);
		if (!cp) {
			size >>= 1;
			break;
		}
		buf = cp;
	}
	sleep(5);
	/* Will cause OOM due to overcommit */
	for (i = 0; i < size; i += 4096)
		buf[i] = 0;
	pause();
	return 0;
}
---------- oom-write.c end ----------

----- write.asm start -----
; nasm -f elf write.asm && ld -s -m elf_i386 -o write write.o
section .text
    CPU 386
    global _start
_start:
; whlie (write(1, buf, 4096) == 4096);
    mov eax, 4 ; NR_write
    mov ebx, 1
    mov ecx, _start - 96
    mov edx, 4096
    int 0x80
    cmp eax, 4096
    je _start
; pause();
    mov eax, 29 ; NR_pause
    int 0x80
; _exit(0);
    mov eax, 1 ; NR_exit
    mov ebx, 0
    int 0x80
----- write.asm end -----

What is happening with this trap:

  (1) out_of_memory() chose oom-write(3805) which consumed most memory.
  (2) oom_kill_process() chose first write(3806) which is one of children
      of oom-write(3805).
  (3) oom_reaper() reclaimed write(3806)'s memory which consumed only
      a few pages.
  (4) out_of_memory() chose oom-write(3805) again.
  (5) oom_kill_process() chose second write(3807) which is one of children
      of oom-write(3805).
  (6) oom_reaper() reclaimed write(3807)'s memory which consumed only
      a few pages.
  (7) second write(3807) is blocked by unkillable mutex held by first
      write(3806), and first write(3806) is waiting for second write(3807)
      to release more memory even after oom_reaper() completed.
  (8) eventually first write(3806) successfully terminated, but
      second write(3807) remained stuck.
  (9) irqbalance(1710) got memory before second write(3807)
      can make forward progress.

----------
[   78.157198] oom-write invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)
(...snipped...)
[   78.325409] [ 3805]  1000  3805   541715   357876     708       6        0             0 oom-write
[   78.327978] [ 3806]  1000  3806       39        1       3       2        0             0 write
[   78.330149] [ 3807]  1000  3807       39        1       3       2        0             0 write
[   78.332167] [ 3808]  1000  3808       39        1       3       2        0             0 write
[   78.334488] [ 3809]  1000  3809       39        1       3       2        0             0 write
[   78.336471] [ 3810]  1000  3810       39        1       3       2        0             0 write
[   78.338414] [ 3811]  1000  3811       39        1       3       2        0             0 write
[   78.340709] [ 3812]  1000  3812       39        1       3       2        0             0 write
[   78.342711] [ 3813]  1000  3813       39        1       3       2        0             0 write
[   78.344727] [ 3814]  1000  3814       39        1       3       2        0             0 write
[   78.346613] [ 3815]  1000  3815       39        1       3       2        0             0 write
[   78.348829] Out of memory: Kill process 3805 (oom-write) score 808 or sacrifice child
[   78.350818] Killed process 3806 (write) total-vm:156kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
[   78.455314] oom-write invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)
(...snipped...)
[   78.631333] [ 3805]  1000  3805   541715   361440     715       6        0             0 oom-write
[   78.633802] [ 3807]  1000  3807       39        1       3       2        0             0 write
[   78.635977] [ 3808]  1000  3808       39        1       3       2        0             0 write
[   78.638325] [ 3809]  1000  3809       39        1       3       2        0             0 write
[   78.640463] [ 3810]  1000  3810       39        1       3       2        0             0 write
[   78.642837] [ 3811]  1000  3811       39        1       3       2        0             0 write
[   78.644924] [ 3812]  1000  3812       39        1       3       2        0             0 write
[   78.646990] [ 3813]  1000  3813       39        1       3       2        0             0 write
[   78.649039] [ 3814]  1000  3814       39        1       3       2        0             0 write
[   78.651242] [ 3815]  1000  3815       39        1       3       2        0             0 write
[   78.653326] Out of memory: Kill process 3805 (oom-write) score 816 or sacrifice child
[   78.655235] Killed process 3807 (write) total-vm:156kB, anon-rss:4kB, file-rss:0kB, shmem-rss:0kB
[   88.776446] MemAlloc-Info: 1 stalling task, 1 dying task, 1 victim task.
[   88.778228] MemAlloc: systemd-journal(481) seq=17 gfp=0x24280ca order=0 delay=10000
[   88.780158] MemAlloc: write(3807) uninterruptible dying victim
(...snipped...)
[   98.915687] MemAlloc-Info: 8 stalling task, 1 dying task, 1 victim task.
[   98.917888] MemAlloc: kthreadd(2) seq=12 gfp=0x27000c0 order=2 delay=14885 uninterruptible
[   98.920297] MemAlloc: systemd-journal(481) seq=17 gfp=0x24280ca order=0 delay=20139
[   98.922652] MemAlloc: irqbalance(1710) seq=3 gfp=0x24280ca order=0 delay=16231
[   98.924874] MemAlloc: vmtoolsd(1908) seq=1 gfp=0x2400240 order=0 delay=20044
[   98.927043] MemAlloc: pickup(3680) seq=1 gfp=0x2400240 order=0 delay=10230 uninterruptible
[   98.929405] MemAlloc: nmbd(3713) seq=1 gfp=0x2400240 order=0 delay=14716
[   98.931559] MemAlloc: oom-write(3805) seq=12718 gfp=0x24280ca order=0 delay=14887
[   98.933843] MemAlloc: write(3806) seq=29813 gfp=0x2400240 order=0 delay=14887 uninterruptible exiting
[   98.936460] MemAlloc: write(3807) uninterruptible dying victim
(...snipped...)
[  140.356230] MemAlloc-Info: 9 stalling task, 1 dying task, 1 victim task.
[  140.358448] MemAlloc: kthreadd(2) seq=12 gfp=0x27000c0 order=2 delay=56326 uninterruptible
[  140.360979] MemAlloc: systemd-journal(481) seq=17 gfp=0x24280ca order=0 delay=61580 uninterruptible
[  140.363716] MemAlloc: irqbalance(1710) seq=3 gfp=0x24280ca order=0 delay=57672
[  140.365983] MemAlloc: vmtoolsd(1908) seq=1 gfp=0x2400240 order=0 delay=61485 uninterruptible
[  140.368521] MemAlloc: pickup(3680) seq=1 gfp=0x2400240 order=0 delay=51671 uninterruptible
[  140.371128] MemAlloc: nmbd(3713) seq=1 gfp=0x2400240 order=0 delay=56157 uninterruptible
[  140.373548] MemAlloc: smbd(3734) seq=1 gfp=0x27000c0 order=2 delay=48147
[  140.375722] MemAlloc: oom-write(3805) seq=12718 gfp=0x24280ca order=0 delay=56328 uninterruptible
[  140.378647] MemAlloc: write(3806) seq=29813 gfp=0x2400240 order=0 delay=56328 exiting
[  140.381695] MemAlloc: write(3807) uninterruptible dying victim
(...snipped...)
[  150.493557] MemAlloc-Info: 7 stalling task, 1 dying task, 1 victim task.
[  150.495725] MemAlloc: kthreadd(2) seq=12 gfp=0x27000c0 order=2 delay=66463
[  150.497897] MemAlloc: systemd-journal(481) seq=17 gfp=0x24280ca order=0 delay=71717 uninterruptible
[  150.500490] MemAlloc: vmtoolsd(1908) seq=1 gfp=0x2400240 order=0 delay=71622 uninterruptible
[  150.502940] MemAlloc: pickup(3680) seq=1 gfp=0x2400240 order=0 delay=61808
[  150.505122] MemAlloc: nmbd(3713) seq=1 gfp=0x2400240 order=0 delay=66294 uninterruptible
[  150.507521] MemAlloc: smbd(3734) seq=1 gfp=0x27000c0 order=2 delay=58284
[  150.509678] MemAlloc: oom-write(3805) seq=12718 gfp=0x24280ca order=0 delay=66465 uninterruptible
[  150.512333] MemAlloc: write(3807) uninterruptible dying victim
----------
Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20151205.txt.xz .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
