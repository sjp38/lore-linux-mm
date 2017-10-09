Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C01156B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 18:28:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j64so51276618pfj.6
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 15:28:55 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id s4si7130106plp.584.2017.10.09.15.28.53
        for <linux-mm@kvack.org>;
        Mon, 09 Oct 2017 15:28:54 -0700 (PDT)
Date: Tue, 10 Oct 2017 09:28:51 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Message-ID: <20171009222851.GR3666@dastard>
References: <CABXGCsMorRzy-dJrjTO6sP80BSb0RAeMhF3QGwSkk50m7VYzOA@mail.gmail.com>
 <CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
 <20171009000529.GY3666@dastard>
 <20171009183129.GE11645@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171009183129.GE11645@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Aleksa Sarai <asarai@suse.com>, Hannes Reinecke <hare@suse.de>, "Eric W. Biederman" <ebiederm@xmission.com>, Jan Blunck <jblunck@infradead.org>, Oscar Salvador <osalvador@suse.com>

On Mon, Oct 09, 2017 at 08:31:29PM +0200, Luis R. Rodriguez wrote:
> On Mon, Oct 09, 2017 at 11:05:29AM +1100, Dave Chinner wrote:
> > On Sat, Oct 07, 2017 at 01:10:58PM +0500, D?D,N?D?D,D>> D?D?D2N?D,D>>D 3/4 D2 wrote:
> > > But seems now got another issue:
> > > 
> > > [ 1966.953781] INFO: task tracker-store:8578 blocked for more than 120 seconds.
> > > [ 1966.953797]       Not tainted 4.13.4-301.fc27.x86_64+debug #1
> > > [ 1966.953800] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> > > disables this message.
> > > [ 1966.953804] tracker-store   D12840  8578   1655 0x00000000
> > > [ 1966.953811] Call Trace:
> > > [ 1966.953823]  __schedule+0x2dc/0xbb0
> > > [ 1966.953830]  ? wait_on_page_bit_common+0xfb/0x1a0
> > > [ 1966.953838]  schedule+0x3d/0x90
> > > [ 1966.953843]  io_schedule+0x16/0x40
> > > [ 1966.953847]  wait_on_page_bit_common+0x10a/0x1a0
> > > [ 1966.953857]  ? page_cache_tree_insert+0x170/0x170
> > > [ 1966.953865]  __filemap_fdatawait_range+0x101/0x1a0
> > > [ 1966.953883]  file_write_and_wait_range+0x63/0xc0
> > 
> > Ok, that's in wait_on_page_writeback(page)
> > ......
> > 
> > > And yet another
> > > 
> > > [41288.797026] INFO: task tracker-store:4535 blocked for more than 120 seconds.
> > > [41288.797034]       Not tainted 4.13.4-301.fc27.x86_64+debug #1
> > > [41288.797037] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> > > disables this message.
> > > [41288.797041] tracker-store   D10616  4535   1655 0x00000000
> > > [41288.797049] Call Trace:
> > > [41288.797061]  __schedule+0x2dc/0xbb0
> > > [41288.797072]  ? bit_wait+0x60/0x60
> > > [41288.797076]  schedule+0x3d/0x90
> > > [41288.797082]  io_schedule+0x16/0x40
> > > [41288.797086]  bit_wait_io+0x11/0x60
> > > [41288.797091]  __wait_on_bit+0x31/0x90
> > > [41288.797099]  out_of_line_wait_on_bit+0x94/0xb0
> > > [41288.797106]  ? bit_waitqueue+0x40/0x40
> > > [41288.797113]  __block_write_begin_int+0x265/0x550
> > > [41288.797132]  iomap_write_begin.constprop.14+0x7d/0x130
> > 
> > And that's in wait_on_buffer().
> > 
> > In both cases we are waiting on a bit lock for IO completion. In the
> > first case it is on page, the second it's on sub-page read IO
> > completion during a write.
> > 
> > Triggeringa hung task timeouts like this doesn't usually indicate a
> > filesystem problem.
> 
> <-- snip -->
> 
> > None of these things usually filesystem problems, and the trainsmash
> > of blocked tasks on filesystem locks is typical for these types of
> > "blocked indefinitely with locks held" type of situations. It does
> > tend to indicate taht there is quite a bit of load on the
> > filesystem, though...
> 
> As Jan Kara noted we've seen this also on customers SLE12-SP2 kernel (4.4
> based). Although we also were never able to root cause, since that bug
> is now closed on our end I figured it would be worth mentioning two
> theories we discussed, one more recent than the other.

Sure, but stuff going on with docker mounts and namespaces has
nothing to do with IO path locking and completions. There's
something in the filesystem or the storage stack below going
wrong here, not above it in the vfsmount layer....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
