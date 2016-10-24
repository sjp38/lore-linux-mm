Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA7D6B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:01:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c78so34550217wme.4
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 09:01:39 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id id7si16813580wjb.231.2016.10.24.09.01.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 09:01:37 -0700 (PDT)
Date: Mon, 24 Oct 2016 12:01:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/5] lib: radix-tree: native accounting and tracking of
 special entries
Message-ID: <20161024160122.GA2125@cmpxchg.org>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
 <20161019172428.7649-4-hannes@cmpxchg.org>
 <20161020223308.GN23194@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161020223308.GN23194@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Dave,

On Fri, Oct 21, 2016 at 09:33:08AM +1100, Dave Chinner wrote:
> On Wed, Oct 19, 2016 at 01:24:26PM -0400, Johannes Weiner wrote:
> > With this in place, the next patch can restore refault detection in
> > single-page files. It will also move the shadow count from the upper
> > bits of count to the new special counter, and then shrink count to a
> > char as well; the growth of struct radix_tree_node is temporary.

[...]

> > @@ -90,9 +91,10 @@ enum radix_tree_tags {
> >  #define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
> >  
> >  struct radix_tree_node {
> > -	unsigned char	shift;	/* Bits remaining in each slot */
> > -	unsigned char	offset;	/* Slot offset in parent */
> > -	unsigned int	count;
> > +	unsigned char	shift;		/* Bits remaining in each slot */
> > +	unsigned char	offset;		/* Slot offset in parent */
> > +	unsigned int	count;		/* Total entry count */
> > +	unsigned char	special;	/* Special entry count */
> 
> How about putting the new char field into the implicit hole between
> offset and count? pahole is your friend here:
> 
> struct radix_tree_node {
>         unsigned char              shift;                /*     0     1 */
>         unsigned char              offset;               /*     1     1 */
> 
>         /* XXX 2 bytes hole, try to pack */
> 
>         unsigned int               count;                /*     4     4 */
> .....

The next patch turns `count' into an unsigned char again, so the hole
is only temporary.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
