Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC316B02C2
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 16:34:09 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id f8-v6so6430978ybn.22
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 13:34:09 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id r126-v6si5386867ywg.168.2018.10.25.13.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 13:34:08 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Date: Thu, 25 Oct 2018 20:32:47 +0000
Message-ID: <20181025203240.GA2504@tower.DHCP.thefacebook.com>
References: <20181023164302.20436-1-guro@fb.com>
 <20181024151950.36fe2c41957d807756f587ca@linux-foundation.org>
 <20181025092352.GP18839@dhcp22.suse.cz>
 <20181025124442.5513d282273786369bbb7460@linux-foundation.org>
 <20181025202014.GA216405@sasha-vm>
In-Reply-To: <20181025202014.GA216405@sasha-vm>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <AE2CA4FCA1F3B04C9616EB5070C6A232@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Rik van Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>, Sasha Levin <Alexander.Levin@microsoft.com>

On Thu, Oct 25, 2018 at 04:20:14PM -0400, Sasha Levin wrote:
> On Thu, Oct 25, 2018 at 12:44:42PM -0700, Andrew Morton wrote:
> > On Thu, 25 Oct 2018 11:23:52 +0200 Michal Hocko <mhocko@kernel.org> wro=
te:
> >=20
> > > On Wed 24-10-18 15:19:50, Andrew Morton wrote:
> > > > On Tue, 23 Oct 2018 16:43:29 +0000 Roman Gushchin <guro@fb.com> wro=
te:
> > > >
> > > > > Spock reported that the commit 172b06c32b94 ("mm: slowly shrink s=
labs
> > > > > with a relatively small number of objects") leads to a regression=
 on
> > > > > his setup: periodically the majority of the pagecache is evicted
> > > > > without an obvious reason, while before the change the amount of =
free
> > > > > memory was balancing around the watermark.
> > > > >
> > > > > The reason behind is that the mentioned above change created some
> > > > > minimal background pressure on the inode cache. The problem is th=
at
> > > > > if an inode is considered to be reclaimed, all belonging pagecach=
e
> > > > > page are stripped, no matter how many of them are there. So, if a=
 huge
> > > > > multi-gigabyte file is cached in the memory, and the goal is to
> > > > > reclaim only few slab objects (unused inodes), we still can event=
ually
> > > > > evict all gigabytes of the pagecache at once.
> > > > >
> > > > > The workload described by Spock has few large non-mapped files in=
 the
> > > > > pagecache, so it's especially noticeable.
> > > > >
> > > > > To solve the problem let's postpone the reclaim of inodes, which =
have
> > > > > more than 1 attached page. Let's wait until the pagecache pages w=
ill
> > > > > be evicted naturally by scanning the corresponding LRU lists, and=
 only
> > > > > then reclaim the inode structure.
> > > >
> > > > Is this regression serious enough to warrant fixing 4.19.1?
> > >=20
> > > Let's not forget about stable tree(s) which backported 172b06c32b94. =
I
> > > would suggest reverting there.
> >=20
> > Yup.  Sasha, can you please take care of this?
>=20
> Sure, I'll revert it from current stable trees.
>=20
> Should 172b06c32b94 and this commit be backported once Roman confirms
> the issue is fixed? As far as I understand 172b06c32b94 addressed an
> issue FB were seeing in their fleet and needed to be fixed.

The memcg leak was also independently reported by several companies,
so it's not only about our fleet.

The memcg css leak is fixed by a series of commits (as in the mm tree):
  37e521912118 math64: prevent double calculation of DIV64_U64_ROUND_UP() a=
rguments
  c6be4e82b1b3 mm: don't miss the last page because of round-off error
  f2e821fc8c63 mm: drain memcg stocks on css offlining
  03a971b56f18 mm: rework memcg kernel stack accounting
  172b06c32b94 mm: slowly shrink slabs with a relatively small number of ob=
jects

The last one by itself isn't enough, and it makes no sense to backport it
without all other patches. So, I'd either backport them all (including
47036ad4032e ("mm: don't reclaim inodes with many attached pages"),
either just revert 172b06c32b94.

Also 172b06c32b94 ("mm: slowly shrink slabs with a relatively small number =
of objects")
by itself is fine, but it reveals an independent issue in inode reclaim cod=
e,
which 47036ad4032e ("mm: don't reclaim inodes with many attached pages") ai=
ms to fix.

Thanks!
