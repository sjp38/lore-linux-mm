Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2647BC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 13:53:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8B852064A
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 13:53:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8B852064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 727E76B0006; Wed, 14 Aug 2019 09:53:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B2366B0008; Wed, 14 Aug 2019 09:53:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A0676B000A; Wed, 14 Aug 2019 09:53:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0148.hostedemail.com [216.40.44.148])
	by kanga.kvack.org (Postfix) with ESMTP id 354A26B0006
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:53:55 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BAD5A8248AA4
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:53:54 +0000 (UTC)
X-FDA: 75821176788.06.money16_79589cd873310
X-HE-Tag: money16_79589cd873310
X-Filterd-Recvd-Size: 7028
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:53:53 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3902EAC45;
	Wed, 14 Aug 2019 13:53:52 +0000 (UTC)
Date: Wed, 14 Aug 2019 15:53:51 +0200
From: Michal Hocko <mhocko@suse.com>
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>,
	Oleg Nesterov <oleg@redhat.com>, Peter Xu <peterx@redhat.com>,
	Mike Rapoport <rppt@linux.ibm.com>, Jann Horn <jannh@google.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190814135351.GY17933@dhcp22.suse.cz>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 13-08-19 17:08:05, Kefeng Wang wrote:
> Hi Andrea Arcangeli and all,
> 
> There is a BUG after apply patch "04f5866e41fb coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping".

Just to make sure, does reverting that commit fixes the bug?

> The following is reproducer and panic log, could anyone check it?
> 
> Syzkaller reproducer:
> # {Threaded:true Collide:true Repeat:false RepeatTimes:0 Procs:1 Sandbox:none Fault:false FaultCall:-1 FaultNth:0 EnableTun:true EnableNetDev:true EnableNetReset:false EnableCgroups:false EnableBinfmtMisc:true EnableCloseFds:true UseTmpDir:true HandleSegv:true Repro:false Trace:false}
> r0 = userfaultfd(0x80800)
> ioctl$UFFDIO_API(r0, 0xc018aa3f, &(0x7f0000000200))
> ioctl$UFFDIO_REGISTER(r0, 0xc020aa00, &(0x7f0000000080)={{&(0x7f0000ff2000/0xe000)=nil, 0xe000}, 0x1})
> ioctl$UFFDIO_COPY(r0, 0xc028aa03, 0x0)
> ioctl$UFFDIO_COPY(r0, 0xc028aa03, &(0x7f0000000000)={&(0x7f0000ffc000/0x3000)=nil, &(0x7f0000ffd000/0x2000)=nil, 0x3000})
> syz_execute_func(&(0x7f00000000c0)="4134de984013e80f059532058300000071f3c4e18dd1ce5a65460f18320ce0b9977d8f64360f6e54e3a50fe53ff30fb837c42195dc42eddb8f087ca2a4d2c4017b708fa878c3e600f3266440d9a200000000c4016c5bdd7d0867dfe07f00f20f2b5f0009404cc442c102282cf2f20f51e22ef2e1291010f2262ef045814cb39700000000f32e3ef0fe05922f79a4000030470f3b58c1312fe7460f50ce0502338d00858526660f346253f6010f0f801d000000470f0f2c0a90c7c7df84feefff3636260fe02c98c8b8fcfc81fc51720a40400e700064660f71e70d2e0f57dfe819d0253f3ecaf06ad647608c41ffc42249bccb430f9bc8b7a042420f8d0042171e0f95ca9f7f921000d9fac4a27d5a1fc4a37961309de9000000003171460fc4d303c466410fd6389dc4426c456300c4233d4c922d92abf90ac6c34df30f5ee50909430f3a15e7776f6e866b0fdfdfc482797841cf6ffc842d9b9a516dc2e52ef2ac2636f20f114832d46231bffd4834eaeac4237d09d0003766420f160182c4a37d047882007f108f2808a6e68fc401505d6a82635d1467440fc7ba0c000000d4c482359652745300")
> poll(&(0x7f00000000c0)=[{}], 0x1, 0x0)

Is there any way to decypher the above?

