Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 345746B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 02:55:54 -0400 (EDT)
Date: Thu, 5 Sep 2013 15:55:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/4] slab: implement byte sized indexes for the freelist
 of a slab
Message-ID: <20130905065552.GA6384@lge.com>
References: <CAAmzW4N1GXbr18Ws9QDKg7ChN5RVcOW9eEv2RxWhaEoHtw=ctw@mail.gmail.com>
 <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140e42dcd61-00e6cf6a-457c-48bd-8bf7-830133923564-000000@email.amazonses.com>
 <20130904083305.GC16355@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130904083305.GC16355@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 04, 2013 at 05:33:05PM +0900, Joonsoo Kim wrote:
> On Tue, Sep 03, 2013 at 02:15:42PM +0000, Christoph Lameter wrote:
> > On Mon, 2 Sep 2013, Joonsoo Kim wrote:
> > 
> > > This patchset implements byte sized indexes for the freelist of a slab.
> > >
> > > Currently, the freelist of a slab consist of unsigned int sized indexes.
> > > Most of slabs have less number of objects than 256, so much space is wasted.
> > > To reduce this overhead, this patchset implements byte sized indexes for
> > > the freelist of a slab. With it, we can save 3 bytes for each objects.
> > >
> > > This introduce one likely branch to functions used for setting/getting
> > > objects to/from the freelist, but we may get more benefits from
> > > this change.
> > >
> > > Below is some numbers of 'cat /proc/slabinfo' related to my previous posting
> > > and this patchset.
> > 
> > You  may also want to run some performance tests. The cache footprint
> > should also be reduced with this patchset and therefore performance should
> > be better.
> 
> Yes, I did a hackbench test today, but I'm not ready for posting it.
> The performance is improved for my previous posting and futher improvement is
> founded by this patchset. Perhaps I will post it tomorrow.
> 

Here are the results from both patchsets on my 4 cpus machine.

* Before *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       238,309,671 cache-misses                                                  ( +-  0.40% )

      12.010172090 seconds time elapsed                                          ( +-  0.21% )

* After my previous posting *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       229,945,138 cache-misses                                                  ( +-  0.23% )

      11.627897174 seconds time elapsed                                          ( +-  0.14% )


* After my previous posting + this patchset *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       218,640,472 cache-misses                                                  ( +-  0.42% )

      11.504999837 seconds time elapsed                                          ( +-  0.21% )



cache-misses are reduced whenever applying each patchset, roughly 5% respectively.
And elapsed times are also improved by 3.1% and 4.2% to baseline, respectively.

I think that all patchsets deserve to be merged, since it reduces memory usage and
also improves performance. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
