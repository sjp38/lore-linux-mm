Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 6A9386B0002
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 16:48:55 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <de471615-f58d-4bf6-a6b5-49994793894d@default>
Date: Fri, 12 Apr 2013 13:48:42 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc zbud hybrid design discussion?
References: <ef105888-1996-4c78-829a-36b84973ce65@default>
 <20130411193534.GB28296@cerebellum>
 <764b8d66-5456-4bd0-b7a4-5fa3aaf717dd@default>
 <20130412201512.GB18888@cerebellum>
In-Reply-To: <20130412201512.GB18888@cerebellum>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: zsmalloc zbud hybrid design discussion?
>=20
> On Thu, Apr 11, 2013 at 04:28:19PM -0700, Dan Magenheimer wrote:
> > (Bob Liu added)
> >
> > > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > > Subject: Re: zsmalloc zbud hybrid design discussion?
> > >
> > > On Wed, Mar 27, 2013 at 01:04:25PM -0700, Dan Magenheimer wrote:
> > > > Seth and all zproject folks --
> > > >
> > > > I've been giving some deep thought as to how a zpage
> > > > allocator might be designed that would incorporate the
> > > > best of both zsmalloc and zbud.
> > > >
> > > > Rather than dive into coding, it occurs to me that the
> > > > best chance of success would be if all interested parties
> > > > could first discuss (on-list) and converge on a design
> > > > that we can all agree on.  If we achieve that, I don't
> > > > care who writes the code and/or gets the credit or
> > > > chooses the name.  If we can't achieve consensus, at
> > > > least it will be much clearer where our differences lie.
> > > >
> > > > Any thoughts?
> >
> > Hi Seth!
> >
> > > I'll put some thoughts, keeping in mind that I'm not throwing zsmallo=
c under
> > > the bus here.  Just what I would do starting from scratch given all t=
hat has
> > > happened.
> >
> > Excellent.  Good food for thought.  I'll add some of my thinking
> > too and we can talk more next week.
> >
> > BTW, I'm not throwing zsmalloc under the bus either.  I'm OK with
> > using zsmalloc as a "base" for an improved hybrid, and even calling
> > the result "zsmalloc".  I *am* however willing to throw the
> > "generic" nature of zsmalloc away... I think the combined requirements
> > of the zprojects are complex enough and the likelihood of zsmalloc
> > being appropriate for future "users" is low enough, that we should
> > accept that zsmalloc is highly tuned for zprojects and modify it
> > as required.  I.e. the API to zsmalloc need not be exposed to and
> > documented for the rest of the kernel.
> >
> > > Simplicity - the simpler the better
> >
> > Generally I agree.  But only if the simplicity addresses the
> > whole problem.  I'm specifically very concerned that we have
> > an allocator that works well across a wide variety of zsize distributio=
ns,
> > even if it adds complexity to the allocator.
> >
> > > High density - LZO best case is ~40 bytes. That's around 1/100th of a=
 page.
> > > I'd say it should support up to at least 64 object per page in the be=
st case.
> > > (see Reclaim effectiveness before responding here)
> >
> > Hmmm... if you pre-check for zero pages, I would guess the percentage
> > of pages with zsize less than 64 is actually quite small.  But 64 size
> > classes may be a good place to start as long as it doesn't overly
> > complicate or restrict other design points.
> >
> > > No slab - the slab approach limits LRU and swap slot locality within =
the pool
> > > pages.  Also swap slots have a tendency to be freed in clusters.  If =
we improve
> > > locality within each pool page, it is more likely that page will be f=
reed
> > > sooner as the zpages it contains will likely be invalidated all toget=
her.
> >
> > "Pool page" =3D?=3D "pageframe used by zsmalloc"
>=20
> Yes.
>=20
> >
> > Isn't it true that that there is no correlation between whether a
> > page is in the same cluster and the zsize (and thus size class) of
> > the zpage?  So every zpage may end up in a different pool page
> > and this theory wouldn't work.  Or am I misunderstanding?
>=20
> I think so.  I didn't say this outright and should have: I'm thinking alo=
ng the
> lines of a first-fit type method.  So you just stack zpages up in a page =
until
> the page is full then allocate a new one.  Searching for free slots would
> ideally be done in reverse LRU so that you put new zpages in the most rec=
ently
> allocated page that has room.  I'm still thinking how to do that efficien=
tly.

