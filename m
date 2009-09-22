Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2ADEC6B0055
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 14:54:27 -0400 (EDT)
Received: by bwz24 with SMTP id 24so14532bwz.38
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 11:54:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090922135453.GF25965@csn.ul.ie>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie>
	 <1253624054-10882-3-git-send-email-mel@csn.ul.ie>
	 <84144f020909220638l79329905sf9a35286130e88d0@mail.gmail.com>
	 <20090922135453.GF25965@csn.ul.ie>
Date: Tue, 22 Sep 2009 21:54:33 +0300
Message-ID: <84144f020909221154x820b287r2996480225692fad@mail.gmail.com>
Subject: Re: [PATCH 2/4] slqb: Record what node is local to a kmem_cache_cpu
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Tue, Sep 22, 2009 at 4:54 PM, Mel Gorman <mel@csn.ul.ie> wrote:
>> I don't understand how the memory leak happens from the above
>> description (or reading the code). page_to_nid() returns some crazy
>> value at free time?
>
> Nope, it isn't a leak as such, the allocator knows where the memory is.
> The problem is that is always frees remote but on allocation, it sees
> the per-cpu list is empty and calls the page allocator again. The remote
> lists just grow.
>
>> The remote list isn't drained properly?
>
> That is another way of looking at it. When the remote lists get to a
> watermark, they should drain. However, it's worth pointing out if it's
> repaired in this fashion, the performance of SLQB will suffer as it'll
> never reuse the local list of pages and instead always get cold pages
> from the allocator.

I worry about setting c->local_nid to the node of the allocated struct
kmem_cache_cpu. It seems like an arbitrary policy decision that's not
necessarily the best option and I'm not totally convinced it's correct
when cpusets are configured. SLUB seems to do the sane thing here by
using page allocator fallback (which respects cpusets AFAICT) and
recycling one slab slab at a time.

Can I persuade you into sending me a patch that fixes remote list
draining to get things working on PPC? I'd much rather wait for Nick's
input on the allocation policy and performance.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
