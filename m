Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D0EAB6B0035
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 00:41:32 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so2096203pad.14
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 21:41:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id a8si4302246pbs.87.2014.03.13.21.41.24
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 21:41:24 -0700 (PDT)
Date: Thu, 13 Mar 2014 21:43:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm: per-thread vma caching
Message-Id: <20140313214308.090d1a18.akpm@linux-foundation.org>
In-Reply-To: <5322720F.1030706@huawei.com>
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
	<20140303164002.02df915e12d05bb98762407f@linux-foundation.org>
	<1393894778.30648.29.camel@buesod1.americas.hpqcorp.net>
	<20140303172348.3f00c9df.akpm@linux-foundation.org>
	<1393900953.30648.32.camel@buesod1.americas.hpqcorp.net>
	<20140303191224.96f93142.akpm@linux-foundation.org>
	<1393902810.30648.36.camel@buesod1.americas.hpqcorp.net>
	<CA+55aFwsjHPe4CF009p_L6PyYdP=F2bzi9-Wm5T+O6XPOCS6fg@mail.gmail.com>
	<5322720F.1030706@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 14 Mar 2014 11:05:51 +0800 Li Zefan <lizefan@huawei.com> wrote:

> Hi Davidlohr,
> 
> On 2014/3/4 11:26, Linus Torvalds wrote:
> > On Mon, Mar 3, 2014 at 7:13 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> >>
> >> Yes, I shortly realized that was silly... but I can say for sure it can
> >> happen and a quick qemu run confirms it. So I see your point as to
> >> asking why we need it, so now I'm looking for an explanation in the
> >> code.
> > 
> > We definitely *do* have users.
> > 
> > One example would be ptrace -> access_process_vm -> __access_remote_vm
> > -> get_user_pages() -> find_extend_vma() -> find_vma_prev -> find_vma.
> > 
> 
> I raw this oops on 3.14.0-rc5-next-20140307, which is possible caused by
> your patch? Don't know how it was triggered.
> 
> ...
>
> [ 6072.027007]  [<ffffffff811a4f62>] get_user_pages+0x52/0x60
> [ 6072.027015]  [<ffffffff811a5088>] __access_remote_vm+0x118/0x1f0
> [ 6072.027023]  [<ffffffff811a51bb>] access_process_vm+0x5b/0x80
> [ 6072.027033]  [<ffffffff812675a7>] proc_pid_cmdline+0x77/0x120
> [ 6072.027041]  [<ffffffff81267da2>] proc_info_read+0xa2/0xe0
> [ 6072.027050]  [<ffffffff811f439d>] vfs_read+0xad/0x1a0
> [ 6072.027057]  [<ffffffff811f45b5>] SyS_read+0x65/0xb0
> [ 6072.027066]  [<ffffffff8159ba12>] system_call_fastpath+0x16/0x1b
> [ 6072.027072] Code: f4 4c 89 f7 89 45 a4 e8 36 0e eb ff 48 3d 00 f0 ff ff 48 89 c3 0f 86 d7 00 00 00 4c 89 e0
>  49 8b 56 40 48 c1 e8 27 25 ff 01 00 00 <48> 8b 0c c2 48 85 c9 75 3e 41 83 e5 08 74 1b 49 8b 87 90 00 00
> [ 6072.027134] RIP  [<ffffffff811a0189>] follow_page_mask+0x69/0x620
> [ 6072.027142]  RSP <ffff880618855c18>
> [ 6072.027146] CR2: 00000000000007f8

Yep.  Please grab whichever of

mm-per-thread-vma-caching-fix-3.patch
mm-per-thread-vma-caching-fix-4.patch
mm-per-thread-vma-caching-fix-5.patch
mm-per-thread-vma-caching-fix-6-checkpatch-fixes.patch
mm-per-thread-vma-caching-fix-6-fix.patch

which you don't have from http://ozlabs.org/~akpm/mmots/broken-out/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
