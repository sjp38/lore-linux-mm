Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 977C56B0036
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 06:43:55 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so2973141pab.1
        for <linux-mm@kvack.org>; Sat, 14 Jun 2014 03:43:55 -0700 (PDT)
Received: from hawking.rebel.net.au (hawking.rebel.net.au. [203.20.69.83])
        by mx.google.com with ESMTPS id ye4si4939074pbb.103.2014.06.14.03.43.51
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 14 Jun 2014 03:43:52 -0700 (PDT)
Message-ID: <539C275B.4010003@davidnewall.com>
Date: Sat, 14 Jun 2014 20:13:39 +0930
From: David Newall <davidn@davidnewall.com>
MIME-Version: 1.0
Subject: copying file results in out of memory, kills other processes, makes
 system unavailable
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, linux-lvm@redhat.com
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi all,

First, I'm not subscribed to any of the mailing lists addressed. Please 
copy me in replies.

I'm not sure if this is an LVM issue or a MM issue.  I rather think it's 
the latter, and I'll explain why, towards the end of this email.

I'm running a qemu virtual machine, 2 x i686 with 2GB RAM.  VM's disks 
are managed via LVM2.  Most disk activity is on one LV, formatted as 
ext4.  Backups are taken using snapshots, and at the time of the problem 
that I am about to describe, there were ten of them, or so.  OS is 
Ubuntu 12.04 with current everything.  Kernel was 3.8.0-42-generic, by 
Canonical's reckoning, and I've possibly reproduced it with a vanilla 
3.14.7-031407-generic from kernel.ubuntu.com.  Applications include 
CUPS, SSH, Samba, Denyhosts and an accounting package compiled using 
RM-COBOL.  Normally the system runs with no use of swap (2GB configured) 
and about half of physical RAM free.  CPU usage is normally around 99.9% 
idle.  This is not a demanding application for the machine!

Physical machine is 8 x amd64, 32GB RAM, Ubuntu 14.04, kernel 
3.13.0-24-generic.  I mention this, but think it not relevant.

The problem presented as machine unavailable.  It would accept 
connections on SSH, but Openssh did not display it's banner 
(SSH-2.0-OpenSSH_5.9p1 Debian-5ubuntu1.2.)  All terminals froze and, 
having configured ServerAlive*, eventually disconnected.

The VM was configured using libvirt, which showed that machine running 
at 200% CPU usage; i.e. 100% x 2 CPUs.

As the machine was mission critical, I elected to kill and restart it.  
I suspect I would have had no alternative, even had I had the luxury of 
unlimited time to investigate.  After restart, I (predictably) found 
nothing unusual in the logs.

Part of the restart process included running a program to "clear 98 
errors" (clear98.)  It produced some output as it went, but didn't 
complete: the machine again went in to this "busy" state.  I restarted 
the machine and noticed that a couple of snapshots had reached 100% on 
their COW tables, removed them and reran clear98, with the same results: 
machine became unresponsive and busy. Actually, I think it got slightly 
further, but not by much. Restarting again, I found another snapshot had 
reached 100% on COW table, removed it, and reran clear98.  Whilst 
running, I kept an eye on snapshots and removed them as they exceeded 
85% on COW table. Accordingly, all snapshots were removed and the 
program completed successfully.

Examining syslog, I found that later incidents were caused by out of 
memory condition.  The process identified by oom-killer was unrelated to 
clear98 (it was a bash script invoked by an incoming SSH connection.)

