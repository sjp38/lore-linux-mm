Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 10B936B0078
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 07:38:05 -0500 (EST)
Date: Thu, 25 Feb 2010 20:37:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] nfs: use 2*rsize readahead size
Message-ID: <20100225123755.GB9077@localhost>
References: <20100224024100.GA17048@localhost> <20100224032934.GF16175@discord.disaster> <20100224041822.GB27459@localhost> <20100224052215.GH16175@discord.disaster> <e48344781002240318u6e6545bdt97712dca4efceb9f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e48344781002240318u6e6545bdt97712dca4efceb9f@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Akshat Aranya <aaranya+fsdevel@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 24, 2010 at 07:18:26PM +0800, Akshat Aranya wrote:
> On Wed, Feb 24, 2010 at 12:22 AM, Dave Chinner <david@fromorbit.com> wrote:
> 
> >
> >> It sounds silly to have
> >>
> >> A  A  A  A  client_readahead_size > server_readahead_size
> >
> > I don't think it is A - the client readahead has to take into account
> > the network latency as well as the server latency. e.g. a network
> > with a high bandwidth but high latency is going to need much more
> > client side readahead than a high bandwidth, low latency network to
> > get the same throughput. Hence it is not uncommon to see larger
> > readahead windows on network clients than for local disk access.
> >
> > Also, the NFS server may not even be able to detect sequential IO
> > patterns because of the combined access patterns from the clients,
> > and so the only effective readahead might be what the clients
> > issue....
> >
> 
> In my experiments, I have observed that the server-side readahead
> shuts off rather quickly even with a single client because the client
> readahead causes multiple pending read RPCs on the server which are
> then serviced in random order and the pattern observed by the
> underlying file system is non-sequential.  In our file system, we had
> to override what the VFS thought was a random workload and continue to
> do readahead anyway.

What's the server side kernel version, plus client/server side
readahead size? I'd expect the context readahead to handle it well.

With the patchset in <http://lkml.org/lkml/2010/2/23/376>, you can
actually see the readahead details:

        # echo 1 > /debug/tracing/events/readahead/enable
        # cp test-file /dev/null
        # cat /debug/tracing/trace  # trimmed output
        readahead-initial(dev=0:15, ino=100177, req=0+2, ra=0+4-2, async=0) = 4
        readahead-subsequent(dev=0:15, ino=100177, req=2+2, ra=4+8-8, async=1) = 8
        readahead-subsequent(dev=0:15, ino=100177, req=4+2, ra=12+16-16, async=1) = 16
        readahead-subsequent(dev=0:15, ino=100177, req=12+2, ra=28+32-32, async=1) = 32
        readahead-subsequent(dev=0:15, ino=100177, req=28+2, ra=60+60-60, async=1) = 24
        readahead-subsequent(dev=0:15, ino=100177, req=60+2, ra=120+60-60, async=1) = 0

And I've actually verified the NFS case with the help of such traces
long ago.  When client_readahead_size <= server_readahead_size, the
readahead requests may look a bit random at first, and then will
quickly turn into a perfect series of sequential context readaheads.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
