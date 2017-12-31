Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F21E6B0038
	for <linux-mm@kvack.org>; Sun, 31 Dec 2017 08:10:06 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g8so26436907pgs.14
        for <linux-mm@kvack.org>; Sun, 31 Dec 2017 05:10:06 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0122.outbound.protection.outlook.com. [104.47.41.122])
        by mx.google.com with ESMTPS id u19si23285631pgn.488.2017.12.31.05.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 31 Dec 2017 05:10:05 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC PATCH 3/3] mm: unclutter THP migration
Date: Sun, 31 Dec 2017 08:09:57 -0500
Message-ID: <4F0E0390-D9C0-4A67-90F7-42CA944FE4F6@cs.rutgers.edu>
In-Reply-To: <20171231090710.GA18691@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-4-mhocko@kernel.org>
 <AEE005DE-5103-4BCC-BAAB-9E126173AB62@cs.rutgers.edu>
 <20171229113627.GB27077@dhcp22.suse.cz>
 <044496C5-5ACD-4845-A7A3-BD920BF9233B@cs.rutgers.edu>
 <20171231090710.GA18691@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_DF0F4D66-2B57-493A-81AD-6BAC75A54D4B_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_DF0F4D66-2B57-493A-81AD-6BAC75A54D4B_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 31 Dec 2017, at 4:07, Michal Hocko wrote:

> On Fri 29-12-17 10:45:46, Zi Yan wrote:
>> On 29 Dec 2017, at 6:36, Michal Hocko wrote:
>>
>>> On Tue 26-12-17 21:19:35, Zi Yan wrote:
> [...]
>>>> And it seems a little bit strange to only re-migrate the head page, =
then come back to all tail
>>>> pages after migrating the rest of pages in the list =E2=80=9Cfrom=E2=
=80=9D. Is it better to split the THP into
>>>> a list other than =E2=80=9Cfrom=E2=80=9D and insert the list after =E2=
=80=9Cpage=E2=80=9D, then retry from the split =E2=80=9Cpage=E2=80=9D?
>>>> Thus, we attempt to migrate all sub pages of the THP after it is spl=
it.
>>>
>>> Why does this matter?
>>
>> Functionally, it does not matter.
>>
>> This behavior is just less intuitive and a little different from curre=
nt one,
>> which implicitly preserves its original order of the not-migrated page=
s
>> in the =E2=80=9Cfrom=E2=80=9D list, although no one relies on this imp=
licit behavior now.
>>
>>
>> Adding one line comment about this difference would be good for code m=
aintenance. :)
>
> OK, I will not argue. I still do not see _why_ we need it but I've adde=
d
> the following.
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 21b3381a2871..0ac5185d3949 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1395,6 +1395,11 @@ int migrate_pages(struct list_head *from, new_pa=
ge_t get_new_page,
>  				 * allocation could've failed so we should
>  				 * retry on the same page with the THP split
>  				 * to base pages.
> +				 *
> +				 * Head page is retried immediatelly and tail
> +				 * pages are added to the tail of the list so
> +				 * we encounter them after the rest of the list
> +				 * is processed.
>  				 */
>  				if (PageTransHuge(page)) {
>  					lock_page(page);
>
> Does that this reflect what you mean?

s/immediatelly/immediately

Yes. Thanks. :)

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_DF0F4D66-2B57-493A-81AD-6BAC75A54D4B_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlpI4aUWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzFYBCACbrsKeuxRDFzChCBOpGQp8VXdq
gORiB9334hYvpqjueiQywiGpnufJ7kT2cqLC56jtr20eTivDujL1dtuVnxHqapx3
UuiIpkhp9K5q3VdHo8Rswo8RE8kEM12DWedL3dh5ABKCnDyrARpeVSTDgZCgQGuA
0g+Jq4Tx+HyHaLo8iY8WNsUH7DWVSAMuWlN01rt9G8Emm/2Irkx3fozmv+26gZxK
cOAHpgaDMDHzwheJuhrcVMrw+9F5+utuCyHDUQnypZqppfSBPPrSt+Vn/DMlqeKZ
EQt1r5FTkb8sfre8lk66d4DrkvGhvZ11lWaY8437O12YF4mumiknRj8gABq+
=QmL8
-----END PGP SIGNATURE-----

--=_MailMate_DF0F4D66-2B57-493A-81AD-6BAC75A54D4B_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
