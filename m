Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 447C85F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 13:50:45 -0400 (EDT)
Date: Tue, 14 Apr 2009 19:51:24 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH v3 2/6] mm, directio: fix fork vs direct-io race
	(read(2) side IOW gup(write) side)
Message-ID: <20090414175124.GC9809@random.random>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <20090414151652.C64D.A69D9226@jp.fujitsu.com> <20090414152500.C65F.A69D9226@jp.fujitsu.com> <x49ab6jyyiy.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49ab6jyyiy.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Jeff Moyer <jmoyer@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Zach Brown <zach.brown@oracle.com>, Andy Grover <andy.grover@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 14, 2009 at 12:45:41PM -0400, Jeff Moyer wrote:
> So, if you're continuously submitting async read I/O, you will starve
> out the fork() call indefinitely.  I agree that you want to allow

IIRC rwsem good enough to stop the down_read when a down_write is
blocked. Otherwise page fault flood in threads would also starve any
mmap or similar call. Still with this approach fork will start to hang
indefinitely waiting for I/O, making it an I/O bound call, and not a
CPU call anymore, which may severely impact interactive-ness of
applications.

As long as fork is useful in the first place to provide memory
protection of different code with different
memory-corruption-trust-levels (otherwise nobody should use fork at
all, and vfork [or better spawn] should become the only option), then
fork from a thread pool is also reasonable. Either fork is totally
useless as a whole (which I wouldn't argue too much about), or if you
agree fork makes any sense, it can also make sense if intermixed with
clone(CLONE_VM) and hopefully it should behave CPU bound like CLONE_VM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
