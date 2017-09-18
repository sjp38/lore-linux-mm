Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7ACEE6B0069
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 11:03:25 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id f24so696573qte.7
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 08:03:25 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id b11si7292805qte.509.2017.09.18.08.03.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 08:03:21 -0700 (PDT)
Date: Mon, 18 Sep 2017 08:02:54 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170918150254.GA24257@castle.DHCP.thefacebook.com>
References: <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <alpine.DEB.2.10.1709151249290.76069@chino.kir.corp.google.com>
 <20170915210807.GA5238@castle>
 <20170918062045.kcfsboxvfmlg2wjo@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170918062045.kcfsboxvfmlg2wjo@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 18, 2017 at 08:20:45AM +0200, Michal Hocko wrote:
> On Fri 15-09-17 14:08:07, Roman Gushchin wrote:
> > On Fri, Sep 15, 2017 at 12:55:55PM -0700, David Rientjes wrote:
> > > On Fri, 15 Sep 2017, Roman Gushchin wrote:
> > > 
> > > > > But then you just enforce a structural restriction on your configuration
> > > > > because
> > > > > 	root
> > > > >         /  \
> > > > >        A    D
> > > > >       /\   
> > > > >      B  C
> > > > > 
> > > > > is a different thing than
> > > > > 	root
> > > > >         / | \
> > > > >        B  C  D
> > > > >
> > > > 
> > > > I actually don't have a strong argument against an approach to select
> > > > largest leaf or kill-all-set memcg. I think, in practice there will be
> > > > no much difference.
> > > > 
> > > > The only real concern I have is that then we have to do the same with
> > > > oom_priorities (select largest priority tree-wide), and this will limit
> > > > an ability to enforce the priority by parent cgroup.
> > > > 
> > > 
> > > Yes, oom_priority cannot select the largest priority tree-wide for exactly 
> > > that reason.  We need the ability to control from which subtree the kill 
> > > occurs in ancestor cgroups.  If multiple jobs are allocated their own 
> > > cgroups and they can own memory.oom_priority for their own subcontainers, 
> > > this becomes quite powerful so they can define their own oom priorities.   
> > > Otherwise, they can easily override the oom priorities of other cgroups.
> > 
> > I believe, it's a solvable problem: we can require CAP_SYS_RESOURCE to set
> > the oom_priority below parent's value, or something like this.
> 
> As said in other email. We can make priorities hierarchical (in the same
> sense as hard limit or others) so that children cannot override their
> parent.

You mean they can set the knob to any value, but parent's value is enforced,
if it's greater than child's value?

If so, this sounds logical to me. Then we have size-based comparison and
priority-based comparison with similar rules, and all use cases are covered.

Ok, can we stick with this design?
Then I'll return oom_priorities in place, and post a (hopefully) final version.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
