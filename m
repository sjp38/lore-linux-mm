Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 3F89F6B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 12:55:10 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <c1c6c6fc-b7a1-4b04-a527-904eb2970340@default>
Date: Fri, 15 Mar 2013 09:54:44 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc limitations and related topics
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default>
 <20130313151359.GA3130@linux.vnet.ibm.com>
 <4ab899f6-208c-4d61-833c-d1e5e8b1e761@default>
 <514104D5.9020700@linux.vnet.ibm.com> <5141BC5D.9050005@oracle.com>
 <20130314132046.GA3172@linux.vnet.ibm.com>
 <006139fe-542e-46f0-8b6c-b05efeb232d6@default>
 <514348DD.2070801@linux.vnet.ibm.com>
In-Reply-To: <514348DD.2070801@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Robert Jennings <rcj@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, minchan@kernel.org, Nitin Gupta <nitingupta910@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: zsmalloc limitations and related topics
>=20
> On 03/14/2013 01:54 PM, Dan Magenheimer wrote:
> >> From: Robert Jennings [mailto:rcj@linux.vnet.ibm.com]
> >> Subject: Re: zsmalloc limitations and related topics
> >>
> >> * Bob (bob.liu@oracle.com) wrote:
> >>> On 03/14/2013 06:59 AM, Seth Jennings wrote:
> >>>> On 03/13/2013 03:02 PM, Dan Magenheimer wrote:
> >>>>>> From: Robert Jennings [mailto:rcj@linux.vnet.ibm.com]
> >>>>>> Subject: Re: zsmalloc limitations and related topics
> >>>>>
> >> <snip>
> >>>>> Yes.  And add pageframe-reclaim to this list of things that
> >>>>> zsmalloc should do but currently cannot do.
> >>>>
> >>>> The real question is why is pageframe-reclaim a requirement?  What
> >>>> operation needs this feature?
> >>>>
> >>>> AFAICT, the pageframe-reclaim requirements is derived from the
> >>>> assumption that some external control path should be able to tell
> >>>> zswap/zcache to evacuate a page, like the shrinker interface.  But t=
his
> >>>> introduces a new and complex problem in designing a policy that does=
n't
> >>>> shrink the zpage pool so aggressively that it is useless.
> >>>>
> >>>> Unless there is another reason for this functionality I'm missing.
> >>>>.
> >>>
> >>> Perhaps it's needed if the user want to enable/disable the memory
> >>> compression feature dynamically.
> >>> Eg, use it as a module instead of recompile the kernel or even
> >>> reboot the system.
> >
> > It's worth thinking about: Under what circumstances would a user want
> > to turn off compression?  While unloading a compression module should
> > certainly be allowed if it makes a user comfortable, in my opinion,
> > if a user wants to do that, we have done our job poorly (or there
> > is a bug).
> >
> >> To unload zswap all that is needed is to perform writeback on the page=
s
> >> held in the cache, this can be done by extending the existing writebac=
k
> >> code.
> >
> > Actually, frontswap supports this directly.  See frontswap_shrink.
>=20
> frontswap_shrink() is a best-effort attempt to fault in all the pages
> stored in the backend.  However, if there is not enough RAM to hold all
> the pages, then it can not completely evacuate the backend.
>=20
> Module exit functions must return void, so there is no way to fail a
> module unload.  If you implement an exit function for your module, you
> must insure that it can always complete successfully.  For this reason
> frontswap_shrink() is unsuitable for module unloading.  You'd need to
> use a mechanism like writeback that could surely evacuate the backend
> (baring I/O failures).

A single call to frontswap_shrink may be unsuitable... multiple
calls (do while zcache/zswap is not empty) may work fine.
Writeback-until-empty should also work fine.

In any case, it's a good point that module exit must succeed,
and that if there is already heavy memory pressure when zcache/zswap
module exit is invoked, module exit may be very very slow and cause
many many swap disk writes, so the system may become unresponsive
(and may even OOM).

So if someone implements zcache/zswap module unload, a thorough
test plan would be good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
