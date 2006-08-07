Date: Mon, 7 Aug 2006 16:10:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: 2.6.18-rc3-mm2: rcu radix tree patches break page migration
Message-ID: <Pine.LNX.4.64.0608071556530.23088@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If I take the following patches out then page migration works reliably 
again. Otherwise page migration may result in weird values in the
page struct. Reproduce by trying to migrate the executable pages
of a running process. This usually creates enough races to break things.
AFAIK the current radix tree rcu patches do not change the behavior
of the tree_lock at all.

radix-tree-rcu-lockless-readside.patch
redo-radix-tree-fixes.patch
adix-tree-rcu-lockless-readside-update.patch
radix-tree-rcu-lockless-readside-semicolon.patch
adix-tree-rcu-lockless-readside-update-tidy.patch
adix-tree-rcu-lockless-readside-fix-2.patch

Output in one failure scenario (after migrating the memory of cron back 
and forth between nodes):

margin:~ # ps ax|grep cron
 3995 ?        Ss     0:00 /usr/sbin/cron
 4256 ttySG0   S+     0:00 grep cron
margin:~ # cat /proc/3995/numa_maps
00000000 default
2000000000000000 default anon=2 dirty=2 N1=2
2000000000200000 default file=/var/run/nscd/passwd dirty=1 mapmax=9 N3=1
2000000800000000 default file=/usr/sbin/cron mapped=5 active=4 N0=2 N1=2 
N2=1
2000000800020000 default file=/usr/sbin/cron anon=1 dirty=1 N0=1
2000000800024000 default file=/lib/ld-2.4.so mapped=7 mapmax=46 N0=7
2000000800068000 default file=/lib/ld-2.4.so anon=2 dirty=2 N0=1 N1=1
2000000800088000 default file=/lib/libpam.so.0.81.2 mapped=1 mapmax=5 N0=1
20000008000a0000 default file=/lib/libpam.so.0.81.2
20000008000ac000 default file=/lib/libpam.so.0.81.2 anon=1 dirty=1 N0=1
20000008000b0000 default anon=1 dirty=1 N0=1
20000008000b4000 default file=/lib/libpam_misc.so.0.81.2 mapped=1 mapmax=2 
N2=1
20000008000b8000 default file=/lib/libpam_misc.so.0.81.2
20000008000c4000 default file=/lib/libpam_misc.so.0.81.2 anon=1 dirty=1 
N0=1
20000008000c8000 default file=/lib/libc-2.4.so mapped=58 mapmax=46 N0=58
2000000800300000 default file=/lib/libc-2.4.so
200000080030c000 default file=/lib/libc-2.4.so anon=2 dirty=2 N0=2
2000000800314000 default anon=1 dirty=1 N0=1
2000000800318000 default file=/lib/libdl-2.4.so mapped=1 mapmax=17 N0=1
2000000800320000 default file=/lib/libdl-2.4.so
200000080032c000 default file=/lib/libdl-2.4.so anon=1 dirty=1 N0=1
2000000800330000 default anon=5 dirty=5 N0=5
607fffff7fffc000 default anon=1 dirty=1 N0=1
607ffffffe58c000 default stack anon=1 dirty=1 N1=1

margin:~ # migratepages 3995 0-2 3
Bad page state in process 'migratepages'
page:a0007ffeafd24fe0 flags:0x000000000009020c mapping:0000000000000000 
mapcount:0 count:0
Trying to fix it up, but a reboot is needed
Backtrace:
margin:~ # kernel BUG at mm/page_alloc.c:308!
events/5[31]: bugcheck! 0 [1]
Modules linked in: autofs4 ipv6 sg

Pid: 31, CPU 5, comm:             events/5
psr : 0000101008522030 ifs : 8000000000000792 ip  : [<a0000001001052e0>]    
Tainted: G    B
ip is at free_pages_bulk+0x480/0x600
unat: 0000000000000000 pfs : 0000000000000792 rsc : 0000000000000003
rnat: 0000000000000000 bsps: 0000000000000000 pr  : 0000000000009981
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001052e0 b6  : e0000130025cbb10 b7  : a0000001000d0580
f6  : 1003e20c49ba5e353f7cf f7  : 1003e20c49ba5e353f7cf
f8  : 1003e00000000000000a0 f9  : 1003e00000000000004e2
f10 : 1003e000000000fa00000 f11 : 1003e000000003b9aca00
r1  : a000000100d62a50 r2  : 0000000000004000 r3  : e00000b003d59070
r8  : 0000000000000026 r9  : 0000000000000001 r10 : 0000000000000002
r11 : 0000000000000003 r12 : e00000b003d5fcd0 r13 : e00000b003d58000
r14 : e00000b003d59070 r15 : 0000000000000000 r16 : 0000000000004000
r17 : e00000b079377de8 r18 : 3f00000000000000 r19 : 3f00000000000000
r20 : ffffffffffff4230 r21 : e000013003040000 r22 : ffffffffffff0028
r23 : a000000100b63290 r24 : a000000100b62e60 r25 : 0000000000000001
r26 : a000000100970e84 r27 : e000013003034230 r28 : e000013003040000
r29 : a000000100b63290 r30 : a000000100b62e60 r31 : 80000001fdc00000

Call Trace:
 [<a000000100012f60>] show_stack+0x40/0xa0
                                sp=e00000b003d5f840 bsp=e00000b003d593c0
 [<a000000100013790>] show_regs+0x7d0/0x800
                                sp=e00000b003d5fa10 bsp=e00000b003d59378
 [<a000000100033990>] die+0x230/0x300
                                sp=e00000b003d5fa10 bsp=e00000b003d59330
 [<a000000100033aa0>] die_if_kernel+0x40/0x60
                                sp=e00000b003d5fa30 bsp=e00000b003d59300
 [<a000000100034ec0>] ia64_bad_break+0x220/0x460
                                sp=e00000b003d5fa30 bsp=e00000b003d592d8
 [<a00000010000bb20>] ia64_leave_kernel+0x0/0x290
                                sp=e00000b003d5fb00 bsp=e00000b003d592d8
 [<a0000001001052e0>] free_pages_bulk+0x480/0x600
                                sp=e00000b003d5fcd0 bsp=e00000b003d59248
 [<a000000100105a40>] drain_node_pages+0xe0/0x180
                                sp=e00000b003d5fcd0 bsp=e00000b003d59200
 [<a000000100145970>] cache_reap+0x4d0/0x600
                                sp=e00000b003d5fcd0 bsp=e00000b003d591b0
 [<a0000001000c72d0>] run_workqueue+0x1b0/0x280
                                sp=e00000b003d5fce0 bsp=e00000b003d59168
 [<a0000001000c7560>] worker_thread+0x1c0/0x240
                                sp=e00000b003d5fce0 bsp=e00000b003d59128
 [<a0000001000d0260>] kthread+0x240/0x2c0
                                sp=e00000b003d5fd50 bsp=e00000b003d590e8
 [<a0000001000114a0>] kernel_thread_helper+0xe0/0x100
                                sp=e00000b003d5fe30 bsp=e00000b003d590c0
 [<a000000100009140>] start_kernel_thread+0x20/0x40
                                sp=e00000b003d5fe30 bsp=e00000b003d590c0
 <6>note: events/5[31] exited with preempt_count 1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
