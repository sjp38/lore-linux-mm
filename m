Message-ID: <41A7CC3D.9030405@yahoo.com.au>
Date: Sat, 27 Nov 2004 11:37:17 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH]: 1/4 batch mark_page_accessed()
References: <16800.47044.75874.56255@gargle.gargle.HOWL> <20041126185833.GA7740@logos.cnet>
In-Reply-To: <20041126185833.GA7740@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Nikita Danilov <nikita@clusterfs.com>, Linux Kernel Mailing List <Linux-Kernel@vger.kernel.org>, Andrew Morton <AKPM@Osdl.ORG>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> On Sun, Nov 21, 2004 at 06:44:04PM +0300, Nikita Danilov wrote:
> 
>>Batch mark_page_accessed() (a la lru_cache_add() and lru_cache_add_active()):
>>page to be marked accessed is placed into per-cpu pagevec
>>(page_accessed_pvec). When pagevec is filled up, all pages are processed in a
>>batch.
>>
>>This is supposed to decrease contention on zone->lru_lock.
> 
> 
> Here are the STP 8way results:
> 
> 8way:
> 

...

> kernbench 
> 
> Decreases performance significantly (on -j4 more notably), probably due to 
> the additional atomic operations as noted by Andrew:
> 
> kernel: nikita-b2                               kernel: patch-2.6.10-rc2
> Host: stp8-002                                  Host: stp8-003
> 

...

> 
> Average Half Load -j 4 Run:                     Average Half Load -j 4 Run:
> Elapsed Time 274.916                            Elapsed Time 245.026
> User Time 833.63                                User Time 832.34
> System Time 73.704                              System Time 73.41
> Percent CPU 335.8                               Percent CPU 373.6
> Context Switches 12984.8                        Context Switches 13427.4
> Sleeps 21459.2                                  Sleeps 21642

Do you think looks like it may be a CPU scheduling or disk/fs artifact?
Neither user nor system time are significantly worse, while the vanilla
kernel is using a lot more of the CPUs' power (ie waiting for IO less,
or becoming idle less often due to CPU scheduler balancing).

Aside: under-load conditions like this is actually something where the
CPU scheduler doesn't do brilliantly at currently. I attribute this to
probably most "performance tests" loading it up as much as possible.
I am (on and off) looking at improving performance in these conditions,
and am making some inroads.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
