Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9B226B0260
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:07:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so14419174wma.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:07:19 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id g75si20803358wmd.39.2016.07.12.07.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 07:07:18 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id r190so3933485wmr.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:07:18 -0700 (PDT)
Date: Tue, 12 Jul 2016 16:07:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Page Allocation Failures/OOM with dm-crypt on software RAID10
 (Intel Rapid Storage)
Message-ID: <20160712140715.GL14586@dhcp22.suse.cz>
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
 <20160712095013.GA14591@dhcp22.suse.cz>
 <d9dbe0328e938eb7544fdb2aa8b5a9c7@mail.ud19.udmedia.de>
 <20160712114920.GF14586@dhcp22.suse.cz>
 <e6c2087730e530e77c2b12d50495bdc9@mail.ud19.udmedia.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e6c2087730e530e77c2b12d50495bdc9@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

On Tue 12-07-16 14:42:12, Matthias Dahl wrote:
> Hello Michal...
> 
> On 2016-07-12 13:49, Michal Hocko wrote:
> 
> > I am not a storage expert (not even mention dm-crypt). But what those
> > counters say is that the IO completion doesn't trigger so the
> > PageWriteback flag is still set. Such a page is not reclaimable
> > obviously. So I would check the IO delivery path and focus on the
> > potential dm-crypt involvement if you suspect this is a contributing
> > factor.
> 
> Sounds reasonable... except that I have no clue how to trace that with
> the limited means I have at my disposal right now and with the limited
> knowledge I have of the kernel internals. ;-)

I guess dm resp. block layer experts would be much better to advise
here.
 
> > Who is consuming those objects? Where is the rest 70% of memory hiding?
> 
> Is there any way to get a more detailed listing of where the memory is
> spent while dd is running? Something I could pipe every 500ms or so for
> later analysis or so?

/proc/slabinfo could at least point on who is eating that memory.

> > Writer will get throttled but the concurrent memory consumer will not
> > normally. So you can end up in this situation.
> 
> Hm, okay. I am still confused though: If I, for example, let dd do the
> exact same thing on a raw partition on the RAID10, nothing like that
> happens. Wouldn't we have the same race and problem then too...?

Direct IO doesn't get throttled like buffered IO.

> It is
> only with dm-crypt in-between that all of this shows itself. But I do
> somehow suspect the RAID10 Intel Rapid Storage to be the cause or at
> least partially.

Well, there are many allocation failures for GFP_ATOMIC requests
from scsi_request_fn path. AFAIU the code, the request is deferred
and retried later.  I cannot find any path which would do regular
__GFP_DIRECT_RECLAIM fallback allocation. So while GFP_ATOMIC is
___GFP_KSWAPD_RECLAIM so it would kick kswapd which should reclaim some
memory there is no guarantee for a forward progress. Anyway, I believe
even __GFP_DIRECT_RECLAIM allocation wouldn't help much in this
particular case. There is not much of a reclaimable memory left - most
of it is dirty/writeback - so we are close to a deadlock state.

But we do not seem to be stuck completely:
                unevictable:12341 dirty:90458 writeback:651272 unstable:0
                unevictable:12341 dirty:90458 writeback:651272 unstable:0
                unevictable:12341 dirty:90458 writeback:651272 unstable:0
                unevictable:12341 dirty:90222 writeback:651252 unstable:0
                unevictable:12341 dirty:90222 writeback:651231 unstable:0
                unevictable:12341 dirty:89321 writeback:651905 unstable:0
                unevictable:12341 dirty:89212 writeback:652014 unstable:0
                unevictable:12341 dirty:89212 writeback:651993 unstable:0
                unevictable:12341 dirty:89212 writeback:651993 unstable:0
                unevictable:12488 dirty:42892 writeback:656597 unstable:0
                unevictable:12488 dirty:42783 writeback:656597 unstable:0
                unevictable:12488 dirty:42125 writeback:657125 unstable:0
                unevictable:12488 dirty:42125 writeback:657125 unstable:0
                unevictable:12488 dirty:42125 writeback:657125 unstable:0
                unevictable:12488 dirty:42125 writeback:657125 unstable:0
                unevictable:12556 dirty:54778 writeback:648616 unstable:0
                unevictable:12556 dirty:54168 writeback:648919 unstable:0
                unevictable:12556 dirty:54168 writeback:648919 unstable:0
                unevictable:12556 dirty:53237 writeback:649506 unstable:0
                unevictable:12556 dirty:53237 writeback:649506 unstable:0
                unevictable:12556 dirty:53128 writeback:649615 unstable:0
                unevictable:12556 dirty:53128 writeback:649615 unstable:0
                unevictable:12556 dirty:52256 writeback:650159 unstable:0
                unevictable:12556 dirty:52256 writeback:650159 unstable:0
                unevictable:12556 dirty:52256 writeback:650138 unstable:0
                unevictable:12635 dirty:49929 writeback:650724 unstable:0
                unevictable:12635 dirty:49820 writeback:650833 unstable:0
                unevictable:12635 dirty:49820 writeback:650833 unstable:0
                unevictable:12635 dirty:49820 writeback:650833 unstable:0
                unevictable:13001 dirty:167859 writeback:651864 unstable:0
                unevictable:13001 dirty:167672 writeback:652038 unstable:0

the number of pages under writeback was more or less same throughout
the time but there are some local fluctuations when some pages do get
completed.

That being said, I believe that IO is stuck due to lack of memory which
is caused by some memory leak or excessive memory consumption. Finding
out who that might be would be the first step. /proc/slabinfo should
show us which slab cache is backing so many unreclaimable objects. If we
are lucky it will be something easier to match to a code. If not you can
enable allocator trace point for a particular object size (or range of
sizes) and see who is requesting them.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
