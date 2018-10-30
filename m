Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FDD66B04D3
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 02:55:58 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id s22-v6so2980246oie.9
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 23:55:58 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id j3si9601934otk.157.2018.10.29.23.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 23:55:56 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 0/2] mm: soft-offline: fix race against page
 allocation
Date: Tue, 30 Oct 2018 06:54:33 +0000
Message-ID: <20181030065433.GA1119@hori1.linux.bs1.fc.nec.co.jp>
References: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180815154334.f3eecd1029a153421631413a@linux-foundation.org>
 <20180822013748.GA10343@hori1.linux.bs1.fc.nec.co.jp>
 <20180822080025.GD29735@dhcp22.suse.cz>
 <20181026084636.GY18839@dhcp22.suse.cz>
In-Reply-To: <20181026084636.GY18839@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <7022FA189286CD4F87E4A444A2A70611@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, "zy.zhengyi@alibaba-inc.com" <zy.zhengyi@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, Oct 26, 2018 at 10:46:36AM +0200, Michal Hocko wrote:
> On Wed 22-08-18 10:00:25, Michal Hocko wrote:
> > On Wed 22-08-18 01:37:48, Naoya Horiguchi wrote:
> > > On Wed, Aug 15, 2018 at 03:43:34PM -0700, Andrew Morton wrote:
> > > > On Tue, 17 Jul 2018 14:32:30 +0900 Naoya Horiguchi <n-horiguchi@ah.=
jp.nec.com> wrote:
> > > >=20
> > > > > I've updated the patchset based on feedbacks:
> > > > >=20
> > > > > - updated comments (from Andrew),
> > > > > - moved calling set_hwpoison_free_buddy_page() from mm/migrate.c =
to mm/memory-failure.c,
> > > > >   which is necessary to check the return code of set_hwpoison_fre=
e_buddy_page(),
> > > > > - lkp bot reported a build error when only 1/2 is applied.
> > > > >=20
> > > > >   >    mm/memory-failure.c: In function 'soft_offline_huge_page':
> > > > >   > >> mm/memory-failure.c:1610:8: error: implicit declaration of=
 function
> > > > >   > 'set_hwpoison_free_buddy_page'; did you mean 'is_free_buddy_p=
age'?
> > > > >   > [-Werror=3Dimplicit-function-declaration]
> > > > >   >        if (set_hwpoison_free_buddy_page(page))
> > > > >   >            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > > > >   >            is_free_buddy_page
> > > > >   >    cc1: some warnings being treated as errors
> > > > >=20
> > > > >   set_hwpoison_free_buddy_page() is defined in 2/2, so we can't u=
se it
> > > > >   in 1/2. Simply doing s/set_hwpoison_free_buddy_page/!TestSetPag=
eHWPoison/
> > > > >   will fix this.
> > > > >=20
> > > > > v1: https://lkml.org/lkml/2018/7/12/968
> > > > >=20
> > > >=20
> > > > Quite a bit of discussion on these two, but no actual acks or
> > > > review-by's?
> > >=20
> > > Really sorry for late response.
> > > Xishi provided feedback on previous version, but no final ack/reviewe=
d-by.
> > > This fix should work on the reported issue, but rewriting soft-offlin=
ing
> > > without PageHWPoison flag would be the better fix (no actual patch ye=
t.)
> >=20
> > If we can go with the later the I would obviously prefer that. I cannot
> > promise to work on the patch though. I can help with reviewing of
> > course.
> >=20
> > If this is important enough that people are hitting the issue in normal
> > workloads then sure, let's go with the simple fix and continue on top o=
f
> > that.
>=20
> Naoya, did you have any chance to look at this or have any plans to look?
> I am willing to review and help with the overal design but I cannot
> really promise to work on the code.

I have a draft version of a patch to isolate a page in buddy-friendly manne=
r
without PageHWPoison flag (that was written weeks ago, but I couldn't finis=
h
because my other project interrupted me ...).
I'll post it after testing, especially confirming that hotplug code properl=
y
reset the isolated page.

Thanks,
Naoya Horiguchi=
