Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id D03046B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:39:32 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <38a8bed3-7249-42c3-affb-7da0592aaf80@default>
Date: Thu, 14 Mar 2013 10:39:06 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc limitations and related topics
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default>
 <20130313151359.GA3130@linux.vnet.ibm.com>
 <4ab899f6-208c-4d61-833c-d1e5e8b1e761@default>
 <514104D5.9020700@linux.vnet.ibm.com>
In-Reply-To: <514104D5.9020700@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Robert Jennings <rcj@linux.vnet.ibm.com>, minchan@kernel.org, Nitin Gupta <nitingupta910@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: zsmalloc limitations and related topics

Hi Seth --

Thanks for the reply.  I think it is very important to
be having these conversations.

> >>> 2) When not full and especially when nearly-empty _after_
> >>>    being full, density may fall below 1.0 as a result of
> >>>    fragmentation.
> >>
> >> True and there are several ways to address this including
> >> defragmentation, fewer class sizes in zsmalloc, aging, and/or writebac=
k
> >> of zpages in sparse zspages to free pageframes during normal writeback=
.
> >
> > Yes.  And add pageframe-reclaim to this list of things that
> > zsmalloc should do but currently cannot do.
>=20
> The real question is why is pageframe-reclaim a requirement?

It is because pageframes are the currency of the MM subsystem.
See more below.

> What operation needs this feature?
> AFAICT, the pageframe-reclaim requirements is derived from the
> assumption that some external control path should be able to tell
> zswap/zcache to evacuate a page, like the shrinker interface.  But this
> introduces a new and complex problem in designing a policy that doesn't
> shrink the zpage pool so aggressively that it is useless.
>=20
> Unless there is another reason for this functionality I'm missing.

That's the reason.  IMHO, it is precisely this "new and complex"
problem that we must solve.  Otherwise, compression is just a cool toy
that may (or may not) help your workload if you turn it on.

Zcache already does implement "a policy that doesn't shrink the
zpage pool so aggressively that it is useless".  While I won't
claim the policy is the right one, it is a policy, it is not
particularly complex, and it is definitely not useless.  And
it depends on pageframe-reclaim.

