Subject: Re: Poor DBT-3 pgsql 8way numbers on recent 2.6 mm kernels
From: Ram Pai <linuxram@us.ibm.com>
In-Reply-To: <1079551915.23637.55.camel@localhost>
References: <1079130684.2961.134.camel@localhost>
	 <20040312233900.0d68711e.akpm@osdl.org> <405379ED.A7D6B1E4@us.ibm.com>
	 <20040313134842.78695cc6.akpm@osdl.org>
	 <1079369109.2961.181.camel@localhost>
	 <1079379197.2844.32.camel@dyn319094bld.beaverton.ibm.com>
	 <1079551915.23637.55.camel@localhost>
Content-Type: text/plain
Message-Id: <1079555588.7222.9.camel@localhost.localdomain>
Mime-Version: 1.0
Date: 17 Mar 2004 12:33:08 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: maryedie@osdl.org
Cc: Andrew Morton <akpm@osdl.org>, Badari Pulavarty <pbadari@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2004-03-17 at 11:31, Mary Edie Meredith wrote:
> Ram, it took a while to implement your suggestion.  Your
> patch was again 2.6.3-rc1-mm1.  Unfortunately, the series
> of mm kernels from  2.6.3-rc1-mm1 thru 2.6.3-mm3 failed
> to run on STP.  
> 
> Judith made a patch (PLM 2766) by reverting
> the patch you referenced below using 2.6.5-rc1-mm1 
> (PLM 2760) as the original.  It compiled and ran without error.  The
> performance did not significantly improve. So I think we can conclude
> that readahead is not the problem.
> 
> 
Ok. that brings down my blood pressure :)

Also Badari/myself ran our DSS workload on 264mm1 with 8GB physical
memory(our database size is much larger, about 30GB) and found the
performance was steady. Yes this is a 8-way system.

Given that your database fits into memory, and your workload is
readonly, I wonder if there were any changes in radix-tree code
that could have regressed the performance? 

[About 6months back I had tried to optimize the radix tree handling, but
did not see much improvement, but again that was probably because my i/o
were hitting the disk most of the time.]

RP



> Here is the data (bigger is better on metric):
> 
> PLM..Kernel........Runid..CPUs..Thruput Metric 
> 2760 2.6.5-rc1-mm1 290149   8   86.82  
> 2766 2.6.5-rc1-mm1*290197   8   88.70 *(rev-readahead)
> 2760 2.6.5-rc1-mm1 290120   4   114.41 (worse than 8)
> 2757 2.6.5-rc1     290064   4   122.74  (baseline 4way) 
> (8way run on 2.6.5-rc1 hasn't completed yet)
> 2679 2.6.4 base    289421   8   137.2   (baseline 8way)
> 
> Meantime I attempted to do a binary search to 
> find the point where the mm kernel performance
> went bad.  It unfortunately appears to have
> occurred during the period of time that the
> mm kernels did not run on STP:
> 
> (These are all 8-way results)
> PLM..Kernel........RUNID...Thruput Metric
> 2656 2.6.3-mm4     288850   87.82
> [2.6.3-rc1-mm1 thru 2.6.3-mm3 fail to run on STP]
> 2603 2.6.2-mm1     290003   115.24
> 2582 2.6.2-rc2-mm1 290005   115.85
> 2564 2.6.1-mm5     289381   124.02
> 
> So there is a little hit between 2.6.1-mm5 and 2.6.2-rc2-mm1
> but a very big hit between 2.6.2.mm1 and 2.6.3-mm4.
> 
> Cliff is on vacation so it may take me a while to 
> track down patches to rix 2.6.3 mm kernels.  I see 
> a patch he tried with reaim on 2.6.3-mm1 (PLM2654) 
> so I'll give that a try.
> 
> It may take a while but I'll report back.  
> 
> Another thing I may not have mentioned before is that
> we use LVM in this workload.  We are also using LVM for
> our dbt2 (OLTP) postgreSQL workload.  Markm is doing
> some runs to see how the latest mm kernel compares 
> with baseline.  
> 
> Thanks.
> 
> On Mon, 2004-03-15 at 11:33, Ram Pai wrote:
> > On Mon, 2004-03-15 at 08:45, Mary Edie Meredith wrote:
> >  
> > > 
> > > 
> > > > And if that is indeed the case I'd be suspecting the CPU scheduler.  But
> > > > then, Meredith's profiles show almost completely idle CPUs.
> > > > 
> > > > The simplest way to hunt this down is the old binary-search-through-the-patches process.  But that requires some test which takes just a few minutes.
> > > 
> > > If you are referring to a binary search to find when the
> > > performance changed, I can do this with STP.  It may take 
> > > some time, but I'm willing.  I didnt want to do that if 
> > > the problem was a known problem.  
> > 
> > Based on your data, I dont think readahead patch is responsible. However
> > since you are seeing this only on mm kernel there is a small needle of
> > suspicion on the readahead patch.
> > 
> > How about reverting only the readahaed patch in mm tree and trying it
> > out? 
> > 
> > http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc1/2.6.3-rc1-mm1/broken-out/adaptive-lazy-readahead.patch
> > 
> > My DSS workload benchmarks always touches the disk because I have only
> > 4GB memory configured. I will give a try with 8GB memory and see if I
> > see any of your behavior. (I wont be able to put all my database in
> > memory)...
> > 
> > RP
> > 
> > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> > > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
