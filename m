Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D12B7C3A59E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 14:20:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 786962173E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 14:20:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="azxjC7MS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 786962173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C5BE6B0007; Mon,  2 Sep 2019 10:20:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 076D16B0008; Mon,  2 Sep 2019 10:20:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA76C6B000A; Mon,  2 Sep 2019 10:20:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0179.hostedemail.com [216.40.44.179])
	by kanga.kvack.org (Postfix) with ESMTP id C86266B0007
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 10:20:26 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 686CD83E6
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 14:20:26 +0000 (UTC)
X-FDA: 75890190852.25.suit03_3bc193f52e3a
X-HE-Tag: suit03_3bc193f52e3a
X-Filterd-Recvd-Size: 12574
Received: from mail-ed1-f68.google.com (mail-ed1-f68.google.com [209.85.208.68])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 14:20:25 +0000 (UTC)
Received: by mail-ed1-f68.google.com with SMTP id u6so9919701edq.6
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 07:20:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=J4G4ckCuRM2JKsOdJYkUqLIGM/a0Pye1senYti+3rmM=;
        b=azxjC7MSM9g5eQtwphjqJS0/aqc+TmyF+rIhRwDVWUYs4MRqv6voou5wY0ThL2Urw0
         IfRuDkBF/h9xHDovl6B+AykjTNSLQNACswl6WbBN6iZ73d0zZoPx7tcBW3U+VUvbHT39
         BbyIdqCYVIM0zxBb33ISGN5GJmvYt8i9AOz8Wf0wy/9m4Ni6vr13aSXGxne6vEUFQU86
         h9daSLAQJkKIByyiZmpuXMSGB9PH2cE/jmgZsqQ2GKdsqvmzQcniWpzT1R+kx74spuVH
         GIgZSzHZrLrrFzEkWkS3vNVU8L7hGSWKZ2gOC06ifTHIx78UK5vEs8On7rDCofg3yUhR
         uDPA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=J4G4ckCuRM2JKsOdJYkUqLIGM/a0Pye1senYti+3rmM=;
        b=HWjdhYnlY/m0dfY4Hz59YS4T9bSPlz9LXvPRriOfdbcEs3AP0Q9YAMAwYpFEoaAheo
         auroZpCkfzjxrHK1SmEieke7hr8Z4ipkbL8rROzOaNkUnaDQpsfz/Sq7rDui1NV1xBvr
         VXSOAF1/wwfAH3GARhqji67eeAw1FPnRG8dGWKhculBza+/ys2lsX4Fm62mlQMV5jNzM
         WEjTN+xkxjb5EiKKvrsFvM+11G9STOtAcemyKZW8GxAYRBewn4viUJp6rjdWROptNGaa
         G+r5SbHaQCxCbOiT3MyBIDJyaj7ErPSyWp5udQuJfp9SCh+kHGDeESyS+RiVaNWgjJ8W
         wQhA==
X-Gm-Message-State: APjAAAXrYKh4Qg4OthNtZDdGNV7j8ClYJzMuo9pmk+csK4A7WP24vv7x
	3hx7wI7eFJoQNsLju0x6UK6c+w==
X-Google-Smtp-Source: APXvYqzjFCn3DvwnwWHzRkyRvK134e7M0HGO0TkO/14kg0V9hFBu+BKbddGa4I1rZnkWw/qfWDSCzQ==
X-Received: by 2002:a17:906:79d8:: with SMTP id m24mr24431393ejo.289.1567434024194;
        Mon, 02 Sep 2019 07:20:24 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id ox27sm1591207ejb.91.2019.09.02.07.20.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Sep 2019 07:20:23 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 0B4861023DD; Mon,  2 Sep 2019 17:20:30 +0300 (+03)
Date: Mon, 2 Sep 2019 17:20:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hillf Danton <hdanton@sina.com>,
	syzbot <syzbot+03ee87124ee05af991bd@syzkaller.appspotmail.com>,
	hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	syzkaller-bugs@googlegroups.com
Subject: Re: KASAN: use-after-free Read in shmem_fault (2)
Message-ID: <20190902142029.fyq3dwn72pqqlzul@box>
References: <20190831045826.748-1-hdanton@sina.com>
 <20190902135254.GC2431@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190902135254.GC2431@bombadil.infradead.org>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 06:52:54AM -0700, Matthew Wilcox wrote:
