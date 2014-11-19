Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5CA6B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 08:16:00 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so5319324wiv.0
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 05:15:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fa3si2616977wjd.31.2014.11.19.05.15.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Nov 2014 05:15:58 -0800 (PST)
Message-ID: <546C97EC.10905@redhat.com>
Date: Wed, 19 Nov 2014 14:15:24 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/19] mm: store mapcount for compound page separate
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com> <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com> <546C761D.6050407@redhat.com> <20141119130050.GA29884@node.dhcp.inet.fi>
In-Reply-To: <20141119130050.GA29884@node.dhcp.inet.fi>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="D0iXfmHUpo7RM25lPPKt2AucLa8O5rJmI"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--D0iXfmHUpo7RM25lPPKt2AucLa8O5rJmI
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11/19/2014 02:00 PM, Kirill A. Shutemov wrote:
> On Wed, Nov 19, 2014 at 11:51:09AM +0100, Jerome Marchand wrote:
>> On 11/05/2014 03:49 PM, Kirill A. Shutemov wrote:
>>> We're going to allow mapping of individual 4k pages of THP compound a=
nd
>>> we need a cheap way to find out how many time the compound page is
>>> mapped with PMD -- compound_mapcount() does this.
>>>
>>> page_mapcount() counts both: PTE and PMD mappings of the page.
>>>
>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>> ---
>>>  include/linux/mm.h   | 17 +++++++++++++++--
>>>  include/linux/rmap.h |  4 ++--
>>>  mm/huge_memory.c     | 23 ++++++++++++++---------
>>>  mm/hugetlb.c         |  4 ++--
>>>  mm/memory.c          |  2 +-
>>>  mm/migrate.c         |  2 +-
>>>  mm/page_alloc.c      | 13 ++++++++++---
>>>  mm/rmap.c            | 50 ++++++++++++++++++++++++++++++++++++++++++=
+-------
>>>  8 files changed, 88 insertions(+), 27 deletions(-)
>>>
>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>> index 1825c468f158..aef03acff228 100644
>>> --- a/include/linux/mm.h
>>> +++ b/include/linux/mm.h
>>> @@ -435,6 +435,19 @@ static inline struct page *compound_head(struct =
page *page)
>>>  	return page;
>>>  }
>>> =20
>>> +static inline atomic_t *compound_mapcount_ptr(struct page *page)
>>> +{
>>> +	return (atomic_t *)&page[1].mapping;
>>> +}
>>
>> IIUC your patch overloads the unused mapping field of the first tail
>> page to store the PMD mapcount. That's a non obvious trick. Why not ma=
ke
>> it more explicit by adding a new field (say compound_mapcount - and th=
e
>> appropriate comment of course) to the union to which mapping already b=
elong?
>=20
> I don't think we want to bloat struct page description: nobody outside =
of
> helpers should use it direcly. And it's exactly what we did to store
> compound page destructor and compound page order.

Yes, but hiding it might make people think this field is unused when
it's not. If it has been done that way for a while, maybe it's not as
much trouble as I think it is, but could you at least add a comment in
the helper.

>=20
>> The patch description would benefit from more explanation too.
>=20
> Agreed.
>=20



--D0iXfmHUpo7RM25lPPKt2AucLa8O5rJmI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUbJfsAAoJEHTzHJCtsuoCs2EIAK2Dy9isSBb5uUh9mv2GOBhN
cgAlRMwQf2dirDILIZMRrbGp3whn7MHQttyuVffvIzipZ5rkzluFCpnJogLuXP+H
WeCR4XLWAkBvM7mbWLDkve/Xa5RRavqTFgW4jqrpS5OFflLaqKP7YyAlB+PPEe8F
pKJqTtUZn5VRA8usXJVzv9Abhwi6B2a2ILXhc0Vpg132qlUqnUzqldpn+hxJj1YT
jQ5ah7TOHkQ0+dr2i+PQXASekKQSgtYoqlxY+dTpubKAyObdX53d/OhvF88lF9KK
cr8Y2do1oM2Ch9woKvnAbJ+HbmK39hkabwuF+SZQfVebu6WYuYUvACzaE+Hh3nw=
=NRWw
-----END PGP SIGNATURE-----

--D0iXfmHUpo7RM25lPPKt2AucLa8O5rJmI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