OK I see.  You probably know that the xvmalloc allocator did something like
that.  I didn't study that code much but Nitin thought zsmalloc was much
superior to xvmalloc.

> > > Also, take a note out of the zbud playbook at track LRU based on pool=
 pages,
> > > not zpages.  One would fill allocation requests from the most recentl=
y used
> > > pool page.
> >
> > Yes, I'm also thinking that should be in any hybrid solution.
> > A "global LRU queue" (like in zbud) could also be applicable to entire =
zspages;
> > this is similar to pageframe-reclaim except all the pageframes in a zsp=
age
> > would be claimed at the same time.
>=20
> This brings up another thing that I left out that might be the stickiest =
part,
> eviction and reclaim.  We first have to figure out if eviction is going t=
o be
> initiated by the user or by the allocator.
>=20
> If we do it in the allocator, then I think we are going to muck up the AP=
I
> because you'll have to register and eviction notification function that t=
he
> allocator can call, once for each zpage in the page frame the allocator i=
s
> trying to reclaim/free.  The locking might get hairy in that case (user -=
>
> allocator -> user).  Additionally the user would have to maintain a diffe=
rent
> lookup system for zpages by address/handle.  Alternatively, you could
> add yet another user-provided callback function to extract the users zpag=
e
> identifier, like zbuds tmem_handle, from the zpage itself.
>=20
> The advantage of doing it in the allocator is it has a page-level view of=
 what
> is going on and therefore can target zpages for eviction in order to free=
 up
> entire page frames.  If the allocator doesn't do this job, then it would =
have
> to have some API for providing information to the user about which zpages
> share a page with a given zpage so that the user can initiate the evictio=
n.
>=20
> Either way, it's challenging to make clean.

Agreed.  I've thought of some steps to make zbud's cleaner that could
be applied to zsmalloc-with-page-reclaim too.  They are NOT clean only
cleaner.  That's one reason why I am less concerned about making
zsmalloc a clean, generic, available-to-future-kernel-users allocator...
I'd rather it fulfill our requirements first now than worry about
cleanness.

I'm mostly offline now for the next few days and will see
you at LCS/LSFMM!

Dan

> > > Reclaim effectiveness - conflicts with density. As the number of zpag=
es per
> > > page increases, the odds decrease that all of those objects will be
> > > invalidated, which is necessary to free up the underlying page, since=
 moving
> > > objects out of sparely used pages would involve compaction (see next)=
.  One
> > > solution is to lower the density, but I think that is self-defeating =
as we lose
> > > much the compression benefit though fragmentation. I think the better=
 solution
> > > is to improve the likelihood that the zpages in the page are likely t=
o be freed
> > > together through increased locality.
> >
> > I do think we should seriously reconsider ZS_MAX_ZSPAGE_ORDER=3D=3D2.
> > The value vs ZS_MAX_ZSPAGE_ORDER=3D=3D0 is enough for most cases and
> > 1 is enough for the rest.  If get_pages_per_zspage were "flexible",
> > there might be a better tradeoff of density vs reclaim effectiveness.
> >
> > I've some ideas along the lines of a hybrid adaptively combining
> > buddying and slab which might make it rarely necessary to have
> > pages_per_zspage exceed 2.  That also might make it much easier
> > to have "variable sized" zspages (size is always one or two).
> >
> > > Not a requirement:
> > >
> > > Compaction - compaction would basically involve creating a virtual ad=
dress
> > > space of sorts, which zsmalloc is capable of through its API with han=
dles,
> > > not pointer.  However, as Dan points out this requires a structure th=
e maintain
> > > the mappings and adds to complexity.  Additionally, the need for comp=
action
> > > diminishes as the allocations are short-lived with frontswap backends=
 doing
> > > writeback and cleancache backends shrinking.
> >
> > I have an idea that might be a step towards compaction but
> > it is still forming.  I'll think about it more and, if
> > it makes sense by then, we can talk about it next week.
> >
> > > So just some thoughts to start some specific discussion.  Any thought=
s?
> >
> > Thanks for your thoughts and moving the conversation forward!
> > It will be nice to talk about this f2f instead of getting sore
> > fingers from long typing!
>=20
> Agreed! Talking has much higher throughput than typing :)
>=20
> Thanks,
> Seth
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
