Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id A91546B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 18:17:01 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id b16so254980igk.1
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 15:17:01 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id qn8si49065igb.26.2015.02.11.15.17.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 15:17:01 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/1] mm: pagemap: limit scan to virtual region being
 asked
Date: Wed, 11 Feb 2015 23:16:18 +0000
Message-ID: <20150211231605.GA5560@hori1.linux.bs1.fc.nec.co.jp>
References: <1421152024-6204-1-git-send-email-shashim@codeaurora.org>
 <20150114010830.GA16100@hori1.linux.bs1.fc.nec.co.jp>
 <20150211140915.760d9737099fa0f1669818a8@linux-foundation.org>
In-Reply-To: <20150211140915.760d9737099fa0f1669818a8@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <A38C936D7D33714A97A52A135FC2DA43@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shiraz Hashim <shashim@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "oleg@redhat.com" <oleg@redhat.com>, "gorcunov@openvz.org" <gorcunov@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Feb 11, 2015 at 02:09:15PM -0800, Andrew Morton wrote:
> On Wed, 14 Jan 2015 01:08:40 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > On Tue, Jan 13, 2015 at 05:57:04PM +0530, Shiraz Hashim wrote:
> > > pagemap_read scans through the virtual address space of a
> > > task till it prepares 'count' pagemaps or it reaches end
> > > of task.
> > >=20
> > > This presents a problem when the page walk doesn't happen
> > > for vma with VM_PFNMAP set. In which case walk is silently
> > > skipped and no pagemap is prepare, in turn making
> > > pagemap_read to scan through task end, even crossing beyond
> > > 'count', landing into a different vma region. This leads to
> > > wrong presentation of mappings for that vma.
> > >=20
> > > Fix this by limiting end_vaddr to the end of the virtual
> > > address region being scanned.
> > >=20
> > > Signed-off-by: Shiraz Hashim <shashim@codeaurora.org>
> >=20
> > This patch works in some case, but there still seems a problem in anoth=
er case.
> >=20
> > Consider that we have two vmas within some narrow (PAGEMAP_WALK_SIZE) r=
egion.
> > One vma in lower address is VM_PFNMAP, and the other vma in higher addr=
ess is not.
> > Then a single call of walk_page_range() skips the first vma and scans t=
he
> > second vma, but the pagemap record of the second vma will be stored on =
the
> > wrong offset in the buffer, because we just skip vma(VM_PFNMAP) without=
 calling
> > any callbacks (within which add_to_pagemap() increments pm.pos).
> >=20
> > So calling pte_hole() for vma(VM_PFNMAP) looks a better fix to me.
> >=20
>=20
> Can we get this finished off?  ASAP, please.

Yes, I think so.
The patch "mm: pagewalk: call pte_hole() for VM_PFNMAP during walk_page_ran=
ge"
(replacing this patch) is already in mainline.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
