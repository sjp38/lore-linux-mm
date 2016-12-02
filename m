Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 081E76B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 10:38:07 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id h201so207058521qke.7
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 07:38:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c14si3261905qtc.42.2016.12.02.07.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 07:38:06 -0800 (PST)
Date: Fri, 2 Dec 2016 16:37:58 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161202163758.0d8cc9bf@redhat.com>
In-Reply-To: <1480630668.5345.7.camel@redhat.com>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
	<20161130134034.3b60c7f0@redhat.com>
	<20161130140615.3bbn7576iwbyc3op@techsingularity.net>
	<20161130160612.474ca93c@redhat.com>
	<20161130163520.hg7icdflagmvarbr@techsingularity.net>
	<20161201183402.2fbb8c5b@redhat.com>
	<1480630668.5345.7.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Abeni <pabeni@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundtion.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Rick Jones <rick.jones2@hpe.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Hannes Frederic Sowa <hannes@stressinduktion.org>, brouer@redhat.com

On Thu, 01 Dec 2016 23:17:48 +0100
Paolo Abeni <pabeni@redhat.com> wrote:

> On Thu, 2016-12-01 at 18:34 +0100, Jesper Dangaard Brouer wrote:
> > (Cc. netdev, we might have an issue with Paolo's UDP accounting and
> > small socket queues)
> > 
> > On Wed, 30 Nov 2016 16:35:20 +0000
> > Mel Gorman <mgorman@techsingularity.net> wrote:
> >   
> > > > I don't quite get why you are setting the socket recv size
> > > > (with -- -s and -S) to such a small number, size + 256.
> > > >     
> > > 
> > > Maybe I missed something at the time I wrote that but why would it
> > > need to be larger?  
> > 
> > Well, to me it is quite obvious that we need some queue to avoid packet
> > drops.  We have two processes netperf and netserver, that are sending
> > packets between each-other (UDP_STREAM mostly netperf -> netserver).
> > These PIDs are getting scheduled and migrated between CPUs, and thus
> > does not get executed equally fast, thus a queue is need absorb the
> > fluctuations.
> > 
> > The network stack is even partly catching your config "mistake" and
> > increase the socket queue size, so we minimum can handle one max frame
> > (due skb "truesize" concept approx PAGE_SIZE + overhead).
> > 
> > Hopefully for localhost testing a small queue should hopefully not
> > result in packet drops.  Testing... ups, this does result in packet
> > drops.
> > 
> > Test command extracted from mmtests, UDP_STREAM size 1024:
> > 
> >  netperf-2.4.5-installed/bin/netperf -t UDP_STREAM  -l 60  -H 127.0.0.1 \
> >    -- -s 1280 -S 1280 -m 1024 -M 1024 -P 15895
> > 
> >  UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0)
> >   port 15895 AF_INET to 127.0.0.1 (127.0.0.1) port 15895 AF_INET
> >  Socket  Message  Elapsed      Messages                
> >  Size    Size     Time         Okay Errors   Throughput
> >  bytes   bytes    secs            #      #   10^6bits/sec
> > 
> >    4608    1024   60.00     50024301      0    6829.98
> >    2560           60.00     46133211           6298.72
> > 
> >  Dropped packets: 50024301-46133211=3891090
> > 
> > To get a better drop indication, during this I run a command, to get
> > system-wide network counters from the last second, so below numbers are
> > per second.
> > 
> >  $ nstat > /dev/null && sleep 1  && nstat
> >  #kernel
> >  IpInReceives                    885162             0.0
> >  IpInDelivers                    885161             0.0
> >  IpOutRequests                   885162             0.0
> >  UdpInDatagrams                  776105             0.0
> >  UdpInErrors                     109056             0.0
> >  UdpOutDatagrams                 885160             0.0
> >  UdpRcvbufErrors                 109056             0.0
> >  IpExtInOctets                   931190476          0.0
> >  IpExtOutOctets                  931189564          0.0
> >  IpExtInNoECTPkts                885162             0.0
> > 
> > So, 885Kpps but only 776Kpps delivered and 109Kpps drops. See
> > UdpInErrors and UdpRcvbufErrors is equal (109056/sec). This drop
> > happens kernel side in __udp_queue_rcv_skb[1], because receiving
> > process didn't empty it's queue fast enough see [2].
> > 
> > Although upstream changes are coming in this area, [2] is replaced with
> > __udp_enqueue_schedule_skb, which I actually tested with... hmm
> > 
> > Retesting with kernel 4.7.0-baseline+ ... show something else. 
> > To Paolo, you might want to look into this.  And it could also explain why
> > I've not see the mentioned speedup by mm-change, as I've been testing
> > this patch on top of net-next (at 93ba2222550) with Paolo's UDP changes.  
> 
> Thank you for reporting this.
> 
> It seems that the commit 123b4a633580 ("udp: use it's own memory
> accounting schema") is too strict while checking the rcvbuf. 
> 
> For very small value of rcvbuf, it allows a single skb to be enqueued,
> while previously we allowed 2 of them to enter the queue, even if the
> first one truesize exceeded rcvbuf, as in your test-case.
> 
> Can you please try the following patch ?

Sure, it looks much better with this patch.


$ /home/jbrouer/git/mmtests/work/testdisk/sources/netperf-2.4.5-installed/bin/netperf -t UDP_STREAM  -l 60  -H 127.0.0.1    -- -s 1280 -S 1280 -m 1024 -M 1024 -P 15895
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 15895 AF_INET to 127.0.0.1 (127.0.0.1) port 15895 AF_INET
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

  4608    1024   60.00     50191555      0    6852.82
  2560           60.00     50189872           6852.59

Only 50191555-50189872=1683 drops, approx 1683/60 = 28/sec

$ nstat > /dev/null && sleep 1  && nstat
#kernel
IpInReceives                    885417             0.0
IpInDelivers                    885416             0.0
IpOutRequests                   885417             0.0
UdpInDatagrams                  885382             0.0
UdpInErrors                     29                 0.0
UdpOutDatagrams                 885410             0.0
UdpRcvbufErrors                 29                 0.0
IpExtInOctets                   931534428          0.0
IpExtOutOctets                  931533376          0.0
IpExtInNoECTPkts                885488             0.0

 
> Thank you,
> 
> Paolo
> ---
>  net/ipv4/udp.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index e1d0bf8..2f5dc92 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1200,19 +1200,21 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
>  	struct sk_buff_head *list = &sk->sk_receive_queue;
>  	int rmem, delta, amt, err = -ENOMEM;
>  	int size = skb->truesize;
> +	int limit;
>  
>  	/* try to avoid the costly atomic add/sub pair when the receive
>  	 * queue is full; always allow at least a packet
>  	 */
>  	rmem = atomic_read(&sk->sk_rmem_alloc);
> -	if (rmem && (rmem + size > sk->sk_rcvbuf))
> +	limit = size + sk->sk_rcvbuf;
> +	if (rmem > limit)
>  		goto drop;
>  
>  	/* we drop only if the receive buf is full and the receive
>  	 * queue contains some other skb
>  	 */
>  	rmem = atomic_add_return(size, &sk->sk_rmem_alloc);
> -	if ((rmem > sk->sk_rcvbuf) && (rmem > size))
> +	if (rmem > limit)
>  		goto uncharge_drop;
>  
>  	spin_lock(&list->lock);
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
