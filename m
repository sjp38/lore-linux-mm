Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 541746B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 06:50:07 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s2so1226231pge.19
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 03:50:07 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0069.outbound.protection.outlook.com. [104.47.2.69])
        by mx.google.com with ESMTPS id 7si4798198ple.699.2017.10.17.03.50.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 03:50:06 -0700 (PDT)
From: Guy Shattah <sguy@mellanox.com>
Subject: RE: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Date: Tue, 17 Oct 2017 10:50:02 +0000
Message-ID: <AM6PR0502MB378375AF8B569DBCCFE20D7DBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
References: <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <20171016082456.no6ux63uy2rmj4fe@dhcp22.suse.cz>
 <0e238c56-c59d-f648-95fc-c8cb56c3652e@mellanox.com>
 <20171016123248.csntl6luxgafst6q@dhcp22.suse.cz>
In-Reply-To: <20171016123248.csntl6luxgafst6q@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh
 Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>



> > On 16/10/2017 11:24, Michal Hocko wrote:
> > > On Sun 15-10-17 10:50:29, Guy Shattah wrote:
> > > >
> > > > On 13/10/2017 19:17, Michal Hocko wrote:
> > > > > On Fri 13-10-17 10:56:13, Cristopher Lameter wrote:
> > > > > > On Fri, 13 Oct 2017, Michal Hocko wrote:
> > > > > > > > There are numerous RDMA devices that would all need the
> > > > > > > > mmap implementation. And this covers only the needs of one
> > > > > > > > subsystem. There are other use cases.
> > > > > > > That doesn't prevent providing a library function which
> > > > > > > could be reused by all those drivers. Nothing really too
> > > > > > > much different from remap_pfn_range.
> > > > > > And then in all the other use cases as well. It would be much
> > > > > > easier if mmap could give you the memory you need instead of
> > > > > > havig numerous drivers improvise on their own. This is in
> > > > > > particular also useful for numerous embedded use cases where yo=
u
> need contiguous memory.
> > > > > But a generic implementation would have to deal with many issues
> > > > > as already mentioned. If you make this driver specific you can
> > > > > have access control based on fd etc... I really fail to see how
> > > > > this is any different from remap_pfn_range.
> > > > Why have several driver specific implementation if you can
> > > > generalize the idea and implement an already existing POSIX
> > > > standard?
> > > Because users shouldn't really care, really. We do have means to get
> > > large memory and having a guaranteed large memory is a PITA. Just
> > > look at hugetlb and all the issues it exposes. And that one is
> > > preallocated and it requires admin to do a conscious decision about
> > > the amount of the memory. You would like to establish something
> > > similar except without bounds to the size and no pre-allowed amount
> > > by an admin. This sounds just crazy to me.
> >
> > Users do care about the performance they get using devices which
> > benefit from contiguous memory allocation.  Assuming that user
> > requires 700Mb of contiguous memory. Then why allocate giant (1GB)
> > page when you can allocate 700Mb out of the 1GB and put the rest of
> > the 300Mb back in the huge-pages/small-pages pool?
>=20
> I believe I have explained that part. Large pages are under admin control=
 and
> responsibility. If you get a free ticket to large memory to any user who =
can
> pin that memory then you are in serious troubles.
>=20
> > > On the other hand if you make this per-device mmap implementation
> > > you can have both admin defined policy on who is allowed this memory
> > > and moreover drivers can implement their fallback strategies which
> > > best suit their needs. I really fail to see how this is any
> > > different from using specialized mmap implementations.
> > We tried doing it in the past. but the maintainer gave us a very good
> > argument:
> > " If you want to support anonymous mmaps to allocate large contiguous
> > pages work with the MM folks on providing that in a generic fashion."
>=20
> Well, we can provide a generic library functions for your driver to use s=
o that
> you do not have to care about implementation details but I do not think
> exposing this API to the userspace in a generic fashion is a good idea.
> Especially when the only usecase that has been thought through so far see=
ms
> to be a very special HW optimiztion.

Are you going to be OK with kernel API which implements contiguous memory a=
llocation?
Possibly with mmap style?  Many drivers could utilize it instead of having =
their own weird
and possibly non-standard way to allocate contiguous memory.
Such API won't be available for user space.

We can begin with implementing kernel API and postpone the userspace api di=
scussion for a future date.
if it is sufficient. We might not have to discuss it at all.
=20

>=20
> > After discussing it with people who have the same requirements as we
> > do - I totally agree with him
> >
> >
> https://emea01.safelinks.protection.outlook.com/?url=3Dhttp%3A%2F%2Fcom
> m
> >
> ents.gmane.org%2Fgmane.linux.drivers.rdma%2F31467&data=3D02%7C01%7Cs
> guy%
> >
> 40mellanox.com%7C24d72e65908044f3d38a08d5149204ee%7Ca652971c7d
> 2e4d9ba6
> >
> a4d149256f461b%7C0%7C0%7C636437539732729965&sdata=3DoueheNfnsMS
> PAGAehcT5
> > ZDteHxMVQ9%2F7nJNKPPfgVvM%3D&reserved=3D0
> >
> > > I might be really wrong but I consider such a general purpose flag
> > > quite dangerous and future maintenance burden. At least from the
> > > hugetlb/THP history I do not see why this should be any different.
> >
> > Could you please elaborate why is it dangerous and future maintenance
> > burden?
>=20
> Providing large contiguous memory ranges is not easy and we actually do n=
ot
> have any reliable way to offer such a functionality for the kernel users
> because we assume they are not that many. Basically anything larger than
> order-3 is best effort. Even changes constant improvements of the
> compaction still leaves us with something we cannot fully rely on. And no=
w
> you want to expose this to the userspace with basically arbitrary memory
> sizes to be supported?
>=20
> But putting that aside. Pinning a lot of memory might cause many
> performance issues and misbehavior. There are still kernel users who need
> high order memory to work properly. On top of that you are basically
> allowing an untrusted user to deplete higher order pages very easily unle=
ss
> there is a clever way to enforce per user limit on this.

My previous suggestion prevents untrusted userspace code.


Guy=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
