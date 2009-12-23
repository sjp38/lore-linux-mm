Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 4356A620002
	for <linux-mm@kvack.org>; Wed, 23 Dec 2009 01:52:56 -0500 (EST)
Message-ID: <4B31BE44.1070308@linux.intel.com>
Date: Wed, 23 Dec 2009 14:52:52 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: initialize unused alien cache entry as NULL at
 alloc_alien_cache().
References: <4B30BDA8.1070904@linux.intel.com> <alpine.DEB.2.00.0912220945250.12048@router.home>
In-Reply-To: <alpine.DEB.2.00.0912220945250.12048@router.home>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, andi@firstfloor.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph & Matt,

Thanks for the review. Node ids beyond nr_node_ids could be used in the case of
memory hotadding.

Let me explain here:
Firstly, original nr_node_ids = 1 + nid of highest POSSIBLE node.

Secondly, consider hotplug-adding the memories that are on a new_added node:
1. when acpi event is triggered:
acpi_memory_device_add() -> acpi_memory_enable_device() -> add_memory() -> node_set_online()

The node_state[N_ONLINE] is updated with this new node added.
And the id of this new node is beyond nr_node_ids.

2. Then as reap_timer is scheduled in:
cache_reap() -> next_reap_node() -> node = next_node(node, node_online_map)
then the new_added node would be selected as the reap node of this cpu, for example CPU X.

3. when reap_timer of CPU X is triggered again:
cache_reap() -> reap_alien()
it would access this new added node as reap_node of CPU X.


I have caught this BUG in our memory-hotadd testing as below:
the test scenario is that there are originally 2 nodes enabled on the machine,
then hot-add memory on the 3rd node.

the BUG is:
[  141.667487] BUG: unable to handle kernel NULL pointer dereference at 0000000000000078
[  141.667782] IP: [<ffffffff810b8a64>] cache_reap+0x71/0x236
[  141.667969] PGD 0
[  141.668129] Oops: 0000 [#1] SMP
[  141.668357] last sysfs file: /sys/class/scsi_host/host4/proc_name
[  141.668469] CPU
[  141.668630] Modules linked in: ipv6 autofs4 rfcomm l2cap crc16 bluetooth rfkill 
binfmt_misc dm_mirror dm_region_hash dm_log dm_multipath dm_mod video output sbs sbshc fan 
battery ac parport_pc lp parport joydev usbhid sr_mod cdrom thermal processor thermal_sys 
container button rtc_cmos rtc_core rtc_lib i2c_i801 i2c_core pcspkr uhci_hcd ohci_hcd 
ehci_hcd usbcore
[  141.671659] Pid: 126, comm: events/27 Not tainted 2.6.32 #9  Server
[  141.671771] RIP: 0010:[<ffffffff810b8a64>]  [<ffffffff810b8a64>] cache_reap+0x71/0x236
[  141.671981] RSP: 0018:ffff88027e81bdf0  EFLAGS: 00010206
[  141.672089] RAX: 0000000000000002 RBX: 0000000000000078 RCX: ffff88047d86e580
[  141.672204] RDX: ffff88047dfcbc00 RSI: ffff88047f13f6c0 RDI: ffff88047d9136c0
[  141.672319] RBP: ffff88027e81be30 R08: 0000000000000001 R09: 0000000000000001
[  141.672433] R10: 0000000000000000 R11: 0000000000000086 R12: ffff88047d87c200
[  141.672548] R13: ffff88047d87d680 R14: ffffffff810b89f3 R15: 0000000000000002
[  141.672663] FS:  0000000000000000(0000) GS:ffff88028b5a0000(0000) knlGS:0000000000000000
[  141.672807] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[  141.672917] CR2: 0000000000000078 CR3: 0000000001001000 CR4: 00000000000006e0
[  141.673032] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  141.673147] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  141.673262] Process events/27 (pid: 126, threadinfo ffff88027e81a000, task 
ffff88027f3ea040)
[  141.673406] Stack:
[  141.673503]  ffff88027e81be30 ffff88028b5b05a0 0000000100000000 ffff88027e81be80
[  141.673808] <0> ffff88028b5b5b40 ffff88028b5b05a0 ffffffff810b89f3 fffffffff00000c6
[  141.674265] <0> ffff88027e81bec0 ffffffff81057394 ffffffff8105733e ffffffff81369f3a
[  141.674813] Call Trace:
[  141.674915]  [<ffffffff810b89f3>] ? cache_reap+0x0/0x236
[  141.675028]  [<ffffffff81057394>] worker_thread+0x17a/0x27b
[  141.675138]  [<ffffffff8105733e>] ? worker_thread+0x124/0x27b
[  141.675256]  [<ffffffff81369f3a>] ? thread_return+0x3e/0xee
[  141.675369]  [<ffffffff8105a244>] ? autoremove_wake_function+0x0/0x38
[  141.675482]  [<ffffffff8105721a>] ? worker_thread+0x0/0x27b
[  141.675593]  [<ffffffff8105a146>] kthread+0x7d/0x87
[  141.675707]  [<ffffffff81012daa>] child_rip+0xa/0x20
[  141.675817]  [<ffffffff81012710>] ? restore_args+0x0/0x30
[  141.675927]  [<ffffffff8105a0c9>] ? kthread+0x0/0x87
[  141.676035]  [<ffffffff81012da0>] ? child_rip+0x0/0x20
[  141.676142] Code: a4 c5 68 08 00 00 65 48 8b 04 25 00 e4 00 00 48 8b 04 18 49 8b 4c 24 
78 48 85 c9 74 5b 41 89 c7 48 98 48 8b 1c c1 48 85 db 74 4d <83> 3b 00 74 48 48 83 3d ff 
d4 65 00 00 75 04 0f 0b eb fe fa 66
[  141.680610] RIP  [<ffffffff810b8a64>] cache_reap+0x71/0x236
[  141.680785]  RSP <ffff88027e81bdf0>
[  141.680886] CR2: 0000000000000078
[  141.681016] ---[ end trace b1e17069ef81fe83 ]--