> >>> 3) Zsmalloc has a density of exactly 1.0 for any number of
> >>>    zpages with zsize >=3D 0.8.
> >>
> >> For this reason zswap does not cache pages which in this range.
> >> It is not enforced in the allocator because some users may be forced t=
o
> >> store these pages; users like zram.
> >
> > Again, without a "representative" workload, we don't know whether
> > or not it is important to manage pages with zsize >=3D 0.8.  You are
> > simply dismissing it as unnecessary because zsmalloc can't handle
> > them and because they don't appear at any measurable frequency
> > in kernbench or SPECjbb.  (Zbud _can_ efficiently handle these larger
> > pages under many circumstances... but without a "representative" worklo=
ad,
> > we don't know whether or not those circumstances will occur.)
>=20
> The real question is not whether any workload would operate on pages
> that don't compress to 80%.  Any workload that operates on pages of
> already compressed or encrypted data would do this.  The question is, is
> it worth it to store those pages in the compressed cache since the
> effective reclaim efficiency approaches 0.

You are letting the implementation of zsmalloc color your
thinking.  Zbud can quite efficiently store pages that compress
up to zsize =3D ((63 * PAGE_SIZE) / 64) because it buddies highly
compressible pages with poorly compressible pages.  This is also,
of course, very zsize-distribution-dependent.

(These are not just already-compressed or encrypted data, although
those are good examples.  Compressibility is related to
entropy, and there may be many anonymous pages that have
high entropy.  We really just don't know.)

> >>> 4) Zsmalloc contains several compile-time parameters;
> >>>    the best value of these parameters may be very workload
> >>>    dependent.
> >>
> >> The parameters fall into two major areas, handle computation and class
> >> size.  The handle can be abstracted away, eliminating the compile-time
> >> parameters.  The class-size tunable could be changed to a default valu=
e
> >> with the option for specifying an alternate value from the user during
> >> pool creation.
> >
> > Perhaps my point here wasn't clear so let me be more blunt:
> > There's no way in hell that even a very sophisticated user
> > will know how to set these values.  I think we need to
> > ensure either that they are "always right" (which without
> > a "representative workload"...) or, preferably, have some way
> > so that they can dynamically adapt at runtime.
>=20
> I think you made the point that if this "representative workload" is
> completely undefined, then having tunables for zsmalloc that are "always
> right" is also not possible.  The best we can hope for is "mostly right"
> which, of course, is difficult to get everyone to agree on and will be
> based on usage.

I agree "always right" is impossible and, as I said, would
prefer adaptable.  I think zsmalloc and zbud address very different
zsize-distributions so some combination may be better than either
by itself.

> >>> If density =3D=3D 1.0, that means we are paying the overhead of
> >>> compression+decompression for no space advantage.  If
> >>> density < 1.0, that means using zsmalloc is detrimental,
> >>> resulting in worse memory pressure than if it were not used.
> >>>
> >>> WORKLOAD ANALYSIS
> >>>
> >>> These limitations emphasize that the workload used to evaluate
> >>> zsmalloc is very important.  Benchmarks that measure data
> >>> throughput or CPU utilization are of questionable value because
> >>> it is the _content_ of the data that is particularly relevant
> >>> for compression.  Even more precisely, it is the "entropy"
> >>> of the data that is relevant, because the amount of
> >>> compressibility in the data is related to the entropy:
> >>> I.e. an entirely random pagefull of bits will compress poorly
> >>> and a highly-regular pagefull of bits will compress well.
> >>> Since the zprojects manage a large number of zpages, both
> >>> the mean and distribution of zsize of the workload should
> >>> be "representative".
> >>>
> >>> The workload most widely used to publish results for
> >>> the various zprojects is a kernel-compile using "make -jN"
> >>> where N is artificially increased to impose memory pressure.
> >>> By adding some debug code to zswap, I was able to analyze
> >>> this workload and found the following:
> >>>
> >>> 1) The average page compressed by almost a factor of six
> >>>    (mean zsize =3D=3D 694, stddev =3D=3D 474)
> >>> 2) Almost eleven percent of the pages were zero pages.  A
> >>>    zero page compresses to 28 bytes.
> >>> 3) On average, 77% of the bytes (3156) in the pages-to-be-
> >>>    compressed contained a byte-value of zero.
> >>> 4) Despite the above, mean density of zsmalloc was measured at
> >>>    3.2 zpages/pageframe, presumably losing nearly half of
> >>>    available space to fragmentation.
> >>>
> >>> I have no clue if these measurements are representative
> >>> of a wide range of workloads over the lifetime of a booted
> >>> machine, but I am suspicious that they are not.  For example,
> >>> the lzo1x compression algorithm claims to compress data by
> >>> about a factor of two.
> >>
> >> I'm suspicious of the "factor of two" claim.  The reference
> >> (http://www.oberhumer.com/opensource/lzo/lzodoc.php) for this would ap=
pear
> >> to be the results of compressing the Calgary Corpus.  This is fine for
> >> comparing compression algorithms but I would be hesitant to apply that
> >> to this problem space.  To illustrate the affect of input set, the new=
er
> >> Canterbury Corpus compresses to ~43% of the input size using LZO1X-1.
> >
> > Yes, agreed, we have no idea if the Corpus is representative of
> > this problem space... because we have no idea what would
> > be a "representative workload" for this problem space.
> >
> > But for how I was using "factor of two", a factor of 100/43=3D~2.3 is
> > close enough.  I was only trying to say "factor of two" may be
> > more "representative" than the "factor of six" in kernbench.
>=20
> Again, this "representative workload" is undefined to the point of
> uselessness.  At this point _any_ actual workload is more useful than
> this undefined representative.

I think you are just saying that, on a scale of zero to infinity,
"one" is better than "zero".  While I can't argue with that logic,
I'd prefer "many" to "one", and I'd prefer some theoretical foundation
which implies that "many" and "very many" will be similar.

> > (As an aside, I like the data Nitin collected here:
> > http://code.google.com/p/compcache/wiki/CompressedLengthDistribution
> > as it shows how different workloads can result in dramatically
> > different zsize distributions.  However, this data includes
> > all the pages in a running system, including both anonymous
> > and file pages, and doesn't include mean/stddev.)
> >
> >> In practice the average for LZO would be workload dependent, as you
> >> demonstrate with the kernel build.  Swap page entropy for any given
> >> workload will not necessarily fit the distribution present in the
> >> Calgary Corpus.  The high density allocation design in zsmalloc allows
> >> for workloads that can compress to factors greater than 2 to do so.
> >
> > Exactly.  But at what cost on other workloads?  And how do we evaluate
> > the cost/benefit of that high density? (... without a "representative
> > workload" ;-)
> >
> >>> I would welcome ideas on how to evaluate workloads for
> >>> "representativeness".  Personally I don't believe we should
> >>> be making decisions about selecting the "best" algorithms
> >>> or merging code without an agreement on workloads.
> >>
> >> I'd argue that there is no such thing as a "representative workload".
> >> Instead, we try different workloads to validate the design and illustr=
ate
> >> the performance characteristics and impacts.
> >
> > Sorry for repeatedly hammering my point in the above, but
> > there have been many design choices driven by what was presumed
> > to be representative (kernbench and now SPECjbb) workload
> > that may be entirely wrong for a different workload (as
> > Seth once pointed out using the text of Moby Dick as a source
> > data stream).
>=20
> The reality we are going to have to face with the feature of memory
> compression is that not every workload can benefit.  The objective
> should be to improve known workloads that are able to benefit.  Then
> make improvements that grow that set of workloads.

Right, I definitely agree that some compression solution is better
than no compression solution, but with this important caveat:

_provided_ that the compression solution doesn't benefit some workloads
and _penalize_ other workloads.

However, the discussion we are having is more about which compression
solution is better and why, because we have made different design choices
based on assumptions that may or may not be valid.  I think it is
incumbent on us to validate those assumptions.

> > Further, the value of different designs can't be measured here just
> > by the workload because the pages chosen to swap may be completely
> > independent of the intended workload-driver... i.e. if you track
> > the pid of the pages intended for swap, the pages can be mostly
> > pages from long-running or periodic system services, not pages
> > generated by kernbench or SPECjbb.  So it is the workload PLUS the
> > environment that is being measured and evaluated.  That makes
> > the problem especially tough.
> >
> > Just to clarify, I'm not suggesting that there is any single
> > workload that can be called representative, just that we may
> > need both a broad set of workloads (not silly benchmarks) AND
> > some theoretical analysis to drive design decisions.  And, without
> > this, arguing about whether zsmalloc is better than zbud or not
> > is silly.  Both zbud and zsmalloc have strengths and weaknesses.
> >
> > That said, it should also be pointed out that the stream of
> > pages-to-compress from cleancache ("file pages") may be dramatically
> > different than for frontswap ("anonymous pages"), so unless you
> > and Seth are going to argue upfront that cleancache pages should
> > NEVER be candidates for compression, the evaluation criteria
> > to drive design decisions needs to encompass both anonymous
> > and file pages.  It is currently impossible to evaluate that
> > with zswap.
> >
> >>> PAGEFRAME EVACUATION AND RECLAIM
> >>>
> >
> > We are definitely on different pages here.  You are still trying to
> > push zswap as a separate subsystem that can independently decide how
> > to size itself.  I see zcache (and zswap) as a "helper" for the MM
> > subsystem which allow MM to store more anonymous/pagecache pages in
> > memory than otherwise possible.
>=20
> IIUC from this and your "Better integration of compression with the
> broader linux-mm" thread, you are wanting to allow the MM to tell a
> compressed-MM subsystem to free up pages.  There are a few problems I
> see here, mostly policy related.  How does the MM know whether is should
> reclaim compressed page space or pages from the inactive list?  In the
> case of frontswap, the policies feedback on one another in that the
> reclaim of an anonymous page from the inactive list via swap results in
> an increase in the number of pages on the anonymous zspage list.
>=20
> I'm not saying I have the solution.  The ideal sizing of the compressed
> pool is a complex issue and, like so many other elements of compressed
> memory design, depends on the workload.
>=20
> That being said, just because an ideal policy for every workload doesn't
> exist doesn't mean you can't choose one policy (hopefully a simple one)
> and improve it as measurable deficiencies are identified.

But a policy very definitely can impose constraints on the underlying
implementation.  I am claiming (and have been since last summer) that
a compression policy integrated (partially or fully) with MM is better
than a completely independent compression policy.  (Right now, the only
information zswap has that it can use to drive its policy is whether
or not alloc_page was successful!)

Assuming an integrated policy, since MM's currency of choice is pageframes,
I am further claiming that it is important for the compression policy
to easily converse in pageframes, i.e. pageframe-reclaim must be supported
by the underlying implementation.  Zsmalloc doesn't support pageframe-
reclaim and adding it may require a complete rewrite.

And I am claiming that a policy for managing compression for BOTH
pagecache pages AND anonymous pages is very important and that
there is opportunity for policy interaction between them.  Zswap
implements compression for only the (far) simpler of these two,
so policy management between the two classes cannot be addressed.

Thanks,
Dan

P.S. (moved to end)

> > (As an aside, I'm measuring zsize=3D28 bytes for a zero page...
> > Seth has repeatedly said 103 bytes and I think this is
> > reflected in your computation above.  Maybe it is 103 for your
> > hardware compression engine?  Else, I'm not sure why our
> > numbers would be different.)
>=20
> I rechecked this and found my measurement was flawed.  It was based on
> compressing a zero-filled file with lzop -1.  The file size is 107 but,
> as I recently discovered, contains LZO metadata as well.  Using lzop -l,
> I got that the compressed size of the data (not the file), is 44 bytes.
>  So still not what you are observing but closer.
>=20
> $ dd if=3D/dev/zero of=3Dzero.page bs=3D4k count=3D1
> $ lzop -1 zero.page
> $ lzop -l zero.page.lzo
> method      compressed  uncompr. ratio uncompressed_name
> LZO1X-1(15)        44      4096   1.1% zero.page

I added debug code to look at dlen in zswap_frontswap_store
on zero-filled pages and always get 28.  Perhaps the lzo code
in the kernel is different from the lzo code in userland lzop?
Or maybe you are measuring on PPC, and lzo is different there?
It would be nice to solve the mystery of this difference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
