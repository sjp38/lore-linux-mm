Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id AC2686B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 15:17:32 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b34c65c9-4b25-431d-8b82-cbe911126be9@default>
Date: Mon, 24 Sep 2012 12:17:15 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120921161252.GV11266@suse.de> <20120921180222.GA7220@phenom.dumpdata.com>
 <505CB9BC.8040905@linux.vnet.ibm.com>
 <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default>
 <50609794.8030508@linux.vnet.ibm.com>
In-Reply-To: <50609794.8030508@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [RFC] mm: add support for zsmalloc and zcache

Once again, you have completely ignored a reasonable
compromise proposal.  Why?

> According to Greg's staging-next, ramster adds 6000 lines of
> new code to zcache.
>   :
> functionally whose code doubles the size of the origin

Indeed, and the 6K lines is all in the ramster-specific directory.
I am not asking that ramster be promoted, only that the small
handful of hooks that enable ramster should exist in zcache
(and tmem) if/when zcache is promoted.  And zcache1+zsmalloc
does not have that.
=20
> Lets be clear about what zcache2 is.  It is not a rewrite in
> the way most people think: a refactored codebase the caries
> out the same functional set as an original codebase.  It is
> an _overwrite_ to accommodate an entirely new set of
> functionally whose code doubles the size of the origin
> codebase and regresses performance on the original
> functionality.

There were some design deficiencies necessary to support a
range of workloads (other than just kernbench) and that
required some redesign.  Those have been clearly documented
in the post of zcache2 and discussed in other threads.  Other
than janitorial work (much of which was proposed by other people).
zcache2 is actually _less_ of  rewrite than most people think.

By "performance regression", you mean it doesn't use zsmalloc
because zbud has to make more conservative assumptions than
"works really well on kernbench".  Mel identified his preference
for conservative assumptions.  The compromise I have
proposed will give you back zsmalloc for your use kernbench
use case.  Why is that not good enough?

Overwrite was simply a mechanism to avoid a patch post that
nobody (other than you) would be able to read.  Anyone
can do a diff. Focusing on the patch mechanism is a red herring.

> > 4. Seth believes that zcache will be promoted out of staging sooner
> >    because, except for a few nits, it is ready today.
> >
> > Cons for (A):
> > 1. Nobody has signed up to do the work, including testing.  It
> >    took the author (and sole expert on all the components
> >    except zsmalloc) between two and three months essentially
> >    fulltime to move zcache1->zcache2.  So forward progress on
> >    zcache will likely be essentially frozen until at least the
> >    end of 2012, possibly a lot longer.
>=20
> This is not true.  I have agreed to do the work necessary to
> make zcache1 acceptable for mainline, which can include
> merging changes from zcache2 if people agree it is a blocker.
>  :
> What is "properly finished"?

In the compromise I have proposed, the work is already done.

You have claimed that that work is not necessary, because it
doesn't help zsmalloc or kernbench.  You have refused to
adapt zsmalloc to meet the needs I have described.  Further
(and sorry to be so horribly blunt in public but, by claiming
you are going to do the work, you are asking for it), you have
NOT designed or written any significant code in the kernel,
just patched and bugfixed and tested and run kernbench on
zcache.  (Zsmalloc, which you have championed, was written
by Nitin and adapted by you.)

And you've continued with (IMHO) disingenuous behavior.
While I understand all too well why that may be necessary
when working for a big company, it makes it very hard to
identify an acceptable compromise.

So, no I don't really trust that you have either the intent
or ability to do the redesigns that I feel (and echoed by
Andrea and Mel) are necessary for zcache to be more than
toy "demo" code.

> The continuous degradation of zcache as "demo" and the

I call it demo code because I wrote it as a demo to
show that in-kernel compression could be a user of
cleancache and frontswap.

I'm not criticizing your code or anyone else's,
I am criticizing MY OWN code.  I had no illusion
that zcache (aka zcache1) was ready for promotion.
It sucked in a number of ways.  MM developers with
real experience in the complexity of managing memory,
Mel and Andrea, without digging very hard, identified
those same ways it sucks.  I'm trying to fix those.
Are you?

> assertion that zcache2 is the "solid codebase" is tedious.
> zcache is actually being worked on by others and has been in
> staging for years.  By definition, _it_ is the more
> hardended codebase.

Please be more specific (and I don't mean a meaningless count
of patches).  Other than your replacement of xvmalloc with
zsmalloc and a bug fix or three, can you point to anything
that was more than cleanup?  Can you point to any broad
workload testing?  And for those two Android distros that have
included zcache (despite the fact that anything in staging
taints the kernel), can you demonstrate that those distros=20
have enabled it or even documented to their users _how_ to
enable it?

> If there are results showing that zcache2 has superior
> performance and stability on the existing use cases please
> share them.  Otherwise this characterization is just propaganda.

Neither of us can demonstrate superior performance on
anything other than kernbench, nor stability on use
cases other than kernbench.  You have repeatedly stated
that performance and stability on kernbench is sufficient
for promotion.

But I agree that it is propaganda regardless of who states
it, so if you stop claiming zcache1 has had enough exposure
to warrant promotion, I won't say that zcache2 is
more stable.

> > 4. Zcache2 already has the foundation in place for "reclaim
> >    frontswap zpages", which mm experts have noted is a critical
> >    requirement for broader zcache acceptance (e.g. KVM).
>=20
> This is dead code in zcache2 right now and relies on
> yet-to-be-posted changes to the core mm to work.
>=20
> My impression is that folks are ok with adding this
> functionality to zcache if/when a good way to do it is
> presented, and it's absence is not a blocker for acceptance.

Andrea and Mel have both stated they think it is necessary.
Much of the redesign in zcache2 is required to provide
it.  And it is yet-to-be-posted because I'm wasting so
much time quibbling with you so that the foundation design
changes and code necessary don't get thrown away.

> > 5. Ramster is already a small incremental addition to core zcache2 code
> >    rather than a fork.
>=20
> In summary, I really don't understand the objection to
> promoting zcache and integrating zcache2 improvements and
> features incrementally.  It seems very natural and
> straightforward to me.  Rewrites can even happen in
> mainline, as James pointed out.  Adoption in mainline just
> provides a more stable environment for more people to use
> and contribute to zcache.

And I, as I have stated repeatedly, don't understand why
anyone would argue to throw away (or even re-do) months of
useful work when a reasonable compromise has been proposed.

James pointed out that the design should best be evolved
until it is right _while_ in staging and, _if_ _necessary_
redesigns can be done after promotion.  You have repeatedly
failed to identify why you think it is necessary to do
it bass-ackwards.

> zcache2 also crashes on PPC64, which uses 64k pages, because
> a 4k maximum page size is hard coded into the new zbudpage
> struct.

OK, that sounds like a bug on a machine few developers have
access to.  So let's fix it (on zcache2).  It doesn't sound
to me like a reason to throw away all the forward progress
and work put into zcache2.  But with the compromise
I proposed, zcache2+zsmalloc wouldn't use zbud on
PPC64 anyway, right?

I simply do NOT understand why you are fighting so hard to
promote old code that works on toy benchmarks.  I'm fighting
for the integrity of a signficiant memory management feature
that _I_ wrote, and _I_ understand thoroughly enough to know
its design flaws, and have demonstrated the desire
and ability to continue to develop/evolve/finish.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
