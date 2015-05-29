Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 589A16B00A3
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:23:34 -0400 (EDT)
Received: by qkx62 with SMTP id 62so46712623qkx.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:23:34 -0700 (PDT)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com. [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id h137si2194240qhc.38.2015.05.29.08.23.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:23:33 -0700 (PDT)
Received: by qcxw10 with SMTP id w10so27343209qcx.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:23:33 -0700 (PDT)
Date: Fri, 29 May 2015 11:23:28 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150529152328.GM27479@htj.duckdns.org>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526141011.GA11065@cmpxchg.org>
 <20150528210742.GF27479@htj.duckdns.org>
 <20150529120838.GC22728@dhcp22.suse.cz>
 <20150529131055.GH27479@htj.duckdns.org>
 <20150529134553.GD22728@dhcp22.suse.cz>
 <20150529140737.GK27479@htj.duckdns.org>
 <20150529145739.GF22728@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150529145739.GF22728@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hello,

On Fri, May 29, 2015 at 04:57:39PM +0200, Michal Hocko wrote:
> > > "
> > > It also allows several control groups that are virtually grouped by
> > > mm_struct, to exist independent of the memory controller i.e., without
> > > adding mem_cgroup's for each controller, to mm_struct.
> > > "
> > > suggests it might have been intentional. That being said, I think it was
> > 
> > I think he's talking about implmenting different controllers which may
> > want to add their own css pointer in mm_struct now wouldn't need to as
> > the mm is tagged with the owning task from which membership of all
> > controllers can be derived.  I don't think that's something we need to
> > worry about.  We haven't seen even a suggestion for such a controller
> > and even if that happens we'd be better off adding a separate field
> > for the new controller.
> 
> Maybe I've just misunderstood. My understandig was that tasks sharing
> the mm could live in different cgroups while the memory would be bound
> by a shared memcg.

Hmm.... it specifically goes into explaining that it's about having
different controllers sharing the owner field.

 "i.e., without adding mem_cgroup's for each controller, to mm_struct."

It seems fairly clear to me.

> > I'm a bit lost on what's cleared defined is actually changing.  It's
> > not like userland had firm control over mm->owner.  It was already a
> > crapshoot, no?
> 
> OK so you creat a task A (leader) which clones several tasks Pn with
> CLONE_VM without CLONE_THREAD. Moving A around would control memcg
> membership while Pn could be moved around freely to control membership
> in other controllers (e.g. cpu to control shares). So it is something
> like moving threads separately.

Sure, it'd behave clearly in certain cases but then again you'd have
cases where how mm->owner changes isn't clear at all when seen from
the userland.  e.g. When the original owner goes away, the assignment
of the next owner is essentially arbitrary.  That's what I meant by
saying it was already a crapshoot.  We should definitely document the
change but this isn't likely to be an issue.  CLONE_VM &&
!CLONE_THREAD is an extreme corner case to begin with and even the
behavior there wasn't all that clearly defined.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
