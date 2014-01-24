Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 81B746B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 23:05:43 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mx11so870870bkb.2
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 20:05:43 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id lk6si1216550bkb.132.2014.01.23.20.05.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 20:05:42 -0800 (PST)
Date: Thu, 23 Jan 2014 23:05:31 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: oom_kill: revert 3% system memory bonus for
 privileged tasks
Message-ID: <20140124040531.GF4407@cmpxchg.org>
References: <20140115234308.GB4407@cmpxchg.org>
 <alpine.DEB.2.02.1401151614480.15665@chino.kir.corp.google.com>
 <20140116070709.GM6963@cmpxchg.org>
 <alpine.DEB.2.02.1401212050340.8512@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401212050340.8512@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 21, 2014 at 08:53:07PM -0800, David Rientjes wrote:
> On Thu, 16 Jan 2014, Johannes Weiner wrote:
> 
> > > Unfortunately, I think this could potentially be too much of a bonus.  On 
> > > your same 32GB machine, if a root process is using 18GB and a user process 
> > > is using 14GB, the user process ends up getting selected while the current 
> > > discount of 3% still selects the root process.
> > > 
> > > I do like the idea of scaling this bonus depending on points, however.  I 
> > > think it would be better if we could scale the discount but also limit it 
> > > to some sane value.
> > 
> > I just reverted to the /= 4 because we had that for a long time and it
> > seemed to work.  I don't really mind either way as long as we get rid
> > of that -3%.  Do you have a suggestion?
> > 
> 
> How about simply using 3% of the root process's points so that root 
> processes get some bonus compared to non-root processes with the same 
> memory usage and it's scaled to the usage rather than amount of available 
> memory?
> 
> So rather than points /= 4, we do
> 
> 	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> 		points -= (points * 3) / 100;
> 
> instead.  Sound good?

Yes, should be okay.

Do you want to send a patch?  Want me to update mine?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
