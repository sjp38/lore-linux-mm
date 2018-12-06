Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 293F36B792D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 04:17:09 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id q18so14205161iog.18
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 01:17:09 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id b5si12500389ioh.127.2018.12.06.01.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 01:17:08 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
Date: Thu, 6 Dec 2018 09:15:53 +0000
Message-ID: <20181206091552.GB26516@hori1.linux.bs1.fc.nec.co.jp>
References: <20181203100309.14784-1-mhocko@kernel.org>
 <20181205122918.GL1286@dhcp22.suse.cz>
 <20181205165716.GS1286@dhcp22.suse.cz>
 <20181206052137.GA28595@hori1.linux.bs1.fc.nec.co.jp>
 <20181206083206.GC1286@dhcp22.suse.cz>
In-Reply-To: <20181206083206.GC1286@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <CD9A479AF56DBD4EA4EB6EB94A401617@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <OSalvador@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Thu, Dec 06, 2018 at 09:32:06AM +0100, Michal Hocko wrote:
> On Thu 06-12-18 05:21:38, Naoya Horiguchi wrote:
> > On Wed, Dec 05, 2018 at 05:57:16PM +0100, Michal Hocko wrote:
> > > On Wed 05-12-18 13:29:18, Michal Hocko wrote:
> > > [...]
> > > > After some more thinking I am not really sure the above reasoning i=
s
> > > > still true with the current upstream kernel. Maybe I just managed t=
o
> > > > confuse myself so please hold off on this patch for now. Testing by
> > > > Oscar has shown this patch is helping but the changelog might need =
to be
> > > > updated.
> > >=20
> > > OK, so Oscar has nailed it down and it seems that 4.4 kernel we have
> > > been debugging on behaves slightly different. The underlying problem =
is
> > > the same though. So I have reworded the changelog and added "just in
> > > case" PageLRU handling. Naoya, maybe you have an argument that would
> > > make this void for current upstream kernels.
> >=20
> > The following commit (not in 4.4.x stable tree) might explain the
> > difference you experienced:
> >=20
> >   commit 286c469a988fbaf68e3a97ddf1e6c245c1446968                      =
   =20
> >   Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>                  =
   =20
> >   Date:   Wed May 3 14:56:22 2017 -0700                                =
   =20
> >                                                                        =
   =20
> >       mm: hwpoison: call shake_page() after try_to_unmap() for mlocked =
page
> >=20
> > This commit adds shake_page() for mlocked pages to make sure that the t=
arget
> > page is flushed out from LRU cache. Without this shake_page(), subseque=
nt
> > delete_from_lru_cache() (from me_pagecache_clean()) fails to isolate it=
 and
> > the page will finally return back to LRU list.  So this scenario leads =
to
> > "hwpoisoned by still linked to LRU list" page.
>=20
> OK, I see. So does that mean that the LRU handling is no longer needed
> and there is a guanratee that all kernels with the above commit cannot
> ever get an LRU page?

Theoretically no such gurantee, because try_to_unmap() doesn't have a
guarantee of success and then memory_failure() returns immediately
when hwpoison_user_mappings fails.
Or the following code (comes after hwpoison_user_mappings block) also impli=
es
that the target page can still have PageLRU flag.

        /*
         * Torn down by someone else?
         */
        if (PageLRU(p) && !PageSwapCache(p) && p->mapping =3D=3D NULL) {
                action_result(pfn, MF_MSG_TRUNCATED_LRU, MF_IGNORED);
                res =3D -EBUSY;
                goto out;
        }

So I think it's OK to keep "if (WARN_ON(PageLRU(page)))" block in
current version of your patch.

Feel free to add my ack.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi=
