Content-Type: text/plain;
  charset="iso-8859-1"
From: Hubertus Franke <frankeh@watson.ibm.com>
Reply-To: frankeh@watson.ibm.com
Subject: Re: [PATCH] recognize MAP_LOCKED in mmap() call
Date: Wed, 25 Sep 2002 11:42:29 -0400
References: <OFC0C42F8D.E1325D58-ON86256C38.00695CD8@hou.us.ray.com> <3D88D9DE.2FB9A23D@digeo.com>
In-Reply-To: <3D88D9DE.2FB9A23D@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209251142.29341.frankeh@watson.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Mark_H_Johnson@raytheon.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 18 September 2002 03:54 pm, Andrew Morton wrote:
> Mark_H_Johnson@raytheon.com wrote:
> > Andrew Morton wrote:
> > >(SuS really only anticipates that mmap needs to look at prior mlocks
> > >in force against the address range.  It also says
> > >
> > >     Process memory locking does apply to shared memory regions,
> > >
> > >and we don't do that either.  I think we should; can't see why SuS
> > >requires this.)
> >
> > Let me make sure I read what you said correctly. Does this mean that
> > Linux 2.4 (or 2.5) kernels do not lock shared memory regions if a process
> > uses mlockall?
>
> Linux does lock these regions.  SuS seems to imply that we shouldn't.
> But we should.
>
> > If not, that is *really bad* for our real time applications. We don't
> > want to take a page fault while running some 80hz task, just because some
> > non-real time application tried to use what little physical memory we
> > allow for the kernel and all other applications.
> >
> > I asked a related question about a week ago on linux-mm and didn't get a
> > response. Basically, I was concerned that top did not show RSS == Size
> > when mlockall(MCL_CURRENT|MCL_FUTURE) was called. Could this explain the
> > difference or is there something else that I'm missing here?
>
> That mlockall should have faulted everything in.  It could be an
> accounting bug, or it could be a bug.  That's not an aspect which
> gets tested a lot.  I'll take a look.


This is what the manpage says...

       mlockall  disables  paging  for  all pages mapped into the
       address space of the calling process.  This  includes  the
       pages  of  the  code,  data  and stack segment, as well as
       shared libraries, user space kernel  data,  shared  memory
       and  memory  mapped files. All mapped pages are guaranteed
       to be resident  in  RAM  when  the  mlockall  system  call
       returns  successfully  and  they are guaranteed to stay in
       RAM until the pages  are  unlocked  again  by  munlock  or
       munlockall  or  until  the  process  terminates  or starts
       another program with exec.  Child processes do not inherit
       page locks across a fork.

Do you read that all pages must be faulted in apriori ?
Or is it sufficient to to make sure non of the currently mapped 
pages are swapped out and future swapout is prohibited.

This still allows for page faults on pages that have not been
mapped in the specified range or process. If required the 
app could touch these and they wouldn't be swapped later.


-- 
-- Hubertus Franke  (frankeh@watson.ibm.com)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
