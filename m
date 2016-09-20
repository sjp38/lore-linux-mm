Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 78EED6B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:47:25 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b71so5587387lfg.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 08:47:25 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id j130si12878870lfd.196.2016.09.20.08.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 08:47:23 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id s29so1136561lfg.3
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 08:47:23 -0700 (PDT)
Date: Tue, 20 Sep 2016 17:47:20 +0200
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: Re: [PATCH] mm/mempolicy.c: forbid static or relative flags for
 local NUMA mode
Message-ID: <20160920154719.GA3899@home>
References: <20160918112943.1645-1-kwapulinski.piotr@gmail.com>
 <20160919115204.GL10785@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160919115204.GL10785@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, vbabka@suse.cz, rientjes@google.com, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 19, 2016 at 01:52:05PM +0200, Michal Hocko wrote:
> On Sun 18-09-16 13:29:43, Piotr Kwapulinski wrote:
> > The MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES flags are irrelevant
> > when setting them for MPOL_LOCAL NUMA memory policy via set_mempolicy.
> > Return the "invalid argument" from set_mempolicy whenever
> > any of these flags is passed along with MPOL_LOCAL.
> 
> man 2 set_mempolicy doesn't list this as invalid option. Maybe this is a
> documentation bug but is it possible that somebody will see this as an
> unexpected error?
> 
The MPOL_LOCAL is currently not documented in "man set_mempolicy(2)".
In case the nodemask is empty for MPOL_LOCAL it is transformed into MPOL_PREFERRED.
The motivation for disabling MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES
flags for MPOL_PREFERRED with empty nodemask is described at this commit
3e1f064562fcff7. Currently I call set_mempolicy(MPOL_LOCAL, ...) via the syscall()
but despite of that it is inconsistent with MPOL_PREFERRED.

> > It is consistent with MPOL_PREFERRED passed with empty nodemask.
> > It also slightly shortens the execution time in paths where these flags
> > are used e.g. when trying to rebind the NUMA nodes for changes in
> > cgroups cpuset mems (mpol_rebind_preferred()) or when just printing
> > the mempolicy structure (/proc/PID/numa_maps).
> 
> I am not sure I understand this argument. What does this patch actually
> fix? If this is about the execution time then why not just bail out
> early when MPOL_LOCAL && (MPOL_F_STATIC_NODES || MPOL_F_RELATIVE_NODES)
>
The mpol_new() performs additional checks on nodemask.

> > Isolated tests done.
> > 
> > Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
> > ---
> >  mm/mempolicy.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 2da72a5..27b07d1 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -276,7 +276,9 @@ static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
> >  				return ERR_PTR(-EINVAL);
> >  		}
> >  	} else if (mode == MPOL_LOCAL) {
> > -		if (!nodes_empty(*nodes))
> > +		if (!nodes_empty(*nodes) ||
> > +		    (flags & MPOL_F_STATIC_NODES) ||
> > +		    (flags & MPOL_F_RELATIVE_NODES))
> >  			return ERR_PTR(-EINVAL);
> >  		mode = MPOL_PREFERRED;
> >  	} else if (nodes_empty(*nodes))
> > -- 
> > 2.9.2
> 
> -- 
> Michal Hocko
> SUSE Labs

--
Piotr Kwapulinski

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
