Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 143866B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:36:18 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id h82-v6so12888611ljh.16
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 10:36:18 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o6-v6si31375927ljg.122.2018.10.22.10.36.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 10:36:16 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: Memory management issue in 4.18.15
Date: Mon, 22 Oct 2018 17:35:57 +0000
Message-ID: <20181022173550.GA9592@tower.DHCP.thefacebook.com>
References: <CADa=ObrwYaoNFn0x06mvv5W1F9oVccT5qjGM8qFBGNPoNuMUNw@mail.gmail.com>
 <20181022083322.GE32333@dhcp22.suse.cz>
In-Reply-To: <20181022083322.GE32333@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F1A88CC12485E84292DE324AD647ABEF@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Spock <dairinin@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, Johannes
 Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <alexander.levin@microsoft.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Oct 22, 2018 at 10:33:22AM +0200, Michal Hocko wrote:
> Cc som more people.
>=20
> I am wondering why 172b06c32b94 ("mm: slowly shrink slabs with a
> relatively small number of objects") has been backported to the stable
> tree when not marked that way. Put that aside it seems likely that the
> upstream kernel will have the same issue I suspect. Roman, could you
> have a look please?

So, the problem is probably caused by the unused inode eviction code:
inode_lru_isolate() invalidates all pages belonging to an unreferenced
clean inode at once, even if the goal was to scan (and potentially free)
just one inode (or any other slab object).

Spock's workload, as described, has few large files in the pagecache,
so it becomes noticeable. A small pressure applied on inode cache
surprisingly results in cleaning up significant percentage of the memory.

It happened before my change too, but was probably less noticeable, because
usually required higher memory pressure to happen. So, too aggressive recla=
im
was less unexpected.

How to fix this?

It seems to me, that we shouldn't try invalidating pagecache pages from
the inode reclaim path at all (maybe except inodes with only few pages).
If an inode has a lot of attached pagecache, let it be evicted "naturally",
through file LRU lists.
But I need to perform some real-life testing on how this will work.

Thanks!
