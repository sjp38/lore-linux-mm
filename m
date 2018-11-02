Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 426406B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 15:39:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d8-v6so2627997pgq.3
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 12:39:11 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m28-v6si36821471pfk.56.2018.11.02.12.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 12:39:10 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Date: Fri, 2 Nov 2018 19:38:35 +0000
Message-ID: <20181102193827.GA18024@castle.DHCP.thefacebook.com>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102073009.GP23921@dhcp22.suse.cz>
 <20181102154844.GA17619@tower.DHCP.thefacebook.com>
 <20181102161314.GF28039@dhcp22.suse.cz>
 <20181102162237.GB17619@tower.DHCP.thefacebook.com>
 <20181102165147.GG28039@dhcp22.suse.cz>
 <20181102172547.GA19042@tower.DHCP.thefacebook.com>
 <20181102174823.GI28039@dhcp22.suse.cz>
In-Reply-To: <20181102174823.GI28039@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <91355EADA23A1D47A4B5ABA6759992D0@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dexuan Cui <decui@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel
 Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri, Nov 02, 2018 at 06:48:23PM +0100, Michal Hocko wrote:
> On Fri 02-11-18 17:25:58, Roman Gushchin wrote:
> > On Fri, Nov 02, 2018 at 05:51:47PM +0100, Michal Hocko wrote:
> > > On Fri 02-11-18 16:22:41, Roman Gushchin wrote:
> [...]
> > > > 2) We do forget to scan the last page in the LRU list. So if we end=
ed up with
> > > > 1-page long LRU, it can stay there basically forever.
> > >=20
> > > Why=20
> > > 		/*
> > > 		 * If the cgroup's already been deleted, make sure to
> > > 		 * scrape out the remaining cache.
> > > 		 */
> > > 		if (!scan && !mem_cgroup_online(memcg))
> > > 			scan =3D min(size, SWAP_CLUSTER_MAX);
> > >=20
> > > in get_scan_count doesn't work for that case?
> >=20
> > No, it doesn't. Let's look at the whole picture:
> >=20
> > 		size =3D lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
> > 		scan =3D size >> sc->priority;
> > 		/*
> > 		 * If the cgroup's already been deleted, make sure to
> > 		 * scrape out the remaining cache.
> > 		 */
> > 		if (!scan && !mem_cgroup_online(memcg))
> > 			scan =3D min(size, SWAP_CLUSTER_MAX);
> >=20
> > If size =3D=3D 1, scan =3D=3D 0 =3D> scan =3D min(1, 32) =3D=3D 1.
> > And after proportional adjustment we'll have 0.
>=20
> My friday brain hurst when looking at this but if it doesn't work as
> advertized then it should be fixed. I do not see any of your patches to
> touch this logic so how come it would work after them applied?

This part works as expected. But the following
	scan =3D div64_u64(scan * fraction[file], denominator);
reliable turns 1 page to scan to 0 pages to scan.

And this is the issue which my patches do address.

Thanks!
