Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2326B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 12:23:29 -0500 (EST)
Received: by mail-ea0-f175.google.com with SMTP id z10so383185ead.6
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 09:23:28 -0800 (PST)
Received: from mail-ea0-x236.google.com (mail-ea0-x236.google.com [2a00:1450:4013:c01::236])
        by mx.google.com with ESMTPS id 43si51060503eeh.178.2014.02.05.09.23.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 09:23:27 -0800 (PST)
Received: by mail-ea0-f182.google.com with SMTP id r15so385563ead.27
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 09:23:27 -0800 (PST)
Date: Wed, 5 Feb 2014 18:23:23 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 4/6] memcg: make sure that memcg is not offline when
 charging
Message-ID: <20140205172323.GA13743@dhcp22.suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-5-git-send-email-mhocko@suse.cz>
 <20140204162939.GP6963@cmpxchg.org>
 <20140205133834.GB2425@dhcp22.suse.cz>
 <20140205152821.GY6963@cmpxchg.org>
 <20140205161940.GE2425@dhcp22.suse.cz>
 <20140205164543.GZ6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140205164543.GZ6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 05-02-14 11:45:43, Johannes Weiner wrote:
> On Wed, Feb 05, 2014 at 05:19:40PM +0100, Michal Hocko wrote:
> > On Wed 05-02-14 10:28:21, Johannes Weiner wrote:
> > > Here is the only exception to the above: swapout records maintain
> > > permanent css references, so they prevent css_free() from running.
> > > For that reason alone we should run one optimistic reparenting in
> > > css_offline() to make sure one swap record does not pin gigabytes of
> > > pages in an offlined cgroup, which is unreachable for reclaim.  But
> > 
> > How can reparenting help for swapped out pages? Or did you mean to at
> > least get rid of swapcache pages?
> 
> I was thinking primarily of page cache.  There could be a lot of it
> left in the group and once css_tryget() is disabled we can't reclaim
> it anymore.

Good point.

> So we'd clean that out at offline time optimistically and
> at css_free() we catch any charges raced that showed up afterwards.

OK, care to send a patch which would clarify the reparenting usage in
both css_offline and css_free?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
