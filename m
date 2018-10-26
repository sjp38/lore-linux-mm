Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EDDCD6B0322
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 11:58:52 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id j63-v6so1488303qte.13
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 08:58:52 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b7-v6si688506qtt.31.2018.10.26.08.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 08:58:52 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH] mm: don't reclaim inodes with many attached pages
Date: Fri, 26 Oct 2018 15:58:15 +0000
Message-ID: <20181026155812.GB6019@tower.DHCP.thefacebook.com>
References: <20181023164302.20436-1-guro@fb.com>
 <20181026085735.GZ18839@dhcp22.suse.cz>
In-Reply-To: <20181026085735.GZ18839@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <ADCAA52362A08F4A8B809D4CF4DF8141@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Rik van
 Riel <riel@surriel.com>, Randy Dunlap <rdunlap@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "dairinin@gmail.com" <dairinin@gmail.com>

On Fri, Oct 26, 2018 at 10:57:35AM +0200, Michal Hocko wrote:
> Spock doesn't seem to be cced here - fixed now
>=20
> On Tue 23-10-18 16:43:29, Roman Gushchin wrote:
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
>=20
> Has this actually fixed/worked around the issue?
>=20
> > Reported-by: Spock <dairinin@gmail.com>
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Rik van Riel <riel@surriel.com>
> > Cc: Randy Dunlap <rdunlap@infradead.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >  fs/inode.c | 7 +++++--
> >  1 file changed, 5 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/fs/inode.c b/fs/inode.c
> > index 73432e64f874..0cd47fe0dbe5 100644
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
>=20
> The comment is just confusing. Did you mean to say s@many@any@ ?

No, here many =3D=3D more than 1.

I'm happy to fix the comment, if you have any suggestions.


Thanks!
