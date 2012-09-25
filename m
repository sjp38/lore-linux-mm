Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 1EFB66B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 21:37:03 -0400 (EDT)
Date: Tue, 25 Sep 2012 11:36:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v3 1/2] writeback: add dirty_background_centisecs per bdi
 variable
Message-ID: <20120925013658.GC23520@dastard>
References: <1347798342-2830-1-git-send-email-linkinjeon@gmail.com>
 <20120920084422.GA5697@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120920084422.GA5697@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

On Thu, Sep 20, 2012 at 04:44:22PM +0800, Fengguang Wu wrote:
> [ CC FS and MM lists ]
> 
> Patch looks good to me, however we need to be careful because it's
> introducing a new interface. So it's desirable to get some acks from
> the FS/MM developers.
> 
> Thanks,
> Fengguang
> 
> On Sun, Sep 16, 2012 at 08:25:42AM -0400, Namjae Jeon wrote:
> > From: Namjae Jeon <namjae.jeon@samsung.com>
> > 
> > This patch is based on suggestion by Wu Fengguang:
> > https://lkml.org/lkml/2011/8/19/19
> > 
> > kernel has mechanism to do writeback as per dirty_ratio and dirty_background
> > ratio. It also maintains per task dirty rate limit to keep balance of
> > dirty pages at any given instance by doing bdi bandwidth estimation.
> > 
> > Kernel also has max_ratio/min_ratio tunables to specify percentage of
> > writecache to control per bdi dirty limits and task throttling.
> > 
> > However, there might be a usecase where user wants a per bdi writeback tuning
> > parameter to flush dirty data once per bdi dirty data reach a threshold
> > especially at NFS server.
> > 
> > dirty_background_centisecs provides an interface where user can tune
> > background writeback start threshold using
> > /sys/block/sda/bdi/dirty_background_centisecs
> > 
> > dirty_background_centisecs is used alongwith average bdi write bandwidth
> > estimation to start background writeback.
> > 
> > One of the use case to demonstrate the patch functionality can be
> > on NFS setup:-
> > We have a NFS setup with ethernet line of 100Mbps, while the USB
> > disk is attached to server, which has a local speed of 25MBps. Server
> > and client both are arm target boards.
> > 
> > Now if we perform a write operation over NFS (client to server), as
> > per the network speed, data can travel at max speed of 100Mbps. But
> > if we check the default write speed of USB hdd over NFS it comes
> > around to 8MB/sec, far below the speed of network.
> > 
> > Reason being is as per the NFS logic, during write operation, initially
> > pages are dirtied on NFS client side, then after reaching the dirty
> > threshold/writeback limit (or in case of sync) data is actually sent
> > to NFS server (so now again pages are dirtied on server side). This
> > will be done in COMMIT call from client to server i.e if 100MB of data
> > is dirtied and sent then it will take minimum 100MB/10Mbps ~ 8-9 seconds.
> > 
> > After the data is received, now it will take approx 100/25 ~4 Seconds to
> > write the data to USB Hdd on server side. Hence making the overall time
> > to write this much of data ~12 seconds, which in practically comes out to
> > be near 7 to 8MB/second. After this a COMMIT response will be sent to NFS
> > client.
> > 
> > However we may improve this write performace by making the use of NFS
> > server idle time i.e while data is being received from the client,
> > simultaneously initiate the writeback thread on server side. So instead
> > of waiting for the complete data to come and then start the writeback,
> > we can work in parallel while the network is still busy in receiving the
> > data. Hence in this way overall performace will be improved.
> > 
> > If we tune dirty_background_centisecs, we can see there
> > is increase in the performace and it comes out to be ~ 11MB/seconds.
> > Results are:-
> > 
> > Write test(create a 1 GB file) result at 'NFS client' after changing 
> > /sys/block/sda/bdi/dirty_background_centisecs 
> > on  *** NFS Server only - not on NFS Client ****

What is the configuration of the client and server? How much RAM,
what their dirty_* parameters are set to, network speed, server disk
speed for local sequential IO, etc?

> > ---------------------------------------------------------------------
> > |WRITE Test with various 'dirty_background_centisecs' at NFS Server |
> > ---------------------------------------------------------------------
> > |          | default = 0 | 300 centisec| 200 centisec| 100 centisec |
> > ---------------------------------------------------------------------
> > |RecSize   |  WriteSpeed |  WriteSpeed |  WriteSpeed |  WriteSpeed  |
> > ---------------------------------------------------------------------
> > |10485760  |  8.44MB/sec |  8.60MB/sec |  9.30MB/sec |  10.27MB/sec |
> > | 1048576  |  8.48MB/sec |  8.87MB/sec |  9.31MB/sec |  10.34MB/sec |
> > |  524288  |  8.37MB/sec |  8.42MB/sec |  9.84MB/sec |  10.47MB/sec |
> > |  262144  |  8.16MB/sec |  8.51MB/sec |  9.52MB/sec |  10.62MB/sec |
> > |  131072  |  8.48MB/sec |  8.81MB/sec |  9.42MB/sec |  10.55MB/sec |
> > |   65536  |  8.38MB/sec |  9.09MB/sec |  9.76MB/sec |  10.53MB/sec |
> > |   32768  |  8.65MB/sec |  9.00MB/sec |  9.57MB/sec |  10.54MB/sec |
> > |   16384  |  8.27MB/sec |  8.80MB/sec |  9.39MB/sec |  10.43MB/sec |
> > |    8192  |  8.52MB/sec |  8.70MB/sec |  9.40MB/sec |  10.50MB/sec |
> > |    4096  |  8.20MB/sec |  8.63MB/sec |  9.80MB/sec |  10.35MB/sec |
> > ---------------------------------------------------------------------

While this set of numbers looks good, it's a very limited in scope.
I can't evaluate whether the change is worthwhile or not from this
test. If I was writing this patch, the questions I'd be seeking to
answer before proposing it for inclusion are as follows....

1. what's the comparison in performance to typical NFS
server writeback parameter tuning? i.e. dirty_background_ratio=5,
dirty_ratio=10, dirty_expire_centiseconds=1000,
dirty_writeback_centisecs=1? i.e. does this give change give any
benefit over the current common practice for configuring NFS
servers?

2. what happens when you have 10 clients all writing to the server
at once? Or a 100? NFS servers rarely have a single writer to a
single file at a time, so what impact does this change have on
multiple concurrent file write performance from multiple clients?

3. Following on from the multiple client test, what difference does it
make to file fragmentation rates? Writing more frequently means
smaller allocations and writes, and that tends to lead to higher
fragmentation rates, especially when multiple files are being
written concurrently. Higher fragmentation also means lower
performance over time as fragmentation accelerates filesystem aging
effects on performance.  IOWs, it may be faster when new, but it
will be slower 3 months down the track and that's a bad tradeoff to
make.

4. What happens for higher bandwidth network links? e.g. gigE or
10gigE? Are the improvements still there? Or does it cause
regressions at higher speeds? I'm especially interested in what
happens to multiple writers at higher network speeds, because that's
a key performance metric used to measure enterprise level NFS
servers.

5. Are the improvements consistent across different filesystem
types?  We've had writeback changes in the past cause improvements
on one filesystem but significant regressions on others.  I'd
suggest that you need to present results for ext4, XFS and btrfs so
that we have a decent idea of what we can expect from the change to
the generic code.

Yeah, I'm asking a lot of questions. That's because the generic
writeback code is extremely important to performance and the impact
of a change cannot be evaluated from a single test.

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
