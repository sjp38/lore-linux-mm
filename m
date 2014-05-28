Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB216B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 12:17:15 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id i7so11382105oag.23
        for <linux-mm@kvack.org>; Wed, 28 May 2014 09:17:15 -0700 (PDT)
Received: from mail-oa0-x249.google.com (mail-oa0-x249.google.com [2607:f8b0:4003:c02::249])
        by mx.google.com with ESMTPS id ou4si32204633oeb.14.2014.05.28.09.17.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 09:17:14 -0700 (PDT)
Received: by mail-oa0-f73.google.com with SMTP id g18so121188oah.0
        for <linux-mm@kvack.org>; Wed, 28 May 2014 09:17:14 -0700 (PDT)
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz> <20140528121023.GA10735@dhcp22.suse.cz> <20140528134905.GF2878@cmpxchg.org> <20140528142144.GL9895@dhcp22.suse.cz> <20140528152854.GG2878@cmpxchg.org>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
In-reply-to: <20140528152854.GG2878@cmpxchg.org>
Date: Wed, 28 May 2014 09:17:13 -0700
Message-ID: <xr93ioopyj1y.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>


On Wed, May 28 2014, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, May 28, 2014 at 04:21:44PM +0200, Michal Hocko wrote:
>> On Wed 28-05-14 09:49:05, Johannes Weiner wrote:
>> > On Wed, May 28, 2014 at 02:10:23PM +0200, Michal Hocko wrote:
>> > > Hi Andrew, Johannes,
>> > > 
>> > > On Mon 28-04-14 14:26:41, Michal Hocko wrote:
>> > > > This patchset introduces such low limit that is functionally similar
>> > > > to a minimum guarantee. Memcgs which are under their lowlimit are not
>> > > > considered eligible for the reclaim (both global and hardlimit) unless
>> > > > all groups under the reclaimed hierarchy are below the low limit when
>> > > > all of them are considered eligible.
>> > > > 
>> > > > The previous version of the patchset posted as a RFC
>> > > > (http://marc.info/?l=linux-mm&m=138677140628677&w=2) suggested a
>> > > > hard guarantee without any fallback. More discussions led me to
>> > > > reconsidering the default behavior and come up a more relaxed one. The
>> > > > hard requirement can be added later based on a use case which really
>> > > > requires. It would be controlled by memory.reclaim_flags knob which
>> > > > would specify whether to OOM or fallback (default) when all groups are
>> > > > bellow low limit.
>> > > 
>> > > It seems that we are not in a full agreement about the default behavior
>> > > yet. Johannes seems to be more for hard guarantee while I would like to
>> > > see the weaker approach first and move to the stronger model later.
>> > > Johannes, is this absolutely no-go for you? Do you think it is seriously
>> > > handicapping the semantic of the new knob?
>> > 
>> > Well we certainly can't start OOMing where we previously didn't,
>> > that's called a regression and automatically limits our options.
>> > 
>> > Any unexpected OOMs will be much more acceptable from a new feature
>> > than from configuration that previously "worked" and then stopped.
>> 
>> Yes and we are not talking about regressions, are we?
>> 
>> > > My main motivation for the weaker model is that it is hard to see all
>> > > the corner case right now and once we hit them I would like to see a
>> > > graceful fallback rather than fatal action like OOM killer. Besides that
>> > > the usaceses I am mostly interested in are OK with fallback when the
>> > > alternative would be OOM killer. I also feel that introducing a knob
>> > > with a weaker semantic which can be made stronger later is a sensible
>> > > way to go.
>> > 
>> > We can't make it stronger, but we can make it weaker. 
>> 
>> Why cannot we make it stronger by a knob/configuration option?
>
> Why can't we make it weaker by a knob?  Why should we design the
> default for unforeseeable cornercases rather than make the default
> make sense for existing cases and give cornercases a fallback once
> they show up?

My 2c...  The following works for my use cases:
1) introduce memory.low_limit_in_bytes (default=0 thus no default change
   from older kernels)
2) interested users will set low_limit_in_bytes to non-zero value.
   Memory protected by low limit should be as migratable/reclaimable as
   mlock memory.  If a zone full of mlock memory causes oom kills, then
   so should the low limit.

If we find corner cases where low_limit_in_bytes is too strict, then we
could discuss a new knob to relax it.  But I think we should start with
a strict low-limit.  If the oom killer gets tied in knots due to low
limit, then I'd like to explore fixing the oom killer before relaxing
low limit.

Disclaimer: new use cases will certainly appear with various
requirements.  But an oom-killing low_limit_in_bytes seems like a
generic opt-in feature, so I think it's worthwhile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
