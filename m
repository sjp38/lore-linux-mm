Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 842386B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:31:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q203so27489733wmb.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:31:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b2si7717546wrc.302.2017.10.09.11.31.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 11:31:31 -0700 (PDT)
Date: Mon, 9 Oct 2017 20:31:29 +0200
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Message-ID: <20171009183129.GE11645@wotan.suse.de>
References: <CABXGCsMorRzy-dJrjTO6sP80BSb0RAeMhF3QGwSkk50m7VYzOA@mail.gmail.com>
 <CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
 <20171009000529.GY3666@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171009000529.GY3666@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Aleksa Sarai <asarai@suse.com>, Hannes Reinecke <hare@suse.de>, "Eric W. Biederman" <ebiederm@xmission.com>, Jan Blunck <jblunck@infradead.org>, Oscar Salvador <osalvador@suse.com>

On Mon, Oct 09, 2017 at 11:05:29AM +1100, Dave Chinner wrote:
> On Sat, Oct 07, 2017 at 01:10:58PM +0500, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> > But seems now got another issue:
> > 
> > [ 1966.953781] INFO: task tracker-store:8578 blocked for more than 120 seconds.
> > [ 1966.953797]       Not tainted 4.13.4-301.fc27.x86_64+debug #1
> > [ 1966.953800] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> > disables this message.
> > [ 1966.953804] tracker-store   D12840  8578   1655 0x00000000
> > [ 1966.953811] Call Trace:
> > [ 1966.953823]  __schedule+0x2dc/0xbb0
> > [ 1966.953830]  ? wait_on_page_bit_common+0xfb/0x1a0
> > [ 1966.953838]  schedule+0x3d/0x90
> > [ 1966.953843]  io_schedule+0x16/0x40
> > [ 1966.953847]  wait_on_page_bit_common+0x10a/0x1a0
> > [ 1966.953857]  ? page_cache_tree_insert+0x170/0x170
> > [ 1966.953865]  __filemap_fdatawait_range+0x101/0x1a0
> > [ 1966.953883]  file_write_and_wait_range+0x63/0xc0
> 
> Ok, that's in wait_on_page_writeback(page)
> ......
> 
> > And yet another
> > 
> > [41288.797026] INFO: task tracker-store:4535 blocked for more than 120 seconds.
> > [41288.797034]       Not tainted 4.13.4-301.fc27.x86_64+debug #1
> > [41288.797037] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> > disables this message.
> > [41288.797041] tracker-store   D10616  4535   1655 0x00000000
> > [41288.797049] Call Trace:
> > [41288.797061]  __schedule+0x2dc/0xbb0
> > [41288.797072]  ? bit_wait+0x60/0x60
> > [41288.797076]  schedule+0x3d/0x90
> > [41288.797082]  io_schedule+0x16/0x40
> > [41288.797086]  bit_wait_io+0x11/0x60
> > [41288.797091]  __wait_on_bit+0x31/0x90
> > [41288.797099]  out_of_line_wait_on_bit+0x94/0xb0
> > [41288.797106]  ? bit_waitqueue+0x40/0x40
> > [41288.797113]  __block_write_begin_int+0x265/0x550
> > [41288.797132]  iomap_write_begin.constprop.14+0x7d/0x130
> 
> And that's in wait_on_buffer().
> 
> In both cases we are waiting on a bit lock for IO completion. In the
> first case it is on page, the second it's on sub-page read IO
> completion during a write.
> 
> Triggeringa hung task timeouts like this doesn't usually indicate a
> filesystem problem.

<-- snip -->

> None of these things usually filesystem problems, and the trainsmash
> of blocked tasks on filesystem locks is typical for these types of
> "blocked indefinitely with locks held" type of situations. It does
> tend to indicate taht there is quite a bit of load on the
> filesystem, though...

As Jan Kara noted we've seen this also on customers SLE12-SP2 kernel (4.4
based). Although we also were never able to root cause, since that bug
is now closed on our end I figured it would be worth mentioning two
theories we discussed, one more recent than the other.

One theory came from observation of logs and these logs hinting at an
older issue our Docker team had been looking into for a while, that of
libdm mounts being leaked into another container's namespace. Apparently
the clue to when this happens is when something as follows is seen on
the docker logs:

2017-06-22T18:59:47.925917+08:00 host-docker-01 dockerd[1957]: time="2017-06-22T18:59:47.925857351+08:00" level=info msg="Container
6b8f678a27d61939f358614c673224675d64f1527bb2046943e2d493f095c865 failed to exit within 30 seconds of signal 15 - using the force"

This is a SIGTERM. When one sees the above message it is a good hint that the
container actually did not finish at all, but instead was forced to be
terminated via 'docker kill' or 'docker rm -f'. To be clear docker was not able
to use SIGTERM so then resorts to SIGKILL.

After this is when we get the next clueful message which interests us to try
to figure out a way to reproduce the originally reported issue:

2017-06-22T18:59:48.071374+08:00 host-docker-01 dockerd[1957]: time="2017-06-22T18:59:48.071314219+08:00" level=error msg="devmapper: Error
unmounting device

Aleksa indicates he's been studying this code for a while, and although he
has fixes for this on Docker it also means he does understands what is
going on here. The above error message indicates Docker in turn *failed* to
still kill the damn container with SIGKILL. This, he indicates, is due to
libdm mounts leaking from one container namespace to another container's
namespace. The error is not docker being unable to umount, its actually
that docker cannot remove the backing device.

Its after this when the bug triggers. It doesn't explain *why* we hit this
bug on XFS, but it should be a clue. Aleksa is however is absolutely sure
that the bugs found internally *are* caused by mount leakage somehow, and
all we know is that XFS oops happened after this.

He suggests this could in theory be reproduced by doing the following
while you have a Docker daemon running:

  o unshare -m
  o mount --make-rprivate /

Effectively forcing a mount leak. We had someone trying to reproduce this
internally somehow but I don't think they were in the end able to.

If this docker issue leads to a kernel issue the severity might be a bit more
serious, it indicates an unprivileged user namespaces can effectively perform a
DoS against the host if it's trying to operate on devicemapper mounts.

Then *another* theory came recently from Jan Blunck during the ALPSS, he noted
he traced a similar issue back to a systemd misuse, ie, systemd setting the
root namespace to 'shared' by default. Originally the root namespace is set to
'private', but systemd decided it'd be a good idea to set it to 'shared'. Which
would quite easily explain the mount namespace leaking.

Aleksa however contends that the mountspace leaking happens because of Docker's
architecture (all of the mounts are created in one mount namespace, and all of
the runc invocations happen in that same mount namespace). Even if you
explicitly set different sharing options (which runc already supports), the
problem still exists.

But if *not* using docker, it gives us an idea of how you perhaps you could
run into a similar issue.

Regardless Aleksa points out there's still a more fundamental issue of "I can
leak a mountpoint as an unprivileged user, no matter what the propagation is":

  % unshare -rm
  % mount --make-rprivate /
  % # I now have the mount alive.

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
