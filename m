Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99DC06B03A5
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 10:27:59 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g27so19009673qte.12
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 07:27:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q97si13587136qkh.44.2017.04.10.07.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 07:27:58 -0700 (PDT)
Date: Mon, 10 Apr 2017 16:27:49 +0200
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170410162749.7d7f31c1@nial.brq.redhat.com>
In-Reply-To: <20170410110351.12215-1-mhocko@kernel.org>
References: <20170410110351.12215-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michal Hocko <mhocko@suse.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Mon, 10 Apr 2017 13:03:42 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> Hi,
> The last version of this series has been posted here [1]. It has seen
> some more serious testing (thanks to Reza Arbab) and fixes for the found
> issues. I have also decided to drop patch 1 [2] because it turned out to
> be more complicated than I initially thought [3]. Few more patches were
> added to deal with expectation on zone/node initialization.
>=20
> I have rebased on top of the current mmotm-2017-04-07-15-53. It
> conflicts with HMM because it touches memory hotplug as
> well. We have discussed [4] with J=C3=A9r=C3=B4me and he agreed to
> rebase on top of this rework [5] so I have reverted his series
> before applyig mine. I will help him to resolve the resulting
> conflicts. You can find the whole series including the HMM revers in
> git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git branch
> attempts/rewrite-mem_hotplug
>=20
> Motivation:
> Movable onlining is a real hack with many downsides - mainly
> reintroduction of lowmem/highmem issues we used to have on 32b systems -
> but it is the only way to make the memory hotremove more reliable which
> is something that people are asking for.
>=20
> The current semantic of memory movable onlinening is really cumbersome,
> however. The main reason for this is that the udev driven approach is
> basically unusable because udev races with the memory probing while only
> the last memory block or the one adjacent to the existing zone_movable
> are allowed to be onlined movable. In short the criterion for the
> successful online_movable changes under udev's feet. A reliable udev
> approach would require a 2 phase approach where the first successful
> movable online would have to check all the previous blocks and online
> them in descending order. This is hard to be considered sane.
>=20
> This patchset aims at making the onlining semantic more usable. First of
> all it allows to online memory movable as long as it doesn't clash with
> the existing ZONE_NORMAL. That means that ZONE_NORMAL and ZONE_MOVABLE
> cannot overlap. Currently I preserve the original ordering semantic so
> the zone always precedes the movable zone but I have plans to remove this
> restriction in future because it is not really necessary.
>=20
> First 3 patches are cleanups which should be ready to be merged right
> away (unless I have missed something subtle of course).
>=20
> Patch 4 deals with ZONE_DEVICE dependencies down the __add_pages path.
>=20
> Patch 5 deals with implicit assumptions of register_one_node on pgdat
> initialization.
>=20
> Patch 6 is the core of the change. In order to make it easier to review
> I have tried it to be as minimalistic as possible and the large code
> removal is moved to patch 9.
>=20
> Patch 7 is a trivial follow up cleanup. Patch 8 fixes sparse warnings
> and finally patch 9 removes the unused code.
>=20
> I have tested the patches in kvm:
> # qemu-system-x86_64 -enable-kvm -monitor pty -m 2G,slots=3D4,maxmem=3D4G=
 -numa node,mem=3D1G -numa node,mem=3D1G ...
>=20
> and then probed the additional memory by
> (qemu) object_add memory-backend-ram,id=3Dmem1,size=3D1G
> (qemu) device_add pc-dimm,id=3Ddimm1,memdev=3Dmem1

Hi Michal,

I've given series some dumb testing, see below for unexpected changes I've =
noticed.

Using the same CLI as above plus hotpluggable dimms present at startup
(it still uses hotplug path as dimms aren't reported in e820)

-object memory-backend-ram,id=3Dmem1,size=3D256M -object memory-backend-ram=
,id=3Dmem0,size=3D256M \
-device pc-dimm,id=3Ddimm1,memdev=3Dmem1,slot=3D1,node=3D0 -device pc-dimm,=
id=3Ddimm0,memdev=3Dmem0,slot=3D0,node=3D0

so dimm1 =3D> memory3[23] and dimm0 =3D> memory3[45]

#issue1:
unable to online memblock as NORMAL adjacent to onlined MOVABLE

1: after boot
memory32:offline removable: 0  zones: Normal Movable
memory33:offline removable: 0  zones: Normal Movable
memory34:offline removable: 0  zones: Normal Movable
memory35:offline removable: 0  zones: Normal Movable

2: online as movable 1st dimm

#echo online_movable > memory32/state
#echo online_movable > memory33/state

everything is as expected:
memory32:online removable: 1  zones: Movable
memory33:online removable: 1  zones: Movable
memory34:offline removable: 0  zones: Movable
memory35:offline removable: 0  zones: Movable

3: try to offline memory32 and online as NORMAL

#echo offline > memory32/state
memory32:offline removable: 1  zones: Normal Movable
memory33:online removable: 1  zones: Movable
memory34:offline removable: 0  zones: Movable
memory35:offline removable: 0  zones: Movable

#echo online_kernel > memory32/state
write error: Invalid argument
// that's not what's expected

memory32:offline removable: 1  zones: Normal Movable
memory33:online removable: 1  zones: Movable
memory34:offline removable: 0  zones: Movable
memory35:offline removable: 0  zones: Movable


=3D=3D=3D=3D=3D=3D
#issue2: dimm1 assigned to node 1 on qemu CLI
memblock is onlined as movable by default

// after boot
memory32:offline removable: 1  zones: Normal
memory33:offline removable: 1  zones: Normal Movable
memory34:offline removable: 1  zones: Normal
memory35:offline removable: 1  zones: Normal Movable
// not related to this issue but notice not all blocks are
// "Normal Movable" when compared when both dimms on node 0 /#issue1/

#echo online_movable > memory33/state
#echo online > memory32/state

memory32:online removable: 1  zones: Movable
memory33:online removable: 1  zones: Movable

before series memory32 goes to zone NORMAL as expected
memory32:online removable: 0  zones: Normal Movable
memory33:online removable: 1  zones: Movable Normal


=3D=3D=3D=3D=3D=3D
#issue3:
removable flag flipped to non-removable state

// before series at commit ef0b577b6:
memory32:offline removable: 0  zones: Normal Movable
memory33:offline removable: 0  zones: Normal Movable
memory34:offline removable: 0  zones: Normal Movable
memory35:offline removable: 0  zones: Normal Movable

// after series at commit 6a010434
memory32:offline removable: 1  zones: Normal
memory33:offline removable: 1  zones: Normal
memory34:offline removable: 1  zones: Normal
memory35:offline removable: 1  zones: Normal Movable

also looking at #issue1 removable flag state doesn't
seem to be consistent between state changes but maybe that's
been broken before

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
