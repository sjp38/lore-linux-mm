Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF3C76B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 20:40:41 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id 16so4098732oin.13
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 17:40:41 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id 199si3829556oie.290.2018.01.29.17.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 17:40:40 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: hwpoison: disable memory error handling on 1GB
 hugepage
Date: Tue, 30 Jan 2018 01:39:22 +0000
Message-ID: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
References: <1517207283-15769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20180129063054.GA5205@hori1.linux.bs1.fc.nec.co.jp>
 <20180129095425.GA21609@dhcp22.suse.cz>
 <a1a921dc-3095-41f7-a4db-0de79bf65f8b@oracle.com>
In-Reply-To: <a1a921dc-3095-41f7-a4db-0de79bf65f8b@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9FBD24293E15124980E3ED3C8E001CC3@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Hi Michal, Mike,

On Mon, Jan 29, 2018 at 10:08:53AM -0800, Mike Kravetz wrote:
> On 01/29/2018 01:54 AM, Michal Hocko wrote:
> > On Mon 29-01-18 06:30:55, Naoya Horiguchi wrote:
> >> My apology, I forgot to CC to the mailing lists.
> >>
> >> On Mon, Jan 29, 2018 at 03:28:03PM +0900, Naoya Horiguchi wrote:
> >>> Recently the following BUG was reported:
> >>>
> >>>     Injecting memory failure for pfn 0x3c0000 at process virtual addr=
ess 0x7fe300000000
> >>>     Memory failure: 0x3c0000: recovery action for huge page: Recovere=
d
> >>>     BUG: unable to handle kernel paging request at ffff8dfcc0003000
> >>>     IP: gup_pgd_range+0x1f0/0xc20
> >>>     PGD 17ae72067 P4D 17ae72067 PUD 0
> >>>     Oops: 0000 [#1] SMP PTI
> >>>     ...
> >>>     CPU: 3 PID: 5467 Comm: hugetlb_1gb Not tainted 4.15.0-rc8-mm1-abc=
+ #3
> >>>     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3=
-1.fc25 04/01/2014
> >>>
> >>> You can easily reproduce this by calling madvise(MADV_HWPOISON) twice=
 on
> >>> a 1GB hugepage. This happens because get_user_pages_fast() is not awa=
re
> >>> of a migration entry on pud that was created in the 1st madvise() eve=
nt.
> >=20
> > Do pgd size pages work properly?

PGD size is unsupported now too, and this patch is also disabling that size=
.

>=20
> Adding Anshuman and Aneesh as they added pgd support for power.  And,
> this patch will disable that as well IIUC.

Thanks Mike, I want to have some feedback from PowerPC developers too.

>=20
> This patch makes sense for x86.  My only concern/question is for other
> archs which may have huge page sizes defined which are > MAX_ORDER and
> < PUD_SIZE.  These would also be classified as gigantic and impacted
> by this patch.  Do these also have the same issue?

Maybe one clearer way is to use more explicit condition like "page size > P=
MD_SIZE".

>=20
> --=20
> Mike Kravetz
>=20
> >>> I think that conversion to pud-aligned migration entry is working,
> >>> but other MM code walking over page table isn't prepared for it.
> >>> We need some time and effort to make all this work properly, so
> >>> this patch avoids the reported bug by just disabling error handling
> >>> for 1GB hugepage.
> >=20
> > Can we also get some documentation which would describe all requirement=
s
> > for HWPoison pages to work properly please?

OK, I'll add this.

> >=20
> >>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >=20
> > Acked-by: Michal Hocko <mhocko@suse.com>
> >=20
> > We probably want a backport to stable as well. Although regular process
> > cannot get giga pages easily without admin help it is still not nice to
> > oops like this.

I'll add CC to stable.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
