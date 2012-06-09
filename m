Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A18F76B0062
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 20:57:00 -0400 (EDT)
Message-ID: <1339203416.6893.10.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [PATCH 2/4] Add a __GFP_SLABMEMCG flag
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sat, 09 Jun 2012 09:56:56 +0900
In-Reply-To: <alpine.DEB.2.00.1206081430380.4213@router.home>
References: <1339148601-20096-1-git-send-email-glommer@parallels.com>
	 <1339148601-20096-3-git-send-email-glommer@parallels.com>
	 <alpine.DEB.2.00.1206081430380.4213@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbeck@gmail.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>

On Fri, 2012-06-08 at 14:31 -0500, Christoph Lameter wrote:
> On Fri, 8 Jun 2012, Glauber Costa wrote:
> 
> >   */
> >  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
> >
> > -#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
> > +#define __GFP_BITS_SHIFT 26	/* Room for N __GFP_FOO bits */
> >  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
> 
> Please make this conditional on CONFIG_MEMCG or so. The bit can be useful
> in particular on 32 bit architectures.

I really don't think that's at all a good idea.  It's asking for trouble
when we don't spot we have a flag overlap.  It also means that we're
trusting the reuser to know that their use case can never clash with
CONFIG_MEMGC and I can't think of any configuration where this is
possible currently.

I think making the flag define of __GFP_SLABMEMCG conditional might be a
reasonable idea so we get a compile failure if anyone tries to use it
when !CONFIG_MEMCG.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
