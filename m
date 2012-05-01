Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 376CF6B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 09:53:59 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so3736995vbb.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 06:53:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201205011333.q41DXsK7026759@farm-0013.internal.tilera.com>
References: <201204291936.q3TJa4Mv008924@farm-0027.internal.tilera.com>
	<alpine.LSU.2.00.1204301308090.2829@eggly.anvils>
	<20120501131413.GA11435@suse.de>
	<201205011333.q41DXsK7026759@farm-0013.internal.tilera.com>
Date: Tue, 1 May 2012 21:53:58 +0800
Message-ID: <CAJd=RBCWcAU17tHofjcGsKPk6M4PxuvDBp9zgmhpJnZHu7hKpA@mail.gmail.com>
Subject: Re: [PATCH] hugetlb: avoid gratuitous BUG_ON in hugetlb_fault() -> hugetlb_cow()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 30, 2012 at 3:04 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
> Commit 66aebce747eaf added code to avoid a race condition by
> elevating the page refcount in hugetlb_fault() while calling
> hugetlb_cow(). =C2=A0However, one code path in hugetlb_cow() includes
> an assertion that the page count is 1, whereas it may now also
> have the value 2 in this path. =C2=A0Consensus is that this BUG_ON
> has served its purpose, so rather than extending it to cover both
> cases, we just remove it.
>
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---

Acked-by: Hillf Danton <dhillf@gmail.com>

> =C2=A0mm/hugetlb.c | =C2=A0 =C2=A01 -
> =C2=A01 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index cd65cb1..baaad5d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2498,7 +2498,6 @@ retry_avoidcopy:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (outside_reserv=
e) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0BUG_ON(huge_pte_none(pte));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (unmap_ref_private(mm, vma, old_page, address)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(page_count(old_page) !=3D 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(huge_pte_none(pte));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&mm->page_table_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ptep =3D huge_pte_offset(mm, address =
& huge_page_mask(h));
> --
> 1.6.5.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
