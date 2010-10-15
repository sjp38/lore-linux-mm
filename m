Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0CB575F0047
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 18:36:07 -0400 (EDT)
Received: by qyk7 with SMTP id 7so2317485qyk.14
        for <linux-mm@kvack.org>; Fri, 15 Oct 2010 15:36:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1010151211040.24683@router.home>
References: <20101015170627.e5033fa4.kamezawa.hiroyu@jp.fujitsu.com>
	<20101015171109.d4575c95.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1010151211040.24683@router.home>
Date: Sat, 16 Oct 2010 07:36:05 +0900
Message-ID: <AANLkTimNqAwb88kG2r4BkukhG7nutDHPXKqaAON687uT@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/2] memcg: avoiding unnecessary get_page at move_charge
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

2010/10/16 Christoph Lameter <cl@linux.com>:
> On Fri, 15 Oct 2010, KAMEZAWA Hiroyuki wrote:
>
>> But above is called all under pte_offset_map_lock().
>> get_page_unless_zero() #1 is not necessary because we do all under a
>> pte_offset_map_lock().
>
> The two (ptl and refcount) are entirely different. The ptl is for
> protecting the page table. The refcount handles only the page.
>
> However, if the entry in the page table is pointing to the page then ther=
e
> must have been a refcount taken on the page. So if you know that the page
> is in the page table and you took the ptl then you can be sure that the
> page refcount will not become zero. Therefore get_page_unless_zero() will
> never fail and there is no need to take additional refcounts as long as
> the page table lock is held and the page is not removed from the page
> table.
>

Ok, thank you for explanation. I can make this function faster.

>> Index: mmotm-1013/mm/vmscan.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- mmotm-1013.orig/mm/vmscan.c
>> +++ mmotm-1013/mm/vmscan.c
>> @@ -1166,7 +1166,8 @@ static unsigned long clear_active_flags(
>> =A0 * found will be decremented.
>> =A0 *
>> =A0 * Restrictions:
>> - * (1) Must be called with an elevated refcount on the page. This is a
>> + * (1) Must be called with an elevated refcount on the page, IOW, the
>> + * =A0 =A0 caller must guarantee that there is a stable reference. This=
 is a
>> =A0 * =A0 =A0 fundamentnal difference from isolate_lru_pages (which is c=
alled
>> =A0 * =A0 =A0 without a stable reference).
>> =A0 * (2) the lru_lock must not be held.
>
> There is no need for this change since you have an elevated refcount.
> IMH The words "stable reference" may be confusing since the refcount may
> change. The elevated refcount protects against the freeing of the page.
>

Sure, drop change this in v2. I misunderstand "elevated refcount"
means "extra get_page()".

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
