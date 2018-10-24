Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8255E6B0005
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 19:49:48 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id j17-v6so7417322qtp.9
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 16:49:48 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m4-v6si4220562qtp.48.2018.10.24.16.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 16:49:47 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Date: Wed, 24 Oct 2018 23:49:01 +0000
Message-ID: <20181024234850.GA15663@castle.DHCP.thefacebook.com>
References: <20181023164302.20436-1-guro@fb.com>
 <20181024151853.3edd9097400b0d52edff1f16@linux-foundation.org>
In-Reply-To: <20181024151853.3edd9097400b0d52edff1f16@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6212D75D74E5C145A20548F85CF0AF78@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Michal
 Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>

On Wed, Oct 24, 2018 at 03:18:53PM -0700, Andrew Morton wrote:
> On Tue, 23 Oct 2018 16:43:29 +0000 Roman Gushchin <guro@fb.com> wrote:
>=20
> > Spock reported that the commit 172b06c32b94 ("mm: slowly shrink slabs
> > with a relatively small number of objects") leads to a regression on
> > his setup: periodically the majority of the pagecache is evicted
> > without an obvious reason, while before the change the amount of free
> > memory was balancing around the watermark.
> >=20
> > The reason behind is that the mentioned above change created some
> > minimal background pressure on the inode cache. The problem is that
> > if an inode is considered to be reclaimed, all belonging pagecache
> > page are stripped, no matter how many of them are there. So, if a huge
> > multi-gigabyte file is cached in the memory, and the goal is to
> > reclaim only few slab objects (unused inodes), we still can eventually
> > evict all gigabytes of the pagecache at once.
> >=20
> > The workload described by Spock has few large non-mapped files in the
> > pagecache, so it's especially noticeable.
> >=20
> > To solve the problem let's postpone the reclaim of inodes, which have
> > more than 1 attached page. Let's wait until the pagecache pages will
> > be evicted naturally by scanning the corresponding LRU lists, and only
> > then reclaim the inode structure.
> >=20
> > ...
> >
> > --- a/fs/inode.c
> > +++ b/fs/inode.c
> > @@ -730,8 +730,11 @@ static enum lru_status inode_lru_isolate(struct li=
st_head *item,
> >  		return LRU_REMOVED;
> >  	}
> > =20
> > -	/* recently referenced inodes get one more pass */
> > -	if (inode->i_state & I_REFERENCED) {
> > +	/*
> > +	 * Recently referenced inodes and inodes with many attached pages
> > +	 * get one more pass.
> > +	 */
> > +	if (inode->i_state & I_REFERENCED || inode->i_data.nrpages > 1) {
> >  		inode->i_state &=3D ~I_REFERENCED;
> >  		spin_unlock(&inode->i_lock);
> >  		return LRU_ROTATE;
>=20
> hm, why "1"?
>=20
> I guess one could argue that this will encompass long symlinks, but I
> just made that up to make "1" appear more justifiable ;)=20
>=20

Well, I'm slightly aware of introducing an inode leak here, so I was thinki=
ng
about some small number of pages. It's definitely makes no sense to reclaim
several Gb of pagecache, however throwing away a couple of pages to speed u=
p
inode reuse is totally fine.
But then I realized that I don't have any justification for a number like
4 or 32, so I ended up with 1. I'm pretty open here, but not sure that swit=
ching
to 0 is much better.

Thanks!
