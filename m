Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4851E900138
	for <linux-mm@kvack.org>; Sun, 28 Aug 2011 23:01:23 -0400 (EDT)
Subject: Re: [patch 2/2]slub: add a type for slab partial list position
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <1314147472.29510.25.camel@sli10-conroe>
References: <1314059823.29510.19.camel@sli10-conroe>
	 <alpine.DEB.2.00.1108231023470.21267@router.home>
	 <1314147472.29510.25.camel@sli10-conroe>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 29 Aug 2011 11:06:27 +0800
Message-ID: <1314587187.4523.55.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Shaohua" <shaohua.li@intel.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, "penberg@kernel.org" <penberg@kernel.org>, "Chen, Tim C" <tim.c.chen@intel.com>

On Wed, 2011-08-24 at 08:57 +0800, Li, Shaohua wrote:
> On Tue, 2011-08-23 at 23:25 +0800, Christoph Lameter wrote:
> > On Tue, 23 Aug 2011, Shaohua Li wrote:
> > 
> > > Adding slab to partial list head/tail is sensentive to performance.
> > > So adding a type to document it to avoid we get it wrong.
> > 
> > I think that if you want to make it more descriptive then using the stats
> > values (DEACTIVATE_TO_TAIL/HEAD) would avoid having to introduce an
> > additional enum and it would also avoid the if statement in the stat call.
> ok, that's better.
> 
> Subject: slub: explicitly document position of inserting slab to partial list
> 
> Adding slab to partial list head/tail is sensitive to performance.
> So explicitly uses DEACTIVATE_TO_TAIL/DEACTIVATE_TO_HEAD to document
> it to avoid we get it wrong.

Frankly speaking, using DEACTIVATE_TO_TAIL/DEACTIVATE_TO_HEAD in
slab_alloc, slab_free make code hard to understand. Just adding some
comments will be more clear and understandable. like the following: 
Do you think so? 


--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2377,6 +2377,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
                 */
                if (unlikely(!prior)) {
                        remove_full(s, page);
+                       /* only one object left in the page, so add to partial tail */
                        add_partial(n, page, 1);
                        stat(s, FREE_ADD_PARTIAL);
                }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
