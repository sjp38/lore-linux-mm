Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FB87C433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 02:21:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0A6E2084F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 02:21:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0A6E2084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45C266B0003; Wed, 14 Aug 2019 22:21:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40CF86B0005; Wed, 14 Aug 2019 22:21:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 323DA6B0007; Wed, 14 Aug 2019 22:21:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0216.hostedemail.com [216.40.44.216])
	by kanga.kvack.org (Postfix) with ESMTP id 1114A6B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 22:21:13 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9F2B92C37
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 02:21:12 +0000 (UTC)
X-FDA: 75823059984.07.toe75_61a4d3efdbe0d
X-HE-Tag: toe75_61a4d3efdbe0d
X-Filterd-Recvd-Size: 10663
Received: from huawei.com (szxga07-in.huawei.com [45.249.212.35])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 02:21:10 +0000 (UTC)
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id AA752BB553C72A46A4AE;
	Thu, 15 Aug 2019 10:21:04 +0800 (CST)
Received: from [127.0.0.1] (10.133.217.137) by DGGEMS406-HUB.china.huawei.com
 (10.3.19.206) with Microsoft SMTP Server id 14.3.439.0; Thu, 15 Aug 2019
 10:21:02 +0800
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
To: Oleg Nesterov <oleg@redhat.com>
CC: Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>, "Andrea
 Arcangeli" <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, Mike Rapoport
	<rppt@linux.ibm.com>, Jann Horn <jannh@google.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190814135351.GY17933@dhcp22.suse.cz>
 <7e0e4254-17f4-5f07-e9af-097c4162041a@huawei.com>
 <20190814151049.GD11595@redhat.com> <20190814154101.GF11595@redhat.com>
From: Kefeng Wang <wangkefeng.wang@huawei.com>
Message-ID: <0cfded81-6668-905f-f2be-490bf7c750fb@huawei.com>
Date: Thu, 15 Aug 2019 10:21:01 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190814154101.GF11595@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.133.217.137]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/8/14 23:41, Oleg Nesterov wrote:
> On 08/14, Oleg Nesterov wrote:
>> I am wondering if "goto skip_mm" in userfaultfd_release() is correct...
>> shouldn't it clear VM_UFFD_* and reset vm_userfaultfd_ctx.ctx even if
>> !mmget_still_valid ?
> 
> Heh, I didn't notice you too mentioned userfaultfd_release() in your email.
> can you try the patch below?

Your patch below fixes the issue, could you send a formal patch ASAP and also it
should be queued into stable, I have test lts4.4, it works too, thanks.

I built kernel with wrong gcc version, and the KASAN is not enabled, When KASAN enabled,
there is an UAF,

