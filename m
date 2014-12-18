Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 609EB6B0032
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 12:16:51 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id r2so1249386igi.6
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 09:16:51 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id ji6si13955158igb.27.2014.12.18.09.16.49
        for <linux-mm@kvack.org>;
        Thu, 18 Dec 2014 09:16:50 -0800 (PST)
From: James Custer <jcuster@sgi.com>
Subject: RE: [patch 4/6] mm: fix invalid use of pfn_valid_within in
 test_pages_in_a_zone
Date: Thu, 18 Dec 2014 17:16:47 +0000
Message-ID: <E0FB9EDDBE1AAD4EA62C90D3B6E4783B739E6CA4@P-EXMB2-DC21.corp.sgi.com>
References: <548f68bb.wuNDZDL8qk6xEWTm%akpm@linux-foundation.org>,<alpine.DEB.2.10.1412171537560.16260@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1412171537560.16260@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, Russ
 Anderson <rja@sgi.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>

Reading the documentation on pageblock_pfn_to_page it checks to see if all =
of [start_pfn, end_pfn) is valid and within the same zone. But the validity=
 in the entirety of [start_pfn, end_pfn) doesn't seem to be a requirement o=
f test_pages_in_a_zone, unless I'm missing something.=0A=
=0A=
Disclaimer: I'm very much not familiar with this area of code, and I fixed =
this bug based off of documentation that I read. =0A=
=0A=
Regards,=0A=
James=0A=
________________________________________=0A=
From: David Rientjes [rientjes@google.com]=0A=
Sent: Wednesday, December 17, 2014 5:40 PM=0A=
To: akpm@linux-foundation.org=0A=
Cc: linux-mm@kvack.org; James Custer; isimatu.yasuaki@jp.fujitsu.com; kamez=
awa.hiroyu@jp.fujitsu.com; Russ Anderson; stable@vger.kernel.org=0A=
Subject: Re: [patch 4/6] mm: fix invalid use of pfn_valid_within in test_pa=
ges_in_a_zone=0A=
=0A=
On Mon, 15 Dec 2014, akpm@linux-foundation.org wrote:=0A=
=0A=
> diff -puN mm/memory_hotplug.c~mm-fix-invalid-use-of-pfn_valid_within-in-t=
est_pages_in_a_zone mm/memory_hotplug.c=0A=
> --- a/mm/memory_hotplug.c~mm-fix-invalid-use-of-pfn_valid_within-in-test_=
pages_in_a_zone=0A=
> +++ a/mm/memory_hotplug.c=0A=
> @@ -1331,7 +1331,7 @@ int is_mem_section_removable(unsigned lo=0A=
>  }=0A=
>=0A=
>  /*=0A=
> - * Confirm all pages in a range [start, end) is belongs to the same zone=
.=0A=
> + * Confirm all pages in a range [start, end) belong to the same zone.=0A=
>   */=0A=
>  int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn)=
=0A=
>  {=0A=
> @@ -1342,10 +1342,11 @@ int test_pages_in_a_zone(unsigned long s=0A=
>       for (pfn =3D start_pfn;=0A=
>            pfn < end_pfn;=0A=
>            pfn +=3D MAX_ORDER_NR_PAGES) {=0A=
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
>               if (i =3D=3D MAX_ORDER_NR_PAGES)=0A=
>                       continue;=0A=
>               page =3D pfn_to_page(pfn + i);=0A=
=0A=
I think it would be much better to implement test_pages_in_a_zone() as a=0A=
wrapper around the logic in memory compaction's pageblock_pfn_to_page()=0A=
that does this exact same check for a pageblock.  It would only need to=0A=
iterate the valid pageblocks in the [start_pfn, end_pfn) range and find=0A=
the zone of the first pfn of the first valid pageblock.  This not only=0A=
removes code, but it also unifies the implementation since your=0A=
implementation above would be slower.=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