Jun 11 11:50:17 crowies kernel: [  838.952607] Mem-Info:
Jun 11 11:50:17 crowies kernel: [  838.952609] DMA per-cpu:
Jun 11 11:50:17 crowies kernel: [  838.952611] CPU    0: hi:    0, btch:   1 usd:   0
Jun 11 11:50:17 crowies kernel: [  838.952612] CPU    1: hi:    0, btch:   1 usd:   0
Jun 11 11:50:17 crowies kernel: [  838.952613] Normal per-cpu:
Jun 11 11:50:17 crowies kernel: [  838.952615] CPU    0: hi:  186, btch:  31 usd:   0
Jun 11 11:50:17 crowies kernel: [  838.952616] CPU    1: hi:  186, btch:  31 usd:   0
Jun 11 11:50:17 crowies kernel: [  838.952617] HighMem per-cpu:
Jun 11 11:50:17 crowies kernel: [  838.952618] CPU    0: hi:  186, btch:  31 usd:   0
Jun 11 11:50:17 crowies kernel: [  838.952620] CPU    1: hi:  186, btch:  31 usd:   0
Jun 11 11:50:17 crowies kernel: [  838.952623] active_anon:11693 inactive_anon:11899 isolated_anon:0
Jun 11 11:50:17 crowies kernel: [  838.952623]  active_file:152931 inactive_file:100402 isolated_file:0
Jun 11 11:50:17 crowies kernel: [  838.952623]  unevictable:0 dirty:5 writeback:8204 unstable:0
Jun 11 11:50:17 crowies kernel: [  838.952623]  free:23425 slab_reclaimable:2164 slab_unreclaimable:121333
Jun 11 11:50:17 crowies kernel: [  838.952623]  mapped:5100 shmem:173 pagetables:1076 bounce:0
Jun 11 11:50:17 crowies kernel: [  838.952623]  free_cma:0
Jun 11 11:50:17 crowies kernel: [  838.952630] DMA free:4068kB min:784kB low:980kB high:1176kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15804kB managed:15916kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8788kB kernel_stack:40kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Jun 11 11:50:17 crowies kernel: [  838.952631] lowmem_reserve[]: 0 869 2016 2016
Jun 11 11:50:17 crowies kernel: [  838.952638] Normal free:43464kB min:44216kB low:55268kB high:66324kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:104kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:890008kB managed:844872kB mlocked:0kB dirty:0kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:8656kB slab_unreclaimable:476544kB kernel_stack:2904kB pagetables:284kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:156 all_unreclaimable? yes
Jun 11 11:50:17 crowies kernel: [  838.952640] lowmem_reserve[]: 0 0 9175 9175
Jun 11 11:50:17 crowies kernel: [  838.952646] HighMem free:46168kB min:512kB low:15100kB high:29688kB active_anon:46772kB inactive_anon:47596kB active_file:611764kB inactive_file:401504kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1174496kB managed:1183744kB mlocked:0kB dirty:20kB writeback:32816kB mapped:20396kB shmem:692kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:4020kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Jun 11 11:50:17 crowies kernel: [  838.952648] lowmem_reserve[]: 0 0 0 0
Jun 11 11:50:17 crowies kernel: [  838.952651] DMA: 1*4kB (U) 10*8kB (U) 1*16kB (U) 0*32kB 0*64kB 1*128kB (U) 1*256kB (U) 1*512kB (U) 1*1024kB (U) 1*2048kB (R) 0*4096kB = 4068kB
Jun 11 11:50:17 crowies kernel: [  838.952662] Normal: 8483*4kB (UEM) 490*8kB (UM) 20*16kB (UM) 0*32kB 0*64kB 0*128kB 1*256kB (R) 0*512kB 1*1024kB (R) 0*2048kB 1*4096kB (R) = 43548kB
Jun 11 11:50:17 crowies kernel: [  838.952672] HighMem: 2055*4kB (UM) 1392*8kB (UM) 609*16kB (UM) 113*32kB (UM) 23*64kB (UM) 2*128kB (M) 0*256kB 5*512kB (U) 5*1024kB (UM) 0*2048kB 1*4096kB (R) = 46220kB
Jun 11 11:50:17 crowies kernel: [  838.952683] 253700 total pagecache pages
Jun 11 11:50:17 crowies kernel: [  838.952684] 172 pages in swap cache
Jun 11 11:50:17 crowies kernel: [  838.952686] Swap cache stats: add 2452, delete 2280, find 45/71
Jun 11 11:50:17 crowies kernel: [  838.952687] Free swap  = 2084224kB
Jun 11 11:50:17 crowies kernel: [  838.952688] Total swap = 2093052kB
Jun 11 11:50:17 crowies kernel: [  838.958154] 524270 pages RAM
Jun 11 11:50:17 crowies kernel: [  838.958159] 295936 pages HighMem
Jun 11 11:50:17 crowies kernel: [  838.958160] 8063 pages reserved
Jun 11 11:50:17 crowies kernel: [  838.958161] 339808 pages shared
Jun 11 11:50:17 crowies kernel: [  838.958162] 463884 pages non-shared


To investigate this problem further, I cloned the VM, created 15 
snapshots, and copied the largest file.  The cp process did not 
complete.  The oom-killer was invoked, which killed a number of 
processes, including all login shells and the cp process.  I was able to 
log in again; no restart was required.  Snapshots had used around 26% of 
COW tables.  I repeated this test a few times with the same general results.

I installed a vanilla kernel, version 3.14.7, and repeated the test 
with, again, the same general results except that my login shells were 
not killed.  They were unresponsive for a period, other than echoing 
keystrokes, but eventually the cp process was killed and they became 
responsive again.  In particular, I was not able to suspect (^Z) nor 
kill (^C) the running process.

I suspect that COW tables reaching 100% use is irrelevant.

I think what occurred was that I was writing to the underlying LV at a 
rate greater than the system was able to populate snapshots' COW tables; 
that the data being written was cached in RAM (but not swap) until free 
RAM was exhausted, and that the oom-killer started killing unrelated 
processes.  Probably, the clear98 program happened to never be targeted 
by oom-killer, and probably  it was responsible for the 200% CPU usage, 
thus starving all other tasks, especially sshd, of CPU-time.

It's hard to say whether LVM or VM is most to blame for this, but I'm 
tempted to say that VM victimises unrelated processes when out of 
memory.  Admittedly this argument is confused by the intervention of 
various kernel modules between the culpable process and the VM 
subsystem, but the general problem of OOM killing unrelated processes is 
easily demonstrated and frequently occurs in practice. It seems to me 
that allowing over-commitment of memory is begging for exactly this sort 
of confusing result.

Let me be clear: Process A requests memory; processes B & C are killed; 
where B & C later become D, E & F!

I feel that over-committing memory is a foolish and odious practice, and 
makes problem determination very much harder than it need be. When a 
process requests memory, if that cannot be satisfied the system should 
return an error and that be the end of it.

No doubt there are settings to control this, which settings I shall use, 
however the topic is sufficiently serious that a general discussion is, 
I think, more than warranted.  Let me propose that a malicious program 
could fork and request memory such that every process other than itself 
was killed.  Possible?

Returning to the problem that I experienced, even without 
over-committing memory, I expect I would still get OOM condition because 
LVM, apparently, is consuming memory.  So there seems to be a problem to 
be solved, there, too.  Again, let me propose that a malicious program 
could write data at a sufficient rate to trigger this problem if 
snapshots are in use, and that it could also remove the files that it 
creates, as it goes, so as to make it difficult to detect what it is 
doing.  In particular, it could remain under any arbitrary disk quota.

Actual use of snapshots seems to beg denial of service.

Hoping for some pearls of wisdom...

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
