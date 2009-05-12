Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 097756B004F
	for <linux-mm@kvack.org>; Tue, 12 May 2009 02:43:49 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id d14so1832269and.26
        for <linux-mm@kvack.org>; Mon, 11 May 2009 23:44:30 -0700 (PDT)
Date: Tue, 12 May 2009 15:44:13 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH -mm] vmscan: report vm_flags in page_referenced()
Message-Id: <20090512154413.ca39795e.minchan.kim@barrios-desktop>
In-Reply-To: <1242109389.11251.310.camel@twins>
References: <20090430195439.e02edc26.akpm@linux-foundation.org>
	<49FB01C1.6050204@redhat.com>
	<20090501123541.7983a8ae.akpm@linux-foundation.org>
	<20090503031539.GC5702@localhost>
	<1241432635.7620.4732.camel@twins>
	<20090507121101.GB20934@localhost>
	<20090507151039.GA2413@cmpxchg.org>
	<20090507134410.0618b308.akpm@linux-foundation.org>
	<20090508081608.GA25117@localhost>
	<20090508125859.210a2a25.akpm@linux-foundation.org>
	<20090512025153.GB7518@localhost>
	<1242109389.11251.310.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 May 2009 08:23:09 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, 2009-05-12 at 10:51 +0800, Wu Fengguang wrote:
> > @@ -406,6 +408,7 @@ static int page_referenced_anon(struct p
> >                 if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
> >                         continue;
> >                 referenced += page_referenced_one(page, vma, &mapcount);
> > +               *vm_flags |= vma->vm_flags;
> >                 if (!mapcount)
> >                         break;
> >         }
> 
> Shouldn't that read:
> 
>   if (page_referenced_on(page, vma, &mapcount)) {
>     referenced++;
>     *vm_flags |= vma->vm_flags;
>   }
> 
> So that we only add the vma-flags of those vmas that actually have a
> young bit set?
> 
> In which case it'd be more at home in page_referenced_one():
> 
> @@ -381,6 +381,8 @@ out_unmap:
>  	(*mapcount)--;
>  	pte_unmap_unlock(pte, ptl);
>  out:
> +	if (referenced)
> +		*vm_flags |= vma->vm_flags;
>  	return referenced;
>  }

Good. I am ACK for peter's suggestion.
It can prevent setting vm_flag for worng vma which don't have the page.

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
