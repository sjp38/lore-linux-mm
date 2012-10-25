Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 043CB6B0071
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 16:22:02 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1576790pad.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 13:22:02 -0700 (PDT)
Date: Thu, 25 Oct 2012 13:22:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in
 numa_maps
In-Reply-To: <1351175972.12171.14.camel@twins>
Message-ID: <alpine.DEB.2.00.1210251317190.17938@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com> <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com> <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com> <CA+1xoqe74R6DX8Yx2dsp1MkaWkC1u6yAEd8eWEdiwi88pYdPaw@mail.gmail.com> <alpine.DEB.2.00.1210241633290.22819@chino.kir.corp.google.com>
 <CA+1xoqd6MEFP-eWdnWOrcz2EmE6tpd7UhgJyS8HjQ8qrGaMMMw@mail.gmail.com> <alpine.DEB.2.00.1210241659260.22819@chino.kir.corp.google.com> <1351167554.23337.14.camel@twins> <1351175972.12171.14.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 25 Oct 2012, Peter Zijlstra wrote:

> So I think the below should work, we hold the spinlock over both rb-tree
> modification as sp free, this makes mpol_shared_policy_lookup() which
> returns the policy with an incremented refcount work with just the
> spinlock.
> 
> Comments?
> 

It's rather unfortunate that we need to protect modification with a 
spinlock and a mutex but since sharing was removed in commit 869833f2c5c6 
("mempolicy: remove mempolicy sharing") it requires that sp_alloc() is 
blockable to do the whole mpol_new() and rebind if necessary, which could 
require mm->mmap_sem; it's not as simple as just converting all the 
allocations to GFP_ATOMIC.

It looks as though there is no other alternative other than protecting 
modification with both the spinlock and mutex, which is a clever 
solution, so it looks good to me, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
