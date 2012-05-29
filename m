Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 743896B0072
	for <linux-mm@kvack.org>; Tue, 29 May 2012 11:58:05 -0400 (EDT)
Date: Tue, 29 May 2012 23:57:59 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: write-behind on streaming writes
Message-ID: <20120529155759.GA11326@localhost>
References: <20120528114124.GA6813@localhost>
 <CA+55aFxHt8q8+jQDuoaK=hObX+73iSBTa4bBWodCX3s-y4Q1GQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxHt8q8+jQDuoaK=hObX+73iSBTa4bBWodCX3s-y4Q1GQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

Hi Linus,

On Mon, May 28, 2012 at 10:09:56AM -0700, Linus Torvalds wrote:
> Ok, pulled.
> 
> However, I have an independent question for you - have you looked at
> any kind of per-file write-behind kind of logic?

Yes, definitely.  Especially for NFS, it benefits to keep each file's
dirty pages low. Because in NFS, a simple stat() will require flushing
all the file's dirty pages before proceeding.

However in general there are no strong user requests for this feature.
I guess it's mainly because they still have the choices to use O_SYNC
or O_DIRECT.

Actually O_SYNC is pretty close to the below code for the purpose of
limiting the dirty and writeback pages, except that it's not on by
default, hence means nothing for normal users.

> The reason I ask is that pretty much every time I write some big file
> (usually when over-writing a harddisk), I tend to use my own hackish
> model, which looks like this:
> 
> #define BUFSIZE (8*1024*1024ul)
> 
>         ...
>         for (..) {
>                 ...
>                 if (write(fd, buffer, BUFSIZE) != BUFSIZE)
>                         break;
>                 sync_file_range(fd, index*BUFSIZE, BUFSIZE,
> SYNC_FILE_RANGE_WRITE);
>                 if (index)
>                         sync_file_range(fd, (index-1)*BUFSIZE,
> BUFSIZE, SYNC_FILE_RANGE_WAIT_BEFORE|SYNC_FILE_RANGE_WRITE|SYNC_FILE_RANGE_WAIT_AFTER);
>                 ....
> 
> and it tends to be *beautiful* for both disk IO performane and for
> system responsiveness while the big write is in progress.

It seems to me all about optimizing the 1-dd case for desktop users,
and the most beautiful thing about per-file write behind is, it keeps
both the number of dirty and writeback pages low in the system when
there are only one or two sequential dirtier tasks. Which is good for
responsiveness.

Note that the above user space code won't work well when there are 10+
dirtier tasks. It effectively creates 10+ IO submitters on different
regions of the disk and thus create lots of seeks. When there are 10+
dirtier tasks, it's not only desirable to have one single flusher
thread to submit all IO, but also for the flusher to work on the
inodes with large write chunk size.

I happen to have some numbers on comparing the current adaptive
(write_bandwidth/2=50MB) and the old fixed 4MB write chunk sizes on
XFS (not choosing ext4 because it internally enforces >=128MB chunk
size).  It's basically 4% performance drop in the 1-dd case and up to
20% in the 100-dd case.

  3.4.0-rc2             3.4.0-rc2-4M+
-----------  ------------------------  
     114.02        -4.2%       109.23  snb/thresh=8G/xfs-1dd-1-3.4.0-rc2
     102.25       -11.7%        90.24  snb/thresh=8G/xfs-10dd-1-3.4.0-rc2
     104.17       -17.5%        85.91  snb/thresh=8G/xfs-20dd-1-3.4.0-rc2
     104.94       -18.7%        85.28  snb/thresh=8G/xfs-30dd-1-3.4.0-rc2
     104.76       -21.9%        81.82  snb/thresh=8G/xfs-100dd-1-3.4.0-rc2

So we probably still want to keep the 0.5s worth of chunk size.

> And I'm wondering if we couldn't expose this kind of write-behind
> logic from the kernel. Sure, it only works for the "contiguous write
> of a single large file" model, but that model isn't actually all
> *that* unusual.
> 
> Right now all the write-back logic is based on the
> balance_dirty_pages() model, which is more of a global dirty model.
> Which obviously is needed too - this isn't an "either or" kind of
> thing, it's more of a "maybe we could have a streaming detector *and*
> the 'random writes' code". So I was wondering if anybody had ever been
> looking more at an explicit write-behind model that uses the same kind
> of "per-file window" that the read-ahead code does.

I can imagine it being implemented in kernel this way:

streaming write detector in balance_dirty_pages():

        if (not globally throttled &&
            is streaming writer &&
            it's crossing the N+1 boundary) {
                queue writeback work for chunk N to the flusher
                wait for work completion
        }

The good thing is, that looks not a complex addition. However the
potential problem is, the "wait for work completion" part won't have
guaranteed complete time, especially when there are multiple dd tasks.
This could result in uncontrollable delays in the write() syscall. So
we may do this instead:

-               wait for work completion
+               sleep for (chunk_size/write_bandwidth)

To avoid long write() delays, we might further split the one big 0.5s
sleep into smaller sleeps.

> (The above code only works well for known streaming writes, but the
> *model* of saying "ok, let's start writeout for the previous streaming
> block, and then wait for the writeout of the streaming block before
> that" really does tend to result in very smooth IO and minimal
> disruption of other processes..)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
