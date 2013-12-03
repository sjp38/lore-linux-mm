Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD4C6B0062
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:06:09 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so19347009pde.34
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:06:08 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id xa2si49628983pab.345.2013.12.02.18.06.06
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 18:06:08 -0800 (PST)
Date: Tue, 3 Dec 2013 11:08:32 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 6/9] mm/rmap: use rmap_walk() in try_to_unmap()
Message-ID: <20131203020832.GD31168@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385624926-28883-7-git-send-email-iamjoonsoo.kim@lge.com>
 <20131202150107.7a814d0753356afc47b58b09@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131202150107.7a814d0753356afc47b58b09@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 02, 2013 at 03:01:07PM -0800, Andrew Morton wrote:
> On Thu, 28 Nov 2013 16:48:43 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > Now, we have an infrastructure in rmap_walk() to handle difference
> > from variants of rmap traversing functions.
> > 
> > So, just use it in try_to_unmap().
> > 
> > In this patch, I change following things.
> > 
> > 1. enable rmap_walk() if !CONFIG_MIGRATION.
> > 2. mechanical change to use rmap_walk() in try_to_unmap().
> > 
> > ...
> >
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -190,7 +190,7 @@ int page_referenced_one(struct page *, struct vm_area_struct *,
> >  
> >  int try_to_unmap(struct page *, enum ttu_flags flags);
> >  int try_to_unmap_one(struct page *, struct vm_area_struct *,
> > -			unsigned long address, enum ttu_flags flags);
> > +			unsigned long address, void *arg);
> 
> This change is ugly and unchangelogged.
> 
> Also, "enum ttu_flags flags" was nice and meaningful, but "void *arg"
> conveys far less information.  A suitable way to address this
> shortcoming is to document `arg' at the try_to_unmap_one() definition
> site.  try_to_unmap_one() doesn't actually have any documentation at
> this stage - let's please fix that?

Okay. I will add some comments.

> >
> > ...
> >
> > @@ -1509,6 +1510,11 @@ bool is_vma_temporary_stack(struct vm_area_struct *vma)
> >  	return false;
> >  }
> >  
> > +static int skip_vma_temporary_stack(struct vm_area_struct *vma, void *arg)
> > +{
> > +	return (int)is_vma_temporary_stack(vma);
> > +}
> 
> The (int) cast is unneeded - the compiler will turn a bool into an int.
> 
> Should this function (and rmap_walk_control.skip()) really be returning
> a bool?

Okay. Will do.

> 
> The name of this function is poor: "skip_foo" implies that the function
> will skip over a foo.  But that isn't what this function does.  Please
> choose something which accurately reflects the function's behavior.

Okay.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
