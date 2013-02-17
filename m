Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 73C6D6B00D3
	for <linux-mm@kvack.org>; Sun, 17 Feb 2013 10:56:36 -0500 (EST)
Message-ID: <5120FDA4.2060704@oracle.com>
Date: Sun, 17 Feb 2013 10:56:20 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: slab: odd BUG on kzalloc
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, mpm@selenic.com
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

Hi all,

I was fuzzing with trinity inside a KVM tools guest, running latest -next kernel,
and hit the following bug:

[  169.773688] BUG: unable to handle kernel NULL pointer dereference at 0000000000000001
[  169.774976] IP: [<ffffffff81a15c2f>] memset+0x1f/0xb0
[  169.775989] PGD 93e02067 PUD ac1a2067 PMD 0
[  169.776898] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[  169.777923] Dumping ftrace buffer:
[  169.778595]    (ftrace buffer empty)
[  169.779352] Modules linked in:
[  169.779996] CPU 0
[  169.780031] Pid: 13438, comm: trinity Tainted: G        W    3.8.0-rc7-next-20130215-sasha-00003-gea816fa #286
[  169.780031] RIP: 0010:[<ffffffff81a15c2f>]  [<ffffffff81a15c2f>] memset+0x1f/0xb0
[  169.780031] RSP: 0018:ffff8800aef19e00  EFLAGS: 00010206
[  169.780031] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000080
[  169.780031] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
[  169.780031] RBP: ffff8800aef19e68 R08: 0000000000000000 R09: 0000000000000001
[  169.780031] R10: 0000000000000001 R11: 0000000000000000 R12: ffff8800bb001b00
[  169.780031] R13: ffff8800bb001b00 R14: 0000000000000001 R15: 0000000000537000
[  169.780031] FS:  00007fb73581b700(0000) GS:ffff8800bb600000(0000) knlGS:0000000000000000
[  169.780031] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  169.780031] CR2: 0000000000000001 CR3: 00000000aed31000 CR4: 00000000000406f0
[  169.780031] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  169.780031] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  169.780031] Process trinity (pid: 13438, threadinfo ffff8800aef18000, task ffff8800aed7b000)
[  169.780031] Stack:
[  169.780031]  ffffffff81269586 ffff8800aef19e38 0000000000000280 ffffffff81291a2e
[  169.780031]  000080d0aa39d9e8 ffff8800aef19e48 0000000000000000 ffff8800aa39d9e8
[  169.780031]  ffff8800a65cc780 ffff8800aa39d960 00000000ffffffea 0000000000000000
[  169.780031] Call Trace:
[  169.780031]  [<ffffffff81269586>] ? kmem_cache_alloc_trace+0x176/0x330
[  169.780031]  [<ffffffff81291a2e>] ? alloc_pipe_info+0x3e/0xa0
[  169.780031]  [<ffffffff81291a2e>] alloc_pipe_info+0x3e/0xa0
[  169.780031]  [<ffffffff81291ac6>] get_pipe_inode+0x36/0xe0
[  169.780031]  [<ffffffff81291d63>] create_pipe_files+0x23/0x140
[  169.780031]  [<ffffffff81291ebd>] __do_pipe_flags+0x3d/0xe0
[  169.780031]  [<ffffffff81291fbb>] sys_pipe2+0x1b/0xa0
[  169.780031]  [<ffffffff83d96135>] ? tracesys+0x7e/0xe6
[  169.780031]  [<ffffffff8129204b>] sys_pipe+0xb/0x10
[  169.780031]  [<ffffffff83d96198>] tracesys+0xe1/0xe6
[  169.780031] Code: 1e 44 88 1f c3 90 90 90 90 90 90 90 49 89 f9 48 89 d1 83 e2 07 48 c1 e9 03 40 0f b6 f6 48 b8 01 01 01 01 01
01 01 01 48 0f af c6 <f3> 48 ab 89 d1 f3 aa 4c 89 c8 c3 66 66 66 90 66 66 66 90 66 66
[  169.780031] RIP  [<ffffffff81a15c2f>] memset+0x1f/0xb0
[  169.780031]  RSP <ffff8800aef19e00>
[  169.780031] CR2: 0000000000000001
[  169.930103] ---[ end trace 4d135f3def21b4bd ]---

The code translates to the following in fs/pipe.c:alloc_pipe_info :

        pipe = kzalloc(sizeof(struct pipe_inode_info), GFP_KERNEL);
        if (pipe) {
                pipe->bufs = kzalloc(sizeof(struct pipe_buffer) * PIPE_DEF_BUFFERS, GFP_KERNEL); <=== this
                if (pipe->bufs) {
                        init_waitqueue_head(&pipe->wait);


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
