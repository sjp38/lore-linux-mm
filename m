Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id D785A6B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 20:46:25 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id d10so3636459vea.33
        for <linux-mm@kvack.org>; Thu, 08 Aug 2013 17:46:24 -0700 (PDT)
Date: Thu, 8 Aug 2013 20:46:21 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] memcg: Limit the number of events registered on
 oom_control
Message-ID: <20130809004621.GD13427@mtj.dyndns.org>
References: <1375874907-22013-1-git-send-email-mhocko@suse.cz>
 <1375874907-22013-2-git-send-email-mhocko@suse.cz>
 <20130807130836.GB27006@htj.dyndns.org>
 <20130807133746.GI8184@dhcp22.suse.cz>
 <20130807134741.GF27006@htj.dyndns.org>
 <20130807135734.GK8184@dhcp22.suse.cz>
 <20130807144730.GB13279@dhcp22.suse.cz>
 <20130807173051.GD16343@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807173051.GD16343@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Anton Vorontsov <anton.vorontsov@linaro.org>

Hello, Michal.

On Wed, Aug 07, 2013 at 07:30:51PM +0200, Michal Hocko wrote:
> On Wed 07-08-13 16:47:30, Michal Hocko wrote:
> > On Wed 07-08-13 15:57:34, Michal Hocko wrote:
> > [...]
> > > Hmm, OK so you think that the fd limit is sufficient already?
> > 
> > Hmm, that would need to touch the code as well (the register callback
> > would need to make sure only one event is registered per cfile). But yes
> > this way would be better. I will send a new patch once I have an idle
> > moment.
> 
> What do you think about the following? I am not sure about EINVAL maybe
> there is a better way to tell userspace it is doing something wrong. I
> would appreciate any suggestions. If this looks good I will post a
> similar patch for vmpressure.

I don't think it's a good idea.  Not sure it matters given that this
isn't a very popular interface but adding this sort of rather
arbitrary restrictions can be confusing and lead to issues in userland
which are extremely annoying to track down.

Also, in terms of layering, this is horribly misplaced.  This is low
level event source implementation, which is not the right place to
implement logic to protect from userland abuses / mistakes.

That's the whole thing with this interface.  It's essentially
implementing a new userland-visible notification framework.  It is a
complex userland visible interface which takes a lot of design and
effort to get right and cgroup core or memcg definitely is not the
place to do anything like this.  Collectively, we are not capable
enough to do pull things like this properly by ourselves and even if
we were it is not the right place to do it.

Given how generally broken delegating to !priv users is, I don't think
there's anything we can or should do at this point rather than noting
that it is broken and was a mistake.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
