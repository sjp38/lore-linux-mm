Message-ID: <447D8C99.2080009@aitel.hist.no>
Date: Wed, 31 May 2006 14:31:21 +0200
From: Helge Hafting <helge.hafting@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org> <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org> <447BD31E.7000503@yahoo.com.au> <447BD63D.2080900@yahoo.com.au> <Pine.LNX.4.64.0605301041200.5623@g5.osdl.org> <447CE43A.6030700@yahoo.com.au> <Pine.LNX.4.64.0605301739030.24646@g5.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605301739030.24646@g5.osdl.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> On Wed, 31 May 2006, Nick Piggin wrote:
>   
>> The requests can only get merged if contiguous requests from the upper
>> layers come down, right?
>>     
>
> It has nothing to do with merging. It has to do with IO patterns.
>
> Seeking.
>
> Seeking is damn expensive - much more so than command issue. People forget 
> that sometimes.
>
> If you can sort the requests so that you don't have to seek back and 
> forth, that's often a HUGE win. 
>
> Yes, the requests will still be small, and yes, the IO might happen in 4kB 
> chunks, but it happens a lot faster if you do it in a good elevator 
> ordering and if you hit the track cache than if you seek back and forth.
>   
This is correct, but doesn't really explain why plugging might be good.

If requests go to disk immediately and the disk is able to keep
up with the seeks, then plugging doesn't help. This is a low-bandwith
case of course, but servicing each request immediately will
keep the latency lower.  The fact that the disk gets busier doesn't
matter unless you worry about power consumption for the access arm.

If lots of requests come in and we don't do plugging, then
lots of the requests will be nicely sorted while waiting for
the first seek.  And when this sorted lot goes to disk, further
requests will be sorted.  I.e. congestion itself can work as dynamic
plugging, giving longer and longer sorted queues until the disk keeps
up with us.

This should get us  just enough sorting for the disk to keep up
with the bandwidth we demand, and therefore minimal latency
for that bandwith.

This is theory, and perhaps it doesn't quite reflect reaility.
I cannot see why it shouldn't, though - it'd be interesting
to know if I missed something obvious here.

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
