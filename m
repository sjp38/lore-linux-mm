Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id EBFD76B0100
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 05:01:57 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9619335pbb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 02:01:57 -0700 (PDT)
Date: Tue, 26 Jun 2012 02:01:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 03/11] memcg: change defines to an enum
In-Reply-To: <4FE972B2.1020509@parallels.com>
Message-ID: <alpine.DEB.2.00.1206260154360.16020@chino.kir.corp.google.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-4-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206252110470.26640@chino.kir.corp.google.com> <4FE972B2.1020509@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On Tue, 26 Jun 2012, Glauber Costa wrote:

> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 8e601e8..9352d40 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -387,9 +387,12 @@ enum charge_type {
> > >   };
> > > 
> > >   /* for encoding cft->private value on file */
> > > -#define _MEM			(0)
> > > -#define _MEMSWAP		(1)
> > > -#define _OOM_TYPE		(2)
> > > +enum res_type {
> > > +	_MEM,
> > > +	_MEMSWAP,
> > > +	_OOM_TYPE,
> > > +};
> > > +
> > >   #define MEMFILE_PRIVATE(x, val)	((x) << 16 | (val))
> > >   #define MEMFILE_TYPE(val)	((val) >> 16 & 0xffff)
> > >   #define MEMFILE_ATTR(val)	((val) & 0xffff)
> > 
> > Shouldn't everything that does MEMFILE_TYPE() now be using type
> > enum res_type rather than int?
> > 
> If you mean the following three fields, no, since they are masks and
> operations.
> 

No, I mean everything in mm/memcontrol.c that does

	int type = MEMFILE_TYPE(...).

Why define a non-anonymous enum if you're not going to use its type?  
Either use enum res_type in place of int or define the enum to be 
anonymous.

It's actually quite effective since gcc will warn if you're using the 
value of an enum type in your switch() statements later in this series and 
one of the enum fields is missing (if you avoid using a "default" case 
statement) if you pass -Wswitch, which is included in -Wall.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
