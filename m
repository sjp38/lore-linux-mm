Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 76E6D6B0005
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 12:23:11 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z7-v6so1464402edh.19
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 09:23:11 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id f9-v6si871795edi.431.2018.11.02.09.23.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 09:23:09 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Date: Fri, 2 Nov 2018 16:22:41 +0000
Message-ID: <20181102162237.GB17619@tower.DHCP.thefacebook.com>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102073009.GP23921@dhcp22.suse.cz>
 <20181102154844.GA17619@tower.DHCP.thefacebook.com>
 <20181102161314.GF28039@dhcp22.suse.cz>
In-Reply-To: <20181102161314.GF28039@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8E3D8C511A8DFD479C3FB43838995FC2@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dexuan Cui <decui@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel
 Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri, Nov 02, 2018 at 05:13:14PM +0100, Michal Hocko wrote:
> On Fri 02-11-18 15:48:57, Roman Gushchin wrote:
> > On Fri, Nov 02, 2018 at 09:03:55AM +0100, Michal Hocko wrote:
> > > On Fri 02-11-18 02:45:42, Dexuan Cui wrote:
> > > [...]
> > > > I totally agree. I'm now just wondering if there is any temporary w=
orkaround,
> > > > even if that means we have to run the kernel with some features dis=
abled or
> > > > with a suboptimal performance?
> > >=20
> > > One way would be to disable kmem accounting (cgroup.memory=3Dnokmem k=
ernel
> > > option). That would reduce the memory isolation because quite a lot o=
f
> > > memory will not be accounted for but the primary source of in-flight =
and
> > > hard to reclaim memory will be gone.
> >=20
> > In my experience disabling the kmem accounting doesn't really solve the=
 issue
> > (without patches), but can lower the rate of the leak.
>=20
> This is unexpected. 90cbc2508827e was introduced to address offline
> memcgs to be reclaim even when they are small. But maybe you mean that
> we still leak in an absence of the memory pressure. Or what does prevent
> memcg from going down?

There are 3 independent issues which are contributing to this leak:
1) Kernel stack accounting weirdness: processes can reuse stack accounted t=
o
different cgroups. So basically any running process can take a reference to=
 any
cgroup.
2) We do forget to scan the last page in the LRU list. So if we ended up wi=
th
1-page long LRU, it can stay there basically forever.
3) We don't apply enough pressure on slab objects.

Because one reference is enough to keep the entire memcg structure in place=
,
we really have to close all three to eliminate the leak. Disabling kmem
accounting mitigates only the last one.

>=20
> > > Another workaround could be to use force_empty knob we have in v1 and
> > > use it when removing a cgroup. We do not have it in cgroup v2 though.
> > > The file hasn't been added to v2 because we didn't really have any
> > > proper usecase. Working around a bug doesn't sound like a _proper_
> > > usecase but I can imagine workloads that bring a lot of metadata obje=
cts
> > > that are not really interesting for later use so something like a
> > > targeted drop_caches...
> >=20
> > This can help a bit too, but even using the system-wide drop_caches kno=
b
> > unfortunately doesn't return all the memory back.
>=20
> Could you be more specific please?

Sure, because problems 1) and 2) exist, echo 3 > /proc/sys/vm/drop_caches c=
an't
reclaim all memcg structures in most cases.

Thanks!
