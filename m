Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E42B6B026A
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:58:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i26-v6so3029190edr.4
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 04:58:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s35-v6si1193669edm.70.2018.07.25.04.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 04:58:09 -0700 (PDT)
Date: Wed, 25 Jul 2018 13:58:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180725115807.GF28386@dhcp22.suse.cz>
References: <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180724133110.GJ1934745@devbig577.frc2.facebook.com>
 <20180724135022.GO28386@dhcp22.suse.cz>
 <20180724135528.GK1934745@devbig577.frc2.facebook.com>
 <20180724142554.GQ28386@dhcp22.suse.cz>
 <20180724142820.GL1934745@devbig577.frc2.facebook.com>
 <20180724144351.GR28386@dhcp22.suse.cz>
 <20180724144940.GN1934745@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724144940.GN1934745@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

On Tue 24-07-18 07:49:40, Tejun Heo wrote:
> Hello, Michal.
> 
> On Tue, Jul 24, 2018 at 04:43:51PM +0200, Michal Hocko wrote:
[...]
> > So IMHO the best option would be to simply inherit the group_oom to
> > children. This would allow users to do their weird stuff but the default
> > configuration would be consistent.
> 
> Persistent config inheritance is a big no no.  It really sucks because
> it makes the inherited state sticky and there's no way of telling why
> the current setting is the way it is without knowing the past
> configurations of the hierarchy.  We actually had a pretty bad
> incident due to memcg swappiness inheritance recently (top level
> cgroups would inherit sysctl swappiness during boot before sysctl
> initialized them and then post-boot it isn't clear why the settings
> are the way they're).
> 
> Nothing in cgroup2 does persistent inheritance.  If something explicit
> is necessary, we do .effective so that the effective config is clearly
> visible.
> 
> > A more restrictive variant would be to disallow changing children to
> > mismatch the parent oom_group == 1. This would have a slight advantage
> > that those users would get back to us with their usecases and we can
> > either loose the restriction or explain that what they are doing is
> > questionable and help with a more appropriate configuration.
> 
> That's a nack too because across delegation, from a child pov, it
> isn't clear why it can't change configs and it's also easy to
> introduce a situation where a child can lock its ancestors out of
> chanding their configs.

OK, fair points. I will keep thinking about this some more. I still
cannot shake a bad feeling about the semantic and how poor users are
going to scratch their heads what the heck is going on here. I will
follow up in other email where we are discussing both options once
I am able to sort this out myself.
-- 
Michal Hocko
SUSE Labs
