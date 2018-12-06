Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 515FA6B7842
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 00:22:36 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id q18so13769460iog.18
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 21:22:36 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id d1si8797858itl.33.2018.12.05.21.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 21:22:35 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
Date: Thu, 6 Dec 2018 05:21:38 +0000
Message-ID: <20181206052137.GA28595@hori1.linux.bs1.fc.nec.co.jp>
References: <20181203100309.14784-1-mhocko@kernel.org>
 <20181205122918.GL1286@dhcp22.suse.cz> <20181205165716.GS1286@dhcp22.suse.cz>
In-Reply-To: <20181205165716.GS1286@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D4B2E35E61EDEC49BA3DEE4D2EF58E40@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Wed, Dec 05, 2018 at 05:57:16PM +0100, Michal Hocko wrote:
> On Wed 05-12-18 13:29:18, Michal Hocko wrote:
> [...]
> > After some more thinking I am not really sure the above reasoning is
> > still true with the current upstream kernel. Maybe I just managed to
> > confuse myself so please hold off on this patch for now. Testing by
> > Oscar has shown this patch is helping but the changelog might need to b=
e
> > updated.
>=20
> OK, so Oscar has nailed it down and it seems that 4.4 kernel we have
> been debugging on behaves slightly different. The underlying problem is
> the same though. So I have reworded the changelog and added "just in
> case" PageLRU handling. Naoya, maybe you have an argument that would
> make this void for current upstream kernels.

The following commit (not in 4.4.x stable tree) might explain the
difference you experienced:

  commit 286c469a988fbaf68e3a97ddf1e6c245c1446968                         =
=20
  Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>                     =
=20
  Date:   Wed May 3 14:56:22 2017 -0700                                   =
=20
                                                                          =
=20
      mm: hwpoison: call shake_page() after try_to_unmap() for mlocked page

This commit adds shake_page() for mlocked pages to make sure that the targe=
t
page is flushed out from LRU cache. Without this shake_page(), subsequent
delete_from_lru_cache() (from me_pagecache_clean()) fails to isolate it and
the page will finally return back to LRU list.  So this scenario leads to
"hwpoisoned by still linked to LRU list" page.

Thanks,
Naoya Horiguchi
