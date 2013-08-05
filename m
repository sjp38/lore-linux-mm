Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 989CE6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 04:50:32 -0400 (EDT)
Date: Mon, 5 Aug 2013 17:50:41 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/4] mm, page_alloc: add likely macro to help compiler
 optimization
Message-ID: <20130805085041.GG27240@lge.com>
References: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20130802162722.GA29220@dhcp22.suse.cz>
 <20130802204710.GX715@cmpxchg.org>
 <20130802213607.GA4742@dhcp22.suse.cz>
 <20130805081008.GF27240@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130805081008.GF27240@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Mon, Aug 05, 2013 at 05:10:08PM +0900, Joonsoo Kim wrote:
> Hello, Michal.
> 
> On Fri, Aug 02, 2013 at 11:36:07PM +0200, Michal Hocko wrote:
> > On Fri 02-08-13 16:47:10, Johannes Weiner wrote:
> > > On Fri, Aug 02, 2013 at 06:27:22PM +0200, Michal Hocko wrote:
> > > > On Fri 02-08-13 11:07:56, Joonsoo Kim wrote:
> > > > > We rarely allocate a page with ALLOC_NO_WATERMARKS and it is used
> > > > > in slow path. For making fast path more faster, add likely macro to
> > > > > help compiler optimization.
> > > > 
> > > > The code is different in mmotm tree (see mm: page_alloc: rearrange
> > > > watermark checking in get_page_from_freelist)
> > > 
> > > Yes, please rebase this on top.
> > > 
> > > > Besides that, make sure you provide numbers which prove your claims
> > > > about performance optimizations.
> > > 
> > > Isn't that a bit overkill?  We know it's a likely path (we would
> > > deadlock constantly if a sizable portion of allocations were to ignore
> > > the watermarks).  Does he have to justify that likely in general makes
> > > sense?
> > 
> > That was more a generic comment. If there is a claim that something
> > would be faster it would be nice to back that claim by some numbers
> > (e.g. smaller hot path).
> > 
> > In this particular case, unlikely(alloc_flags & ALLOC_NO_WATERMARKS)
> > doesn't make any change to the generated code with gcc 4.8.1 resp.
> > 4.3.4 I have here.
> > Maybe other versions of gcc would benefit from the hint but changelog
> > didn't tell us. I wouldn't add the anotation if it doesn't make any
> > difference for the resulting code.
> 
> Hmm, Is there no change with gcc 4.8.1 and 4.3.4?
> 
> I found a change with gcc 4.6.3 and v3.10 kernel.

Ah... I did a test on mmotm (Johannes's git) and found that this patch
doesn't make any effect. I guess, a change from Johannes ('rearrange
watermark checking in get_page_from_freelist') already makes better code
for !ALLOC_NO_WATERMARKS case. IMHO, although there is no effect, it is
better to add likely macro, because arrangement can be changed from time
to time without any consideration of assembly code generation. How about
your opinion, Johannes and Michal?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
