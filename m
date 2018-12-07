Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3088E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 10:07:33 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id y19so3919067ioq.1
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 07:07:33 -0800 (PST)
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id o202si2080473itb.60.2018.12.07.07.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 07:07:32 -0800 (PST)
Date: Fri, 7 Dec 2018 15:06:36 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181207150636.00003dfa@huawei.com>
In-Reply-To: <20181207002044.GI3544@redhat.com>
References: <b8fab9a7-62ed-5d8d-3cb1-aea6aacf77fe@intel.com>
	<20181206192050.GC3544@redhat.com>
	<d6508932-377c-a4d1-d4d8-01d0f55b9190@intel.com>
	<c583be1b-17db-1ed3-0f5a-bd119edc8bfe@deltatee.com>
	<f7eb9939-d550-706a-946d-acbb7383172e@intel.com>
	<20181206223935.GG3544@redhat.com>
	<c1126d60-95c0-ed34-6314-fcec17ac1c29@intel.com>
	<935fc14d-91f2-bc2a-f8b5-665e4145e148@deltatee.com>
	<5e6c87d5-e4ef-12e7-32bf-c163f7ff58d7@intel.com>
	<cd5cf2a6-7415-eae7-0305-004cc7db994b@deltatee.com>
	<20181207002044.GI3544@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki  <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>,  Ross Zwisler  <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams" <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, "Philip Yang  <Philip.Yang@amd.com>, Christian =?ISO-8859-1?Q?K=F6nig?=" <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, "John Hubbard  <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko" <mhocko@kernel.org>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Thu, 6 Dec 2018 19:20:45 -0500
Jerome Glisse <jglisse@redhat.com> wrote:

> On Thu, Dec 06, 2018 at 04:48:57PM -0700, Logan Gunthorpe wrote:
> >=20
> >=20
> > On 2018-12-06 4:38 p.m., Dave Hansen wrote: =20
> > > On 12/6/18 3:28 PM, Logan Gunthorpe wrote: =20
> > >> I didn't think this was meant to describe actual real world performa=
nce
> > >> between all of the links. If that's the case all of this seems like a
> > >> pipe dream to me. =20
> > >=20
> > > The HMAT discussions (that I was a part of at least) settled on just
> > > trying to describe what we called "sticker speed".  Nobody had an
> > > expectation that you *really* had to measure everything.
> > >=20
> > > The best we can do for any of these approaches is approximate things.=
 =20
> >=20
> > Yes, though there's a lot of caveats in this assumption alone.
> > Specifically with PCI: the bus may run at however many GB/s but P2P
> > through a CPU's root complexes can slow down significantly (like down to
> > MB/s).
> >=20
> > I've seen similar things across QPI: I can sometimes do P2P from
> > PCI->QPI->PCI but the performance doesn't even come close to the sticker
> > speed of any of those buses.
> >=20
> > I'm not sure how anyone is going to deal with those issues, but it does
> > firmly place us in world view #2 instead of #1. But, yes, I agree
> > exposing information like in #2 full out to userspace, especially
> > through sysfs, seems like a nightmare and I don't see anything in HMS to
> > help with that. Providing an API to ask for memory (or another resource)
> > that's accessible by a set of initiators and with a set of requirements
> > for capabilities seems more manageable. =20
>=20
> Note that in #1 you have bridge that fully allow to express those path
> limitation. So what you just describe can be fully reported to userspace.
>=20
> I explained and given examples on how program adapt their computation to
> the system topology it does exist today and people are even developing new
> programming langage with some of those idea baked in.
>=20
> So they are people out there that already rely on such information they
> just do not get it from the kernel but from a mix of various device speci=
fic
> API and they have to stich everything themself and develop a database of
> quirk and gotcha. My proposal is to provide a coherent kernel API where
> we can sanitize that informations and report it to userspace in a single
> and coherent description.
>=20
> Cheers,
> J=E9r=F4me

I know it doesn't work everywhere, but I think it's worth enumerating what
cases we can get some of these numbers for and where the complexity lies.
I.e. What can the really determined user space library do today?

So one open question is how close can we get in a userspace only prototype.
At the end of the day userspace can often read HMAT directly if it wants to
/sys/firmware/acpi/tables/HMAT.  Obviously that gets us only the end to
end view (world 2).  I dislike the limitations of that as much as the next
person. It is slowly improving with the word "Auditable" being
kicked around - btw anyone interested in ACPI who works for a UEFI
member, there are efforts going on and more viewpoints would be great.
Expect some baby steps shortly.

For devices on PCIe (and protocols on top of it e.g. CCIX), a lot of
this is discoverable to some degree.=20
* Link speed,
* Number of Lanes,
* Full topology.

What isn't there (I think)
* In component latency / bandwidth limitations (some activity going
  on to improve that long term)
* Effect of credit allocations etc on effectively bandwidth - interconnect
  performance is a whole load of black magic.

Presumably there is some information available from NVLink etc?

So whilst I really like the proposal in some ways, I wonder how much explor=
ation
could be done of the usefulness of the data without touching the kernel at =
all.

The other aspect that is needed to actually make this 'dynamically' useful =
is
to be able to map whatever Performance Counters are available to the releva=
nt
'links', bridges etc.   Ticket numbers are not all that useful unfortunately
except for small amounts of data on lightly loaded buses.

The kernel ultimately only needs to have a model of this topology if:
1) It's going to use it itself
2) Its going to do something automatic with it.
3) It needs to fix garbage info or supplement with things only the kernel k=
nows.

Jonathan
