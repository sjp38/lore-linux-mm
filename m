Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id A805B6B00D4
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 20:24:12 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so5620120pbb.3
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 17:24:12 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id kr8si31621832pbc.32.2014.06.09.17.24.08
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 17:24:10 -0700 (PDT)
Date: Tue, 10 Jun 2014 09:24:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/vmscan.c: avoid recording the original scan targets
 in shrink_lruvec()
Message-ID: <20140610002410.GB8171@bbox>
References: <1402320436-22270-1-git-send-email-slaoub@gmail.com>
 <20140609232459.GA8171@bbox>
 <1402359051.22759.7.camel@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402359051.22759.7.camel@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: mgorman@suse.de, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 10, 2014 at 08:10:51AM +0800, Chen Yucong wrote:
> On Tue, 2014-06-10 at 08:24 +0900, Minchan Kim wrote:
> > Hello,
> > 
> > On Mon, Jun 09, 2014 at 09:27:16PM +0800, Chen Yucong wrote:
> > > Via https://lkml.org/lkml/2013/4/10/334 , we can find that recording the
> > > original scan targets introduces extra 40 bytes on the stack. This patch
> > > is able to avoid this situation and the call to memcpy(). At the same time,
> > > it does not change the relative design idea.
> > > 
> > > ratio = original_nr_file / original_nr_anon;
> > > 
> > > If (nr_file > nr_anon), then ratio = (nr_file - x) / nr_anon.
> > >  x = nr_file - ratio * nr_anon;
> > > 
> > > if (nr_file <= nr_anon), then ratio = nr_file / (nr_anon - x).
> > >  x = nr_anon - nr_file / ratio;
> > 
> > Nice cleanup!
> > 
> > Below one nitpick.
> > 
> 
> > 
> > If both nr_file and nr_anon are zero, then the nr_anon could be zero
> > if HugePage are reclaimed so that it could pass the below check
> > 
> >         if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
> > 
> > 
> The Mel Gorman's patch has already handled this situation you're
> describing. It's called:
>  
> mm: vmscan: use proportional scanning during direct reclaim and full
> scan at DEF_PRIORITY

It seems I was far away from vmscan.c for a while.
Thanks for the pointing out. So,

Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
