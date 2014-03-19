Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id AC2836B0158
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 06:12:06 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id a1so6989320wgh.20
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 03:12:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cr4si14213952wjc.137.2014.03.19.03.12.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Mar 2014 03:12:05 -0700 (PDT)
Date: Wed, 19 Mar 2014 11:12:02 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/3] Volatile Ranges (v11)
Message-ID: <20140319101202.GE26358@quack.suse.cz>
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
 <20140318151113.GA10724@gmail.com>
 <CALAqxLV=uRV825taKrnH2=p_kAf5f1PbQ7=J5MopFt9ATj=a3A@mail.gmail.com>
 <20140319004918.GB13475@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140319004918.GB13475@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed 19-03-14 09:49:18, Minchan Kim wrote:
> On Tue, Mar 18, 2014 at 11:07:50AM -0700, John Stultz wrote:
> > On Tue, Mar 18, 2014 at 8:11 AM, Minchan Kim <minchan@kernel.org> wrote:
> > > 1) SIGBUS
> > >
> > > It's one of the arguable issue because some user want to get a
> > > SIGBUS(ex, Firefox) while other want a just zero page(ex, Google
> > > address sanitizer) without signal so it should be option.
> > >
> > >         int vrange(start, len, VRANGE_VOLATILE|VRANGE_ZERO, &purged);
> > >         int vrange(start, len, VRANGE_VOLATILE|VRANGE_SIGNAL, &purged);
> > 
> > So, the zero-fill on volatile access feels like a *very* special case
> > to me, since a null page could be valid data in many cases. Since
> > support/interest for volatile ranges has been middling at best, I want
> > to start culling the stranger use cases. I'm open in the future to
> > adding a special flag or something if it really make sense, but at
> > this point, lets just get the more general volatile range use cases
> > supported.
> 
> I'm not sure it's special case. Because some user could reserve
> a big volatile VMA and want to use the range by circle queue for
> caching so overwriting could happen easily.
> We should call vrange(NOVOLATILE) to prevent SIGBUS right before
> overwriting. I feel it's unnecessary overhead and we could avoid
> the cost with VRANGE_ZERO.
> Do you think this usecase would be rare?
  If I understand it correctly the buffer would be volatile all the time
and userspace would like to opportunistically access it. Hum, but then with
your automatic zero-filling it could see half of the page with data and
half of the page zeroed out (the page got evicted in the middle of
userspace reading it). I don't think that's a very comfortable interface to
work with (you would have to very carefully verify the data you've read is
really valid). And frankly in most cases I'm afraid the application would
fail to do proper verification and crash randomly under memory pressure. So
I wouldn't provide VRANGE_ZERO unless I come across real people for which
avoiding marking the range as NONVOLATILE is a big deal and they are OK with
handling all the odd situations that can happen.

That being said I agree with you that it makes sense to extend the syscall
with flags argument so that we have some room for different modifications
of the functionality.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