> On Sat, Aug 31, 2019 at 12:58:26PM +0800, Hillf Danton wrote:
> > On Fri, 30 Aug 2019 12:40:06 -0700
> > > syzbot found the following crash on:
> > > 
> > > HEAD commit:    a55aa89a Linux 5.3-rc6
> > > git tree:       upstream
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=12f4beb6600000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=2a6a2b9826fdadf9
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=03ee87124ee05af991bd
> > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > 
> > > Unfortunately, I don't have any reproducer for this crash yet.
> > > 
> > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > Reported-by: syzbot+03ee87124ee05af991bd@syzkaller.appspotmail.com
> > > 
> > > ==================================================================
> > > BUG: KASAN: use-after-free in perf_trace_lock_acquire+0x401/0x530  
> > > include/trace/events/lock.h:13
> > > Read of size 8 at addr ffff8880a5cf2c50 by task syz-executor.0/26173
> > > 
> > > CPU: 0 PID: 26173 Comm: syz-executor.0 Not tainted 5.3.0-rc6 #146
> > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> > > Google 01/01/2011
> > > Call Trace:
> > >   __dump_stack lib/dump_stack.c:77 [inline]
> > >   dump_stack+0x172/0x1f0 lib/dump_stack.c:113
> > >   print_address_description.cold+0xd4/0x306 mm/kasan/report.c:351
> > >   __kasan_report.cold+0x1b/0x36 mm/kasan/report.c:482
> > >   kasan_report+0x12/0x17 mm/kasan/common.c:618
> > >   __asan_report_load8_noabort+0x14/0x20 mm/kasan/generic_report.c:132
> > >   perf_trace_lock_acquire+0x401/0x530 include/trace/events/lock.h:13
> > >   trace_lock_acquire include/trace/events/lock.h:13 [inline]
> > >   lock_acquire+0x2de/0x410 kernel/locking/lockdep.c:4411
> > >   __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
> > >   _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:151
> > >   spin_lock include/linux/spinlock.h:338 [inline]
> > >   shmem_fault+0x5ec/0x7b0 mm/shmem.c:2034
> > >   __do_fault+0x111/0x540 mm/memory.c:3083
> > >   do_shared_fault mm/memory.c:3535 [inline]
> > >   do_fault mm/memory.c:3613 [inline]
> > >   handle_pte_fault mm/memory.c:3840 [inline]
> > >   __handle_mm_fault+0x2adf/0x3f20 mm/memory.c:3964
> > >   handle_mm_fault+0x1b5/0x6b0 mm/memory.c:4001
> > >   do_user_addr_fault arch/x86/mm/fault.c:1441 [inline]
> > >   __do_page_fault+0x536/0xdd0 arch/x86/mm/fault.c:1506
> > >   do_page_fault+0x38/0x590 arch/x86/mm/fault.c:1530
> > >   page_fault+0x39/0x40 arch/x86/entry/entry_64.S:1202
> > > RIP: 0010:copy_user_generic_unrolled+0x89/0xc0  
> > > arch/x86/lib/copy_user_64.S:91
> > > Code: 38 4c 89 47 20 4c 89 4f 28 4c 89 57 30 4c 89 5f 38 48 8d 76 40 48 8d  
> > > 7f 40 ff c9 75 b6 89 d1 83 e2 07 c1 e9 03 74 12 4c 8b 06 <4c> 89 07 48 8d  
> > > 76 08 48 8d 7f 08 ff c9 75 ee 21 d2 74 10 89 d1 8a
> > > RSP: 0018:ffff88806b927e18 EFLAGS: 00010202
> > > RAX: 0000000000000001 RBX: 0000000000000008 RCX: 0000000000000001
> > > RDX: 0000000000000000 RSI: ffff88806b927e80 RDI: 0000000020000000
> > > RBP: ffff88806b927e50 R08: 0000000500000004 R09: ffffed100d724fd1
> > > R10: ffffed100d724fd0 R11: ffff88806b927e87 R12: 0000000020000000
> > > R13: ffff88806b927e80 R14: 0000000020000008 R15: 00007ffffffff000
> > >   copy_to_user include/linux/uaccess.h:152 [inline]
> > >   do_pipe2+0xec/0x160 fs/pipe.c:857
> > >   __do_sys_pipe fs/pipe.c:878 [inline]
> > >   __se_sys_pipe fs/pipe.c:876 [inline]
> > >   __x64_sys_pipe+0x33/0x40 fs/pipe.c:876
> > >   do_syscall_64+0xfd/0x6a0 arch/x86/entry/common.c:296
> > >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > RIP: 0033:0x459879
> > > Code: fd b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
> > > 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
> > > ff 0f 83 cb b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> > > RSP: 002b:00007f833e81fc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000016
> > > RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 0000000000459879
> > > RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000020000000
> > > RBP: 000000000075c118 R08: 0000000000000000 R09: 0000000000000000
> > > R10: 0000000000000000 R11: 0000000000000246 R12: 00007f833e8206d4
> > > R13: 00000000004f5b47 R14: 00000000004db7b8 R15: 00000000ffffffff
> > > 
> > > Allocated by task 25774:
> > >   save_stack+0x23/0x90 mm/kasan/common.c:69
> > >   set_track mm/kasan/common.c:77 [inline]
> > >   __kasan_kmalloc mm/kasan/common.c:493 [inline]
> > >   __kasan_kmalloc.constprop.0+0xcf/0xe0 mm/kasan/common.c:466
> > >   kasan_slab_alloc+0xf/0x20 mm/kasan/common.c:501
> > >   slab_post_alloc_hook mm/slab.h:520 [inline]
> > >   slab_alloc mm/slab.c:3319 [inline]
> > >   kmem_cache_alloc+0x121/0x710 mm/slab.c:3483
> > >   shmem_alloc_inode+0x1c/0x50 mm/shmem.c:3630
> > >   alloc_inode+0x68/0x1e0 fs/inode.c:227
> > >   new_inode_pseudo+0x19/0xf0 fs/inode.c:916
> > >   new_inode+0x1f/0x40 fs/inode.c:945
> > >   shmem_get_inode+0x84/0x7e0 mm/shmem.c:2228
> > >   __shmem_file_setup.part.0+0x1e2/0x2b0 mm/shmem.c:3985
> > >   __shmem_file_setup mm/shmem.c:3979 [inline]
> > >   shmem_kernel_file_setup mm/shmem.c:4015 [inline]
> > >   shmem_zero_setup+0xe1/0x4cc mm/shmem.c:4059
> > >   mmap_region+0x13d5/0x1760 mm/mmap.c:1804
> > >   do_mmap+0x82e/0x1090 mm/mmap.c:1561
> > >   do_mmap_pgoff include/linux/mm.h:2374 [inline]
> > >   vm_mmap_pgoff+0x1c5/0x230 mm/util.c:391
> > >   ksys_mmap_pgoff+0xf7/0x630 mm/mmap.c:1611
> > >   __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
> > >   __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
> > >   __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
> > >   do_syscall_64+0xfd/0x6a0 arch/x86/entry/common.c:296
> > >   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > 
> > > Freed by task 26359:
> > >   save_stack+0x23/0x90 mm/kasan/common.c:69
> > >   set_track mm/kasan/common.c:77 [inline]
> > >   __kasan_slab_free+0x102/0x150 mm/kasan/common.c:455
> > >   kasan_slab_free+0xe/0x10 mm/kasan/common.c:463
> > >   __cache_free mm/slab.c:3425 [inline]
> > >   kmem_cache_free+0x86/0x320 mm/slab.c:3693
> > >   shmem_free_in_core_inode+0x63/0xb0 mm/shmem.c:3640
> > >   i_callback+0x44/0x80 fs/inode.c:216
> > >   __rcu_reclaim kernel/rcu/rcu.h:222 [inline]
> > >   rcu_do_batch kernel/rcu/tree.c:2114 [inline]
> > >   rcu_core+0x67f/0x1580 kernel/rcu/tree.c:2314
> > >   rcu_core_si+0x9/0x10 kernel/rcu/tree.c:2323
> > >   __do_softirq+0x262/0x98c kernel/softirq.c:292
> > > 
> > > The buggy address belongs to the object at ffff8880a5cf2a90
> > >   which belongs to the cache shmem_inode_cache(17:syz0) of size 1192
> > > The buggy address is located 448 bytes inside of
> > >   1192-byte region [ffff8880a5cf2a90, ffff8880a5cf2f38)
> > > The buggy address belongs to the page:
> > > page:ffffea0002973c80 refcount:1 mapcount:0 mapping:ffff88808e1418c0  
> > > index:0xffff8880a5cf2ffd
> > > flags: 0x1fffc0000000200(slab)
> > > raw: 01fffc0000000200 ffffea0002592ec8 ffffea0002492588 ffff88808e1418c0
> > > raw: ffff8880a5cf2ffd ffff8880a5cf2040 0000000100000003 0000000000000000
> > > page dumped because: kasan: bad access detected
> > > 
> > > Memory state around the buggy address:
> > >   ffff8880a5cf2b00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> > >   ffff8880a5cf2b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> > > > ffff8880a5cf2c00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> > >                                                   ^
> > >   ffff8880a5cf2c80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> > >   ffff8880a5cf2d00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> > > ==================================================================
> > 
> > 
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -2021,6 +2021,12 @@ static vm_fault_t shmem_fault(struct vm_
> >  			shmem_falloc_waitq = shmem_falloc->waitq;
> >  			prepare_to_wait(shmem_falloc_waitq, &shmem_fault_wait,
> >  					TASK_UNINTERRUPTIBLE);
> > +			/*
> > +			 * it is not trivial to see what will take place after
> > +			 * releasing i_lock and taking a nap, so hold inode to
> > +			 * be on the safe side.
> 
> I think the comment could be improved.  How about:
> 
> 			 * The file could be unmapped by another thread after
> 			 * releasing i_lock, and the inode then freed.  Hold
> 			 * a reference to the inode to prevent this.

It only can happen if mmap_sem was released, so it's better to put
__iget() to the branch above next to up_read(). I've got confused at first
how it is possible from ->fault().

This way iput() below should only be called for ret == VM_FAULT_RETRY.

> 
> > +			 */
> > +			__iget(inode);
> >  			spin_unlock(&inode->i_lock);
> >  			schedule();
> >  
> > @@ -2034,6 +2040,7 @@ static vm_fault_t shmem_fault(struct vm_
> >  			spin_lock(&inode->i_lock);
> >  			finish_wait(shmem_falloc_waitq, &shmem_fault_wait);
> >  			spin_unlock(&inode->i_lock);
> > +			iput(inode);
> >  			return ret;
> >  		}
> >  		spin_unlock(&inode->i_lock);
> > 
> > 

-- 
 Kirill A. Shutemov

