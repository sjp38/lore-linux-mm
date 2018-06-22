Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 820B16B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 05:09:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i19-v6so343788eds.20
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 02:09:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g20-v6si3101192edq.282.2018.06.22.02.09.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 02:09:38 -0700 (PDT)
Date: Fri, 22 Jun 2018 11:09:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: dm bufio: Reduce dm_bufio_lock contention
Message-ID: <20180622090935.GT10465@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1806141424510.30404@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615073201.GB24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806150724260.15022@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615115547.GH24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806150832100.26650@file01.intranet.prod.int.rdu2.redhat.com>
 <20180615130925.GI24039@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806181003560.4201@file01.intranet.prod.int.rdu2.redhat.com>
 <20180619104312.GD13685@dhcp22.suse.cz>
 <alpine.LRH.2.02.1806191228110.25656@file01.intranet.prod.int.rdu2.redhat.com>
 <20180622090151.GS10465@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622090151.GS10465@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: jing xia <jing.xia.mail@gmail.com>, Mike Snitzer <snitzer@redhat.com>, agk@redhat.com, dm-devel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 22-06-18 11:01:51, Michal Hocko wrote:
> On Thu 21-06-18 21:17:24, Mikulas Patocka wrote:
[...]
> > What about this patch? If __GFP_NORETRY and __GFP_FS is not set (i.e. the 
> > request comes from a block device driver or a filesystem), we should not 
> > sleep.
> 
> Why? How are you going to audit all the callers that the behavior makes
> sense and moreover how are you going to ensure that future usage will
> still make sense. The more subtle side effects gfp flags have the harder
> they are to maintain.

So just as an excercise. Try to explain the above semantic to users. We
currently have the following.

 * __GFP_NORETRY: The VM implementation will try only very lightweight
 *   memory direct reclaim to get some memory under memory pressure (thus
 *   it can sleep). It will avoid disruptive actions like OOM killer. The
 *   caller must handle the failure which is quite likely to happen under
 *   heavy memory pressure. The flag is suitable when failure can easily be
 *   handled at small cost, such as reduced throughput

 * __GFP_FS can call down to the low-level FS. Clearing the flag avoids the
 *   allocator recursing into the filesystem which might already be holding
 *   locks.

So how are you going to explain gfp & (__GFP_NORETRY | ~__GFP_FS)? What
is the actual semantic without explaining the whole reclaim or force
users to look into the code to understand that? What about GFP_NOIO |
__GFP_NORETRY? What does it mean to that "should not sleep". Do all
shrinkers have to follow that as well?
-- 
Michal Hocko
SUSE Labs
