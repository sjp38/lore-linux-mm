Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1396B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 12:23:59 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y6so19715778lff.0
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 09:23:59 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 8si13757966lff.273.2016.09.20.09.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 09:23:57 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id s64so1183898lfs.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 09:23:57 -0700 (PDT)
Date: Tue, 20 Sep 2016 18:23:53 +0200
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: Re: [PATCH] mm/mempolicy.c: forbid static or relative flags for
 local NUMA mode
Message-ID: <20160920162352.GC3899@home>
References: <20160918112943.1645-1-kwapulinski.piotr@gmail.com>
 <65cb95b8-4521-cc4c-a30c-e6c23731479c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65cb95b8-4521-cc4c-a30c-e6c23731479c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, rientjes@google.com, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, linux-man@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>

On Tue, Sep 20, 2016 at 05:12:16PM +0200, Vlastimil Babka wrote:
> [CC += linux-api@vger.kernel.org]
> 
>     Since this is a kernel-user-space API change, please CC linux-api@. The
> kernel source file Documentation/SubmitChecklist notes that all Linux kernel
> patches that change userspace interfaces should be CCed to
> linux-api@vger.kernel.org, so that the various parties who are interested in
> API changes are informed. For further information, see
> https://www.kernel.org/doc/man-pages/linux-api-ml.html
> 
> I think man page should document the change? Also I noticed that MPOL_NUMA
> itself is missing in the man page...
> 
> On 09/18/2016 01:29 PM, Piotr Kwapulinski wrote:
> > The MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES flags are irrelevant
> > when setting them for MPOL_LOCAL NUMA memory policy via set_mempolicy.
> > Return the "invalid argument" from set_mempolicy whenever
> > any of these flags is passed along with MPOL_LOCAL.
> > It is consistent with MPOL_PREFERRED passed with empty nodemask.
> > It also slightly shortens the execution time in paths where these flags
> > are used e.g. when trying to rebind the NUMA nodes for changes in
> > cgroups cpuset mems (mpol_rebind_preferred()) or when just printing
> > the mempolicy structure (/proc/PID/numa_maps).
> 
> Hmm not sure I understand. How does change in mpol_new() affect
> mpol_rebind_preferred()?
When MPOL_LOCAL is passed to set_mempolicy along with empty nodemask 
it is transformed into MPOL_PREFERRED (inside mpol_new()).
Unlike MPOL_PREFERRED the MPOL_LOCAL may be set along with 
MPOL_F_STATIC_NODES or MPOL_F_RELATIVE_NODES flag (inconsistency).
Later on when the set of allowed NUMA nodes is changed by cgroups 
cpuset.mems the mpol_rebind_preferred() is called. Because one of
the flags is set the unnecessary code is executed. The same is for
mpol_to_str().

> 
> Vlastimil
> 
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
> > 
> 

--
Piotr Kwapulinski

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
