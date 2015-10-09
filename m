Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 433CC6B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 14:51:37 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so93789098pab.3
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 11:51:37 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id kz9si4501505pbc.150.2015.10.09.11.51.36
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 11:51:36 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH][RFC] mm: Introduce kernelcore=reliable option
Date: Fri, 9 Oct 2015 18:51:34 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32B523DB@ORSMSX114.amr.corp.intel.com>
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <561762DC.3080608@huawei.com> <561787DA.4040809@jp.fujitsu.com>
 <5617989E.9070700@huawei.com> <5617D878.5060903@intel.com>
In-Reply-To: <5617D878.5060903@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, "zhongjiang@huawei.com" <zhongjiang@huawei.com>

> I understand if the mirrored regions are always at the start of the zone
> today, but is that somehow guaranteed going forward on all future hardwar=
e?
>
> I think it's important to at least consider what we would do if DMA32
> turned out to be non-reliable.

Current hardware can map one mirrored region from each memory controller.
We have two memory controllers per socket.  So on a 4-socket machine we wil=
l
usually have 8 separate mirrored ranges. Two per NUMA node (assuming
cluster on die is not enabled).

Practically I think it is safe to assume that any sane configuration will a=
lways
choose to mirror the <4GB range:

1) It's a trivial percentage of total memory on a system that supports mirr=
or
(2GB[1] out of my, essentially minimal, 512GB[2] machine). So 0.4% ... why =
would
you not mirror it?
2) It contains a bunch of things that you are likely to want mirrored. Curr=
ently
our boot loaders put the kernel there (don't they??). All sorts of BIOS spa=
ce that
might be accessed at any time by SMI is there.

BUT ... we might want the kernel to ignore its mirrored status precisely be=
cause
we want to make sure that anyone who really needs DMA or DMA32 allocations
is not prevented from using it.

-Tony

[*] 2GB-4GB is MMIO space, so only 2GB of actual memory below the 4GB line.
[2] Big servers should always have at least one DIMM populated in every cha=
nnel
to provide enough memory bandwidth to feed all the cores. This machine has
4 sockets * 2 memory controllers * 4 channels =3D 32 total. Fill them with =
a single
16GB DIMM each gives 512G. Big systems can use larger DIMMs, and fill up to
3 DIMMS on each channel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
