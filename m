Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DCF2F6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 22:27:28 -0500 (EST)
Date: Wed, 3 Mar 2010 11:27:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] nfs: use 4*rsize readahead size
Message-ID: <20100303032724.GA9979@localhost>
References: <20100224032934.GF16175@discord.disaster> <20100224041822.GB27459@localhost> <20100224052215.GH16175@discord.disaster> <20100224061247.GA8421@localhost> <20100224073940.GJ16175@discord.disaster> <20100226074916.GA8545@localhost> <20100302031021.GA14267@localhost> <1267539563.3099.43.camel@localhost.localdomain> <19341.19446.356359.99958@stoffel.org> <1267555339.3099.127.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1267555339.3099.127.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: John Stoffel <john@stoffel.org>, Dave Chinner <david@fromorbit.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 03, 2010 at 02:42:19AM +0800, Trond Myklebust wrote:
> On Tue, 2010-03-02 at 12:33 -0500, John Stoffel wrote: 
> > >>>>> "Trond" == Trond Myklebust <Trond.Myklebust@netapp.com> writes:
> > 
> > Trond> On Tue, 2010-03-02 at 11:10 +0800, Wu Fengguang wrote: 
> > >> Dave,
> > >> 
> > >> Here is one more test on a big ext4 disk file:
> > >> 
> > >> 16k	39.7 MB/s
> > >> 32k	54.3 MB/s
> > >> 64k	63.6 MB/s
> > >> 128k	72.6 MB/s
> > >> 256k	71.7 MB/s
> > >> rsize ==> 512k  71.7 MB/s
> > >> 1024k	72.2 MB/s
> > >> 2048k	71.0 MB/s
> > >> 4096k	73.0 MB/s
> > >> 8192k	74.3 MB/s
> > >> 16384k	74.5 MB/s
> > >> 
> > >> It shows that >=128k client side readahead is enough for single disk
> > >> case :) As for RAID configurations, I guess big server side readahead
> > >> should be enough.
> > 
> > Trond> There are lots of people who would like to use NFS on their
> > Trond> company WAN, where you typically have high bandwidths (up to
> > Trond> 10GigE), but often a high latency too (due to geographical
> > Trond> dispersion).  My ping latency from here to a typical server in
> > Trond> NetApp's Bangalore office is ~ 312ms. I read your test results
> > Trond> with 10ms delays, but have you tested with higher than that?
> > 
> > If you have that high a latency, the low level TCP protocol is going
> > to kill your performance before you get to the NFS level.  You really
> > need to open up the TCP window size at that point.  And it only gets
> > worse as the bandwidth goes up too.  
> 
> Yes. You need to open the TCP window in addition to reading ahead
> aggressively.

I only get ~10MB/s throughput with following settings.

# huge NFS ra size
echo 89512 > /sys/devices/virtual/bdi/0:15/read_ahead_kb        

# on both sides
/sbin/tc qdisc add dev eth0 root netem delay 200ms              

net.core.rmem_max = 873800000
net.core.wmem_max = 655360000
net.ipv4.tcp_rmem = 8192 87380000 873800000
net.ipv4.tcp_wmem = 4096 65536000 655360000

Did I miss something?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
