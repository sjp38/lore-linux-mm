Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0C37A6B02B4
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 03:23:33 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y190so122651824pgb.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 00:23:33 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id q5si4291323plk.178.2017.08.14.00.23.31
        for <linux-mm@kvack.org>;
        Mon, 14 Aug 2017 00:23:31 -0700 (PDT)
Date: Mon, 14 Aug 2017 16:22:11 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 06/14] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170814072211.GK20323@X58A-UD3R>
References: <20170810115922.kegrfeg6xz7mgpj4@tardis>
 <016b01d311d1$d02acfa0$70806ee0$@lge.com>
 <20170810125133.2poixhni4d5aqkpy@tardis>
 <20170810131737.skdyy4qcxlikbyeh@tardis>
 <20170811034328.GH20323@X58A-UD3R>
 <20170811080329.3ehu7pp7lcm62ji6@tardis>
 <20170811085201.GI20323@X58A-UD3R>
 <20170811094448.GJ20323@X58A-UD3R>
 <CANrsvRM4ijD0ym0HJySqjOfcCeUbGCc6bBppK43y5MqC5aB1gQ@mail.gmail.com>
 <20170814070522.wwj4as2hk2o7avlu@tardis>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814070522.wwj4as2hk2o7avlu@tardis>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, tglx@linutronix.de, Michel Lespinasse <walken@google.com>, kirill@shutemov.name, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Aug 14, 2017 at 03:05:22PM +0800, Boqun Feng wrote:
> > I like Boqun's approach most but, _whatever_. It's ok if it solves the problem.
> > The last one is not bad when it is used for syscall exit, but we have to give
> > up valid dependencies unnecessarily in other cases. And I think Peterz's
> > approach should be modified a bit to make it work neatly, like:
> > 
> > crossrelease_hist_end(...)
> > {
> > ...
> >        invalidate_xhlock(&xhlock(cur->xhlock_idx_max));
> > 
> >        for (c = 0; c < XHLOCK_CXT_NR; c++)
> >               if ((cur->xhlock_idx_max - cur->xhlock_idx_hist[c]) >=
> > MAX_XHLOCKS_NR)
> >                      invalidate_xhlock(&xhlock(cur->xhlock_idx_hist[c]));
> > ...
> > }
> > 
> 
> Haven't looked into this deeply, but my gut feeling is this is
> unnecessary, will have a deep look.

Of course, for now, it looks like we can rely on the check_same_context()
on the commit, without invalidating it. But I think the approach might be
dangerous in future. I think it would be better to do it explicitlly.

> 
> Regards,
> Boqun
> 
> > And then Peterz's approach can also work, I think.
> > 
> > ---
> > Thanks,
> > Byungchul


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
