Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BFB106B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 05:26:57 -0400 (EDT)
Message-ID: <4C91E2CC.9040709@redhat.com>
Date: Thu, 16 Sep 2010 11:26:36 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Cross Memory Attach
References: <20100915104855.41de3ebf@lilo>	<4C90A6C7.9050607@redhat.com>	<AANLkTi=rmUUPCm212Sju-wW==5cT4eqqU+FEP_hX-Z_y@mail.gmail.com> <20100916104819.36d10acb@lilo>
In-Reply-To: <20100916104819.36d10acb@lilo>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: Bryan Donlan <bdonlan@gmail.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

  On 09/16/2010 03:18 AM, Christopher Yeoh wrote:
> On Wed, 15 Sep 2010 23:46:09 +0900
> Bryan Donlan<bdonlan@gmail.com>  wrote:
>
> >  On Wed, Sep 15, 2010 at 19:58, Avi Kivity<avi@redhat.com>  wrote:
> >
> >  >  Instead of those two syscalls, how about a vmfd(pid_t pid, ulong
> >  >  start, ulong len) system call which returns an file descriptor that
> >  >  represents a portion of the process address space.  You can then
> >  >  use preadv() and pwritev() to copy memory, and
> >  >  io_submit(IO_CMD_PREADV) and io_submit(IO_CMD_PWRITEV) for
> >  >  asynchronous variants (especially useful with a dma engine, since
> >  >  that adds latency).
> >  >
> >  >  With some care (and use of mmu_notifiers) you can even mmap() your
> >  >  vmfd and access remote process memory directly.
> >
> >  Rather than introducing a new vmfd() API for this, why not just add
> >  implementations for these more efficient operations to the existing
> >  /proc/$pid/mem interface?
>
> Perhaps I'm misunderstanding something here, but
> accessing /proc/$pid/mem requires ptracing the target process.
> We can't really have all these MPI processes ptraceing each other
> just to send/receive a message....
>

You could have each process open /proc/self/mem and pass the fd using 
SCM_RIGHTS.

That eliminates a race; with copy_to_process(), by the time the pid is 
looked up it might designate a different process.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
