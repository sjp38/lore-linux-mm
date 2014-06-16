Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1F66B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 19:45:44 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so2294048pde.38
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 16:45:44 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id kr8si12518880pbc.32.2014.06.16.16.45.42
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 16:45:43 -0700 (PDT)
Date: Tue, 17 Jun 2014 08:46:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
Message-ID: <20140616234608.GB18790@bbox>
References: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
 <1402923474.3958.34.camel@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402923474.3958.34.camel@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 16, 2014 at 08:57:54PM +0800, Chen Yucong wrote:
> On Mon, 2014-06-09 at 21:27 +0800, Chen Yucong wrote:
> > Via https://lkml.org/lkml/2013/4/10/334 , we can find that recording the
> > original scan targets introduces extra 40 bytes on the stack. This patch
> > is able to avoid this situation and the call to memcpy(). At the same time,
> > it does not change the relative design idea.
> > 
> > ratio = original_nr_file / original_nr_anon;
> > 
> > If (nr_file > nr_anon), then ratio = (nr_file - x) / nr_anon.
> >  x = nr_file - ratio * nr_anon;
> > 
> > if (nr_file <= nr_anon), then ratio = nr_file / (nr_anon - x).
> >  x = nr_anon - nr_file / ratio;
> > 
> Hi Andrew Morton,
> 
> I think the patch
>  
> [PATCH]
> mm-vmscanc-avoid-recording-the-original-scan-targets-in-shrink_lruvec-fix.patch
> 
> which I committed should be discarded. Because It have some critical
> defects.
>     1) If we want to solve the divide-by-zero and unfair problems, it
> needs to two variables for recording the ratios.
>  
>     2) For "x = nr_file - ratio * nr_anon", the "x" is likely to be a
> negative number. we can assume:
> 
>       nr[LRU_ACTIVE_FILE] = 30
>       nr[LRU_INACTIVE_FILE] = 30
>       nr[LRU_ACTIVE_ANON] = 0
>       nr[LRU_INACTIVE_ANON] = 40
> 
>       ratio = 60/40 = 3/2
> 
> When the value of (nr_reclaimed < nr_to_reclaim) become false, there are
> the following results:
>       nr[LRU_ACTIVE_FILE] = 15
>       nr[LRU_INACTIVE_FILE] = 15
>       nr[LRU_ACTIVE_ANON] = 0
>       nr[LRU_INACTIVE_ANON] = 25
>  
>       nr_file = 30
>       nr_anon = 25
> 
>       x = 30 - 25 * (3/2) = 30 - 37.5 = -7.5.
> 
> The result is too terrible. 
>    
>    3) This method is less accurate than the original, especially for the
> qualitative difference between FILE and ANON that is very small.

Yes, 3 changed old behavior. I'm ashamed but wanted to clean it up.
Is it worth to clean it up?
