Date: Thu, 12 Jun 2008 11:41:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: repeatable slab corruption with LTP msgctl08
Message-Id: <20080612114152.18895d6c.akpm@linux-foundation.org>
In-Reply-To: <48516BF3.8050805@colorfullife.com>
References: <20080611221324.42270ef2.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0806121332130.11556@sbz-30.cs.Helsinki.FI>
	<48516BF3.8050805@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, Nadia Derbey <Nadia.Derbey@bull.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008 20:33:23 +0200 Manfred Spraul <manfred@colorfullife.com> wrote:

> Pekka J Enberg wrote:
> > Hi Andrew,
> >
> > On Wed, 11 Jun 2008, Andrew Morton wrote:
> >   
> >> version is ltp-full-20070228 (lots of retro-computing there).
> >>
> >> Config is at http://userweb.kernel.org/~akpm/config-vmm.txt
> >>
> >> ./testcases/bin/msgctl08 crashes after ten minutes or so:
> >>
> >> slab: Internal list corruption detected in cache 'size-128'(26), slabp f2905000(20). Hexdump:
> >>
> >> 000: 00 e0 12 f2 88 32 c0 f7 88 00 00 00 88 50 90 f2
> >> 010: 14 00 00 00 0f 00 00 00 00 00 00 00 ff ff ff ff
> >> 020: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
> >> 030: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
> >> 040: fd ff ff ff fd ff ff ff 00 00 00 00 fd ff ff ff
> >> 050: fd ff ff ff fd ff ff ff 19 00 00 00 17 00 00 00
> >> 060: fd ff ff ff fd ff ff ff 0b 00 00 00 fd ff ff ff
> >> 070: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
> >> 080: 10 00 00 00
> >>     
> >
> > Looking at the above dump, slabp->free is 0x0f and the bufctl it points to 
> > is 0xff ("BUFCTL_END") which marks the last element in the chain. This is 
> > wrong as the total number of objects in the slab (cachep->num) is 26 but 
> > the number of objects in use (slabp->inuse) is 20. So somehow you have 
> > managed to lost 6 objects from the bufctl chain.
> >
> >   
> Hmm. double kfree() should be cached by the redzone code.
> And I disagree with your link interpretation:
> 
> 000: 00 e0 12 f2 88 32 c0 f7 88 00 00 00 88 50 90 f2
> 010:
> inuse: 14 00 00 00 (20 entries in use, 6 should be free)
> free:  0f 00 00 00
> nodeid: 00 00 00 00
> bufctl[0x00] ff ff ff ff 020: fd ff ff ff fd ff ff ff fd ff ff ff
> bufctl[0x4] fd ff ff ff  030: fd ff ff ff fd ff ff ff fd ff ff ff
> bufctl[0x8] fd ff ff ff  040: fd ff ff ff fd ff ff ff 00 00 00 00
> bufctl[0x0c] fd ff ff ff 050: fd ff ff ff fd ff ff ff 19 00 00 00
> bufctl[0x10] 17 00 00 00 060: fd ff ff ff fd ff ff ff 0b 00 00 00
> bufctl[0x14] fd ff ff ff 070: fd ff ff ff fd ff ff ff fd ff ff ff
> bufctl[0x18] fd ff ff ff 080: 10 00 00 00
> 
> free: points to entry 0x0f.
> bufctl[0x0f] is 0x19, i.e. it points to entry 0x19
> 0x19 points to 0x10
> 0x10 points to 0x17
> 0x17 is a BUFCTL_ACTIVE - that's a bug.
> but: 0x13 is a valid link entry, is points to 0x0b
> 0x0b points to 0x00, which is BUFCTL_END.
> 
> IMHO the most probable bug is a single bit error:
> bufctl[0x10] should be 0x13 instead of 0x17.
> 
> What about printing all redzone words? That would allow us to validate the bufctl chain.
> 
> Andrew: Could you post the new oops?
> 

umm, what new oops?

I have four saved away here:

slab: Internal list corruption detected in cache 'size-96'(32), slabp ea2a5040(28). Hexdump:

