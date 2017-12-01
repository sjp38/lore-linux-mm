Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id F2CE16B025F
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 08:54:58 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m17so6507086pgu.19
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 05:54:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si3187975pgp.129.2017.12.01.05.54.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 05:54:57 -0800 (PST)
Date: Fri, 1 Dec 2017 14:54:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: simplify alloc_pages_before_oomkill handling
Message-ID: <20171201135453.jrldrcrwpped4b5d@dhcp22.suse.cz>
References: <20171130152824.1591-1-guro@fb.com>
 <20171201091425.ekrpxsmkwcusozua@dhcp22.suse.cz>
 <20171201133214.GB7741@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171201133214.GB7741@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 01-12-17 13:32:15, Roman Gushchin wrote:
> Hi, Michal!
> 
> I totally agree that out_of_memory() function deserves some refactoring.
> 
> But I think there is an issue with your patch (see below):
> 
> On Fri, Dec 01, 2017 at 10:14:25AM +0100, Michal Hocko wrote:
> > Recently added alloc_pages_before_oomkill gained new caller with this
> > patchset and I think it just grown to deserve a simpler code flow.
> > What do you think about this on top of the series?
> > 
> > ---
[...]
> > @@ -1112,13 +1111,8 @@ bool out_of_memory(struct oom_control *oc)
> >  	}
> >  
> >  	if (mem_cgroup_select_oom_victim(oc)) {
> > -		oc->page = alloc_pages_before_oomkill(oc);
> > -		if (oc->page) {
> > -			if (oc->chosen_memcg &&
> > -			    oc->chosen_memcg != INFLIGHT_VICTIM)
> > -				mem_cgroup_put(oc->chosen_memcg);
> 
> You're removing chosen_memcg releasing here, but I don't see where you
> do this instead. And I'm not sure that putting mem_cgroup_put() into
> alloc_pages_before_oomkill() is a way towards simpler code.

Dohh, I though I did. But obviously it is not there.

> I was thinking about a bit larger refactoring: splitting out_of_memory()
> into the following parts (defined as separate functions): victim selection
> (per-process, memcg-aware or just allocating task), last allocation attempt,
> OOM action (kill process, kill memcg, panic). Hopefully it can simplify the things,
> but I don't have code yet.

OK, I will not push if you have further plans of course. This just hit
my eyes...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
