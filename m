Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 279D16B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 02:34:34 -0500 (EST)
Received: by wghb13 with SMTP id b13so17986241wgh.0
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 23:34:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n17si5728087wjr.109.2015.02.26.23.34.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Feb 2015 23:34:32 -0800 (PST)
Message-ID: <54F01E02.1090007@suse.cz>
Date: Fri, 27 Feb 2015 08:34:26 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <54EED9A7.5010505@suse.cz> <alpine.DEB.2.10.1502261902580.24302@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502261902580.24302@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org

On 02/27/2015 04:09 AM, David Rientjes wrote:
> On Thu, 26 Feb 2015, Vlastimil Babka wrote:
> 
>> > to restrict an allocation to a local node, but remove GFP_TRANSHUGE and
>> > it's obscurity.  Instead, we require that a caller clear __GFP_WAIT if it
>> > wants to avoid reclaim.
>> > 
>> > This allows the aforementioned functions to actually reclaim as they
>> > should.  It also enables any future callers that want to do
>> > __GFP_THISNODE but also __GFP_NORETRY && __GFP_NOWARN to reclaim.  The
>> > rule is simple: if you don't want to reclaim, then don't set __GFP_WAIT.
>> 
>> So, I agree with the intention, but this has some subtle implications that
>> should be mentioned/decided. The check for GFP_THISNODE in
>> __alloc_pages_slowpath() comes earlier than the check for __GFP_WAIT. So the
>> differences will be:
>> 
>> 1) We will now call wake_all_kswapds(), unless __GFP_NO_KSWAPD is passed, which
>> is only done for hugepages and some type of i915 allocation. Do we want the
>> opportunistic attempts from slab to wake up kswapds or do we pass the flag?
>> 
>> 2) There will be another attempt on get_page_from_freelist() with different
>> alloc_flags than in the fast path attempt. Without __GFP_WAIT (and also, again,
>> __GFP_KSWAPD, since your commit b104a35d32, which is another subtle check for
>> hugepage allocations btw), it will consider the allocation atomic and add
>> ALLOC_HARDER flag, unless __GFP_NOMEMALLOC is in __gfp_flags - it seems it's
>> generally not. It will also clear ALLOC_CPUSET, which was the concern of
>> b104a35d32. However, if I look at __cpuset_node_allowed(), I see that it's
>> always true for __GFP_THISNODE, which makes me question commit b104a35d32 in
>> light of your patch 2/2 and generally the sanity of all these flags and my
>> career choice.
>> 
> 
> Do we do either of these?  gfp_exact_node() sets __GFP_THISNODE and clears 
> __GFP_WAIT which will make the new conditional trigger immediately for 
> NUMA configs.

Oh, right. I missed the new trigger. My sanity and career is saved!

Well, no... the flags are still a mess. Aren't GFP_TRANSHUGE | __GFP_THISNODE
allocations still problematic after this patch and 2/2? Those do include
__GFP_WAIT (unless !defrag). So with only patch 2/2 without 1/2 they would match
GFP_THISNODE and bail out (not good for khugepaged at least...). With both
patches they won't bail out and __GFP_NO_KSWAPD will prevent most of the stuff
described above, including clearing ALLOC_CPUSET. But __cpuset_node_allowed()
will allow it to allocate anywhere anyway thanks to the newly passed
__GFP_THISNODE, which would be a regression of what b104a35d32 fixed... unless
I'm missing something else that prevents it, which wouldn't surprise me at all.

There's this outdated comment:

 * The __GFP_THISNODE placement logic is really handled elsewhere,
 * by forcibly using a zonelist starting at a specified node, and by
 * (in get_page_from_freelist()) refusing to consider the zones for
 * any node on the zonelist except the first.  By the time any such
 * calls get to this routine, we should just shut up and say 'yes'.

AFAIK the __GFP_THISNODE zonelist contains *only* zones from the single node and
there's no other "refusing". And I don't really see why __GFP_THISNODE should
have this exception, it feels to me like "well we shouldn't reach this but we
are not sure, so let's play it safe". So maybe we could just remove this
exception? I don't think any other user of __GFP_THISNODE | __GFP_WAIT user
relies on this allowed memset violation?

> Existing callers of GFP_KERNEL | __GFP_THISNODE aren't impacted and 
> net/openvswitch/flow.c is mentioned in the changelog as actually wanting 
> GFP_NOWAIT | __GFP_THISNODE so that this early check still fails.
> 
>> Ugh :)
>> 
> 
> Ugh indeed.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
