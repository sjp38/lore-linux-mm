Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 3D3456B0070
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 03:51:07 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so118928wey.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 00:51:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKYAXd975U_n2SSFXz0VfEs6GrVCoc2S=3kQbfw_2uOtGXbGxA@mail.gmail.com>
References: <1347798342-2830-1-git-send-email-linkinjeon@gmail.com>
	<20120920084422.GA5697@localhost>
	<20120925013658.GC23520@dastard>
	<CAKYAXd975U_n2SSFXz0VfEs6GrVCoc2S=3kQbfw_2uOtGXbGxA@mail.gmail.com>
Date: Fri, 19 Oct 2012 16:51:05 +0900
Message-ID: <CAKYAXd-BXOrXJDMo5_ANACn2qo3J5oM3vMJD-LXnEacegxHgTA@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] writeback: add dirty_background_centisecs per bdi variable
From: Namjae Jeon <linkinjeon@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

Hi Dave.

Test Procedure:

1) Local USB disk WRITE speed on NFS server is ~25 MB/s

2) Run WRITE test(create 1 GB file) on NFS Client with default
writeback settings on NFS Server. By default
bdi->dirty_background_bytes = 0, that means no change in default
writeback behaviour

3) Next we change bdi->dirty_background_bytes = 25 MB (almost equal to
local USB disk write speed on NFS Server)
*** only on NFS Server - not on NFS Client ***

[NFS Server]
# echo $((25*1024*1024)) > /sys/block/sdb/bdi/dirty_background_bytes
# cat /sys/block/sdb/bdi/dirty_background_bytes
26214400

4) Run WRITE test again on NFS client to see change in WRITE speed at NFS client

Test setup details:
Test result on PC - FC16 - RAM 3 GB - ethernet - 1000 Mbits/s,
Create 1 GB File

--------------------------------------------------------------------------------
Table 1: XFS over NFS - WRITE SPEED on NFS Client
--------------------------------------------------------------------------------
             default writeback        bdi->dirty_background_bytes
                      setting                  = 25 MB

RecSize     write speed(MB/s)   write speed(MB/s)          % Change
10485760       27.39                       28.53                          4%
1048576         27.9                        28.59                          2%
524288           27.55                      28.94                          5%
262144           25.4                        28.58                         13%
131072           25.73                       27.55                         7%
65536             25.85                       28.45                        10%
32768             26.13                       28.64                        10%
16384             26.17                       27.93                         7%
8192              25.64                        28.07                         9%
4096              26.28                        28.19                         7%

------------------------------------------------------------------------------
Table 2: EXT4 over NFS - WRITE SPEED on NFS Client
------------------------------------------------------------------------------
                  default writeback    bdi->dirty_background_bytes
                          setting              = 25 MB

RecSize     write speed(MB/s)   write speed(MB/s)       % Change
10485760         23.87                     28.3                        19%
1048576           24.81                    27.79                       12%
524288            24.53                     28.14                       15%
262144            24.21                     27.99                       16%
131072            24.11                     28.33                       18%
65536              23.73                     28.21                       19%
32768              25.66                     27.52                        7%
16384              24.3                       27.67                       14%
8192                23.6                       27.08                       15%
4096                23.35                     27.24                        17%

As mentioned in the above Table 1 & 2, there is performance
improvement on NFS client on gigabit Ethernet on both EXT4/XFS over
NFS. We did not observe any degradation in write speed.
However, performance gain varies on different file systems i.e.
different on XFS & EXT4 over NFS.

We also tried this change on BTRFS over NFS, but we did not see any
significant change in WRITE speed.

----------------------------------------------------------------------------------
Multiple NFS Client test:
-----------------------------------------------------------------------------------
Sorry - We could not arrange multiple PCs to verify this.
So, we tried 1 NFS Server + 2 NFS Clients using 3 target boards:
ARM Target + 512 MB RAM + ethernet - 100 Mbits/s, create 1 GB File

-----------------------------------------------------------------------------
Table 3: bdi->dirty_background_bytes = 0 MB
         - default writeback behaviour
-----------------------------------------------------------------------------
RecSize        Write Speed        Write Speed     Combined
                    on Client 1          on client 2     write speed
                        (MB/s)               (MB/s)          (MB/s)