000: 20 90 b5 ec 88 54 80 f7 e0 00 00 00 e0 50 2a ea
010: 1c 00 00 00 17 00 00 00 00 00 00 00 fd ff ff ff
020: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
030: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
040: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
050: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
060: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
070: fd ff ff ff fd ff ff ff 18 00 00 00 1f 00 00 00
080: fd ff ff ff fd ff ff ff 1c 00 00 00 ff ff ff ff
090: fd ff ff ff fd ff ff ff fd ff ff ff
------------[ cut here ]------------
kernel BUG at mm/slab.c:2949!
invalid opcode: 0000 [#1] SMP 
last sysfs file: 
Modules linked in:

Pid: 5535, comm: msgctl08 Not tainted (2.6.26-rc5-mm3 #3)
EIP: 0060:[<c0184b5b>] EFLAGS: 00010082 CPU: 0
EIP is at check_slabp+0xeb/0x100
EAX: 00000001 EBX: ea2a50db ECX: 00000001 EDX: eea93230
ESI: ea2a5040 EDI: 0000009c EBP: eea95e84 ESP: eea95e60
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process msgctl08 (pid: 5535, ti=eea94000 task=eea93230 task.ti=eea94000)
Stack: c048897a 000000ff 00000020 ea2a5040 0000001c f7801140 f7822478 00000010 
       ea2a5040 eea95eec c0185eaf 00000000 00000010 000000d0 00000001 f78054ac 
       000000d0 f7801140 00000010 f7805488 f7808d38 c063a068 eea935e8 00000001 
Call Trace:
 [<c0185eaf>] ? cache_alloc_refill+0xcf/0x6c0
 [<c01865f4>] ? __kmalloc+0x154/0x160
 [<c0264113>] ? load_msg+0x33/0x150
 [<c0264113>] ? load_msg+0x33/0x150
 [<c02648ab>] ? do_msgsnd+0x17b/0x2e0
 [<c0264779>] ? do_msgsnd+0x49/0x2e0
 [<c02647d8>] ? do_msgsnd+0xa8/0x2e0
 [<c0264a42>] ? sys_msgsnd+0x32/0x40
 [<c0106eb2>] ? sys_ipc+0xb2/0x240
 [<c02855e4>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c0102f35>] ? sysenter_past_esp+0x6a/0xa5
 =======================
Code: 02 fa ff 8b 55 f0 8b 42 38 8d 04 85 1c 00 00 00 39 f8 76 0b 43 f7 c7 0f 00 00 00 75 d2 eb bd c7 04 24 7a 89 48 c0 e8 25 02 fa ff <0f> 0b eb fe 83 c4 18 5b 5e 5f 5d c3 8b 56 10 e9 6b ff ff ff 90 
EIP: [<c0184b5b>] check_slabp+0xeb/0x100 SS:ESP 0068:eea95e60
---[ end trace ec15c778c59809d4 ]---


slab: Internal list corruption detected in cache 'size-128'(26), slabp f2905000(20). Hexdump:

000: 00 e0 12 f2 88 32 c0 f7 88 00 00 00 88 50 90 f2
010: 14 00 00 00 0f 00 00 00 00 00 00 00 ff ff ff ff
020: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
030: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
040: fd ff ff ff fd ff ff ff 00 00 00 00 fd ff ff ff
050: fd ff ff ff fd ff ff ff 19 00 00 00 17 00 00 00
060: fd ff ff ff fd ff ff ff 0b 00 00 00 fd ff ff ff
070: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
080: 10 00 00 00
------------[ cut here ]------------
kernel BUG at mm/slab.c:2949!
invalid opcode: 0000 [#1] SMP 
Modules linked in:

Pid: 3348, comm: msgctl08 Not tainted (2.6.26-rc5 #1)
EIP: 0060:[<c017a35b>] EFLAGS: 00010086 CPU: 0
EIP is at check_slabp+0xeb/0x100
EAX: 00000001 EBX: f2905083 ECX: 00000001 EDX: f20ee670
ESI: f2905000 EDI: 00000084 EBP: f4671e88 ESP: f4671e64
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process msgctl08 (pid: 3348, ti=f4670000 task=f20ee670 task.ti=f4670000)
Stack: c0472f2b 00000000 0000001a f2905000 00000014 f7c01500 ffffffff 0000000e 
       f2905000 f4671eec c017b69f 00000010 000000d0 f20ee670 f7c032ac 000000d0 
       f7c01500 0000000e f7c03288 f7c06df0 f29ec088 00000098 00000000 00000000 
Call Trace:
 [<c017b69f>] ? cache_alloc_refill+0xcf/0x6b0
 [<c017bdd4>] ? __kmalloc+0x154/0x160
 [<c0257663>] ? load_msg+0x33/0x150
 [<c0257663>] ? load_msg+0x33/0x150
 [<c0257dfb>] ? do_msgsnd+0x17b/0x2e0
 [<c0257cc9>] ? do_msgsnd+0x49/0x2e0
 [<c0126f1f>] ? __do_softirq+0x6f/0x100
 [<c0126e58>] ? _local_bh_enable+0x48/0xa0
 [<c0257f92>] ? sys_msgsnd+0x32/0x40
 [<c0106e12>] ? sys_ipc+0xb2/0x240
 [<c0102f58>] ? sysenter_past_esp+0xa5/0xb1
 [<c0102f1d>] ? sysenter_past_esp+0x6a/0xb1
 =======================
Code: 86 fa ff 8b 55 f0 8b 42 38 8d 04 85 1c 00 00 00 39 f8 76 0b 43 f7 c7 0f 00 00 00 75 d2 eb bd c7 04 24 2b 2f 47 c0 e8 85 86 fa ff <0f> 0b eb fe 83 c4 18 5b 5e 5f 5d c3 8b 56 10 e9 6b ff ff ff 90 
EIP: [<c017a35b>] check_slabp+0xeb/0x100 SS:ESP 0068:f4671e64
---[ end trace d7a2cbbb5a3654be ]---


slab: Internal list corruption detected in cache 'size-128'(26), slabp f7159000(18). Hexdump:

000: 00 f0 f8 f2 88 32 c0 f7 88 00 00 00 88 90 15 f7
010: 12 00 00 00 08 00 00 00 00 00 00 00 13 00 00 00
020: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
030: 06 00 00 00 ff ff ff ff fd ff ff ff 18 00 00 00
040: fd ff ff ff fd ff ff ff 17 00 00 00 fd ff ff ff
050: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
060: fd ff ff ff fd ff ff ff 05 00 00 00 fd ff ff ff
070: fd ff ff ff fd ff ff ff 00 00 00 00 0f 00 00 00
080: fd ff ff ff
------------[ cut here ]------------
kernel BUG at mm/slab.c:2949!
invalid opcode: 0000 [#1] SMP 
Modules linked in:

Pid: 3735, comm: msgctl08 Not tainted (2.6.26-rc5 #3)
EIP: 0060:[<c017a35b>] EFLAGS: 00010086 CPU: 1
EIP is at check_slabp+0xeb/0x100
EAX: 00000001 EBX: f7159083 ECX: 00000001 EDX: efa2f120
ESI: f7159000 EDI: 00000084 EBP: efa31e88 ESP: efa31e64
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process msgctl08 (pid: 3735, ti=efa30000 task=efa2f120 task.ti=efa30000)
Stack: c0472f2b 000000ff 0000001a f7159000 00000012 f7c01500 ffffffff 0000000e 
       f7159000 efa31eec c017b69f 00000010 000000d0 efa2f120 f7c032ac 000000d0 
       f7c01500 0000000e f7c03288 f7c1f4c8 f7184088 00000098 00000000 00000000 
Call Trace:
 [<c017b69f>] ? cache_alloc_refill+0xcf/0x6b0
 [<c017bdd4>] ? __kmalloc+0x154/0x160
 [<c0257663>] ? load_msg+0x33/0x150
 [<c0257663>] ? load_msg+0x33/0x150
 [<c0257dfb>] ? do_msgsnd+0x17b/0x2e0
 [<c0257cc9>] ? do_msgsnd+0x49/0x2e0
 [<c0257d28>] ? do_msgsnd+0xa8/0x2e0
 [<c0257f92>] ? sys_msgsnd+0x32/0x40
 [<c0106e12>] ? sys_ipc+0xb2/0x240
 [<c0102f58>] ? sysenter_past_esp+0xa5/0xb1
 [<c0102f1d>] ? sysenter_past_esp+0x6a/0xb1
 =======================
Code: 86 fa ff 8b 55 f0 8b 42 38 8d 04 85 1c 00 00 00 39 f8 76 0b 43 f7 c7 0f 00 00 00 75 d2 eb bd c7 04 24 2b 2f 47 c0 e8 85 86 fa ff <0f> 0b eb fe 83 c4 18 5b 5e 5f 5d c3 8b 56 10 e9 6b ff ff ff 90 
EIP: [<c017a35b>] check_slabp+0xeb/0x100 SS:ESP 0068:efa31e64
---[ end trace f87c199ef1dd2595 ]---


slab: Internal list corruption detected in cache 'size-128'(26), slabp ed9a9000(21). Hexdump:

000: 00 c0 3a f3 88 32 80 f7 88 00 00 00 88 90 9a ed
010: 15 00 00 00 12 00 00 00 00 00 00 00 fd ff ff ff
020: fd ff ff ff fd ff ff ff 07 00 00 00 fd ff ff ff
030: fd ff ff ff fd ff ff ff 08 00 00 00 0f 00 00 00
040: fd ff ff ff fd ff ff ff ff ff ff ff fd ff ff ff
050: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
060: fd ff ff ff 03 00 00 00 fd ff ff ff fd ff ff ff
070: fd ff ff ff fd ff ff ff fd ff ff ff fd ff ff ff
080: fd ff ff ff
------------[ cut here ]------------
kernel BUG at mm/slab.c:2949!
invalid opcode: 0000 [#1] SMP 
last sysfs file: 
Modules linked in:

Pid: 5787, comm: msgctl08 Not tainted (2.6.26-rc5-mm3 #4)
EIP: 0060:[<c0184b5b>] EFLAGS: 00010082 CPU: 0
EIP is at check_slabp+0xeb/0x100
EAX: 00000001 EBX: ed9a9083 ECX: 00000001 EDX: ef708390
ESI: ed9a9000 EDI: 00000084 EBP: eee09e84 ESP: eee09e60
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process msgctl08 (pid: 5787, ti=eee08000 task=ef708390 task.ti=eee08000)
Stack: c048897a 000000ff 0000001a ed9a9000 00000015 f7801500 ffffffff 00000003 
       ed9a9000 eee09eec c0185eaf 00000000 00000010 000000d0 00000001 f78032ac 
       000000d0 f7801500 00000003 f7803288 f7806df0 f2199088 00000098 00000001 
Call Trace:
 [<c0185eaf>] ? cache_alloc_refill+0xcf/0x6c0
 [<c01865f4>] ? __kmalloc+0x154/0x160
 [<c0264113>] ? load_msg+0x33/0x150
 [<c0264113>] ? load_msg+0x33/0x150
 [<c02648ab>] ? do_msgsnd+0x17b/0x2e0
 [<c0264779>] ? do_msgsnd+0x49/0x2e0
 [<c0142bab>] ? trace_hardirqs_on+0xb/0x10
 [<c0128d78>] ? _local_bh_enable+0x48/0xa0
 [<c0264a42>] ? sys_msgsnd+0x32/0x40
 [<c0106eb2>] ? sys_ipc+0xb2/0x240
 [<c02855e4>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c0102f35>] ? sysenter_past_esp+0x6a/0xa5
 [<c03d007b>] ? check_tsc_sync_source+0xfb/0x100
 =======================
Code: 02 fa ff 8b 55 f0 8b 42 38 8d 04 85 1c 00 00 00 39 f8 76 0b 43 f7 c7 0f 00 00 00 75 d2 eb bd c7 04 24 7a 89 48 c0 e8 25 02 fa ff <0f> 0b eb fe 83 c4 18 5b 5e 5f 5d c3 8b 56 10 e9 6b ff ff ff 90 
EIP: [<c0184b5b>] check_slabp+0xeb/0x100 SS:ESP 0068:eee09e60
---[ end trace 0ba54d745d3f642c ]---

but they're all from under basically the same conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
