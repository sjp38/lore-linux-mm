Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 87D216B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 01:38:59 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so1130440pad.3
        for <linux-mm@kvack.org>; Sun, 06 Sep 2015 22:38:59 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id rb8si18191215pab.112.2015.09.06.22.38.57
        for <linux-mm@kvack.org>;
        Sun, 06 Sep 2015 22:38:58 -0700 (PDT)
Date: Mon, 7 Sep 2015 14:38:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: slab:Fix the unexpected index mapping result of
 kmalloc_size(INDEX_NODE + 1)
Message-ID: <20150907053855.GC21207@js1304-P5Q-DELUXE>
References: <OF591717D2.930C6B40-ON48257E7D.0017016C-48257E7D.0020AFB4@zte.com.cn>
 <20150729152803.67f593847050419a8696fe28@linux-foundation.org>
 <20150731001827.GA15029@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1507310845440.11895@east.gentwo.org>
 <20150807015609.GB15802@js1304-P5Q-DELUXE>
 <20150904132902.5d62a09077435d742d6f2f1b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150904132902.5d62a09077435d742d6f2f1b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, liu.hailong6@zte.com.cn, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, jiang.xuexin@zte.com.cn, David Rientjes <rientjes@google.com>

On Fri, Sep 04, 2015 at 01:29:02PM -0700, Andrew Morton wrote:
> On Fri, 7 Aug 2015 10:56:09 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > On Fri, Jul 31, 2015 at 08:57:35AM -0500, Christoph Lameter wrote:
> > > On Fri, 31 Jul 2015, Joonsoo Kim wrote:
> > > 
> > > > I don't think that this fix is right.
> > > > Just "kmalloc_size(INDEX_NODE) * 2" looks insane because it means 192 * 2
> > > > = 384 on his platform. Why we need to check size is larger than 384?
> > > 
> > > Its an arbitrary boundary. Making it large ensures that the smaller caches
> > > stay operational and do not fall back to page sized allocations.
> > 
> > If it is an arbitrary boundary, it would be better to use static value
> > such as "256" rather than kmalloc_size(INDEX_NODE) * 2.
> > Value of kmalloc_size(INDEX_NODE) * 2 can be different in some archs
> > and it is difficult to manage such variation. It would cause this kinds of
> > bug again. I recommand following change. How about it?
> > 
> > -       if (size >= kmalloc_size(INDEX_NODE + 1)
> > +       if (!slab_early_init &&
> > +               size >= kmalloc_size(INDEX_NODE) &&
> > +               size >= 256
> > 
> 
> Guys, can we please finish this off?  afaict Jianxuexin's original
> patch is considered undesirable, but his machine is still going BUG.

Hello,

Sure. It should be fixed soon. If Christoph agree with my approach, I
will make it to proper formatted patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
