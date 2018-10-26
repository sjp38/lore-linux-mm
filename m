Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 702F56B031E
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 11:55:18 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id s17-v6so855768ybg.21
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 08:55:18 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n68-v6si7078010ywe.141.2018.10.26.08.55.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 08:55:16 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Date: Fri, 26 Oct 2018 15:54:46 +0000
Message-ID: <20181026155438.GA6019@tower.DHCP.thefacebook.com>
References: <20181023164302.20436-1-guro@fb.com>
 <20181024151950.36fe2c41957d807756f587ca@linux-foundation.org>
 <20181025092352.GP18839@dhcp22.suse.cz>
 <20181025124442.5513d282273786369bbb7460@linux-foundation.org>
 <20181025202014.GA216405@sasha-vm>
 <20181025203240.GA2504@tower.DHCP.thefacebook.com>
 <20181026073303.GW18839@dhcp22.suse.cz>
In-Reply-To: <20181026073303.GW18839@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <47B8F01C10FB374D95B1D9CA48FCE328@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sasha Levin <sashal@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Rik van Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>, Sasha Levin <Alexander.Levin@microsoft.com>

On Fri, Oct 26, 2018 at 09:33:03AM +0200, Michal Hocko wrote:
> On Thu 25-10-18 20:32:47, Roman Gushchin wrote:
> > On Thu, Oct 25, 2018 at 04:20:14PM -0400, Sasha Levin wrote:
> > > On Thu, Oct 25, 2018 at 12:44:42PM -0700, Andrew Morton wrote:
> > > > On Thu, 25 Oct 2018 11:23:52 +0200 Michal Hocko <mhocko@kernel.org>=
 wrote:
> > > >=20
> > > > > On Wed 24-10-18 15:19:50, Andrew Morton wrote:
> > > > > > On Tue, 23 Oct 2018 16:43:29 +0000 Roman Gushchin <guro@fb.com>=
 wrote:
> > > > > >
> > > > > > > Spock reported that the commit 172b06c32b94 ("mm: slowly shri=
nk slabs
> > > > > > > with a relatively small number of objects") leads to a regres=
sion on
> > > > > > > his setup: periodically the majority of the pagecache is evic=
ted
> > > > > > > without an obvious reason, while before the change the amount=
 of free
> > > > > > > memory was balancing around the watermark.
> > > > > > >
> > > > > > > The reason behind is that the mentioned above change created =
some
> > > > > > > minimal background pressure on the inode cache. The problem i=
s that
> > > > > > > if an inode is considered to be reclaimed, all belonging page=
cache
> > > > > > > page are stripped, no matter how many of them are there. So, =
if a huge
> > > > > > > multi-gigabyte file is cached in the memory, and the goal is =
to
> > > > > > > reclaim only few slab objects (unused inodes), we still can e=
ventually
> > > > > > > evict all gigabytes of the pagecache at once.
> > > > > > >
> > > > > > > The workload described by Spock has few large non-mapped file=
s in the
> > > > > > > pagecache, so it's especially noticeable.
> > > > > > >
> > > > > > > To solve the problem let's postpone the reclaim of inodes, wh=
ich have
> > > > > > > more than 1 attached page. Let's wait until the pagecache pag=
es will
> > > > > > > be evicted naturally by scanning the corresponding LRU lists,=
 and only
> > > > > > > then reclaim the inode structure.
> > > > > >
> > > > > > Is this regression serious enough to warrant fixing 4.19.1?
> > > > >=20
> > > > > Let's not forget about stable tree(s) which backported 172b06c32b=
94. I
> > > > > would suggest reverting there.
> > > >=20
> > > > Yup.  Sasha, can you please take care of this?
> > >=20
> > > Sure, I'll revert it from current stable trees.
> > >=20
> > > Should 172b06c32b94 and this commit be backported once Roman confirms
> > > the issue is fixed? As far as I understand 172b06c32b94 addressed an
> > > issue FB were seeing in their fleet and needed to be fixed.
> >=20
> > The memcg leak was also independently reported by several companies,
> > so it's not only about our fleet.
>=20
> By memcg leak you mean a lot of dead memcgs with small amount of memory
> which are staying behind and the global memory pressure removes them
> only very slowly or almost not at all, right?

Right.

>=20
> I have avague recollection that systemd can trigger a pattern which
> makes this "leak" noticeable. Is that right? If yes what would be a
> minimal and safe fix for the stable tree? "mm: don't miss the last page
> because of round-off error" would sound like the candidate but I never
> got around to review it properly.

Yes, systemd can create and destroy a ton of cgroups under some circumstanc=
es,
but there is nothing systemd-specific here. It's quite typical to run servi=
ces
in new cgroups, so with time the number of dying cgroups tends to grow.

I've listed all necessary patches, it's the required set (except the last p=
atch,
but it has to be squashed). f2e821fc8c63 can be probably skipped, but I hav=
en't
tested without it, and it's the most straightforward patch from the set.

Daniel McGinnes has reported the same issue in the cgroups@ mailing list,
and he confirmed that this patchset solved the problem for him.

> > The memcg css leak is fixed by a series of commits (as in the mm tree):
> >   37e521912118 math64: prevent double calculation of DIV64_U64_ROUND_UP=
() arguments
> >   c6be4e82b1b3 mm: don't miss the last page because of round-off error
> >   f2e821fc8c63 mm: drain memcg stocks on css offlining
> >   03a971b56f18 mm: rework memcg kernel stack accounting
>=20
> btw. none of these sha are refering to anything in my git tree. They all
> seem to be in the next tree though.

Yeah, they all are in the mm tree, and hashes are from Johannes's git.

>=20
> >   172b06c32b94 mm: slowly shrink slabs with a relatively small number o=
f objects
> >=20
> > The last one by itself isn't enough, and it makes no sense to backport =
it
> > without all other patches. So, I'd either backport them all (including
> > 47036ad4032e ("mm: don't reclaim inodes with many attached pages"),
> > either just revert 172b06c32b94.
> >=20
> > Also 172b06c32b94 ("mm: slowly shrink slabs with a relatively small num=
ber of objects")
> > by itself is fine, but it reveals an independent issue in inode reclaim=
 code,
> > which 47036ad4032e ("mm: don't reclaim inodes with many attached pages"=
) aims to fix.
>=20
> To me it sounds it needs much more time to settle before it can be
> considered safe for the stable tree. Even if the patch itself is correct
> it seems too subtle and reveal a behavior which was not anticipated and
> that just proves it is far from straightforward.

Absolutely. I'm not pushing this to stable at all, that single patch
was an accident.

Thanks!
