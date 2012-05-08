Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 1AF5F6B0081
	for <linux-mm@kvack.org>; Tue,  8 May 2012 14:57:44 -0400 (EDT)
Date: Tue, 8 May 2012 14:51:49 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH] frontswap (v15). +--------+ |zsmalloc| +--------+
 +---------+    +------------+          | | swap    +--->| frontswap  +
          v +---------+    +------------|      +--------+  +----->| zcache |
 +--------+
Message-ID: <20120508185149.GA8601@phenom.dumpdata.com>
References: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, ngupta@vflare.org, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, aarcange@redhat.com, dhowells@redhat.com, riel@redhat.com, JBeulich@novell.com

On Fri, Apr 20, 2012 at 05:44:09PM -0400, Konrad Rzeszutek Wilk wrote:
> [Example usage, others are tmem, ramster, and RFC KVM]

Bummer that the little ASCII art got all eaten up in the subject.

> 
> Frontswap provides a "transcendent memory" interface for swap pages.
> In some environments, dramatic performance savings may be obtained because
> swapped pages are saved in RAM (or a RAM-like device) instead of a swap disk.
> A nice overview of it is visible at: http://lwn.net/Articles/454795/
.. snip.
> The last time these patches were posted [https://lkml.org/lkml/2011/10/27/206]
> the discussion got very technical - and the feeling I got was that:
>  - The API is too simple. The hard decisions (what to do when memory
>    is low and the pages are mlocked, disk is faster than the CPU compression,
>    need some way to shed pages when OOM conditions are close by, which pages
>    to compress) are left to the backends. Adding VM pressure hooks could solve 
>    some (if not all) of these issues? Dan is working on figuring this out for
>    zcache.
>  - the backends - like zcache - are tied in how this API is used. This means
>    that to get zcache out of staging need to think of the frontswap and
>    zcache (and also the other backends).

So I am in a little bind and would appreciate some feedback. Both Seth and Dan
have been working on finding the corner pieces of the zcache and seeing under
which workload it works badly (and good) and adding in the appropriate feedback
mechanism (by using the data that vm core is exporting). This is to keep the
size of zcache pool a manageable size where it won't impact negatively the rest
of the system (as zcache uses precious memory and in some cases it might make
sense for it to bypass some pages, while in other the opposite hold). But for
virtualization cases the "quality" of pages (so active, was-active) is not
that important - as the virtualized backend can de-duplicate large amount of
guest pages.

On a naive side this looks to be dealing with discriminate tastes (zcache which
needs high quality pages) and less so (xen tmem which doesn't care about which
type) so perhaps the frontswap should know which backend it is dealing with
and based on that feed it certain pages. Or it can be simple and just feed it
to the backend and the backend can decide to skip on the page (or not).

Which brings the next point - perhaps this API should not be in the swap-space.
Instead much closer to the core VM? This way the heuristics that are attempted
there do not have to be attempted in the discriminating cases (zcache)?

Either way, for this to work some type of "glue" between the {VM,swapcache} ->
{zcache, tmem, ramster} needs to be there - either in form of this API or
some other? Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
