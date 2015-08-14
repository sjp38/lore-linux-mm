Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id B1B736B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 04:39:17 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so23468850qkb.2
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 01:39:17 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id 80si8432845qkp.10.2015.08.14.01.39.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Aug 2015 01:39:16 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
Date: Fri, 14 Aug 2015 08:38:18 +0000
Message-ID: <20150814083818.GB6956@hori1.linux.bs1.fc.nec.co.jp>
References: <BLU436-SMTP256072767311DFB0FD3AE1B807D0@phx.gbl>
 <20150813085332.GA30163@hori1.linux.bs1.fc.nec.co.jp>
 <BLU437-SMTP1006340696EDBC91961809807D0@phx.gbl>
 <20150813100407.GA2993@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP1366B3FB4A3904EBDAE6BF9807D0@phx.gbl>
 <20150814041939.GA9951@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP110412F310BD1723C6F1C3E807C0@phx.gbl>
 <20150814072649.GA31021@hori1.linux.bs1.fc.nec.co.jp>
 <BLU437-SMTP24AA9CF28EF66D040D079B807C0@phx.gbl>
 <BLU436-SMTP11907D46F39F24F62D7E440807C0@phx.gbl>
In-Reply-To: <BLU436-SMTP11907D46F39F24F62D7E440807C0@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <C3B450F316B3124F8A76D0A2838434E8@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Aug 14, 2015 at 03:59:21PM +0800, Wanpeng Li wrote:
> On 8/14/15 3:54 PM, Wanpeng Li wrote:
> >[...]
> >>OK, then I rethink of handling the race in unpoison_memory().
> >>
> >>Currently properly contained/hwpoisoned pages should have page refcount=
 1
> >>(when the memory error hits LRU pages or hugetlb pages) or refcount 0
> >>(when the memory error hits the buddy page.) And current unpoison_memor=
y()
> >>implicitly assumes this because otherwise the unpoisoned page has no pl=
ace
> >>to go and it's just leaked.
> >>So to avoid the kernel panic, adding prechecks of refcount and mapcount
> >>to limit the page to unpoison for only unpoisonable pages looks OK to m=
e.
> >>The page under soft offlining always has refcount >=3D2 and/or mapcount=
 > 0,
> >>so such pages should be filtered out.
> >>
> >>Here's a patch. In my testing (run soft offline stress testing then rep=
eat
> >>unpoisoning in background,) the reported (or similar) bug doesn't happe=
n.
> >>Can I have your comments?
> >As page_action() prints out page maybe still referenced by some users,
> >however, PageHWPoison has already set. So you will leak many poison page=
s.
> >
>
> Anyway, the bug is still there.
>
> [  944.387559] BUG: Bad page state in process expr  pfn:591e3
> [  944.393053] page:ffffea00016478c0 count:-1 mapcount:0 mapping:
> (null) index:0x2
> [  944.401147] flags: 0x1fffff80000000()
> [  944.404819] page dumped because: nonzero _count

Hmm, no luck :(

To investigate more, I'd like to test the exactly same kernel as yours, so
could you share the kernel info (.config and base kernel and what patches
you applied)? or pushing your tree somewhere like github?
# if you like, sending to me privately is fine.

I think that I tested v4.2-rc6 + <your recent 7 hwpoison patches> +
"mm/hwpoison: fix race between soft_offline_page and unpoison_memory",
but I experienced some conflict in applying your patches for some reason,
so it might happen that we are testing on different kernels.

Mine is here:
  https://github.com/Naoya-Horiguchi/linux v4.2-rc6/fix_race_soft_offline_u=
npoison

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