> ./syz-execprog -executor=./syz-executor -repeat=0 -procs=16 -cover=0 repofile
> 
> 
> [   74.783362] invalid opcode: 0000 [#1] SMP PTI
> [   74.783740] ------------[ cut here ]------------
> [   74.784430] CPU: 5 PID: 12803 Comm: syz-executor.15 Not tainted 5.3.0-rc4 #15
> [   74.785831] kernel BUG at ../fs/userfaultfd.c:385!

This looks like
	BUG_ON(ctx->mm != mm)
where mm is vmf->vma->vm_mm while ctx->mm
git grep  "ctx->mm[[:space:]]=" v5.3-rc4
[...]
v5.3-rc4:fs/userfaultfd.c:              ctx->mm = vma->vm_mm;
v5.3-rc4:fs/userfaultfd.c:      ctx->mm = current->mm;

seem to always come from the local mm so it shouldn't really be out of
sync. VMAs and the process doesn't change the mm pointer during the life
time except for execing

> [   74.787906] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
> [   74.787916] RIP: 0010:handle_userfault+0x615/0x6b0
> [   74.793714] Code: c3 e9 ed fc ff ff 48 39 84 24 a0 00 00 00 0f 85 1a fe ff ff e9 69 fe ff ff e8 f7 28 d8 ff 0f 0b 0f 0b 0f 0b 90 e9 71 fa ff ff <0f> 0b bd 00 01 00 00 e9 29 fa ff ff a8 08 75 49 48 c7 c7 e0 1a e5
> [   74.793716] RSP: 0018:ffffc9000853b9a0 EFLAGS: 00010287
> [   74.793719] RAX: ffff88842b685708 RBX: ffffc9000853baa8 RCX: 00000000ebeaed2d
> [   74.793720] RDX: 0000000000000100 RSI: 0000000000000200 RDI: ffffc9000853baa8
> [   74.793721] RBP: ffff88841b29afe8 R08: ffff88841bdb8cb8 R09: 00000000fffffff0
> [   74.793723] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88841f6b2400
> [   74.793724] R13: ffff88841b6e6900 R14: ffff888107d0f000 R15: ffff88842b685708
> [   74.793726] FS:  00007f662e18f700(0000) GS:ffff88842fa80000(0000) knlGS:0000000000000000
> [   74.793728] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   74.793729] CR2: 0000000020ffd000 CR3: 000000041b3aa006 CR4: 00000000000206e0
> [   74.793734] Call Trace:
> [   74.793741]  ? __lock_acquire+0x44a/0x10d0
> [   74.793749]  ? find_held_lock+0x31/0xa0
> [   74.793755]  ? __handle_mm_fault+0xfc2/0x1140
> [   74.827705]  __handle_mm_fault+0xfcf/0x1140
> [   74.827714]  handle_mm_fault+0x18d/0x390
> [   74.830599]  ? handle_mm_fault+0x46/0x390
> [   74.830604]  __do_page_fault+0x250/0x4e0
> [   74.830609]  do_page_fault+0x31/0x210
> [   74.830635]  async_page_fault+0x43/0x50
> [   74.836532] RIP: 0010:copy_user_handle_tail+0x2/0x10
> [   74.836534] Code: c3 0f 1f 80 00 00 00 00 66 66 90 83 fa 40 0f 82 70 ff ff ff 89 d1 f3 a4 31 c0 66 66 90 c3 66 2e 0f 1f 84 00 00 00 00 00 89 d1 <f3> a4 89 c8 66 66 90 c3 66 0f 1f 44 00 00 66 66 90 83 fa 08 0f 82

But this looks strange decodecode gives me
Code: c3 0f 1f 80 00 00 00 00 66 66 90 83 fa 40 0f 82 70 ff ff ff 89 d1 f3 a4 31 c0 66 66 90 c3 66 2e 0f 1f 84 00 00 00 00 00 89 d1 <f3> a4 89 c8 66 66 90 c3 66 0f 1f 44 00 00 66 66 90 83 fa 08 0f 82
All code
========
   0:   c3                      retq
   1:   0f 1f 80 00 00 00 00    nopl   0x0(%rax)
   8:   66 66 90                data16 xchg %ax,%ax
   b:   83 fa 40                cmp    $0x40,%edx
   e:   0f 82 70 ff ff ff       jb     0xffffffffffffff84
  14:   89 d1                   mov    %edx,%ecx
  16:   f3 a4                   rep movsb %ds:(%rsi),%es:(%rdi)
  18:   31 c0                   xor    %eax,%eax
  1a:   66 66 90                data16 xchg %ax,%ax
  1d:   c3                      retq
  1e:   66 2e 0f 1f 84 00 00    nopw   %cs:0x0(%rax,%rax,1)
  25:   00 00 00
  28:   89 d1                   mov    %edx,%ecx
  2a:   f3 a4                   rep movsb %ds:(%rsi),%es:*(%rdi)                <-- trapping instruction

but that doesn't really match BUG_ON at all. Could you provide
disassembly for that function and your build. I would like to see what
do we have in registers and what ctx->mm vs. mm are.

-- 
Michal Hocko
SUSE Labs