[   67.393442] ==================================================================
[   67.395531] BUG: KASAN: use-after-free in handle_userfault+0x12f/0xc70
[   67.397001] Read of size 8 at addr ffff8883c622c160 by task syz-executor.9/5225
[   67.398672]
[   67.399035] CPU: 2 PID: 5225 Comm: syz-executor.9 Not tainted 5.3.0-rc4 #3
[   67.400601] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1ubuntu1 04/01/2014
[   67.402818] Call Trace:
[   67.403393]  dump_stack+0x9a/0xeb
[   67.404245]  ? handle_userfault+0x12f/0xc70
[   67.405268]  print_address_description+0x79/0x440
[   67.406411]  ? handle_userfault+0x12f/0xc70
[   67.407454]  __kasan_report+0x15c/0x1df
[   67.408418]  ? rwlock_bug.part.0+0x60/0x60
[   67.409470]  ? handle_userfault+0x12f/0xc70
[   67.410491]  kasan_report+0xe/0x20
[   67.411477]  handle_userfault+0x12f/0xc70
[   67.412610]  ? __lock_acquire+0x66c/0x2420
[   67.413728]  ? userfaultfd_ioctl+0x1c30/0x1c30
[   67.414910]  ? match_held_lock+0x1b/0x250
[   67.415993]  ? check_chain_key+0x1d7/0x2d0
[   67.417127]  ? lock_downgrade+0x3a0/0x3a0
[   67.418198]  ? do_raw_spin_lock+0x10a/0x1d0
[   67.419319]  ? rwlock_bug.part.0+0x60/0x60
[   67.420442]  __handle_mm_fault+0x17e0/0x1ac0
[   67.421618]  ? check_chain_key+0x1d7/0x2d0
[   67.422733]  ? __pmd_alloc+0x260/0x260
[   67.423824]  ? mark_held_locks+0x46/0xa0
[   67.424867]  ? handle_mm_fault+0x142/0x540
[   67.425958]  handle_mm_fault+0x20c/0x540
[   67.427044]  __do_page_fault+0x3b4/0x6a0
[   67.428144]  do_page_fault+0x32/0x310
[   67.429190]  async_page_fault+0x43/0x50
[   67.430243] RIP: 0010:copy_user_handle_tail+0x2/0x10
[   67.431586] Code: c3 0f 1f 80 00 00 00 00 66 66 90 83 fa 40 0f 82 70 ff ff ff 89 d1 f3 a4 31 c0 66 66 90 c3 66 2e 0f 1f 84 00 00 00 00 00 89 d1 <f3> a4 89 c8 66 66 90 c3 66 0f 1f 44 00 00 66 66 90 83 fa 08 0f 82
[   67.436978] RSP: 0018:ffff8883c4e8f908 EFLAGS: 00010246
[   67.438743] RAX: 0000000000000001 RBX: 0000000020ffd000 RCX: 0000000000001000
[   67.441101] RDX: 0000000000001000 RSI: 0000000020ffd000 RDI: ffff8883c0aa4000
[   67.442865] RBP: 0000000000001000 R08: ffffed1078154a00 R09: 0000000000000000
[   67.444534] R10: 0000000000000200 R11: ffffed10781549ff R12: ffff8883c0aa4000
[   67.446216] R13: ffff8883c6096000 R14: ffff88837721f838 R15: ffff8883c6096000
[   67.448388]  _copy_from_user+0xa1/0xd0
[   67.449655]  mcopy_atomic+0xb3d/0x1380
[   67.450991]  ? lock_downgrade+0x3a0/0x3a0
[   67.452337]  ? mm_alloc_pmd+0x130/0x130
[   67.453618]  ? __might_fault+0x7d/0xe0
[   67.454980]  userfaultfd_ioctl+0x14a2/0x1c30
[   67.456430]  ? drop_futex_key_refs+0x25/0x70
[   67.457873]  ? __x64_sys_userfaultfd+0x200/0x200
[   67.459420]  ? futex_wait_setup+0x200/0x200
[   67.460823]  ? migrate_swap_stop+0x4e0/0x4e0
[   67.462257]  ? plist_del+0xd8/0x190
[   67.463494]  ? wake_up_q+0x59/0xa0
[   67.464678]  ? check_chain_key+0x1d7/0x2d0
[   67.466088]  ? __lock_acquire+0x66c/0x2420
[   67.467496]  ? match_held_lock+0x1b/0x250
[   67.468937]  ? do_vfs_ioctl+0x131/0x9d0
[   67.470224]  do_vfs_ioctl+0x131/0x9d0
[   67.471473]  ? match_held_lock+0x1b/0x250
[   67.472821]  ? ioctl_preallocate+0x170/0x170
[   67.474251]  ? debug_lockdep_rcu_enabled.part.4+0x16/0x30
[   67.476046]  ? selinux_file_ioctl+0x1f9/0x390
[   67.477500]  ? selinux_vm_enough_memory+0x70/0x70
[   67.479080]  ? m_next+0x33/0x70
[   67.480184]  ? do_dup2+0x2c0/0x2c0
[   67.481475]  ksys_ioctl+0x70/0x80
[   67.482607]  ? mark_held_locks+0x1c/0xa0
[   67.483938]  __x64_sys_ioctl+0x3d/0x50
[   67.485203]  do_syscall_64+0x72/0x330
[   67.486463]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   67.488158] RIP: 0033:0x458c59
[   67.489166] Code: ad b8 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 0f 83 7b b8 fb ff c3 66 2e 0f 1f 84 00 00 00 00
[   67.495146] RSP: 002b:00007f33a38d6c78 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
[   67.497608] RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000458c59
[   67.499931] RDX: 0000000020000000 RSI: 00000000c028aa03 RDI: 0000000000000003
[   67.502262] RBP: 000000000073c040 R08: 0000000000000000 R09: 0000000000000000
[   67.504608] R10: 0000000000000000 R11: 0000000000000246 R12: 00007f33a38d76d4
[   67.506939] R13: 00000000004c34cf R14: 00000000004d6958 R15: 00000000ffffffff
[   67.509359]
[   67.509906] Allocated by task 5145:
[   67.511091]  save_stack+0x19/0x80
[   67.512209]  __kasan_kmalloc.constprop.8+0xa0/0xd0
[   67.513805]  kmem_cache_alloc+0xae/0x290
[   67.515158]  __x64_sys_userfaultfd+0x70/0x200
[   67.516617]  do_syscall_64+0x72/0x330
[   67.517843]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   67.519509]
[   67.520052] Freed by task 5145:
[   67.521112]  save_stack+0x19/0x80
[   67.522224]  __kasan_slab_free+0x12e/0x180
[   67.523600]  slab_free_freelist_hook+0x5d/0x160
[   67.525090]  kmem_cache_free+0xa5/0x3b0
[   67.526366]  userfaultfd_release+0x353/0x3e0
[   67.527805]  __fput+0x15f/0x390
[   67.528866]  task_work_run+0xc7/0x100
[   67.530095]  get_signal+0xfd3/0x12e0
[   67.531305]  do_signal+0x93/0xa70
[   67.532417]  exit_to_usermode_loop+0x9d/0x130
[   67.533885]  do_syscall_64+0x2be/0x330
[   67.535139]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[   67.536788]
[   67.537332] The buggy address belongs to the object at ffff8883c622c000
[   67.537332]  which belongs to the cache userfaultfd_ctx_cache of size 360
[   67.541634] The buggy address is located 352 bytes inside of
[   67.541634]  360-byte region [ffff8883c622c000, ffff8883c622c168)
[   67.545400] The buggy address belongs to the page:
[   67.546996] page:ffffea000f188b00 refcount:1 mapcount:0 mapping:ffff8883c73a5900 index:0x0 compound_mapcount: 0
[   67.550241] flags: 0x2fffff80010200(slab|head)
[   67.551730] raw: 002fffff80010200 dead000000000100 dead000000000122 ffff8883c73a5900
[   67.554230] raw: 0000000000000000 0000000080240024 00000001ffffffff 0000000000000000
[   67.556743] page dumped because: kasan: bad access detected
[   67.558575]
[   67.559105] Memory state around the buggy address:
[   67.560722]  ffff8883c622c000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[   67.563063]  ffff8883c622c080: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[   67.565406] >ffff8883c622c100: fb fb fb fb fb fb fb fb fb fb fb fb fb fc fc fc
[   67.567760]                                                        ^
[   67.569795]  ffff8883c622c180: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
[   67.572016]  ffff8883c622c200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[   67.574231] ==================================================================