10485760            5.45                  5.36              10.81
1048576              5.44                  5.34              10.78
524288                5.48                  5.51              10.99
262144                6.24                  4.83              11.07
131072                5.58                  5.53              11.11
65536                  5.51                  5.48              10.99
32768                  5.42                  5.46              10.88
16384                  5.62                  5.58              11.2
8192                    5.59                  5.49              11.08
4096                    5.57                  6.38              11.95

-----------------------------------------------------------------------
Table 4: bdi->dirty_background_bytes = 25 MB
-----------------------------------------------------------------------
RecSize        Write Speed        Write Speed     Combined
                     on Client 1        on client 2     write speed
                         (MB/s)            (MB/s)          (MB/s)

10485760              5.43              5.76             11.19
1048576                5.51              5.72             11.23
524288                  5.37              5.69             11.06
262144                  5.46              5.51             10.97
131072                  5.64              5.6               11.24
65536                    5.53              5.64             11.17
32768                    5.51              5.53             11.04
16384                    5.51              5.51             11.02
8192                      5.61              5.59             11.2
4096                      6.11              5.65             11.76

As mentioned in the above table 3 & 4, there is no significant drop in
WRITE speed of individual NFS Clients.
There is minor improvement on combined write speed of NFS client 1 & 2.


> 1. what's the comparison in performance to typical NFS
> server writeback parameter tuning? i.e. dirty_background_ratio=5,
> dirty_ratio=10, dirty_expire_centiseconds=1000,
> dirty_writeback_centisecs=1? i.e. does this give change give any
> benefit over the current common practice for configuring NFS
> servers?

Agreed, that above improvement in write speed can be achieved by
tuning above write-back parameters.
But if we change these settings, it will change write-back behavior
system wide.
On the other hand, if we change proposed per bdi setting,
bdi->dirty_background_bytes it will change write-back behavior for the
block device exported on NFS server.

> 2. what happens when you have 10 clients all writing to the server
> at once? Or a 100? NFS servers rarely have a single writer to a
> single file at a time, so what impact does this change have on
> multiple concurrent file write performance from multiple clients

Sorry, we could not arrange more than 2 PCs for verifying this.
So, We tried this on 3 ARM target boards - 1 ARM board as NFS server &
2 ARM targets as NFS clients connected with HUB on 100 Mbits/s
ethernet link speed.
Please refer above Table 3 & 4 results for this.

> 3. Following on from the multiple client test, what difference does it
> make to file fragmentation rates? Writing more frequently means
> smaller allocations and writes, and that tends to lead to higher
> fragmentation rates, especially when multiple files are being
> written concurrently. Higher fragmentation also means lower
> performance over time as fragmentation accelerates filesystem aging
> effects on performance.  IOWs, it may be faster when new, but it
> will be slower 3 months down the track and that's a bad tradeoff to
> make.

We agree that there could be bit more framentation. But as you know,
we are not changing writeback settings at NFS clients.
So, write-back behavior on NFS client will not change - IO requests
will be buffered at NFS client as per existing write-back behavior.

Also, by default we set bdi->dirty_background_bytes = 0, so, it does
not change default writeback setting unless user wants to tune it as
per the environment.


> 4. What happens for higher bandwidth network links? e.g. gigE or
> 10gigE? Are the improvements still there? Or does it cause
> regressions at higher speeds? I'm especially interested in what
> happens to multiple writers at higher network speeds, because that's
> a key performance metric used to measure enterprise level NFS
> servers.

As mentioned in the above table 1 & 2, on GIGABIT Ethernet interface
also it provides performance improvement in WRITE speed. It is not
degrading write speed.

We could not arrange 10gigE, so we could verify this patch only on
100Mbits/s and 1000Mbits/s Ethernet link.

> 5. Are the improvements consistent across different filesystem
> types?  We've had writeback changes in the past cause improvements
> on one filesystem but significant regressions on others.  I'd
> suggest that you need to present results for ext4, XFS and btrfs so
> that we have a decent idea of what we can expect from the change to
> the generic code.

As mentioned in the above Table 1 & 2, performance gain in WRITE speed
is different on different file systems i.e. different on NFS client
over XFS & EXT4.
We also tried BTRFS over NFS, but we could not see any WRITE speed
performance gain/degrade on BTRFS over NFS, so we are not posting
BTRFS results here.

Please let us know your opinion.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
