Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 695FD6B0038
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 19:14:14 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so1583980pab.34
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 16:14:14 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id lq5si4224705pab.45.2014.12.09.16.14.11
        for <linux-mm@kvack.org>;
        Tue, 09 Dec 2014 16:14:12 -0800 (PST)
From: James Custer <jcuster@sgi.com>
Subject: RE: [PATCH] mm: fix invalid use of pfn_valid_within in
 test_pages_in_a_zone
Date: Wed, 10 Dec 2014 00:14:09 +0000
Message-ID: <E0FB9EDDBE1AAD4EA62C90D3B6E4783B739E643B@P-EXMB2-DC21.corp.sgi.com>
References: <1418153696-167580-1-git-send-email-jcuster@sgi.com>,<54878D56.4030508@jp.fujitsu.com>
In-Reply-To: <54878D56.4030508@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Russ Anderson <rja@sgi.com>, Derek Fults <dfults@sgi.com>

It is exactly the same if CONFIG_HOLES_IN_NODE is set, but if CONFIG_HOLES_=
IN_NODE is not set, then pfn_valid_within is always 1.=0A=
=0A=
From: https://lkml.org/lkml/2007/3/21/272=0A=
=0A=
"Generally we work under the assumption that memory the mem_map=0A=
array is contigious and valid out to MAX_ORDER_NR_PAGES block=0A=
of pages, ie. that if we have validated any page within this=0A=
MAX_ORDER_NR_PAGES block we need not check any other.  This is not=0A=
true when CONFIG_HOLES_IN_ZONE is set and we must check each and=0A=
every reference we make from a pfn.=0A=
=0A=
Add a pfn_valid_within() helper which should be used when scanning=0A=
pages within a MAX_ORDER_NR_PAGES block when we have already=0A=
checked the validility of the block normally with pfn_valid().=0A=
This can then be optimised away when we do not have holes within=0A=
a MAX_ORDER_NR_PAGES block of pages."=0A=
=0A=
So, since we're iterating over a pageblock there must be a valid pfn to be =
able to use pfn_valid_within (which makes sense since if CONFIG_HOLES_IN_NO=
DE is not set, it is always 1).=0A=
=0A=
I'm just going off of the documentation there and what makes sense to me ba=
sed off that documentation. Does that explanation help?=0A=
=0A=
Regards,=0A=
James Custer=0A=
________________________________________=0A=
From: Yasuaki Ishimatsu [isimatu.yasuaki@jp.fujitsu.com]=0A=
Sent: Tuesday, December 09, 2014 6:01 PM=0A=
To: James Custer; linux-kernel@vger.kernel.org; linux-mm@kvack.org; akpm@li=
nux-foundation.org; kamezawa.hiroyu@jp.fujitsu.com=0A=
Cc: Russ Anderson; Derek Fults=0A=
Subject: Re: [PATCH] mm: fix invalid use of pfn_valid_within in test_pages_=
in_a_zone=0A=
=0A=
(2014/12/10 4:34), James Custer wrote:=0A=
> Offlining memory by 'echo 0 > /sys/devices/system/memory/memory#/online'=
=0A=
> or reading valid_zones 'cat /sys/devices/system/memory/memory#/valid_zone=
s'=0A=
=0A=
> causes BUG: unable to handle kernel paging request due to invalid use of=
=0A=
> pfn_valid_within. This is due to a bug in test_pages_in_a_zone.=0A=
=0A=
The information is not enough to understand what happened on your system.=
=0A=
Could you show full BUG messages?=0A=
=0A=
>=0A=
> In order to use pfn_valid_within within a MAX_ORDER_NR_PAGES block of pag=
es,=0A=
> a valid pfn within the block must first be found. There only needs to be=
=0A=
> one valid pfn found in test_pages_in_a_zone in the first place. So the=0A=
> fix is to replace pfn_valid_within with pfn_valid such that the first=0A=
> valid pfn within the pageblock is found (if it exists). This works=0A=
> independently of CONFIG_HOLES_IN_ZONE.=0A=
>=0A=
> Signed-off-by: James Custer <jcuster@sgi.com>=0A=
> ---=0A=
>   mm/memory_hotplug.c | 11 ++++++-----=0A=
>   1 file changed, 6 insertions(+), 5 deletions(-)=0A=
>=0A=
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c=0A=
> index 1bf4807..304c187 100644=0A=
> --- a/mm/memory_hotplug.c=0A=
> +++ b/mm/memory_hotplug.c=0A=
> @@ -1331,7 +1331,7 @@ int is_mem_section_removable(unsigned long start_pf=
n, unsigned long nr_pages)=0A=
>   }=0A=
>=0A=
>   /*=0A=
> - * Confirm all pages in a range [start, end) is belongs to the same zone=
.=0A=
> + * Confirm all pages in a range [start, end) belong to the same zone.=0A=
>    */=0A=
>   int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn=
)=0A=
>   {=0A=
> @@ -1342,10 +1342,11 @@ int test_pages_in_a_zone(unsigned long start_pfn,=
 unsigned long end_pfn)=0A=
>       for (pfn =3D start_pfn;=0A=
>            pfn < end_pfn;=0A=
>            pfn +=3D MAX_ORDER_NR_PAGES) {=0A=
=0A=
> -             i =3D 0;=0A=
> -             /* This is just a CONFIG_HOLES_IN_ZONE check.*/=0A=
> -             while ((i < MAX_ORDER_NR_PAGES) && !pfn_valid_within(pfn + =
i))=0A=
> -                     i++;=0A=
> +             /* Find the first valid pfn in this pageblock */=0A=
> +             for (i =3D 0; i < MAX_ORDER_NR_PAGES; i++) {=0A=
> +                     if (pfn_valid(pfn + i))=0A=
> +                             break;=0A=
> +             }=0A=
=0A=
If CONFIG_HOLES_IN_NODE is set, there is no difference. Am I making a mista=
ke?=0A=
=0A=
Thanks,=0A=
Yasuaki Ishimatsu=0A=
=0A=
=0A=
>               if (i =3D=3D MAX_ORDER_NR_PAGES)=0A=
>                       continue;=0A=
>               page =3D pfn_to_page(pfn + i);=0A=
>=0A=
=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
