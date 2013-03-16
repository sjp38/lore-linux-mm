Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id E1B376B0037
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 07:02:27 -0400 (EDT)
Date: Sat, 16 Mar 2013 21:32:11 +1030
From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: OOM triggered with plenty of memory free
Message-ID: <20130316110211.GA30445@marvin.atrad.com.au>
References: <CAJd=RBDHwgtm=to3WUj73d7q6cjJ7oG6capjUxvcpVk0wH-fbQ@mail.gmail.com>
 <CAGDaZ_ryxdMBm44kotjKyCeFEFk3OURjHav3zVOcQNGwP_ZwAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGDaZ_ryxdMBm44kotjKyCeFEFk3OURjHav3zVOcQNGwP_ZwAQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jonathan Woithe <jwoithe@atrad.com.au>

On Sat, Mar 16, 2013 at 02:33:23AM -0700, Raymond Jennings wrote:
> On Sat, Mar 16, 2013 at 2:25 AM, Hillf Danton <dhillf@gmail.com> wrote:
> >> Some system specifications:
> >> - CPU: i7 860 at 2.8 GHz
> >> - Mainboard: Advantech AIMB-780
> >> - RAM: 4 GB
> >> - Kernel: 2.6.35.11 SMP, 32 bit (kernel.org kernel, no patches applied)
> 
> > The highmem no longer holds memory with 64-bit kernel.
> 
> I don't really think that's a valid reason to dismiss problems with
> 32-bit though, as I still use it myself.
> 
> Anyway, to the parent poster, could you tell us more, such as how much
> ram you had left free?
> 
> A printout of /proc/meminfo might help here.

Sure.  Here is the contents of /proc/meminfo as it was just before the
machine was rebooted:

MemTotal:        3048988 kB
MemFree:         1930548 kB
Buffers:               0 kB
Cached:            56876 kB
SwapCached:            0 kB
Active:            78016 kB
Inactive:          53500 kB
Active(anon):      57220 kB
Inactive(anon):    22888 kB
Active(file):      20796 kB
Inactive(file):    30612 kB
Unevictable:      127172 kB
Mlocked:          127172 kB
HighTotal:       2194952 kB
HighFree:        1923040 kB
LowTotal:         854036 kB
LowFree:            7508 kB
SwapTotal:       8393924 kB
SwapFree:        8393924 kB
Dirty:                52 kB
Writeback:           684 kB
AnonPages:        202204 kB
Mapped:            25208 kB
Shmem:              2600 kB
Slab:             818868 kB
SReclaimable:       6240 kB
SUnreclaim:       812628 kB
KernelStack:        2608 kB
PageTables:         1388 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     9918416 kB
Committed_AS:     433632 kB
VmallocTotal:     122880 kB
VmallocUsed:       24952 kB
VmallocChunk:      56908 kB
DirectMap4k:       16376 kB
DirectMap4M:      892928 kB

"free" reported this:

             total       used       free     shared    buffers     cached
Mem:       3048988    1101120    1947868          0          0      48780
-/+ buffers/cache:    1052340    1996648
Swap:      8393924          0    8393924

Earlier posts in this thread (at that point only in linux-mm) concentrated
on the /proc/slabinfo output which was retrieved from a similar system to
the faulting one (with only about 100 days uptime this was not yet OOMing),
This included the following:

  kmalloc-128       1234556 1235168    128   32    1 : tunables    0    0    0 : slabdata  38599  38599      0
  kmalloc-64        1238117 1238144     64   64    1 : tunables    0    0    0 : slabdata  19346  19346      0
  kmalloc-32        1236600 1236608     32  128    1 : tunables    0    0    0 : slabdata   9661   9661      0

which pointed to a kernel memory leak.  This was subsequently confirmed
using kmemleak which threw many detections similar to the following example:

  unreferenced object 0xf5d3b500 (size 128):
  comm "udevd", pid 1382, jiffies 4294676664 (age 15504.596s)
  hex dump (first 32 bytes):
    01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<c19734ec>] kmemleak_alloc+0x2c/0x60
    [<c10e70ba>] kmem_cache_alloc+0xaa/0x130
    [<c106095c>] prepare_creds+0x2c/0xb0
    [<c1060a5d>] copy_creds+0x7d/0x1f0
    [<c103e2ea>] copy_process+0x23a/0xe00
    [<c103ef33>] do_fork+0x83/0x3a0
    [<c100a8b4>] sys_clone+0x34/0x40
    [<c1003139>] ptregs_clone+0x15/0x1c
    [<ffffffff>] 0xffffffff

Dave Hansen then noted:
> Your kmemleak data shows that the leaks are always from either 'struct
> cred', or 'struct pid'.  Those are _generally_ tied to tasks, but you
> only have a couple thousand task_structs.
> 
> My suspicion would be that something is allocating those structures, but
> a refcount got leaked somewhere.

For details refer to past posts in this thread to linux-mm.

At this point I was able to test 3.7.9 (the latest stable available then)
and the above leak did not appear to be occurring.  3.4.x and 3.0.x are also
ok, so it seems that somewhere between 2.6.35.11 and 3.0 it went away. 
[An aside: unfortunately 3.7.9 has an unrelated bug in the network card
driver we're using (introduced in 3.3) which hits us in other ways.  A git
bisect has isolated the offending commit, but until that's fixed we can't
move to anything newer than a 3.2 kernel.]

Since it's relatively easy to tell whether the memory leak is present using
kmemleak and I now have access to some off-line hardware to permit testing,
I am thinking of running a git bisect to see if I can identify which commit
fixed the leak.  Even if it turns out to be of academic interest only, it
would be good to know that it was fixed rather than somehow being avoided
for the moment due to another change.

Let me know if there's anything more I could do.

Regards
  jonathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
