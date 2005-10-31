Date: Mon, 31 Oct 2005 06:34:30 -0800
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <27700000.1130769270@[10.10.2.4]>
In-Reply-To: <20051030235440.6938a0e9.akpm@osdl.org>
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie><20051031055725.GA3820@w-mikek2.ibm.com><4365BBC4.2090906@yahoo.com.au> <20051030235440.6938a0e9.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kravetz@us.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

>> Despite what people were trying to tell me at Ottawa, this patch
>> set really does add quite a lot of complexity to the page
>> allocator, and it seems to be increasingly only of benefit to
>> dynamically allocating hugepages and memory hot unplug.
> 
> Remember that Rohit is seeing ~10% variation between runs of scientific
> software, and that his patch to use higher-order pages to preload the
> percpu-pages magazines fixed that up.  I assume this means that it provided
> up to 10% speedup, which is a lot.

I, for one, would like to see some harder numbers on that, together with 
which architectures they actually affect. 
 
> But the patch caused page allocator fragmentation and several reports of
> gigE Tx buffer allocation failures, so I dropped it.

Yes, it made that condition worse but ...
 
> We think that Mel's patches will allow us to reintroduce Rohit's
> optimisation.

... frankly, it happens without Rohit's patch as well (under more stress).
If we want a OS that is robust, and supports higher order allocations,
we need to start caring about fragmentations. Not just for large pages,
and hotplug, but also for more common things like jumbo GigE frames,
CIFS, various device drivers, kernel stacks > 4K etc. 

To me, the question is "do we support higher order allocations, or not?".
Pretending we do, making a half-assed job of it, and then it not working
well under pressure is not helping anyone. I'm told, for instance, that
AMD64 requires > 4K stacks - that's pretty fundamental, as just one 
instance. I'd rather make Linux pretty bulletproof - the added feature
stuff is just a bonus that comes for free with that.

We don't make a good job of doing long-term stress testing, which is 
where fragmentation occurs. Unfortunately, customers do ;-(. I've become
fairly convinced we need something like this.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
