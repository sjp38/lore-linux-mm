Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 652976B0073
	for <linux-mm@kvack.org>; Fri, 29 May 2015 10:57:43 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so18438696wic.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 07:57:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vf7si9994696wjc.127.2015.05.29.07.57.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 07:57:41 -0700 (PDT)
Date: Fri, 29 May 2015 16:57:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150529145739.GF22728@dhcp22.suse.cz>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526141011.GA11065@cmpxchg.org>
 <20150528210742.GF27479@htj.duckdns.org>
 <20150529120838.GC22728@dhcp22.suse.cz>
 <20150529131055.GH27479@htj.duckdns.org>
 <20150529134553.GD22728@dhcp22.suse.cz>
 <20150529140737.GK27479@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150529140737.GK27479@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 29-05-15 10:07:37, Tejun Heo wrote:
> Hello,
> 
> On Fri, May 29, 2015 at 03:45:53PM +0200, Michal Hocko wrote:
> > Sure but we are talking about processes here. They just happen to share
> > mm. And this is exactly the behavior change I am talking about... With
> 
> Are we talking about CLONE_VM w/o CLONE_THREAD?  ie. two threadgroups
> sharing the same VM?

yes.

> > the owner you could emulate "threads" with this patch you cannot
> > anymore. IMO we shouldn't allow for that but just reading the original
> > commit message (cf475ad28ac35) which has added mm->owner:
> > "
> > It also allows several control groups that are virtually grouped by
> > mm_struct, to exist independent of the memory controller i.e., without
> > adding mem_cgroup's for each controller, to mm_struct.
> > "
> > suggests it might have been intentional. That being said, I think it was
> 
> I think he's talking about implmenting different controllers which may
> want to add their own css pointer in mm_struct now wouldn't need to as
> the mm is tagged with the owning task from which membership of all
> controllers can be derived.  I don't think that's something we need to
> worry about.  We haven't seen even a suggestion for such a controller
> and even if that happens we'd be better off adding a separate field
> for the new controller.

Maybe I've just misunderstood. My understandig was that tasks sharing
the mm could live in different cgroups while the memory would be bound
by a shared memcg.

> > a mistake back at the time and we should move on to a saner model. But I
> > also believe we should be really vocal when the user visible behavior
> > changes. If somebody really asks for the previous behavior I would
> > insist on a _strong_ usecase.
> 
> I'm a bit lost on what's cleared defined is actually changing.  It's
> not like userland had firm control over mm->owner.  It was already a
> crapshoot, no?

OK so you creat a task A (leader) which clones several tasks Pn with
CLONE_VM without CLONE_THREAD. Moving A around would control memcg
membership while Pn could be moved around freely to control membership
in other controllers (e.g. cpu to control shares). So it is something
like moving threads separately.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
