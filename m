Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id F41DE6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 15:36:40 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id s7so2055881qap.20
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 12:36:40 -0700 (PDT)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id v48si9544104qgv.15.2014.06.05.12.36.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 12:36:40 -0700 (PDT)
Received: by mail-qg0-f51.google.com with SMTP id q107so2375617qgd.38
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 12:36:40 -0700 (PDT)
Date: Thu, 5 Jun 2014 15:36:37 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140605193637.GA31654@mtj.dyndns.org>
References: <20140528134905.GF2878@cmpxchg.org>
 <20140528142144.GL9895@dhcp22.suse.cz>
 <20140528152854.GG2878@cmpxchg.org>
 <20140528155414.GN9895@dhcp22.suse.cz>
 <20140528163335.GI2878@cmpxchg.org>
 <20140603110743.GD1321@dhcp22.suse.cz>
 <20140603142249.GP2878@cmpxchg.org>
 <20140604144658.GB17612@dhcp22.suse.cz>
 <20140604154408.GT2878@cmpxchg.org>
 <alpine.LSU.2.11.1406041218080.9583@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1406041218080.9583@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

Hello, guys.

On Wed, Jun 04, 2014 at 12:18:59PM -0700, Hugh Dickins wrote:
> that it is more comfortable with OOMing as the default.  Okay.  But I
> would expect there to be many who want the attempt towards isolation that
> low limit offers, without a collapse to OOM at the first misjudgement.

Ignoring all the mm details about NUMA, zones, overcommit or whatnot,
solely focusing on the core feature provided by the interface, which
BTW is what should guide the interface design anyway, I'm curious
about how this would end up.

The first thing which strikes me is that it's not symmetric with the
limits.  We have two of them - soft and hard limits.  A hard limit
provides the absolute boundary which can't be exceeded while a soft
limit, in principle, gives a guideline on memory usage of the group to
the kernel so that its behavior can be better suited to the purpose of
the system.

We still seem to have a number of issues with the semantics of
softlimit but its principle role makes sense to me.  It allows
userland to provide additional information or hints on how resource
allocation should be managed across different groups and as such can
be used for rule-of-thumb, this-will-prolly-work kind of easy /
automatic configuration, which is a very useful thing.  Can be a lot
more widely useful than hard limits in the long term.

It seems that the main suggested use case for soft guarantee is
"reasonable" isolation, which seems symmetric to the role of soft
limit; however, if I think about it more, I'm not sure whether such
usage would make sense.

The thing with softlimit is that it doesn't affect resource allocation
until the limit is hit.  The system keeps memory distribution balanced
and useful through reclaiming less useful stuff and that part isn't
adversely affected by softlimit.  This means that softlimit
configuration is relaxed in both directions.  It doesn't have to be
completely accurate.  It can be good enough or "reasonable" and still
useful without affecting the whole system adversely.

However, soft guarantee isn't like that.  Because it disables reclaim
completely until the guaranteed amount is reached which many workloads
wouldn't have trouble filling up over time, the configuration isn't
relaxed downwards.  Any configured value adversely affects the overall
efficiency of the system, which in turn breaks the "reasonable"
isolation use case because such usages require the configuration to be
not punishing by default.

So, that's where I think the symmetry breaks.  The direction of the
pressure the guarantee exerts makes it punishing for the system by
default, which means that it can't be a generally useful thing which
can be widely configured with should-be-good-enough values.  It
inherently is something which requires a lot more attention and thus a
lot less useful (at least its usefulness is a lot narrower).

As soft limit has been misused to provide guarantee, I think it's a
healthy thing to separate it out and implement it properly and I
probably am not very qualified to make calls on mm decisions; however,
I strongly think that we should think through the actual use cases
before deciding which features and interface we expose to userland.
They better make sense and are actually useful.  I strongly believe
that failure to do so had been one of the main reasons why we got
burned so badly with cgroup in general.  Let's please not repeat that.
If this is useful, let's find out why and how and crystailize the
interface for those usages.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
