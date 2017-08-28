Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 26B016B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 08:37:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l19so498821wmi.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 05:37:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h19si271800wrb.48.2017.08.28.05.36.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Aug 2017 05:36:58 -0700 (PDT)
Date: Mon, 28 Aug 2017 14:36:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170828123657.GK17097@dhcp22.suse.cz>
References: <20170728091904.14627-1-mhocko@kernel.org>
 <20170823175709.GA22743@xo-6d-61-c0.localdomain>
 <20170825063545.GA25498@dhcp22.suse.cz>
 <20170825072818.GA15494@amd>
 <20170825080442.GF25498@dhcp22.suse.cz>
 <20170825213936.GA13576@amd>
 <87pobjhssq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87pobjhssq.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Sat 26-08-17 14:11:33, NeilBrown wrote:
> On Fri, Aug 25 2017, Pavel Machek wrote:
> 
> > On Fri 2017-08-25 10:04:42, Michal Hocko wrote:
> >> On Fri 25-08-17 09:28:19, Pavel Machek wrote:
> >> > On Fri 2017-08-25 08:35:46, Michal Hocko wrote:
> >> > > On Wed 23-08-17 19:57:09, Pavel Machek wrote:
> >> [...]
> >> > > > Dunno. < 1msec probably is temporary, 1 hour probably is not. If it causes
> >> > > > problems, can you just #define GFP_TEMPORARY GFP_KERNEL ? Treewide replace,
> >> > > > and then starting again goes not look attractive to me.
> >> > > 
> >> > > I do not think we want a highlevel GFP_TEMPORARY without any meaning.
> >> > > This just supports spreading the flag usage without a clear semantic
> >> > > and it will lead to even bigger mess. Once we can actually define what
> >> > > the flag means we can also add its users based on that new semantic.
> >> > 
> >> > It has real meaning.
> >> 
> >> Which is?
> >
> > "This allocation is temporary. It lasts milliseconds, not hours."
> 
> It isn't sufficient to give a rule for when GFP_TEMPORARY will be used,
> you also need to explain (at least in general terms) how the information
> will be used.  Also you need to give guidelines on whether the flag
> should be set for allocation that will last seconds or minutes.
> 
> If we have a flag that doesn't have a well defined meaning that actually
> affects behavior, it will not be used consistently, and if we ever
> change exactly how it behaves we can expect things to break.  So it is
> better not to have a flag, than to have a poorly defined flag.

Absolutely agreed!

> My current thoughts is that the important criteria is not how long the
> allocation will be used for, but whether it is reclaimable.  Allocations
> that will only last 5 msecs are reclaimable by calling "usleep(5000)".
> Other allocations might be reclaimable in other ways.  Allocations that
> are not reclaimable may well be directed to a more restricted pool of
> memory, and might be more likely to fail.  If we grew a strong
> "reclaimable" concept, this 'temporary' concept that you want to hold on
> to would become a burden.

... and here again. The whole motivation for the flag was to gather
these objects together and reduce chances of internal fragmentation
due to long lived objects mixed with short term ones. Without an
explicit way to reclaim those objects or having a clear checkpoint to
wait for it is not really helping us to reach desired outcome (less
fragmented memory).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
