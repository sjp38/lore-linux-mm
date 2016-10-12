Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D321D6B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 09:10:42 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n189so33296523qke.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:10:42 -0700 (PDT)
Received: from mail-qt0-x232.google.com (mail-qt0-x232.google.com. [2607:f8b0:400d:c0d::232])
        by mx.google.com with ESMTPS id e132si3796864qkb.116.2016.10.12.06.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 06:10:42 -0700 (PDT)
Received: by mail-qt0-x232.google.com with SMTP id q7so14615616qtq.1
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 06:10:42 -0700 (PDT)
Received: from jfdmac.sonatest.net (modemcable066.15-37-24.static.videotron.ca. [24.37.15.66])
        by smtp.gmail.com with ESMTPSA id i32sm2793228qta.43.2016.10.12.06.10.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 06:10:40 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: help for random Padding overwritten
From: Jean-Francois Dagenais <jeff.dagenais@gmail.com>
In-Reply-To: <FFB991A5-E3A4-48A1-9111-83F4F8319ADD@gmail.com>
Date: Wed, 12 Oct 2016 09:10:40 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <FDE9F409-3577-4171-B1C1-97FCE2ADBBE5@gmail.com>
References: <FFB991A5-E3A4-48A1-9111-83F4F8319ADD@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Responding to my self to help others...

> On Oct 8, 2016, at 08:14, Jean-Francois Dagenais =
<jeff.dagenais@gmail.com> wrote:
>=20
>=20
> <3>[  191.166625] Padding ddca2f60: 00 00 00 00 00 00 00 00 01 00 00 =
00 fc 03 00 00  ................
> <3>[  191.166669] Padding ddca2f70: 21 c4 ff ff 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a  !...ZZZZZZZZZZZZ
> <3>[  191.166713] Padding ddca2f80: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> <3>[  191.166755] Padding ddca2f90: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> <3>[  191.166798] Padding ddca2fa0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> <3>[  191.166841] Padding ddca2fb0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> <3>[  191.166883] Padding ddca2fc0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> <3>[  191.166926] Padding ddca2fd0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> <3>[  191.166969] Padding ddca2fe0: 5a 5a 5a 5a 00 00 5c 1f            =
              ZZZZ..\.
> <3>[  191.167011] FIX vm_area_struct: Restoring =
0xddca2f60-0xddca2fe7=3D0x5a
>=20

Found the bug. It was in xilinx_cdma.c where the tx descriptor allocator =
was
mistakenly trying to link the previous HW SG struct which didn't exist =
with the
current one being created. It was using list_first_entry on a freshly
initialized list_head (pointing to itself), so container_of was backing =
from
another struct type into the wrong struct. The 0x1f5c0000 was the =
physical
address of the HW SG descriptor written 4 bytes below the transaction =
struct
found at VM0xddca3000.

>=20
> I'd like to stop messing around and debug this like a pro. What tools =
and/or
> keywords and/or technique should I know and use here?

Anyway, are there any tools worth sharing? For example a tool that could =
absorb
the huge owner tracing output so we can later "data mine" who may have =
owned
which part of memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
