Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 2BD586B0036
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 19:28:29 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <764b8d66-5456-4bd0-b7a4-5fa3aaf717dd@default>
Date: Thu, 11 Apr 2013 16:28:19 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc zbud hybrid design discussion?
References: <ef105888-1996-4c78-829a-36b84973ce65@default>
 <20130411193534.GB28296@cerebellum>
In-Reply-To: <20130411193534.GB28296@cerebellum>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.orgBob Liu <bob.liu@oracle.com>

(Bob Liu added)

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: zsmalloc zbud hybrid design discussion?
>=20
> On Wed, Mar 27, 2013 at 01:04:25PM -0700, Dan Magenheimer wrote:
> > Seth and all zproject folks --
> >
> > I've been giving some deep thought as to how a zpage
> > allocator might be designed that would incorporate the
> > best of both zsmalloc and zbud.
> >
> > Rather than dive into coding, it occurs to me that the
> > best chance of success would be if all interested parties
> > could first discuss (on-list) and converge on a design
> > that we can all agree on.  If we achieve that, I don't
> > care who writes the code and/or gets the credit or
> > chooses the name.  If we can't achieve consensus, at
> > least it will be much clearer where our differences lie.
> >
> > Any thoughts?

Hi Seth!
=20
> I'll put some thoughts, keeping in mind that I'm not throwing zsmalloc un=
der
> the bus here.  Just what I would do starting from scratch given all that =
has
> happened.

Excellent.  Good food for thought.  I'll add some of my thinking
too and we can talk more next week.

BTW, I'm not throwing zsmalloc under the bus either.  I'm OK with
using zsmalloc as a "base" for an improved hybrid, and even calling
the result "zsmalloc".  I *am* however willing to throw the
"generic" nature of zsmalloc away... I think the combined requirements
of the zprojects are complex enough and the likelihood of zsmalloc
being appropriate for future "users" is low enough, that we should
accept that zsmalloc is highly tuned for zprojects and modify it
as required.  I.e. the API to zsmalloc need not be exposed to and
documented for the rest of the kernel.
=20
> Simplicity - the simpler the better

Generally I agree.  But only if the simplicity addresses the
whole problem.  I'm specifically very concerned that we have
an allocator that works well across a wide variety of zsize distributions,
even if it adds complexity to the allocator.

> High density - LZO best case is ~40 bytes. That's around 1/100th of a pag=
e.
> I'd say it should support up to at least 64 object per page in the best c=
ase.
> (see Reclaim effectiveness before responding here)

Hmmm... if you pre-check for zero pages, I would guess the percentage
of pages with zsize less than 64 is actually quite small.  But 64 size
classes may be a good place to start as long as it doesn't overly
complicate or restrict other design points.

> No slab - the slab approach limits LRU and swap slot locality within the =
pool
> pages.  Also swap slots have a tendency to be freed in clusters.  If we i=
mprove
> locality within each pool page, it is more likely that page will be freed
> sooner as the zpages it contains will likely be invalidated all together.

"Pool page" =3D?=3D "pageframe used by zsmalloc"

Isn't it true that that there is no correlation between whether a
page is in the same cluster and the zsize (and thus size class) of
the zpage?  So every zpage may end up in a different pool page
and this theory wouldn't work.  Or am I misunderstanding?

> Also, take a note out of the zbud playbook at track LRU based on pool pag=
es,
> not zpages.  One would fill allocation requests from the most recently us=
ed
> pool page.

Yes, I'm also thinking that should be in any hybrid solution.
A "global LRU queue" (like in zbud) could also be applicable to entire zspa=
ges;
this is similar to pageframe-reclaim except all the pageframes in a zspage
would be claimed at the same time.

> Reclaim effectiveness - conflicts with density. As the number of zpages p=
er
> page increases, the odds decrease that all of those objects will be
> invalidated, which is necessary to free up the underlying page, since mov=
ing
> objects out of sparely used pages would involve compaction (see next).  O=
ne
> solution is to lower the density, but I think that is self-defeating as w=
e lose
> much the compression benefit though fragmentation. I think the better sol=
ution
> is to improve the likelihood that the zpages in the page are likely to be=
 freed
> together through increased locality.

I do think we should seriously reconsider ZS_MAX_ZSPAGE_ORDER=3D=3D2.
The value vs ZS_MAX_ZSPAGE_ORDER=3D=3D0 is enough for most cases and
1 is enough for the rest.  If get_pages_per_zspage were "flexible",
there might be a better tradeoff of density vs reclaim effectiveness.

I've some ideas along the lines of a hybrid adaptively combining
buddying and slab which might make it rarely necessary to have
pages_per_zspage exceed 2.  That also might make it much easier
to have "variable sized" zspages (size is always one or two).

> Not a requirement:
>=20
> Compaction - compaction would basically involve creating a virtual addres=
s
> space of sorts, which zsmalloc is capable of through its API with handles=
,
> not pointer.  However, as Dan points out this requires a structure the ma=
intain
> the mappings and adds to complexity.  Additionally, the need for compacti=
on
> diminishes as the allocations are short-lived with frontswap backends doi=
ng
> writeback and cleancache backends shrinking.

I have an idea that might be a step towards compaction but
it is still forming.  I'll think about it more and, if
it makes sense by then, we can talk about it next week.

> So just some thoughts to start some specific discussion.  Any thoughts?

Thanks for your thoughts and moving the conversation forward!
It will be nice to talk about this f2f instead of getting sore
fingers from long typing!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
