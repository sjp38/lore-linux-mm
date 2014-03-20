Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 63F6E6B0188
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 21:09:51 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so145066pbb.40
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 18:09:51 -0700 (PDT)
Received: from lgeamrelo05.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id wt1si157217pbc.290.2014.03.19.18.09.48
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 18:09:50 -0700 (PDT)
Date: Thu, 20 Mar 2014 10:09:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] Volatile Ranges (v11)
Message-ID: <20140320010954.GE16478@bbox>
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
 <20140318151113.GA10724@gmail.com>
 <CALAqxLV=uRV825taKrnH2=p_kAf5f1PbQ7=J5MopFt9ATj=a3A@mail.gmail.com>
 <20140319004918.GB13475@bbox>
 <20140319101202.GE26358@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140319101202.GE26358@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello,

On Wed, Mar 19, 2014 at 11:12:02AM +0100, Jan Kara wrote:
> On Wed 19-03-14 09:49:18, Minchan Kim wrote:
> > On Tue, Mar 18, 2014 at 11:07:50AM -0700, John Stultz wrote:
> > > On Tue, Mar 18, 2014 at 8:11 AM, Minchan Kim <minchan@kernel.org> wrote:
> > > > 1) SIGBUS
> > > >
> > > > It's one of the arguable issue because some user want to get a
> > > > SIGBUS(ex, Firefox) while other want a just zero page(ex, Google
> > > > address sanitizer) without signal so it should be option.
> > > >
> > > >         int vrange(start, len, VRANGE_VOLATILE|VRANGE_ZERO, &purged);
> > > >         int vrange(start, len, VRANGE_VOLATILE|VRANGE_SIGNAL, &purged);
> > > 
> > > So, the zero-fill on volatile access feels like a *very* special case
> > > to me, since a null page could be valid data in many cases. Since
> > > support/interest for volatile ranges has been middling at best, I want
> > > to start culling the stranger use cases. I'm open in the future to
> > > adding a special flag or something if it really make sense, but at
> > > this point, lets just get the more general volatile range use cases
> > > supported.
> > 
> > I'm not sure it's special case. Because some user could reserve
> > a big volatile VMA and want to use the range by circle queue for
> > caching so overwriting could happen easily.
> > We should call vrange(NOVOLATILE) to prevent SIGBUS right before
> > overwriting. I feel it's unnecessary overhead and we could avoid
> > the cost with VRANGE_ZERO.
> > Do you think this usecase would be rare?
>   If I understand it correctly the buffer would be volatile all the time
> and userspace would like to opportunistically access it. Hum, but then with
> your automatic zero-filling it could see half of the page with data and
> half of the page zeroed out (the page got evicted in the middle of
> userspace reading it). I don't think that's a very comfortable interface to
> work with (you would have to very carefully verify the data you've read is
> really valid). And frankly in most cases I'm afraid the application would
> fail to do proper verification and crash randomly under memory pressure. So
> I wouldn't provide VRANGE_ZERO unless I come across real people for which
> avoiding marking the range as NONVOLATILE is a big deal and they are OK with
> handling all the odd situations that can happen.

Plaes think following usecase.

Let's assume big volatile cacne.
If there is request for cache, it should find a object in a cache
and if it found, it should call vrange(NOVOLATILE) right before
passing it to the user and investigate it was purged or not.
If it wasn't purged, cache manager could pass the object to the user.
But it's circular cache so if there is no request from user, cache manager
always overwrites objects so it could encounter SIGBUS easily
so as current sematic, cache manager always should call vrange(NOVOLATILE)
right before the overwriting. Otherwise, it should register SIGBUS handler
to unmark volatile by page unit. SIGH.

If we support VRANGE_ZERO, cache manager could overwrite object without
SIGBUS handling or vrange(NOVOLATILE) call. Just need is vrange(NOVOLATILE)
call while cache manager pass it to the user.

> 
> That being said I agree with you that it makes sense to extend the syscall
> with flags argument so that we have some room for different modifications
> of the functionality.
> 
> 								Honza
> -- 
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
