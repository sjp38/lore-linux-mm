Message-ID: <46B68369.1090802@yahoo.com.au>
Date: Mon, 06 Aug 2007 12:11:53 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <200707102015.44004.kernel@kolivas.org>	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	 <46A57068.3070701@yahoo.com.au>	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>	 <46A58B49.3050508@yahoo.com.au>	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>	 <46A6CC56.6040307@yahoo.com.au> <b21f8390707310937i5f90fa2rae650221b3ff4880@mail.gmail.com>
In-Reply-To: <b21f8390707310937i5f90fa2rae650221b3ff4880@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Hawkins <darthmdh@gmail.com>
Cc: Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Matthew Hawkins wrote:
> On 7/25/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>I guess /proc/meminfo, /proc/zoneinfo, /proc/vmstat, /proc/slabinfo
>>before and after the updatedb run with the latest kernel would be a
>>first step. top and vmstat output during the run wouldn't hurt either.
> 
> 
> Hi Nick,
> 
> I've attached two files with this kind of info.  Being up at the cron
> hours of the morning meant I got a better picture of what my system is
> doing.  Here's a short summary of what I saw in top:
> 
> beagleindexer used gobs of ram.  600M or so (I have 1G)

Hmm OK, beagleindexer. I thought beagle didn't need frequent reindexing
because of inotify? Oh well...


> updatedb didn't use much ram, but while it was running kswapd kept on
> frequenting the top 10 cpu hogs - it would stick around for 5 seconds
> or so then disappear for no more than 10 seconds, then come back
> again.  This behaviour persisted during the run.  updatedb ran third
> (beagleindexer was first, then update-dlocatedb)

Kswapd will use CPU when memory is low, even if there is no swapping.

Your "buffers" grew by 600% (from 50MB to 350MB), and slab also grew
by a few thousand entries. This is not just a problem when it pushes
out swap, it will also harm filebacked working set.

This (which Ray's traces also show) is a bit of a problem. As Andrew
noticed, use-once isn't working well for buffer cache, and it doesn't
really for dentry and inode cache either (although those don't seem
to be as much of a problem on your workload).

Andrew has done a little test patch for this in -mm, but it probably
wants more work and testing. If you can test the -mm kernel and see
if things are improved, that would help.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
