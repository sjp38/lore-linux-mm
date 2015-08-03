Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id A874B9003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 07:41:28 -0400 (EDT)
Received: by qged69 with SMTP id d69so85927330qge.0
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 04:41:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v72si12679375qge.61.2015.08.03.04.41.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 04:41:27 -0700 (PDT)
Message-ID: <55BF5360.9070309@redhat.com>
Date: Mon, 03 Aug 2015 13:41:20 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv9 26/36] mm: rework mapcount accounting to enable 4k mapping
 of THPs
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com> <1437402069-105900-27-git-send-email-kirill.shutemov@linux.intel.com> <55BB8E72.3070101@redhat.com> <20150803104328.GB25034@node.dhcp.inet.fi>
In-Reply-To: <20150803104328.GB25034@node.dhcp.inet.fi>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="m0qCAmf4j3uA62wVoHejXOT7LbH5S2Cdt"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--m0qCAmf4j3uA62wVoHejXOT7LbH5S2Cdt
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 08/03/2015 12:43 PM, Kirill A. Shutemov wrote:
> On Fri, Jul 31, 2015 at 05:04:18PM +0200, Jerome Marchand wrote:
>> On 07/20/2015 04:20 PM, Kirill A. Shutemov wrote:
>>> We're going to allow mapping of individual 4k pages of THP compound.
>>> It means we need to track mapcount on per small page basis.
>>>
>>> Straight-forward approach is to use ->_mapcount in all subpages to tr=
ack
>>> how many time this subpage is mapped with PMDs or PTEs combined. But
>>> this is rather expensive: mapping or unmapping of a THP page with PMD=

>>> would require HPAGE_PMD_NR atomic operations instead of single we hav=
e
>>> now.
>>>
>>> The idea is to store separately how many times the page was mapped as=

>>> whole -- compound_mapcount. This frees up ->_mapcount in subpages to
>>> track PTE mapcount.
>>>
>>> We use the same approach as with compound page destructor and compoun=
d
>>> order to store compound_mapcount: use space in first tail page,
>>> ->mapping this time.
>>>
>>> Any time we map/unmap whole compound page (THP or hugetlb) -- we
>>> increment/decrement compound_mapcount. When we map part of compound p=
age
>>> with PTE we operate on ->_mapcount of the subpage.
>>>
>>> page_mapcount() counts both: PTE and PMD mappings of the page.
>>>
>>> Basically, we have mapcount for a subpage spread over two counters.
>>> It makes tricky to detect when last mapcount for a page goes away.
>>>
>>> We introduced PageDoubleMap() for this. When we split THP PMD for the=

>>> first time and there's other PMD mapping left we offset up ->_mapcoun=
t
>>> in all subpages by one and set PG_double_map on the compound page.
>>> These additional references go away with last compound_mapcount.
>>
>> So this stays even if all PTE mappings goes and the page is again mapp=
ed
>> only with PMD. I'm not sure how often that happen and if it's an issue=

>> worth caring about.
>=20
> We don't have a cheap way to detect this situation and it shouldn't
> happen often enough to care.
>=20

I thought so.


--m0qCAmf4j3uA62wVoHejXOT7LbH5S2Cdt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVv1NgAAoJEHTzHJCtsuoCpsIIAI2P3/OIVzSvgZsfRbxEDha4
zE0KXtm43uXfTTt1UTgDGaYV4QicNYQkTLqwPjuC/1LmV36iLDNg7HxawM2zV4Na
wQ6kU5axVjE8jPfvBg/Dc4JtYYW87g/2RKGCymV7v/WJ82/u5fBUceGOlaWzJTDG
aEj5WR0smla5gc9kawQ640+BBmepUsb7rkjOXwlOcUqa0tkfBWbc/3H8pt47vRpv
38MXckjDCCpHF1Wqb+73PM/kNHCqKs6JvPsXR0M2aVL1csw+ktGVIJ8u6nXrW1mf
j1qPITlRj5v1TXzKknkyu5zP1zDkHVw5tUn+oA8CwqmZ22Rq5WBGzNi5Hrwff7o=
=3FGj
-----END PGP SIGNATURE-----

--m0qCAmf4j3uA62wVoHejXOT7LbH5S2Cdt--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
