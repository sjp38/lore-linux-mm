Date: Wed, 11 Jun 2008 22:13:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: repeatable slab corruption with LTP msgctl08
Message-Id: <20080611221324.42270ef2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>, Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Running current mainline on my old 2-way PIII.  Distro is RH FC1.  LTP
version is ltp-full-20070228 (lots of retro-computing there).

Config is at http://userweb.kernel.org/~akpm/config-vmm.txt


./testcases/bin/msgctl08 crashes after ten minutes or so:

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


Pekka (or Christoph): could you please decrypt the slab bits for us?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
