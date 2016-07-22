Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C214828E4
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 03:19:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b62so62950482pfa.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 00:19:16 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id u125si14386635pfb.245.2016.07.22.00.19.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 00:19:15 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
Date: Fri, 22 Jul 2016 07:17:37 +0000
Message-ID: <20160722071737.GA3785@hori1.linux.bs1.fc.nec.co.jp>
References: <20160721123001.GI26379@dhcp22.suse.cz>
 <5790C3DB.8000505@huawei.com> <20160721125555.GJ26379@dhcp22.suse.cz>
 <5790CD52.6050200@huawei.com> <20160721134044.GL26379@dhcp22.suse.cz>
 <5790D4FF.8070907@huawei.com> <20160721140124.GN26379@dhcp22.suse.cz>
 <5790D8A3.3090808@huawei.com> <20160721142722.GP26379@dhcp22.suse.cz>
 <5790DD4B.2060000@huawei.com>
In-Reply-To: <5790DD4B.2060000@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <DFE84DB6DBD6084AABA0B72C7758BD04@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jul 21, 2016 at 10:33:47PM +0800, zhong jiang wrote:
> On 2016/7/21 22:27, Michal Hocko wrote:
> > On Thu 21-07-16 22:13:55, zhong jiang wrote:
> >> On 2016/7/21 22:01, Michal Hocko wrote:
> >>> On Thu 21-07-16 21:58:23, zhong jiang wrote:
> >>>> On 2016/7/21 21:40, Michal Hocko wrote:
> >>>>> On Thu 21-07-16 21:25:38, zhong jiang wrote:
> >>>>>> On 2016/7/21 20:55, Michal Hocko wrote:
> >>>>> [...]
> >>>>>>> OK, now I understand what you mean. So you mean that a different =
process
> >>>>>>> initiates the migration while this path copies to pte. That is ce=
rtainly
> >>>>>>> possible but I still fail to see what is the problem about that.
> >>>>>>> huge_pte_alloc will return the identical pte whether it is regula=
r or
> >>>>>>> migration one. So what exactly is the problem?
> >>>>>>>
> >>>>>> copy_hugetlb_page_range obtain the shared dst_pte, it may be not e=
qual
> >>>>>> to the src_pte.  The dst_pte can come from other process sharing t=
he
> >>>>>> mapping.
> >>>>> So you mean that the parent doesn't have the shared pte while the c=
hild
> >>>>> would get one?
> >>>>> =20
> >>>>  no, parent must have the shared pte because the the child copy the
> >>>> parent. but parent is not the only source pte we can get. when we
> >>>> scan the maping->i_mmap, firstly ,it can obtain a shared pte from
> >>>> other process. but I am not sure.
> >>> But then all the shared ptes should be identical, no? Or am I missing
> >>> something?
> >>  all the shared ptes should be identical, but  there is  a possibility=
 that new process
> >>  want to share the pte from other process ,  other than the parent,  F=
or the first time
> >>  the process is about to share pte with it.   is it possiblity?
> > I do not see how. They are opperating on the same mapping so I really d=
o
> > not see how different process makes any difference.
> >
>    ok , In a words . the new process get the shared pte, The shared pte n=
ot come from the parent process.
>   so , src_pte is not equal to dst_pte.  because src_pte come from the pa=
rent, while dst_pte come from
>   other process.    obviously, it is not same.=20

I think that (src_pte !=3D dst_pte) can happen and that's ok if there's no
migration entry.  But even if we have both of normal entry and migration en=
try
for one hugepage, that still looks fine to me because the running migration
operation fails (because there remains mapcounts on the source hugepage),
and all migration entries are turned back to normal entries pointing to the
source hugepage.

Could you try to see and share what happens on your workload with Michal's =
patch?
If something weird/critical still happens, let's merge your patch.
# I'm trying to write some test cases for it, but might take some time ...

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
