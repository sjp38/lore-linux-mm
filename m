Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 35BC16B0038
	for <linux-mm@kvack.org>; Fri, 29 May 2015 10:07:44 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so16938063qkh.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 07:07:44 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id 19si5717038qku.6.2015.05.29.07.07.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 07:07:43 -0700 (PDT)
Received: by qgdy38 with SMTP id y38so4559002qgd.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 07:07:42 -0700 (PDT)
Date: Fri, 29 May 2015 10:07:37 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150529140737.GK27479@htj.duckdns.org>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526141011.GA11065@cmpxchg.org>
 <20150528210742.GF27479@htj.duckdns.org>
 <20150529120838.GC22728@dhcp22.suse.cz>
 <20150529131055.GH27479@htj.duckdns.org>
 <20150529134553.GD22728@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150529134553.GD22728@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hello,

On Fri, May 29, 2015 at 03:45:53PM +0200, Michal Hocko wrote:
> Sure but we are talking about processes here. They just happen to share
> mm. And this is exactly the behavior change I am talking about... With

Are we talking about CLONE_VM w/o CLONE_THREAD?  ie. two threadgroups
sharing the same VM?

> the owner you could emulate "threads" with this patch you cannot
> anymore. IMO we shouldn't allow for that but just reading the original
> commit message (cf475ad28ac35) which has added mm->owner:
> "
> It also allows several control groups that are virtually grouped by
> mm_struct, to exist independent of the memory controller i.e., without
> adding mem_cgroup's for each controller, to mm_struct.
> "
> suggests it might have been intentional. That being said, I think it was

I think he's talking about implmenting different controllers which may
want to add their own css pointer in mm_struct now wouldn't need to as
the mm is tagged with the owning task from which membership of all
controllers can be derived.  I don't think that's something we need to
worry about.  We haven't seen even a suggestion for such a controller
and even if that happens we'd be better off adding a separate field
for the new controller.

> a mistake back at the time and we should move on to a saner model. But I
> also believe we should be really vocal when the user visible behavior
> changes. If somebody really asks for the previous behavior I would
> insist on a _strong_ usecase.

I'm a bit lost on what's cleared defined is actually changing.  It's
not like userland had firm control over mm->owner.  It was already a
crapshoot, no?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
