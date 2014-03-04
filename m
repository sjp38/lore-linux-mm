Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 89EDB6B0037
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 00:32:20 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id um1so4745634pbc.2
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 21:32:20 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id po10si12904441pab.73.2014.03.03.21.32.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 21:32:19 -0800 (PST)
Message-ID: <1393911136.2512.1.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v4] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 03 Mar 2014 21:32:16 -0800
In-Reply-To: <CA+55aFwsjHPe4CF009p_L6PyYdP=F2bzi9-Wm5T+O6XPOCS6fg@mail.gmail.com>
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
	 <20140303164002.02df915e12d05bb98762407f@linux-foundation.org>
	 <1393894778.30648.29.camel@buesod1.americas.hpqcorp.net>
	 <20140303172348.3f00c9df.akpm@linux-foundation.org>
	 <1393900953.30648.32.camel@buesod1.americas.hpqcorp.net>
	 <20140303191224.96f93142.akpm@linux-foundation.org>
	 <1393902810.30648.36.camel@buesod1.americas.hpqcorp.net>
	 <CA+55aFwsjHPe4CF009p_L6PyYdP=F2bzi9-Wm5T+O6XPOCS6fg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 2014-03-03 at 19:26 -0800, Linus Torvalds wrote:
> On Mon, Mar 3, 2014 at 7:13 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> >
> > Yes, I shortly realized that was silly... but I can say for sure it can
> > happen and a quick qemu run confirms it. So I see your point as to
> > asking why we need it, so now I'm looking for an explanation in the
> > code.
> 
> We definitely *do* have users.
> 
> One example would be ptrace -> access_process_vm -> __access_remote_vm
> -> get_user_pages() -> find_extend_vma() -> find_vma_prev -> find_vma.

And:

[    4.274542] Call Trace:
[    4.274747]  [<ffffffff81809525>] dump_stack+0x46/0x58
[    4.275069]  [<ffffffff811331ee>] vmacache_find+0xae/0xc0
[    4.275425]  [<ffffffff8113c840>] find_vma+0x20/0x80
[    4.275625]  [<ffffffff8113e5cb>] find_extend_vma+0x2b/0x90
[    4.275982]  [<ffffffff81138a09>] __get_user_pages+0x99/0x5a0
[    4.276427]  [<ffffffff81137b0b>] ? follow_page_mask+0x32b/0x400
[    4.276671]  [<ffffffff81138fc2>] get_user_pages+0x52/0x60
[    4.276886]  [<ffffffff81167dc3>] copy_strings.isra.20+0x1a3/0x2f0
[    4.277239]  [<ffffffff81167f4d>] copy_strings_kernel+0x3d/0x50
[    4.277472]  [<ffffffff811b3688>] load_script+0x1e8/0x280
[    4.277692]  [<ffffffff81167d0a>] ? copy_strings.isra.20+0xea/0x2f0
[    4.277931]  [<ffffffff81167ff7>] search_binary_handler+0x97/0x1d0
[    4.278288]  [<ffffffff811694bf>] do_execve_common.isra.28+0x4ef/0x650
[    4.278544]  [<ffffffff81169638>] do_execve+0x18/0x20
[    4.278754]  [<ffffffff8116984e>] SyS_execve+0x2e/0x40
[    4.278960]  [<ffffffff8181b549>] stub_execve+0x69/0xa0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
