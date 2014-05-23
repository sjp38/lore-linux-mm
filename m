Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 15BD96B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 08:09:51 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id m15so4751880wgh.20
        for <linux-mm@kvack.org>; Fri, 23 May 2014 05:09:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si6283522eeo.84.2014.05.23.05.09.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 05:09:50 -0700 (PDT)
Date: Fri, 23 May 2014 14:09:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: deprecate memory.force_empty knob
Message-ID: <20140523120948.GA22135@dhcp22.suse.cz>
References: <1399994956-3907-1-git-send-email-mhocko@suse.cz>
 <xr9338g9o03z.fsf@gthelen.mtv.corp.google.com>
 <20140519140248.GD3017@dhcp22.suse.cz>
 <20140519155018.GF3017@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140519155018.GF3017@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 19-05-14 17:50:18, Michal Hocko wrote:
> On Mon 19-05-14 16:02:48, Michal Hocko wrote:
> > On Fri 16-05-14 15:00:16, Greg Thelen wrote:
> [...]
> > > -- First, demonstrate that just rmdir, without memory.force_empty,
> > >    temporarily hides reparented child memory stats.
> > > 
> > > $ /test
> > > p/memory.stat:rss 0
> > > p/memory.stat:total_rss 69632
> > > p/c/memory.stat:rss 69632
> > > p/c/memory.stat:total_rss 69632
> > > For a small time the p/c memory has not been reparented to p.
> > > p/memory.stat:rss 0
> > > p/memory.stat:total_rss 0
> > 
> > OK, this is a bug. Our iterators skip the children because css_tryget
> > fails on it but css_offline still not done.

Recent cgroup changes distinguish css_tryget and css_tryget_online
(http://marc.info/?l=linux-kernel&m=140025648704805). So we will only
need to use css_tryget rather than the _online variant in
__mem_cgroup_iter_next. I guess this is what Johannes was talking about.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
