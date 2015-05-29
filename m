Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id D0D1F6B0038
	for <linux-mm@kvack.org>; Fri, 29 May 2015 09:45:57 -0400 (EDT)
Received: by wivl4 with SMTP id l4so17984384wiv.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 06:45:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5si9651182wjf.140.2015.05.29.06.45.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 06:45:56 -0700 (PDT)
Date: Fri, 29 May 2015 15:45:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150529134553.GD22728@dhcp22.suse.cz>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526141011.GA11065@cmpxchg.org>
 <20150528210742.GF27479@htj.duckdns.org>
 <20150529120838.GC22728@dhcp22.suse.cz>
 <20150529131055.GH27479@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150529131055.GH27479@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 29-05-15 09:10:55, Tejun Heo wrote:
> On Fri, May 29, 2015 at 02:08:38PM +0200, Michal Hocko wrote:
> > > I suppose that making mm always follow the threadgroup leader should
> > > be fine, right? 
> > 
> > That is the plan.
> 
> Cool.
> 
> > > While this wouldn't make any difference in the unified hierarchy,
> > 
> > Just to make sure I understand. "wouldn't make any difference" because
> > the API is not backward compatible right?
> 
> Hmm... because it's always per-process.  If any thread is going, the
> whole process is going together.

Sure but we are talking about processes here. They just happen to share
mm. And this is exactly the behavior change I am talking about... With
the owner you could emulate "threads" with this patch you cannot
anymore. IMO we shouldn't allow for that but just reading the original
commit message (cf475ad28ac35) which has added mm->owner:
"
It also allows several control groups that are virtually grouped by
mm_struct, to exist independent of the memory controller i.e., without
adding mem_cgroup's for each controller, to mm_struct.
"
suggests it might have been intentional. That being said, I think it was
a mistake back at the time and we should move on to a saner model. But I
also believe we should be really vocal when the user visible behavior
changes. If somebody really asks for the previous behavior I would
insist on a _strong_ usecase.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
