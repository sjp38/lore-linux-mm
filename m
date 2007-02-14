Date: Wed, 14 Feb 2007 15:35:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Use ZVC counters to establish exact size of dirtyable pages
In-Reply-To: <20070214151931.852766f9.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702141521090.3615@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702121014500.15560@schroedinger.engr.sgi.com>
 <20070213000411.a6d76e0c.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702130933001.23798@schroedinger.engr.sgi.com>
 <20070214142432.a7e913fa.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702141433190.3228@schroedinger.engr.sgi.com>
 <20070214151931.852766f9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007, Andrew Morton wrote:

> > > But this function can, I think, also return negative (ie: very large)
> > > numbers.  I don't think we handle that right.
> > 
> > How would that occur? The only way that I could think this would happen is 
> > if for some strange reason the highmem counts are bigger than the total 
> > counts.
> 
> Dunno, maybe it can't happen.  But those counters are approximate and
> perhaps there are edge cases which occur when differences between them are
> calculated and most of the pages are not free and not on the LRU.
> 
> It all needs careful thought.

That would require a deferral of counters greater than the size of low 
memory. And this is bound highmem so we are talking about 32 bit systems 
that are pretty limited in their number of processors and storage.

The maximum deferral of a counter is 2 * stat_threshhold * nr_cpus. The 
max that I know about on i386 are 64GB systems. The stat threshold for 
zones with a size <128MB is 10 but we have a range from -threashold .. 
+threashold. So for 8 processors a counter can be deferred at most for 8 * 
2 * 10 * 4 kbytes = 640 kbytes. Assume that all 3 counters are off the max 
then we reach 1920 kbytes. Lets say the highmem counters are also off by 
the max then we reach ~ 4 mbytes. This is still far less than the size of 
low memory.

One could now think that the LRU size could get to less than 4 mbytes 
in lowmem and then we would have a problem. But would such a system still be 
functional?

If you want to be safe we can make sure that the number returned is > 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
