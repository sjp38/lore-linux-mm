Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 77DE66B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 13:29:48 -0500 (EST)
MIME-Version: 1.0
Message-ID: <4e603875-823e-4bc9-afc5-ae85ce4ca0ef@default>
Date: Mon, 4 Mar 2013 10:29:32 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zsmalloc limitations and related topics
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default>
 <51300702.1050006@gmail.com>
In-Reply-To: <51300702.1050006@gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: minchan@kernel.org, sjenning@linux.vnet.ibm.com, Nitin Gupta <nitingupta910@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

> From: Ric Mason [mailto:ric.masonn@gmail.com]
> Subject: Re: zsmalloc limitations and related topics
>=20
> On 02/28/2013 07:24 AM, Dan Magenheimer wrote:
> > Hi all --
> >
> > I've been doing some experimentation on zsmalloc in preparation
> > for my topic proposed for LSFMM13 and have run across some
> > perplexing limitations.  Those familiar with the intimate details
> > of zsmalloc might be well aware of these limitations, but they
> > aren't documented or immediately obvious, so I thought it would
> > be worthwhile to air them publicly.  I've also included some
> > measurements from the experimentation and some related thoughts.
> >
> > (Some of the terms here are unusual and may be used inconsistently
> > by different developers so a glossary of definitions of the terms
> > used here is appended.)
> >
> > ZSMALLOC LIMITATIONS
> >
> > Zsmalloc is used for two zprojects: zram and the out-of-tree
> > zswap.  Zsmalloc can achieve high density when "full".  But:
> >
> > 1) Zsmalloc has a worst-case density of 0.25 (one zpage per
> >     four pageframes).
> > 2) When not full and especially when nearly-empty _after_
> >     being full, density may fall below 1.0 as a result of
> >     fragmentation.
>=20
> What's the meaning of nearly-empty _after_ being full?

Step 1:  Add a few (N) pages to zsmalloc.  It is "nearly empty".
Step 2:  Now add many more pages to zsmalloc until allocation
         limits are reached.  It is "full".
Step 3:  Now remove many pages from zsmalloc until there are
         N pages remaining.  It is now "nearly empty after
         being full".

Fragmentation characteristics are different comparing
after Step 1 and after Step 3 even though, in both cases,
zsmalloc contains N pages.
=20
> > 3) Zsmalloc has a density of exactly 1.0 for any number of
> >     zpages with zsize >=3D 0.8.
> > 4) Zsmalloc contains several compile-time parameters;
> >     the best value of these parameters may be very workload
> >     dependent.
> >
> > If density =3D=3D 1.0, that means we are paying the overhead of
> > compression+decompression for no space advantage.  If
> > density < 1.0, that means using zsmalloc is detrimental,
> > resulting in worse memory pressure than if it were not used.
> >
> > WORKLOAD ANALYSIS
> >
> > These limitations emphasize that the workload used to evaluate
> > zsmalloc is very important.  Benchmarks that measure data
>=20
> Could you share your benchmark? In order that other guys can take
> advantage of it.

As Seth does, I just used "make" of a kernel.  I run it on
a full graphical installation of EL6.  In order to ensure there
is memory pressure, I limit physical memory to 1GB, and use
"make -j20".

> > throughput or CPU utilization are of questionable value because
> > it is the _content_ of the data that is particularly relevant
> > for compression.  Even more precisely, it is the "entropy"
> > of the data that is relevant, because the amount of
> > compressibility in the data is related to the entropy:
> > I.e. an entirely random pagefull of bits will compress poorly
> > and a highly-regular pagefull of bits will compress well.
> > Since the zprojects manage a large number of zpages, both
> > the mean and distribution of zsize of the workload should
> > be "representative".
> >
> > The workload most widely used to publish results for
> > the various zprojects is a kernel-compile using "make -jN"
> > where N is artificially increased to impose memory pressure.
> > By adding some debug code to zswap, I was able to analyze
> > this workload and found the following:
> >
> > 1) The average page compressed by almost a factor of six
> >     (mean zsize =3D=3D 694, stddev =3D=3D 474)
>=20
> stddev is what?

Standard deviation.  See:
http://en.wikipedia.org/wiki/Standard_deviation=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
