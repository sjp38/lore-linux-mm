Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1CF82963
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 19:17:23 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id vv3so85103864pab.2
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 16:17:23 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id p20si22612100pfa.90.2016.04.20.16.17.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Apr 2016 16:17:22 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: mce: a question about memory_failure_early_kill in
 memory_failure()
Date: Wed, 20 Apr 2016 23:15:06 +0000
Message-ID: <20160420231506.GA18729@hori1.linux.bs1.fc.nec.co.jp>
References: <571612DE.8020908@huawei.com>
 <20160420070735.GA10125@hori1.linux.bs1.fc.nec.co.jp>
 <57175F30.6050300@huawei.com> <571760F3.2040305@huawei.com>
In-Reply-To: <571760F3.2040305@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E573CA58F5DCFF42B55D91F321DCF0B6@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 20, 2016 at 06:58:59PM +0800, Xishi Qiu wrote:
> On 2016/4/20 18:51, Xishi Qiu wrote:
>=20
> > On 2016/4/20 15:07, Naoya Horiguchi wrote:
> >=20
> >> On Tue, Apr 19, 2016 at 07:13:34PM +0800, Xishi Qiu wrote:
> >>> /proc/sys/vm/memory_failure_early_kill
> >>>
> >>> 1: means kill all processes that have the corrupted and not reloadabl=
e page mapped.
> >>> 0: means only unmap the corrupted page from all processes and only ki=
ll a process
> >>> who tries to access it.
> >>>
> >>> If set memory_failure_early_kill to 0, and memory_failure() has been =
called.
> >>> memory_failure()
> >>> 	hwpoison_user_mappings()
> >>> 		collect_procs()  // the task(with no PF_MCE_PROCESS flag) is not in=
 the tokill list
> >>> 			try_to_unmap()
> >>>
> >>> If the task access the memory, there will be a page fault,
> >>> so the task can not access the original page again, right?
> >>
> >> Yes, right. That's the behavior in default "late kill" case.
> >>
> >=20
> > Hi Naoya,
> >=20
> > Thanks for your reply, my confusion is that after try_to_unmap(), there=
 will be a
> > page fault if the task access the memory, and we will alloc a new page =
for it.

When try_to_unmap() is called for PageHWPoison(page) without TTU_IGNORE_HWP=
OISON,
page table entries mapping the error page are replaced with hwpoison entrie=
s,
which changes the bahavior of a subsequent page fault. Then, the page fault=
 will
fail with VM_FAULT_HWPOISON, so finally the process will be killed without =
allocating
a new page.

>=20
> Hi Naoya,
>=20
> If we alloc a new page, the task won't access the poisioned page again, s=
o it won't be
> killed by mce(late kill), right?

Allocating a new page for virtual address affected by memory error is dange=
rous
because if the error page was dirty (or anonymous as you mentioned), the da=
ta
is lost and new page allocation means that the data lost is ignored. The fi=
rst
priority of hwpoison mechanism is to avoid consuming corrupted data.

> If the poisioned page is anon, we will lost data, right?

Yes, that's the idea.

>=20
> > So how the hardware(mce) know this page fault is relate to the poisione=
d page which
> > is unmapped from the task?=20
> >=20
> > Will we record something in pte when after try_to_unmap() in memory_fai=
lure()?

As mentioned above, hwpoison entry does this job.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
