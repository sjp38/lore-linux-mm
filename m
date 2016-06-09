Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A768828E5
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 00:47:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a69so46124612pfa.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 21:47:20 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e21si5384260pfj.74.2016.06.08.21.39.51
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 21:39:56 -0700 (PDT)
Date: Thu, 9 Jun 2016 13:40:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Cleanup - Reorganize the shrink_page_list code into
 smaller functions
Message-ID: <20160609044059.GB29779@bbox>
References: <1463779979.22178.142.camel@linux.intel.com>
 <20160531091550.GA19976@bbox>
 <20160531171722.GA5763@linux.intel.com>
 <20160601071225.GN19976@bbox>
 <1464805433.22178.191.camel@linux.intel.com>
 <20160607082158.GA23435@bbox>
 <1465332209.22178.236.camel@linux.intel.com>
MIME-Version: 1.0
In-Reply-To: <1465332209.22178.236.camel@linux.intel.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, Jun 07, 2016 at 01:43:29PM -0700, Tim Chen wrote:
> On Tue, 2016-06-07 at 17:21 +0900, Minchan Kim wrote:
> > On Wed, Jun 01, 2016 at 11:23:53AM -0700, Tim Chen wrote:
> > >=20
> > > On Wed, 2016-06-01 at 16:12 +0900, Minchan Kim wrote:
> > > >=20
> > > > =A0
> > > > Hi Tim,
> > > >=20
> > > > To me, this reorganization is too limited and not good for me,
> > > > frankly speaking. It works for only your goal which allocate batch
> > > > swap slot, I guess. :)
> > > >=20
> > > > My goal is to make them work with batch page=5Fcheck=5Freferences,
> > > > batch try=5Fto=5Funmap and batch =5F=5Fremove=5Fmapping where we ca=
n avoid frequent
> > > > mapping->lock(e.g., anon=5Fvma or i=5Fmmap=5Flock with hoping such =
batch locking
> > > > help system performance) if batch pages has same inode or anon.
> > > This is also my goal to group pages that are either under the same
> > > mapping or are anonymous pages together so we can reduce the i=5Fmmap=
=5Flock
> > > acquisition. =A0One logic that's yet to be implemented in your patch
> > > is the grouping of similar pages together so we only need one i=5Fmma=
p=5Flock
> > > acquisition. =A0Doing this efficiently is non-trivial. =A0
> > Hmm, my assumption is based on same inode pages are likely to order
> > in LRU so no need to group them. If successive page in page=5Flist comes
> > from different inode, we can drop the lock and get new lock from new
> > inode. That sounds strange?
> >=20
>=20
> Sounds reasonable. But your process function passed to spl=5Fbatch=5Fpage=
s may
> need to be modified to know if the radix tree lock or swap info lock
> has already been held, as it deals with only 1 page. =A0It may be
> tricky as the lock may get acquired and dropped more than once in process
> function.
>=20
> Are you planning to update the patch with lock batching?

Hi Tim,

Okay, I will give it a shot.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
