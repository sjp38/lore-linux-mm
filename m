Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 572916B0388
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 12:37:51 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id p22so8079642qka.0
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 09:37:51 -0800 (PST)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id r45si8497046qte.148.2017.02.09.09.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 09:37:48 -0800 (PST)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v3 13/14] mm: migrate: move_pages() supports thp migration
Date: Thu, 09 Feb 2017 11:37:46 -0600
Message-ID: <55143FF5-ED23-4DC8-811C-D31AE254C38E@sent.com>
In-Reply-To: <20170209091655.GB15890@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-14-zi.yan@sent.com>
 <20170209091655.GB15890@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_30514661-25B7-4549-AAE1-440772AF6120_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_30514661-25B7-4549-AAE1-440772AF6120_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 9 Feb 2017, at 3:16, Naoya Horiguchi wrote:

> On Sun, Feb 05, 2017 at 11:12:51AM -0500, Zi Yan wrote:
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> This patch enables thp migration for move_pages(2).
>>
>> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> ---
>>  mm/migrate.c | 37 ++++++++++++++++++++++++++++---------
>>  1 file changed, 28 insertions(+), 9 deletions(-)
>>
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 84181a3668c6..9bcaccb481ac 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -1413,7 +1413,17 @@ static struct page *new_page_node(struct page *=
p, unsigned long private,
>>  	if (PageHuge(p))
>>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>>  					pm->node);
>> -	else
>> +	else if (thp_migration_supported() && PageTransHuge(p)) {
>> +		struct page *thp;
>> +
>> +		thp =3D alloc_pages_node(pm->node,
>> +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
>> +			HPAGE_PMD_ORDER);
>> +		if (!thp)
>> +			return NULL;
>> +		prep_transhuge_page(thp);
>> +		return thp;
>> +	} else
>>  		return __alloc_pages_node(pm->node,
>>  				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
>>  }
>> @@ -1440,6 +1450,8 @@ static int do_move_page_to_node_array(struct mm_=
struct *mm,
>>  	for (pp =3D pm; pp->node !=3D MAX_NUMNODES; pp++) {
>>  		struct vm_area_struct *vma;
>>  		struct page *page;
>> +		struct page *head;
>> +		unsigned int follflags;
>>
>>  		err =3D -EFAULT;
>>  		vma =3D find_vma(mm, pp->addr);
>> @@ -1447,8 +1459,10 @@ static int do_move_page_to_node_array(struct mm=
_struct *mm,
>>  			goto set_status;
>>
>>  		/* FOLL_DUMP to ignore special (like zero) pages */
>> -		page =3D follow_page(vma, pp->addr,
>> -				FOLL_GET | FOLL_SPLIT | FOLL_DUMP);
>> +		follflags =3D FOLL_GET | FOLL_SPLIT | FOLL_DUMP;
>
> FOLL_SPLIT should be added depending on thp_migration_supported().

Sure. I will fix it.


--
Best Regards
Yan Zi

--=_MailMate_30514661-25B7-4549-AAE1-440772AF6120_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYnKjqAAoJEEGLLxGcTqbMx1AH/iB0WeZCPh+yAr7n6dF35sNm
VhXJzu6LMlFuUqct+uPSUwi23UVQ7fTww+5/gjgOG2VBVUE+a1T1z8T1MYcjHKEq
+/L2VYj08tVUCw34nGZR0LxGQCVXLwCnSV4kH+0dMEGhkNZl6dwIhuLJh3Go1Rsv
KJ5joqeK866W8DALZDFlmkkzVi36ptH9R9LXeeIz17CZLlZzsWbZLJo8A3kXYNBk
iuNgrmT10ZU+Not1GdDmfUGpw+DJE++USe5/Bnv2NsrpBQgmVAnMWVWA9Jk8VlRV
39IGe/gzJtyGFwzH+4/ySkJuUm+YjHsDDbtUQob9EZEU3twTMk2mAvOHBn+SNgs=
=BG9o
-----END PGP SIGNATURE-----

--=_MailMate_30514661-25B7-4549-AAE1-440772AF6120_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
