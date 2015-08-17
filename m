Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F2A4D6B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 00:33:43 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so99689405pab.0
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 21:33:43 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id f5si22641858pdb.6.2015.08.16.21.33.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Aug 2015 21:33:43 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
Date: Mon, 17 Aug 2015 04:32:08 +0000
Message-ID: <1439785924-27885-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <BLU436-SMTP2235CDFEDA4DEB534BF8C85807C0@phx.gbl>
In-Reply-To: <BLU436-SMTP2235CDFEDA4DEB534BF8C85807C0@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, Aug 14, 2015 at 05:01:34PM +0800, Wanpeng Li wrote:
> On 8/14/15 4:38 PM, Naoya Horiguchi wrote:
> > On Fri, Aug 14, 2015 at 03:59:21PM +0800, Wanpeng Li wrote:
> >> On 8/14/15 3:54 PM, Wanpeng Li wrote:
> >>> [...]
> >>>> OK, then I rethink of handling the race in unpoison_memory().
> >>>>
> >>>> Currently properly contained/hwpoisoned pages should have page refco=
unt 1
> >>>> (when the memory error hits LRU pages or hugetlb pages) or refcount =
0
> >>>> (when the memory error hits the buddy page.) And current unpoison_me=
mory()
> >>>> implicitly assumes this because otherwise the unpoisoned page has no=
 place
> >>>> to go and it's just leaked.
> >>>> So to avoid the kernel panic, adding prechecks of refcount and mapco=
unt
> >>>> to limit the page to unpoison for only unpoisonable pages looks OK t=
o me.
> >>>> The page under soft offlining always has refcount >=3D2 and/or mapco=
unt > 0,
> >>>> so such pages should be filtered out.
> >>>>
> >>>> Here's a patch. In my testing (run soft offline stress testing then =
repeat
> >>>> unpoisoning in background,) the reported (or similar) bug doesn't ha=
ppen.
> >>>> Can I have your comments?
> >>> As page_action() prints out page maybe still referenced by some users=
,
> >>> however, PageHWPoison has already set. So you will leak many poison p=
ages.
> >>>
> >> Anyway, the bug is still there.
> >>
> >> [  944.387559] BUG: Bad page state in process expr  pfn:591e3
> >> [  944.393053] page:ffffea00016478c0 count:-1 mapcount:0 mapping:
> >> (null) index:0x2
> >> [  944.401147] flags: 0x1fffff80000000()
> >> [  944.404819] page dumped because: nonzero _count
> > Hmm, no luck :(
> >
> > To investigate more, I'd like to test the exactly same kernel as yours,=
 so
> > could you share the kernel info (.config and base kernel and what patch=
es
> > you applied)? or pushing your tree somewhere like github?
> > # if you like, sending to me privately is fine.
> >
> > I think that I tested v4.2-rc6 + <your recent 7 hwpoison patches> +
> > "mm/hwpoison: fix race between soft_offline_page and unpoison_memory",
> > but I experienced some conflict in applying your patches for some reaso=
n,
> > so it might happen that we are testing on different kernels.
>=20
> I don't have special config and tree, the latest mmotm has already
> merged my recent 8 hwpoison patches, you can test based on it.

OK, so I wrote the next version against mmotm-2015-08-13-15-29 (replied to
this email.) It moves PageSetHWPoison part into migration code, which shoul=
d
close up the reported race window and minimize the another revived race win=
dow
of reusing offlined pages, so I feel that it's a good compromise between tw=
o
races.

My testing shows no kernel panic with these patches (same testing easily ca=
used
panics for bare mmotm-2015-08-13-15-29,) so they should work. But I'm appre=
ciated
if you help double checking.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