corresponding assembly code is:
ffffffff810b8a3f:       65 48 8b 04 25 00 e4    mov    %gs:0xe400,%rax
ffffffff810b8a46:       00 00
ffffffff810b8a48:       48 8b 04 18             mov    (%rax,%rbx,1),%rax
ffffffff810b8a4c:       49 8b 4c 24 78          mov    0x78(%r12),%rcx
ffffffff810b8a51:       48 85 c9                test   %rcx,%rcx
ffffffff810b8a54:       74 5b                   je     ffffffff810b8ab1 <cache_reap+0xbe>
ffffffff810b8a56:       41 89 c7                mov    %eax,%r15d
ffffffff810b8a59:       48 98                   cltq
ffffffff810b8a5b:       48 8b 1c c1             mov    (%rcx,%rax,8),%rbx
ffffffff810b8a5f:       48 85 db                test   %rbx,%rbx
ffffffff810b8a62:       74 4d                   je     ffffffff810b8ab1 <cache_reap+0xbe>
ffffffff810b8a64:       83 3b 00                cmpl   $0x0,(%rbx)

here (0xffffffff810b8a64) this is the oops point, corresponding to code $KSRC/mm/slab.c:1035:

1025 /*
1026  * Called from cache_reap() to regularly drain alien caches round robin.
1027  */
1028 static void reap_alien(struct kmem_cache *cachep, struct kmem_list3 *l3)
1029 {
1030         int node = __get_cpu_var(reap_node);
1031
1032         if (l3->alien) {
1033                 struct array_cache *ac = l3->alien[node];
1034
1035                 if (ac && ac->avail && spin_trylock_irq(&ac->lock)) {
1036                         __drain_alien_cache(cachep, ac, node);
1037                         spin_unlock_irq(&ac->lock);
1038                 }
1039         }
1040 }

RAX: 0000000000000002 -> node
RBX: 0000000000000078 -> ac
(%rbx) -> ac->avail

The value of ac is random and invalid, ac->avail dereference causes the oops.
the reap_node (3rd node) is the new added node by mem hotadd. however, for old kmem_list,
its l3->alien has only 2 cache entries (nr_node_ids = 2), so l3->alien[2] is invalid.

Christoph Lameter wrote:
> On Tue, 22 Dec 2009, Haicheng Li wrote:
> 
>>  	struct array_cache **ac_ptr;
>> -	int memsize = sizeof(void *) * nr_node_ids;
>> +	int memsize = sizeof(void *) * MAX_NUMNODES;
>>  	int i;
> 
> Why does the alien cache pointer array size have to be increased? node ids
> beyond nr_node_ids cannot be used.
> 
> 
>>  	if (limit > 1)
>>  		limit = 12;
>>  	ac_ptr = kmalloc_node(memsize, gfp, node);
> 
> Use kzalloc to ensure zeroed memory.
> 
>>  	if (ac_ptr) {
>> +		memset(ac_ptr, 0, memsize);
>>  		for_each_node(i) {
>> -			if (i == node || !node_online(i)) {
>> -				ac_ptr[i] = NULL;
>> +			if (i == node || !node_online(i))
>>  				continue;
>> -			}
>>  			ac_ptr[i] = alloc_arraycache(node, limit, 0xbaadf00d,
>> gfp);
>>  			if (!ac_ptr[i]) {
>>  				for (i--; i >= 0; i--)
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
