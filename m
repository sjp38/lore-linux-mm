Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id C09B26B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 23:53:38 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id b40so515599qcq.39
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 20:53:37 -0700 (PDT)
Message-ID: <516633BB.40307@gmail.com>
Date: Thu, 11 Apr 2013 11:53:31 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch 0/2] mm: Add parameters to make kernel behavior at
 memory error on dirty cache selectable
References: <51662D5B.3050001@hitachi.com>
In-Reply-To: <51662D5B.3050001@hitachi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hi Mitsuhiro,
On 04/11/2013 11:26 AM, Mitsuhiro Tanino wrote:
> Hi All,
> Please find a patch set that introduces these new sysctl interfaces,
> to handle a case when an memory error is detected on dirty page cache.
>
> - vm.memory_failure_dirty_panic
> - vm.memory_failure_print_ratelimit
> - vm.memory_failure_print_ratelimit_burst
>
> Problem
> ---------
> Recently, it is common that enterprise servers likely have a large
> amount of memory, especially for cloud environment. This means that
> possibility of memory failures is increased.
>
> To handle memory failure, Linux has a hwpoison feature. When a memory
> error is detected by memory scrub, the error is reported as machine
> check, uncorrected recoverable (UCR), to OS. Then OS isolates the memory
> region with memory failure if the memory page can be isolated.
> The hwpoison handles it according to the memory region, such as kernel,
> dirty cache, clean cache. If the memory region can be isolated, the
> page is marked "hwpoison" and it is not used again.
>
> When SRAO machine check is reported on a page which is included dirty
> page cache, the page is truncated because the memory is corrupted and
> data of the page cannot be written to a disk any more.
>
> As a result, if the dirty cache includes user data, the data is lost,
> and data corruption occurs if an application uses old data.

One question against mce instead of the patchset. ;-)

When check memory is bad? Before memory access? Is there a process scan 
it period?

