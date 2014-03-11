Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 157D06B0037
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 15:31:17 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lj1so9199799pab.6
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 12:31:16 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id zt8si21072787pbc.345.2014.03.11.12.31.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Mar 2014 12:31:05 -0700 (PDT)
Message-ID: <1394566262.2786.23.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH -mm] mm,numa,mprotect: always continue after finding a
 stable thp page
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 11 Mar 2014 12:31:02 -0700
In-Reply-To: <20140311180652.GM10663@suse.de>
References: <5318E4BC.50301@oracle.com>
	 <20140306173137.6a23a0b2@cuia.bos.redhat.com> <5318FC3F.4080204@redhat.com>
	 <20140307140650.GA1931@suse.de> <20140307150923.GB1931@suse.de>
	 <20140307182745.GD1931@suse.de> <20140311162845.GA30604@suse.de>
	 <531F3F15.8050206@oracle.com> <531F4128.8020109@redhat.com>
	 <531F48CC.303@oracle.com> <20140311180652.GM10663@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Sasha Levin <sasha.levin@oracle.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, hhuang@redhat.com, knoel@redhat.com, aarcange@redhat.com

On Tue, 2014-03-11 at 18:06 +0000, Mel Gorman wrote:
> On Tue, Mar 11, 2014 at 01:33:00PM -0400, Sasha Levin wrote:
> > Okay. So just this patch on top of the latest -next shows the following issues:
> > 
> > 1. BUG in task_numa_work:
> > 
> > [  439.417171] BUG: unable to handle kernel paging request at ffff880e17530c00
> > [  439.418216] IP: [<ffffffff81299385>] vmacache_find+0x75/0xa0
> > [  439.419073] PGD 8904067 PUD 1028fcb067 PMD 1028f10067 PTE 8000000e17530060
> > [  439.420340] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> > [  439.420340] Dumping ftrace buffer:
> > [  439.420340]    (ftrace buffer empty)
> > [  439.420340] Modules linked in:
> > [  439.420340] CPU: 12 PID: 9937 Comm: trinity-c212 Tainted: G        W    3.14.0-rc5-next-20140307-sasha-00009-g3b24300-dirty #137
> > [  439.420340] task: ffff880e1a45b000 ti: ffff880e1a490000 task.ti: ffff880e1a490000
> > [  439.420340] RIP: 0010:[<ffffffff81299385>]  [<ffffffff81299385>] vmacache_find+0x75/0xa0
> > [  439.420340] RSP: 0018:ffff880e1a491e68  EFLAGS: 00010286
> > [  439.420340] RAX: ffff880e17530c00 RBX: 0000000000000000 RCX: 0000000000000001
> > [  439.420340] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffff880e1a45b000
> > [  439.420340] RBP: ffff880e1a491e68 R08: 0000000000000000 R09: 0000000000000000
> > [  439.420340] R10: 0000000000000001 R11: 0000000000000000 R12: ffff880e1ab75000
> > [  439.420340] R13: ffff880e1ab75000 R14: 0000000000010000 R15: 0000000000000000
> > [  439.420340] FS:  00007f3458c05700(0000) GS:ffff880d2b800000(0000) knlGS:0000000000000000
> > [  439.420340] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [  439.420340] CR2: ffff880e17530c00 CR3: 0000000e1a472000 CR4: 00000000000006a0
> > [  439.420340] Stack:
> > [  439.420340]  ffff880e1a491e98 ffffffff812a7610 ffffffff8118de40 0000000000000117
> > [  439.420340]  00000001000036da ffff880e1a45b000 ffff880e1a491ef8 ffffffff8118de4b
> > [  439.420340]  ffff880e1a491ec8 ffffffff81269575 ffff880e1ab750a8 ffff880e1a45b000
> > [  439.420340] Call Trace:
> > [  439.420340]  [<ffffffff812a7610>] find_vma+0x20/0x90
> > [  439.420340]  [<ffffffff8118de40>] ? task_numa_work+0x130/0x360
> > [  439.420340]  [<ffffffff8118de4b>] task_numa_work+0x13b/0x360
> > [  439.420340]  [<ffffffff81269575>] ? context_tracking_user_exit+0x195/0x1d0
> > [  439.420340]  [<ffffffff8116c5be>] task_work_run+0xae/0xf0
> > [  439.420340]  [<ffffffff8106ffbe>] do_notify_resume+0x8e/0xe0
> > [  439.420340]  [<ffffffff844b17a2>] int_signal+0x12/0x17
> > [  439.420340] Code: 42 10 00 00 00 00 48 c7 42 18 00 00 00 00 eb 38 66 0f 1f 44 00 00 31 d2 48 89 c7 48 63 ca 48 8b 84 cf b8 07 00 00 48 85 c0 74 0b <48> 39 30 77 06 48 3b 70 08 72 12 ff c2 83 fa 04 75 de 66 0f 1f
> > [  439.420340] RIP  [<ffffffff81299385>] vmacache_find+0x75/0xa0
> > [  439.420340]  RSP <ffff880e1a491e68>
> > [  439.420340] CR2: ffff880e17530c00
> > 
> 
> Ok, this does not look related. It looks like damage from the VMA caching
> patches, possibly a use-after free. I'm skeptical that it's related to
> automatic NUMA balancing as such based on the second trace you posted.

Indeed, this issue is separate. It was reported a few days ago by
Fengguang: http://lkml.org/lkml/2014/3/9/201

Apparently this has only been seen in DEBUG_PAGEALLOC + trinity
scenarios, just like in Sasha's trace. I'm suspecting some invalidation
is missing (not sure what DEBUG_PAGEALLOC enables differently in this
aspect), as when we do the vmacache_find() the vma is bogus which
triggers the paging request error.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
