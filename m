Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 1D9416B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 12:03:59 -0400 (EDT)
Date: Wed, 11 Sep 2013 18:03:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] vmpressure: fix divide-by-0 in vmpressure_work_fn
Message-ID: <20130911160357.GA32273@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1309062254470.11420@eggly.anvils>
 <20130909110847.GB18056@dhcp22.suse.cz>
 <20130911154057.GA16765@teo>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130911154057.GA16765@teo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Anton Vorontsov <anton@enomsg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 11-09-13 08:40:57, Anton Vorontsov wrote:
> On Mon, Sep 09, 2013 at 01:08:47PM +0200, Michal Hocko wrote:
> > On Fri 06-09-13 22:59:16, Hugh Dickins wrote:
> > > Hit divide-by-0 in vmpressure_work_fn(): checking vmpr->scanned before
> > > taking the lock is not enough, we must check scanned afterwards too.
> > 
> > As vmpressure_work_fn seems the be the only place where we set scanned
> > to 0 (except for the rare occasion when scanned overflows which
> > would be really surprising) then the only possible way would be two
> > vmpressure_work_fn racing over the same work item. system_wq is
> > !WQ_NON_REENTRANT so one work item might be processed by multiple
> > workers on different CPUs. This means that the vmpr->scanned check in
> > the beginning of vmpressure_work_fn is inherently racy.
> > 
> > Hugh's patch fixes the issue obviously but doesn't it make more sense to
> > move the initial vmpr->scanned check under the lock instead?
> > 
> > Anton, what was the initial motivation for the out of the lock
> > check? Does it really optimize anything?
> 
> Thanks a lot for the explanation.
> 
> Answering your question: the idea was to minimize the lock section, but the
> section is quite small anyway so I doubt that it makes any difference (during
> development I could not measure any effect of vmpressure() calls in my system,
> though the system itself was quite small).
> 
> I am happy with moving the check under the lock

The patch below. I find it little bit nicer than Hugh's original one
because having the two checks sounds more confusing.
What do you think Hugh, Anton?

> or moving the work into its own WQ_NON_REENTRANT queue.

That sounds like an overkill.

---