>
>
> Solution
> ---------
> The patch proposes a new sysctl interface, vm.memory_failure_dirty_panic,
> in order to prevent data corruption comes from data lost problem.
> Also this patch displays information of affected file such as device name,
> inode number, file offset and file type if the file is mapped on a memory
> and the page is dirty cache.
>
> When SRAO machine check occurs on a dirty page cache, corresponding
> data cannot be recovered any more. Therefore, the patch proposes a kernel
> option to keep a system running or force system panic in order
> to avoid further trouble such as data corruption problem of application.
>
> System administrator can select an error action using this option
> according to characteristics of target system.
>
>
>
> Use Case
> ---------
> This option is intended to be adopted in KVM guest because it is
> supposed that Linux on KVM guest operates customers business and
> it is big impact to lost or corrupt customers data by memory failure.
>
> On the other hand, this option does not recommend to apply KVM host
> as following reasons.
>
> - Making KVM host panic has a big impact because all virtual guests are
>    affected by their host panic. Affected virtual guests are forced to stop
>    and have to be restarted on the other hypervisor.
>
> - If disk cached model of qemu is set to "none", I/O type of virtual
>    guests becomes O_DIRECT and KVM host does not cache guest's disk I/O.
>    Therefore, if SRAO machine check is reported on a dirty page cache
>    in KVM host, its virtual machines are not affected by the machine check.
>    So the host is expected to keep operating instead of kernel panic.
>
>
> Past discussion
> --------------------
> This problem was previously discussed in the kernel community,
> (refer: mail threads pertaining to
> http://marc.info/?l=linux-kernel&m=135187403804934&w=4).
>
>>> - I worry that if a hardware error occurs, it might affect a large
>>>    amount of memory all at the same time.  For example, if a 4G memory
>>>    block goes bad, this message will be printed a million times?
>
> As Andrew mentioned in the above threads, if 4GB memory blocks goes bad,
> error messages will be printed a million times and this behavior loses
> a system reliability.
>
> Therefore, the second patch introduces two sysctl parameters for
> __ratelimit() which is used at mce_notify_irq() in order to notify
> occurrence of machine check event to system administrator.
> The use of __ratelimit(), this patch can limit quantity of messages
> per interval to be output at syslog or terminal console.
>
> If system administrator needs to limit quantity of messages,
> these parameters are available.
>
> - vm.memory_failure_print_ratelimit:
>    Specifies the minimum length of time between messages.
>    By default the rate limiting is disabled.
>
> - vm.memory_failure_print_ratelimit_burst:
>    Specifies the number of messages we can send before rate limiting.
>
>
>
> Test Results
> ---------
> These patches are tested on 3.8.1 kernel(FC18) using software pseudo MCE
> injection from KVM host to guest.
>
>
> ******** Host OS Screen logs(SRAO Machine Check injection) ********
> Inject software pseudo MCE into guest qemu process.
>
> (1) Load mce-inject module
> # modprobe mce-inject
>
> (2) Find a PID of target qemu-kvm and page struct
> # ps -C qemu-kvm -o pid=
>   8176
>
> (3) Edit software pseudo MCE data
> Choose a offset of page struct and insert the offset to ADDR line in mce-file.
>
> #  ./page-types -p 8176 -LN | grep "___UDlA____Ma_b___________________"
> voffset         offset  flags
> ...
> 7fd25eb77       344d77  ___UDlA____Ma_b___________________
> 7fd25eb78       344d78  ___UDlA____Ma_b___________________
> 7fd25eb79       344d79  ___UDlA____Ma_b___________________
> 7fd25eb7a       344d7a  ___UDlA____Ma_b___________________
> 7fd25eb7b       344d7b  ___UDlA____Ma_b___________________
> 7fd25eb7c       344d7c  ___UDlA____Ma_b___________________
> 7fd25eb7d       344d7d  ___UDlA____Ma_b___________________
> ...
>
> # vi mce-file
> CPU 0 BANK 2
> STATUS UNCORRECTED SRAO 0x17a
> MCGSTATUS MCIP RIPV
> MISC 0x8c
> ADDR 0x344d77000
> EOF
>
> (4) Inject MCE
> # mce-inject mce-file
>
> Try step (3) to (4) a couple of times
>
>
>
>
> ******** Guest OS Screen logs(kdump) ********
> Receive MCE from KVM host
>
> (1) Set vm.memory_failure_dirty_panic parameter to 1.
>
> (2) When guest catches MCE injection from qemu and
>      MCE hit dirty page cache, hwpoison dirty cache handler
>      displays information of affected file such as Device name,
>      Inode Number, Offset and File Type.
>      And then, system goes a panic.
>
> ex.
> -------------
> [root@host /]# sysctl -a | grep memory_failure
> vm.memory_failure_dirty_panic = 1
> vm.memory_failure_early_kill = 0
> vm.memory_failure_recovery = 1
> [root@host /]#
> [  517.975220] MCE 0x326e6: clean LRU page recovery: Recovered
> [  521.969218] MCE 0x34df8: clean LRU page recovery: Recovered
> [  525.769171] MCE 0x37509: corrupted page was clean: dropped without side effects
> [  525.771070] MCE 0x37509: clean LRU page recovery: Recovered
> [  529.969246] MCE 0x39c18: File was corrupted: Dev:vda3 Inode:808998 Offset:6561
> [  529.969995] Kernel panic - not syncing: MCE 0x39c18: Force a panic because of dirty page cache was corrupted : File type:0x81a4
> [  529.969995]
> [  529.970055] Pid: 245, comm: kworker/0:2 Tainted: G   M         3.8.1 #22
> [  529.970055] Call Trace:
> [  529.970055]  [<ffffffff81645d1e>] panic+0xc1/0x1d0
> [  529.970055]  [<ffffffff811991fa>] me_pagecache_dirty+0xda/0x1a0
> [  529.970055]  [<ffffffff8119a0ab>] memory_failure+0x4eb/0xca0
> [  529.970055]  [<ffffffff8102f34d>] mce_process_work+0x3d/0x60
> [  529.970055]  [<ffffffff8107a5f7>] process_one_work+0x147/0x490
> [  529.970055]  [<ffffffff8102f310>] ? mce_schedule_work+0x50/0x50
> [  529.970055]  [<ffffffff8107ce8e>] worker_thread+0x15e/0x450
> [  529.970055]  [<ffffffff8107cd30>] ? busy_worker_rebind_fn+0x110/0x110
> [  529.970055]  [<ffffffff81081f50>] kthread+0xc0/0xd0
> [  529.970055]  [<ffffffff81010000>] ? ftrace_define_fields_xen_mc_entry+0xa0/0xf0
> [  529.970055]  [<ffffffff81081e90>] ? kthread_create_on_node+0x120/0x120
> [  529.970055]  [<ffffffff81657cec>] ret_from_fork+0x7c/0xb0
> [  529.970055]  [<ffffffff81081e90>] ? kthread_create_on_node+0x120/0x120
> -------------
>
> (3) Case of a number of MCE occurs
> If a number of MCE occurs during a minute, error messages are suppressed to output
> by __ratelimit() with following message.
>
> [  414.815303] me_pagecache_dirty: 3 callbacks suppressed
>
> ex.
> -------------
> [root@host /]# sysctl -a | grep memory_failure
> vm.memory_failure_dirty_panic = 0
> vm.memory_failure_early_kill = 0
> vm.memory_failure_print_ratelimit = 30
> vm.memory_failure_print_ratelimit_burst = 2
> vm.memory_failure_recovery = 1
>
> [root@host /]#
>
> [  181.565534] MCE 0xc38c: File was corrupted: Dev:vda3 Inode:808998 Offset:9566
> [  181.566310] MCE 0xc38c: dirty LRU page recovery: Recovered
> [  183.525425] MCE 0xc45a: Unknown page state
> [  183.527225] MCE 0xc45a: unknown page state page recovery: Failed
> [  183.527907] MCE 0xc45a: unknown page state page still referenced by -1 users
> [  185.000329] MCE 0xc524: dirty LRU page recovery: Recovered
> [  186.065231] MCE 0xc5ef: dirty LRU page recovery: Recovered
> [  188.054096] MCE 0xc6ba: clean LRU page recovery: Recovered
> [  189.565275] MCE 0xc783: clean LRU page recovery: Recovered
> [  191.692628] MCE 0xc84c: clean LRU page recovery: Recovered
> [  193.000257] MCE 0xc91d: File was corrupted: Dev:vda3 Inode:808998 Offset:6201
> [  193.001222] MCE 0xc91d: dirty LRU page recovery: Recovered
> [  194.065314] MCE 0xc9e6: dirty LRU page recovery: Recovered
> [  195.711211] MCE 0xcaaf: clean LRU page recovery: Recovered
> [  197.565339] MCE 0xcb78: dirty LRU page recovery: Recovered
> [  200.054177] MCE 0xcc41: dirty LRU page recovery: Recovered
> [  201.000272] MCE 0xcd0a: clean LRU page recovery: Recovered
> [  204.054109] MCE 0xcdd3: clean LRU page recovery: Recovered
> [  205.283189] MCE 0xcf65: clean LRU page recovery: Recovered
> [  207.110339] MCE 0xd02f: Unknown page state
> [  207.110787] MCE 0xd02f: unknown page state page recovery: Failed
> [  207.111427] MCE 0xd02f: unknown page state page still referenced by -1 users
> [  209.000134] MCE 0xd0f9: dirty LRU page recovery: Recovered
> [  210.106360] MCE 0xd1c5: dirty LRU page recovery: Recovered
> [  211.796333] me_pagecache_dirty: 3 callbacks suppressed
> [  211.796961] MCE 0xd296: File was corrupted: Dev:vda3 Inode:808998 Offset:9320
> [  211.798091] MCE 0xd296: dirty LRU page recovery: Recovered
> [  213.565288] MCE 0xd35f: clean LRU page recovery: Recovered
> -------------
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
