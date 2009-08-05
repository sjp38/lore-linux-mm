Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D5C96B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 03:53:13 -0400 (EDT)
Message-ID: <4A793B92.9040204@redhat.com>
Date: Wed, 05 Aug 2009 10:58:10 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost>
In-Reply-To: <20090805024058.GA8886@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 08/05/2009 05:40 AM, Wu Fengguang wrote:
> Greetings,
>
> Jeff Dike found that many KVM pages are being refaulted in 2.6.29:
>
> "Lots of pages between discarded due to memory pressure only to be
> faulted back in soon after. These pages are nearly all stack pages.
> This is not consistent - sometimes there are relatively few such pages
> and they are spread out between processes."
>
> The refaults can be drastically reduced by the following patch, which
> respects the referenced bit of all anonymous pages (including the KVM
> pages).
>
> However it risks reintroducing the problem addressed by commit 7e9cd4842
> (fix reclaim scalability problem by ignoring the referenced bit,
> mainly the pte young bit). I wonder if there are better solutions?
>    

How do you distinguish between kvm pages and non-kvm anonymous pages?  
More importantly, why should you?

Jeff, do you see the refaults on Nehalem systems?  If so, that's likely 
due to the lack of an accessed bit on EPT pagetables.  It would be 
interesting to compare with Barcelona  (which does).

If that's indeed the case, we can have the EPT ageing mechanism give 
pages a bit more time around by using an available bit in the EPT PTEs 
to return accessed on the first pass and not-accessed on the second.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
