Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0T0K4L1015563
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 19:20:04 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0T0IC7m205780
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 19:18:12 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0T0IBgN002617
	for <linux-mm@kvack.org>; Mon, 28 Jan 2008 19:18:12 -0500
Subject: Re: [PATCH] Fix procfs task exe symlink
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <20080126220336.a2a3caf7.akpm@linux-foundation.org>
References: <1201112977.5443.29.camel@localhost.localdomain>
	 <20080126220336.a2a3caf7.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 28 Jan 2008 16:18:09 -0800
Message-Id: <1201565889.10206.147.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@ftp.linux.org.uk, dhowells@redhat.com, wtaber@us.ibm.com, owilliam@br.ibm.com, rkissel@us.ibm.com, hch@lst.de
List-ID: <linux-mm.kvack.org>

On Sat, 2008-01-26 at 22:03 -0800, Andrew Morton wrote:
> > On Wed, 23 Jan 2008 10:29:37 -0800 Matt Helsley <matthltc@us.ibm.com> wrote:
> > 
> > Andrew, please consider this patch for inclusion in -mm.
> > 
> > ...
> >
> 
> Can't say that we're particularly exercised about mvfs's problems, but the
> current way of doing /proc/pid/exe is indeed a nasty hack.
> 
> > 
> >  fs/binfmt_flat.c          |    3 +
> >  fs/exec.c                 |    2 +
> >  fs/proc/base.c            |   77 ++++++++++++++++++++++++++++++++++++++++++++++
> >  fs/proc/internal.h        |    1 
> >  fs/proc/task_mmu.c        |   34 --------------------
> >  fs/proc/task_nommu.c      |   34 --------------------
> >  include/linux/init_task.h |    8 ++++
> >  include/linux/mm.h        |   22 +++++++++++++
> >  include/linux/mm_types.h  |    7 ++++
> >  include/linux/proc_fs.h   |   14 +++++++-
> >  kernel/fork.c             |    3 +
> >  mm/mmap.c                 |   22 ++++++++++---
> >  mm/nommu.c                |   15 +++++++-
> >  13 files changed, 164 insertions(+), 78 deletions(-)
> 
> It's a fairly expensive fix though.  Can't we just do a strcpy() somewhere
> at exec time?

I chose not to do this because I thought it would change the output of
readlink on /proc/pid/exe under certain circumstances.

For instance, I think the output of the following would be slightly
different:

$ mkdir tmp
$ cd tmp
$ cp /bin/sleep ./
$ ./sleep 10 &
$ SLEEP_PID=$!
$ ls -l /proc/4733/exe
lrwxrwxrwx 1 mhelsley mhelsley 0 Jan 28 15:51 /proc/4733/exe -> /home/mhelsley/tmp/sleep
$ rm sleep
$ echo $?
0
$ ls -l /proc/4733/exe
lrwxrwxrwx 1 mhelsley mhelsley 0 Jan 28 15:51 /proc/4733/exe -> /home/mhelsley/tmp/sleep (deleted)

I think simply storing the string at exec time wouldn't show the latter
result. Perhaps we could do a lookup during readlink to fix it. That may
not always work though -- could chroot or mount namespaces break this?

Al Viro's unmap example might also have different output if we just
stored the string. When the last VM_EXECUTABLE VMA goes away the symlink
shouldn't work. So I think we'd still have to track the map/unmap of
VM_EXECUTABLE VMAs similar to what I do in my patch.

Using chroot we get a "permission denied" error when doing a readlink
on /proc/pid/exe symlinks that point outside the chroot. I'm not sure a
lookup using the stored string will fix all cases here.

Then there's mount namespaces to consider. I think that the string would
hold the path in the mount namespace of the executable whose exe link
we're reading rather than the path in the mount namespace of the task
reading the link.

We may be able to work around all of these. I'm not sure that patch
would be simpler though.

If you want something a little simpler I could follow Oleg Nesterov's
suggestions. I think that could trim at least 20 lines at the cost of
continuing to use the mmap semaphore in the /proc/pid/exe readlink path.

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
