Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 112D56B004D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 18:17:25 -0400 (EDT)
Date: Fri, 31 Jul 2009 00:17:28 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
Message-ID: <20090730221727.GI12579@kernel.dk>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com> <20090730213956.GH12579@kernel.dk> <33307c790907301501v4c605ea8oe57762b21d414445@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <33307c790907301501v4c605ea8oe57762b21d414445@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Martin Bligh <mbligh@google.com>
Cc: Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 30 2009, Martin Bligh wrote:
> On Thu, Jul 30, 2009 at 2:39 PM, Jens Axboe<jens.axboe@oracle.com> wrote:
> > On Tue, Jul 28 2009, Chad Talbott wrote:
> >> I run a simple workload on a 4GB machine which dirties a few largish
> >> inodes like so:
> >>
> >> # seq 10 | xargs -P0 -n1 -i\{} dd if=/dev/zero of=/tmp/dump\{}
> >> bs=1024k count=100
> >>
> >> While the dds are running data is written out at disk speed.  However,
> >> once the dds have run to completion and exited there is ~500MB of
> >> dirty memory left.  Background writeout then takes about 3 more
> >> minutes to clean memory at only ~3.3MB/s.  When I explicitly sync, I
> >> can see that the disk is capable of 40MB/s, which finishes off the
> >> files in ~10s. [1]
> >>
> >> An interesting recent-ish change is "writeback: speed up writeback of
> >> big dirty files."  When I revert the change to __sync_single_inode the
> >> problem appears to go away and background writeout proceeds at disk
> >> speed.  Interestingly, that code is in the git commit [2], but not in
> >> the post to LKML. [3]  This is may not be the fix, but it makes this
> >> test behave better.
> >
> > Can I talk you into trying the per-bdi writeback patchset? I just tried
> > your test on a 16gb machine, and the dd's finish immediately since it
> > wont trip the writeout at that percentage of dirty memory. The 1GB of
> > dirty memory is flushed when it gets too old, 30 seconds later in two
> > chunks of writeout running at disk speed.
> 
> How big did you make the dds? It has to be writing more data than
> you have RAM, or it's not going to do anything much interesting ;-)

The test case above on a 4G machine is only generating 1G of dirty data.
I ran the same test case on the 16G, resulting in only background
writeout. The relevant bit here being that the background writeout
finished quickly, writing at disk speed.

I re-ran the same test, but using 300 100MB files instead. While the
dd's are running, we are going at ~80MB/sec (this is disk speed, it's an
x25-m). When the dd's are done, it continues doing 80MB/sec for 10
seconds or so. Then the remainder (about 2G) is written in bursts at
disk speeds, but with some time in between.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
