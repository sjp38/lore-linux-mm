Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3866B0092
	for <linux-mm@kvack.org>; Sat, 12 Apr 2014 09:25:00 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so5082576eek.9
        for <linux-mm@kvack.org>; Sat, 12 Apr 2014 06:24:58 -0700 (PDT)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id 43si14175344eei.145.2014.04.12.06.24.56
        for <linux-mm@kvack.org>;
        Sat, 12 Apr 2014 06:24:57 -0700 (PDT)
Date: Sat, 12 Apr 2014 15:24:44 +0200
From: Andres Freund <andres@2ndquadrant.com>
Subject: Re: Postgresql performance problems with IO latency, especially
 during fsync()
Message-ID: <20140412132444.GU14419@alap3.anarazel.de>
References: <20140326191113.GF9066@alap3.anarazel.de>
 <20140409092009.GA27519@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409092009.GA27519@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, Wu Fengguang <fengguang.wu@intel.com>, rhaas@anarazel.de

Hi Dave,

On 2014-04-09 19:20:09 +1000, Dave Chinner wrote:
> On Wed, Mar 26, 2014 at 08:11:13PM +0100, Andres Freund wrote:
> > So, the average read time is less than one ms (SSD, and about 50% cached
> > workload). But once another backend does the fsync(), read latency
> > skyrockets.
> > 
> > A concurrent iostat shows the problem pretty clearly:
> > Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s	avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
> > sda               1.00     0.00 6322.00  337.00    51.73     4.38	17.26     2.09    0.32    0.19    2.59   0.14  90.00
> > sda               0.00     0.00 6016.00  303.00    47.18     3.95	16.57     2.30    0.36    0.23    3.12   0.15  94.40
> > sda               0.00     0.00 6236.00 1059.00    49.52    12.88	17.52     5.91    0.64    0.20    3.23   0.12  88.40
> > sda               0.00     0.00  105.00 26173.00     0.89   311.39	24.34   142.37    5.42   27.73    5.33   0.04 100.00
> > sda               0.00     0.00   78.00 27199.00     0.87   324.06	24.40   142.30    5.25   11.08    5.23   0.04 100.00
> > sda               0.00     0.00   10.00 33488.00     0.11   399.05	24.40   136.41    4.07  100.40    4.04   0.03 100.00
> > sda               0.00     0.00 3819.00 10096.00    31.14   120.47	22.31    42.80    3.10    0.32    4.15   0.07  96.00
> > sda               0.00     0.00 6482.00  346.00    52.98     4.53	17.25     1.93    0.28    0.20    1.80   0.14  93.20
> > 
> > While the fsync() is going on (or the kernel decides to start writing
> > out aggressively for some other reason) the amount of writes to the disk
> > is increased by two orders of magnitude. Unsurprisingly with disastrous
> > consequences for read() performance. We really want a way to pace the
> > writes issued to the disk more regularly.

> I'm running in a 16p VM with 16GB RAM (in 4 nodes via fake-numa) and
> an unmodified benchmark on a current 3.15-linus tree. All storage
> (guest and host) is XFS based, guest VMs use virtio and direct IO to
> the backing storage.  The host is using noop IO scheduling.

> The first IO setup I ran was a 100TB XFS filesystem in the guest.
> The backing file is a sparse file on an XFS filesystem on a pair of
> 240GB SSDs (Samsung 840 EVO) in RAID 0 via DM.  The SSDs are
> exported as JBOD from a RAID controller which has 1GB of FBWC.  The
> guest is capable of sustaining around 65,000 random read IOPS and
> 40,000 write IOPS through this filesystem depending on the tests
> being run.

I think the 1GB FBWC explains the behaviour - IIRC the test as written
flushes about 400-500MB during fsync(). If the writebach cache can just
take that and continue as if nothing happened you'll see no problem.

> I'm not sure how you were generating the behaviour you reported, but
> the test program as it stands does not appear to be causing any
> problems at all on the sort of storage I'd expect large databases to
> be hosted on....

Since I had developed it while at LSF/MM I had little choice but to run
it only on my laptop. You might remember the speed of the conference
network ;)

> I've tried a few tweaks to the test program, but I haven't been able
> to make it misbehave. What do I need to tweak in the test program or
> my test VM to make the kernel misbehave like you reported?

I think there's two tweaks that would be worthwile to try to reproduce
the problem there:
* replace: "++writes % 100000" by something like "++writes %
  500000". That should create more than 1GB of dirty memory to be
  flushed out at the later fsync() which should then hit with your
  amount of WC cache.
* replace the: "nsleep(200000);" by something smaller. I guess 70000 or
  so might also trigger the problem alone.

Unfortunately right now I don't have any free rig with decent storage
available...

Greetings,

Andres Freund

-- 
 Andres Freund	                   http://www.2ndQuadrant.com/
 PostgreSQL Development, 24x7 Support, Training & Services

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
