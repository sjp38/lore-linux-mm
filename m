Date: Tue, 30 Jul 2002 12:11:03 -0400
Subject: Re: [RFC] start_aggressive_readahead
Content-Type: text/plain; charset=US-ASCII; format=flowed
Mime-Version: 1.0 (Apple Message framework v482)
From: Scott Kaplan <sfkaplan@cs.amherst.edu>
In-Reply-To: <3D44F01A.C7AAA1B4@zip.com.au>
Message-Id: <F245ABF4-A3D6-11D6-9922-000393829FA4@cs.amherst.edu>
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Monday, July 29, 2002, at 03:34 AM, Andrew Morton wrote:

> Scott Kaplan wrote:
>> In other words, it's not hits that should necessarily make you grow
>> the cache -- it's the evidence that there will be an *increase* in hits 
>> if
>> you do.
>
> Ah, but if we're not getting hits in the readahead window
> then we're getting misses.  And misses shrink the window.

Yes, and that's the wrong thing to do.  If you are getting hits, you 
should try *skrinking* the window to see if there is a reduction in hits.  
If there is no reduction, you can capture just as many hits with a smaller 
window -- the extra space was superfluous.  If you're getting misses, you 
should try to *grow* the window (to commit an awful case of verbing) in an 
attempt to turn such misses into hits.  If growing the window doesn't 
decrease the misses, then you may need too large of an increase to cache 
those pages successfully.  If growing the window does decrease the misses,
  then keep growing until you don't see a decrease.

What's I'm describing here has its own major pitfalls:

1) It considers only the read-ahead pool.  Shrinking or growing the window 
could also have an effect on the hits and misses to the used pool of pages.

2) You can get trapped in local minima.  Part of what makes memory 
allocation hard under any realistic on-line replacement policy is that 
changes in hits/misses are non-monotonic.  For example, if we are 
observing misses to evicted read-ahead pages and try to grow the cache in 
response, we may not see any improvement unless we grow the cache 
sufficiently, and then get diminishing returns if we grow it beyond that 
point.  To avoid this kind of problem, you need more than just hit and 
miss counts -- you need reference distributions.

> I tend to think that if pages at the tail of the LRU are being
> referenced with any frequency we've goofed anyway.

I disagree.  Referencing things at the tail of the LRU is the sign of 
having done something *right*.  It means that for a workload with 
substantial memory needs, the VM system is holding onto pages *just long 
enough*, and no longer, to ensure that they are cached before reuse.  It 
means that the workload is leaving some pages unused for some time, but 
consistently revisiting those pages as part of a phase change that is near 
the scale of the memory size.  It a case where LRU and its approximations 
perform about as well as possible.  Remember that the ordering of resident 
pages doesn't need to be very exact.  A policy can have a completely 
goofed notion of which pages will be used soon; if they're all resident, 
it doesn't matter that the ordering among the resident pages was poor.  
What counts is that they were resident.  When you evict pages poorly, that'
s when the mis-ordering is trouble:  Referencing pages that have just been 
reclaimed is when we've really goofed.  Otherwise, it's fine.

This comment serves to highlight a point:  Memory pressure is not merely 
defined by the amount of paging or the number of new page allocations.  It 
should also be defined by the number of references to pages that *nearly* 
got evicted.  Those references represent behavior that is on the scale of 
the memory size, where good and bad decisions make a different.  Therefore,
  those are events relevant to the VM and the physical memory it is 
managing, and should contribute to the perception that there is pressure 
on the memory resources.

Scott
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (Darwin)
Comment: For info see http://www.gnupg.org

iD8DBQE9Rrqa8eFdWQtoOmgRAq8oAJ9fJ+AlaXcfSc3U5xLIQQITPAc8QwCfQGK5
NvLZM39UauOSZ5TSjZYPH6s=
=ovjL
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
