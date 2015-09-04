Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA7A6B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 05:10:52 -0400 (EDT)
Received: by qgx61 with SMTP id 61so11060691qgx.3
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 02:10:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 138si2106454qhs.81.2015.09.04.02.10.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 02:10:51 -0700 (PDT)
Date: Fri, 4 Sep 2015 11:10:38 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150904111038.4a428b03@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1509031113450.24411@east.gentwo.org>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903060247.GV1933@devil.localdomain>
	<20150903122949.78ee3c94@redhat.com>
	<alpine.DEB.2.11.1509031113450.24411@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dave Chinner <dchinner@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Snitzer <snitzer@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>, brouer@redhat.com

On Thu, 3 Sep 2015 11:19:53 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> On Thu, 3 Sep 2015, Jesper Dangaard Brouer wrote:
> 
> > I'm buying into the problem of variable object lifetime sharing the
> > same slub.
> 
[...]
>
> > With the SLAB bulk free API I'm introducing, we can speedup slub
> > slowpath, by free several objects with a single cmpxchg_double, BUT
> > these objects need to belong to the same page.
> >  Thus, as Dave describe with merging, other users of the same size
> > objects might end up holding onto objects scattered across several
> > pages, which gives the bulk free less opportunities.
> 
> This happens regardless as far as I can tell. On boot up you may end up
> for a time in special situations where that is true.

That is true, which is also why below measurements should be taken with
a grain of salt, as benchmarking is done within 10 min of boot up.


> > That would be a technical argument for introducing a SLAB_NO_MERGE flag
> > per slab.  But I want to do some measurement before making any
> > decision. And it might be hard to show for my use-case of SKB free,
> > because SKB allocs will likely be dominating 256 bytes slab anyhow.

I'll give you some preliminary measurements on my patchset which uses
the new SLAB bulk free API of SKBs in the TX completion on ixgbe NIC
driver (function ixgbe_clean_tx_irq() will bulk free max 32 SKBs).

Basic test-type is IPv4 forwarding, on a single CPU (i7-4790K CPU @
4.00GHz), with generator pktgen sending 14Mpps (using script
samples/pktgen/pktgen_sample03_burst_single_flow.sh). 

Test setup notes
 * Kernel: 4.1.0-mmotm-2015-08-24-16-12+ #261 SMP
  - with patches "detached freelist" and Christophs irqon/off fix.

Config /etc/sysctl.conf ::
 net/ipv4/conf/default/rp_filter = 0
 net/ipv4/conf/all/rp_filter = 0
 # Forwarding performance is affected by early demux
 net/ipv4/ip_early_demux = 0
 net.ipv4.ip_forward = 1

Setup::
 $ base_device_setup.sh ixgbe3
 $ base_device_setup.sh ixgbe4
 $ netfilter_unload_modules.sh ; netfilter_unload_modules.sh; rmmod nf_reject_ipv4
 $ ip neigh add 172.16.0.66 dev ixgbe4 lladdr 00:aa:aa:aa:aa:aa
 # GRO negatively affect forwarding performance (as least for UDP test)
 $ ethtool -K ixgbe4 gro off tso off gso off
 $ ethtool -K ixgbe3 gro off tso off gso off

First I tested a none patched kernel with/without "slab_nomerge".
 (Single CPU IP-forwarding of UDP packets)
 * Normal      : 2049166 pps
 * slab_nomerge: 2053440 pps
 * Diff: +4274pps and -1.02ns
 * Nanosec diff show we are below accuracy of system

Thus, results are the same.
Using bulking changes the picture:

Bulk free of max 32 SKBs in ixgbe TX-DMA-completion:
 * Bulk-free32: 2091218 pps
 * Diff to "Normal" case above: +42052 pps and 9.81ns
 * Nanosec diff is significant (enough above accuracy level of system)
 * Summary: Pretty nice improvement!

Same test with "slab_nomerge":
 * slab_nomerge: 2121703 pps
 * Diff to above: +30485 pps and -6.87 ns
 * Nanosec diff were upto 3ns in testrun, this 6ns is still valid
 * Summary: slab_nomerge did make a difference!

Total improvement is quite significant: +72537 pps and -16.68ns (+3.5%)

It is important to be critical about your own measurements.  What is
the real cause of this change.  Lets see that happens if we tune SLUB
per CPU structures to have more "room", instead of using "slab_nomerge".

Tuning::
  echo 256 > /sys/kernel/slab/skbuff_head_cache/cpu_partial
  echo 9   > /sys/kernel/slab/skbuff_head_cache/min_partial

Test with bulk-free32 and SLUB-tuning:
 * slub-tuned: 2110842 pps
 * Note this gets very close to "slab_nomerge"
  - 2121703 - 2110842 = 10861 pps
  - (1/2121703*10^9)-(1/2110842*10^9) = -2.42 ns
 * Nanosec diff around 2.5ns is not significant enough, call results the same

Thus, I could achieve the same performance results by tuning SLUB as I
could with "slab_nomerge".  Maybe the advantage from "slab_nomerge" was
just that I got my "own" per CPU structures, and this implicitly larger
per CPU memory for myself?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