> 
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -880,6 +880,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
>  	/* len == 0 means wake all */
>  	struct userfaultfd_wake_range range = { .len = 0, };
>  	unsigned long new_flags;
> +	bool xxx;
>  
>  	WRITE_ONCE(ctx->released, true);
>  
> @@ -895,8 +896,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
>  	 * taking the mmap_sem for writing.
>  	 */
>  	down_write(&mm->mmap_sem);
> -	if (!mmget_still_valid(mm))
> -		goto skip_mm;
> +	xxx = mmget_still_valid(mm);
>  	prev = NULL;
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  		cond_resched();
> @@ -907,19 +907,20 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
>  			continue;
>  		}
>  		new_flags = vma->vm_flags & ~(VM_UFFD_MISSING | VM_UFFD_WP);
> -		prev = vma_merge(mm, prev, vma->vm_start, vma->vm_end,
> -				 new_flags, vma->anon_vma,
> -				 vma->vm_file, vma->vm_pgoff,
> -				 vma_policy(vma),
> -				 NULL_VM_UFFD_CTX);
> -		if (prev)
> -			vma = prev;
> -		else
> -			prev = vma;
> +		if (xxx) {
> +			prev = vma_merge(mm, prev, vma->vm_start, vma->vm_end,
> +					 new_flags, vma->anon_vma,
> +					 vma->vm_file, vma->vm_pgoff,
> +					 vma_policy(vma),
> +					 NULL_VM_UFFD_CTX);
> +			if (prev)
> +				vma = prev;
> +			else
> +				prev = vma;
> +		}
>  		vma->vm_flags = new_flags;
>  		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
>  	}
> -skip_mm:
>  	up_write(&mm->mmap_sem);
>  	mmput(mm);
>  wakeup:
> 
> 
> .
> 


