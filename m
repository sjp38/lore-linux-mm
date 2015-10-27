Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 119AD6B0038
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 03:39:26 -0400 (EDT)
Received: by iodd200 with SMTP id d200so49232473iod.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 00:39:25 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id c88si8673315iod.69.2015.10.27.00.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 00:39:25 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so214700071pad.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 00:39:25 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH 4/5] mm: simplify reclaim path for MADV_FREE
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151027070903.GD26803@bbox>
Date: Tue, 27 Oct 2015 15:39:16 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <32537EDE-3EE6-4C44-B820-5BCAF7A5D535@gmail.com>
References: <1445236307-895-1-git-send-email-minchan@kernel.org> <1445236307-895-5-git-send-email-minchan@kernel.org> <alpine.LSU.2.11.1510261828350.10825@eggly.anvils> <EDCE64A3-D874-4FE3-91B5-DE5E26A452F5@gmail.com> <20151027070903.GD26803@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>


> On Oct 27, 2015, at 15:09, Minchan Kim <minchan@kernel.org> wrote:
>=20
> Hello Yalin,
>=20
> Sorry for missing you in Cc list.
> IIRC, mails to send your previous mail =
address(Yalin.Wang@sonymobile.com)
> were returned.
>=20
> You added comment bottom line so I'm not sure what PageDirty you =
meant.
>=20
>> it is wrong here if you only check PageDirty() to decide if the page =
is freezable or not .
>> The Anon page are shared by multiple process, _mapcount > 1 ,
>> so you must check all pt_dirty bit during page_referenced() function,
>> see this mail thread:
>> http://ns1.ske-art.com/lists/kernel/msg1934021.html
>=20
> If one of pte among process sharing the page was dirty, the dirtiness =
should
> be propagated from pte to PG_dirty by try_to_unmap_one.
> IOW, if the page doesn't have PG_dirty flag, it means all of process =
did
> MADV_FREE.
>=20
> Am I missing something from you question?
> If so, could you show exact scenario I am missing?
>=20
> Thanks for the interest.
oh, yeah , that is right , i miss that , pte_dirty will propagate to =
PG_dirty ,
so that is correct .
Generic to say this patch move set_page_dirty() from add_to_swap() to=20
try_to_unmap(), i think can change a little about this patch:

@@ -1476,6 +1446,8 @@ static int try_to_unmap_one(struct page *page, =
struct vm_area_struct *vma,
				ret =3D SWAP_FAIL;
				goto out_unmap;
			}
+			if (!PageDirty(page))
+				SetPageDirty(page);
			if (list_empty(&mm->mmlist)) {
				spin_lock(&mmlist_lock);
				if (list_empty(&mm->mmlist))

i think this 2 lines can be removed ,
since  pte_dirty have propagated to set_page_dirty() , we don=E2=80=99t =
need this line here ,
otherwise you will always dirty a AnonPage, even it is clean,
then we will page out this clean page to swap partition one more , this =
is not needed.
am i understanding correctly ?

By the way, please change my mail address to yalin.wang2010@gmail.com in =
CC list .
Thanks a lot. :)=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
