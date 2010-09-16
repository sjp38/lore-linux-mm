Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BEC216B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 04:08:43 -0400 (EDT)
Date: Thu, 16 Sep 2010 10:08:26 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Message-ID: <20100916080826.GB21228@elte.hu>
References: <4C90A6C7.9050607@redhat.com>
 <AANLkTi=rmUUPCm212Sju-wW==5cT4eqqU+FEP_hX-Z_y@mail.gmail.com>
 <20100916105311.CA00.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100916105311.CA00.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Alexander Viro <viro@ftp.linux.org.uk>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bryan Donlan <bdonlan@gmail.com>, Avi Kivity <avi@redhat.com>, Christopher Yeoh <cyeoh@au1.ibm.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Wed, Sep 15, 2010 at 19:58, Avi Kivity <avi@redhat.com> wrote:
> > 
> > > Instead of those two syscalls, how about a vmfd(pid_t pid, ulong start,
> > > ulong len) system call which returns an file descriptor that represents a
> > > portion of the process address space.  You can then use preadv() and
> > > pwritev() to copy memory, and io_submit(IO_CMD_PREADV) and
> > > io_submit(IO_CMD_PWRITEV) for asynchronous variants (especially useful with
> > > a dma engine, since that adds latency).
> > >
> > > With some care (and use of mmu_notifiers) you can even mmap() your vmfd and
> > > access remote process memory directly.
> > 
> > Rather than introducing a new vmfd() API for this, why not just add
> > implementations for these more efficient operations to the existing
> > /proc/$pid/mem interface?
> 
> As far as I heared from my friend, old HP MPI implementation used 
> /proc/$pid/mem for this purpose. (I don't know current status). 
> However almost implementation doesn't do that because /proc/$pid/mem 
> required the process is ptraced. As far as I understand , very old 
> /proc/$pid/mem doesn't require it. but It changed for security 
> concern. Then, Anybody haven't want to change this interface because 
> they worry break security.
> 
> But, I don't know what exactly protected "the process is ptraced" 
> check. If anyone explain the reason and we can remove it. I'm not 
> againt at all.

I did some Git digging - that ptrace check for /proc/$pid/mem read/write 
goes all the way back to the beginning of written human history, aka 
Linux v2.6.12-rc2.

I researched the fragmented history of the stone ages as well, i checked 
out numerous cave paintings, and while much was lost, i was able to 
recover this old fragment of a clue in the cave called 'patch-2.3.27', 
carbon-dated back as far as the previous millenium (!):

  mem_read() in fs/proc/base.c:

+ *  1999, Al Viro. Rewritten. Now it covers the whole per-process part.
+ *  Instead of using magical inumbers to determine the kind of object
+ *  we allocate and fill in-core inodes upon lookup. They don't even
+ *  go into icache. We cache the reference to task_struct upon lookup too.
+ *  Eventually it should become a filesystem in its own. We don't use the
+ *  rest of procfs anymore.

In such a long timespan language has changed much, so not all of this 
scribbling can be interpreted - but one thing appears to be sure: this 
is where the MAY_PTRACE() restriction was introduced to /proc/$pid/mem - 
as part of a massive rewrite.

Alas, the reason for the restriction was not documented, and is feared 
to be lost forever.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
