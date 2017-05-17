Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EE036B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 17:34:11 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id m28so348239uab.9
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:34:11 -0700 (PDT)
Received: from mail-ua0-x241.google.com (mail-ua0-x241.google.com. [2607:f8b0:400c:c08::241])
        by mx.google.com with ESMTPS id b24si59879uac.207.2017.05.17.14.34.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 14:34:10 -0700 (PDT)
Received: by mail-ua0-x241.google.com with SMTP id j17so100296uag.1
        for <linux-mm@kvack.org>; Wed, 17 May 2017 14:34:10 -0700 (PDT)
Date: Wed, 17 May 2017 17:34:07 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 07/17] cgroup: Prevent kill_css() from being
 called more than once
Message-ID: <20170517213407.GD942@htj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-8-git-send-email-longman@redhat.com>
 <20170517192357.GC942@htj.duckdns.org>
 <c541638f-b302-8c96-0dcd-f4b758a4a81f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c541638f-b302-8c96-0dcd-f4b758a4a81f@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On Wed, May 17, 2017 at 04:24:32PM -0400, Waiman Long wrote:
> On 05/17/2017 03:23 PM, Tejun Heo wrote:
> > Hello,
> >
> > On Mon, May 15, 2017 at 09:34:06AM -0400, Waiman Long wrote:
> >> The kill_css() function may be called more than once under the condition
> >> that the css was killed but not physically removed yet followed by the
> >> removal of the cgroup that is hosting the css. This patch prevents any
> >> harmm from being done when that happens.
> >>
> >> Signed-off-by: Waiman Long <longman@redhat.com>
> > So, this is a bug fix which isn't really related to this patchset.
> > I'm applying it to cgroup/for-4.12-fixes w/ stable cc'd.
> >
> > Thanks.
> >
> Actually, this bug can be easily triggered with the resource domain
> patch later in the series. I guess it can also happen in the current
> code base, but I don't have a test that can reproduce it.

I can reproduce it easily.

[test /sys/fs/cgroup/asdf]# while true; do mkdir asdf; echo +memory > cgroup.subtree_control; echo -memory
[   66.159258] percpu_ref_kill_and_confirm called more than once on css_release!
[   66.159293] ------------[ cut here ]------------
[   66.160966] WARNING: CPU: 1 PID: 1802 at lib/percpu-refcount.c:334 percpu_ref_kill_and_confirm+0x190/0x1a0
[   66.162406] Modules linked in:
[   66.162686] CPU: 1 PID: 1802 Comm: rmdir Not tainted 4.12.0-rc1-work+ #42
[   66.163279] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1.fc26 04/01/2014
[   66.164043] task: ffff880018240040 task.stack: ffffc90000478000
[   66.164571] RIP: 0010:percpu_ref_kill_and_confirm+0x190/0x1a0
[   66.165106] RSP: 0018:ffffc9000047bde8 EFLAGS: 00010092
[   66.165664] RAX: 0000000000000041 RBX: ffff88001a0fc148 RCX: 0000000000000002
[   66.166443] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff810acc2e
[   66.167083] RBP: ffffc9000047be00 R08: 0000000000000000 R09: 0000000000000001
[   66.167696] R10: ffffc9000047bd50 R11: 0000000000000000 R12: 0000000000000286
[   66.168293] R13: ffffffff810e7c50 R14: ffff88001a106bb8 R15: 0000000000000000
[   66.168897] FS:  00007fba87594700(0000) GS:ffff88001fc80000(0000) knlGS:0000000000000000
[   66.169613] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   66.170204] CR2: 000056167ee4e008 CR3: 000000001820e000 CR4: 00000000000006a0
[   66.170861] Call Trace:
[   66.171075]  kill_css+0x3e/0x170
[   66.171352]  cgroup_destroy_locked+0xac/0x170
[   66.171732]  cgroup_rmdir+0x2c/0x150
[   66.172037]  kernfs_iop_rmdir+0x48/0x70
[   66.172377]  vfs_rmdir+0x73/0x150
[   66.172679]  do_rmdir+0x16d/0x1c0
[   66.172962]  SyS_rmdir+0x16/0x20
[   66.173244]  entry_SYSCALL_64_fastpath+0x18/0xad
[   66.173682] RIP: 0033:0x7fba870c1487
[   66.173985] RSP: 002b:00007ffec57e43a8 EFLAGS: 00000246 ORIG_RAX: 0000000000000054
[   66.174719] RAX: ffffffffffffffda RBX: 00007fba87388b38 RCX: 00007fba870c1487
[   66.175439] RDX: 00007fba8738ae80 RSI: 0000000000000000 RDI: 00007ffec57e5751
[   66.176281] RBP: 00007fba87388ae0 R08: 0000000000000000 R09: 0000000000000000
[   66.177046] R10: 000056167ee4e010 R11: 0000000000000246 R12: 00007fba87388b38
[   66.177821] R13: 0000000000000030 R14: 00007fba87388b58 R15: 0000000000002710
[   66.178574] Code: 80 3d f5 d3 89 00 00 0f 85 b8 fe ff ff 48 8b 53 10 48 c7 c6 e0 c0 83 81 48 c7 c7 68 e0 9c 81 c6 05 d6 d3 89 00 01 e8 09 0a d4 ff <0f> ff 48 8b 43 08 e9 8f fe ff ff 0f 1f 44 00 00 55 ba ff ffff
[   66.181059] ---[ end trace 50ce5cd95cda7a2c ]---

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
