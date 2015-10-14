Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id B55F36B0254
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 16:24:51 -0400 (EDT)
Received: by ykoo7 with SMTP id o7so58886197yko.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 13:24:51 -0700 (PDT)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id l186si4486515ywg.13.2015.10.14.13.24.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 13:24:51 -0700 (PDT)
Received: by ykaz22 with SMTP id z22so33157947yka.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 13:24:50 -0700 (PDT)
Date: Wed, 14 Oct 2015 16:24:48 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
Message-ID: <20151014202448.GE12799@mtj.duckdns.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
 <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
 <20151014165729.GA12799@mtj.duckdns.org>
 <CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
 <20151014190259.GC12799@mtj.duckdns.org>
 <CA+55aFz27G4gLS9AFs6hHJfULXAqA=tM5KA=YvBH8MaZ+sT-VA@mail.gmail.com>
 <20151014193829.GD12799@mtj.duckdns.org>
 <CA+55aFyzsMYcRX3V5CEWB4Zb-9BuRGCjib3DMXuX5y9nBWiZ1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyzsMYcRX3V5CEWB4Zb-9BuRGCjib3DMXuX5y9nBWiZ1w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

Hello,

On Wed, Oct 14, 2015 at 01:10:33PM -0700, Linus Torvalds wrote:
> At the same time, some of the same issues that are pushing people to
> move timers around (put idle cores to deeper sleeps etc) would also
> argue for moving delayed work around to other cpus if possible.
> 
> So I agree that there is a push to make timer cpu targets more dynamic
> in a way we historically didn't really have. At the same time, I think
> the same forces that want to move timers around would actually likely
> want to move delayed work around too...

I fully agree.  We gotta get this in order sooner or later.  I'll try
to come up with a transition plan.

> > * This makes queue_delayed_work() behave differently from queue_work()
> >   and when I checked years ago the local queueing guarantee was
> >   definitely being depended upon by some users.
> 
> Yes. But the delayed work really is different. By definition, we know
> that the current cpu is busy and active _right_now_, and so keeping
> work on that cpu isn't obviously wrong.
> 
> But it's *not* obviously right to schedule something on that
> particular cpu a few seconds from now, when it might be happily asleep
> and there might be better cpus to bother..

But in terms of API consistency, it sucks to have queue_work()
guarantee local queueing but not queue_delayed_work().  The ideal
situation would be updating both so that neither guarantees.  If that
turns out to be too painful, maybe we can rename queue_delayed_work()
so that it signifies its difference from queue_work().  Let's see.

> > I do want to get rid of the local queueing guarnatee for all work
> > items.  That said, I don't think this is the right way to do it.
> 
> Hmm. I guess that for being past rc5, taking your patch is the safe
> thing. I really don't like it very much, though.

Heh, yeah, I pondered about calling it a happy accident and just
sticking with the new behavior.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
