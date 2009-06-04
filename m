Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 00A6F6B004F
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 01:20:25 -0400 (EDT)
Date: Thu, 4 Jun 2009 07:27:38 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [10/16] HWPOISON: Handle poisoned pages in set_page_dirty()
Message-ID: <20090604052738.GR1065@one.firstfloor.org>
References: <20090603846.816684333@firstfloor.org> <20090603184644.190E71D0281@basil.firstfloor.org> <20090604003621.GA12210@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090604003621.GA12210@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 08:36:21AM +0800, Wu Fengguang wrote:
> On Thu, Jun 04, 2009 at 02:46:43AM +0800, Andi Kleen wrote:
> > 
> > Bail out early in set_page_dirty for poisoned pages. We don't want any
> > of the dirty accounting done or file system write back started, because
> > the page will be just thrown away.
>  
> I'm afraid this patch is not necessary and could be harmful.
> 
> It is not necessary because a poisoned page will normally already be
> isolated from page cache, or likely cannot be isolated because it has
> dirty buffers.

Hmm I think I had a case when I originally wrote the code where it was needed.
But I can't clearly remember now what it was.

But you're right the page cache isolation should normally take care of it.

> It is harmful because it put the page into dirty state without queuing
> it for IO by moving it to s_io. When more normal pages are dirtied
> later, __set_page_dirty_nobuffers() won't move the inode into s_io,
> hence delaying the writeback of good pages for arbitrary long time.

That's a good point.

I dropped the patch for now.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
