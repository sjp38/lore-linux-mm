Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DAED56B0069
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:18:43 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c83so14131490pfj.11
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 01:18:43 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0095.outbound.protection.outlook.com. [104.47.33.95])
        by mx.google.com with ESMTPS id h3si13233021plh.592.2017.11.22.01.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 01:18:42 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
Date: Wed, 22 Nov 2017 04:18:35 -0500
Message-ID: <26CA724E-070E-4D06-B75E-F1880B1F2CF9@cs.rutgers.edu>
In-Reply-To: <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz>
References: <20171121021855.50525-1-zi.yan@sent.com>
 <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_5264ABDE-3473-4695-B0D4-900CEEEF86F0_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Reale <ar@linux.vnet.ibm.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_5264ABDE-3473-4695-B0D4-900CEEEF86F0_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 22 Nov 2017, at 3:54, Michal Hocko wrote:

> On Mon 20-11-17 21:18:55, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>
>> In [1], Andrea reported that during memory hotplug/hot remove
>> prep_transhuge_page() is called incorrectly on non-THP pages for
>> migration, when THP is on but THP migration is not enabled.
>> This leads to a bad state of target pages for migration.
>>
>> This patch fixes it by only calling prep_transhuge_page() when we are
>> certain that the target page is THP.
>>
>> [1] https://lkml.org/lkml/2017/11/20/411
>
> lkml.org tends to be quite unstable so a
> http://lkml.kernel.org/r/$msg-id is usually a preferred way.

Got it. Thanks.

>
>>
>> Cc: stable@vger.kernel.org # v4.14
>> Fixes: 8135d8926c08 ("mm: memory_hotplug: memory hotremove supports th=
p migration")
>> Reported-by: Andrea Reale <ar@linux.vnet.ibm.com>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
>> ---
>>  include/linux/migrate.h | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
>> index 895ec0c4942e..a2246cf670ba 100644
>> --- a/include/linux/migrate.h
>> +++ b/include/linux/migrate.h
>> @@ -54,7 +54,7 @@ static inline struct page *new_page_nodemask(struct =
page *page,
>>  	new_page =3D __alloc_pages_nodemask(gfp_mask, order,
>>  				preferred_nid, nodemask);
>>
>> -	if (new_page && PageTransHuge(page))
>> +	if (new_page && PageTransHuge(new_page))
>>  		prep_transhuge_page(new_page);
>
> I would keep the two checks consistent. But that leads to a more
> interesting question. new_page_nodemask does
>
> 	if (thp_migration_supported() && PageTransHuge(page)) {
> 		order =3D HPAGE_PMD_ORDER;
> 		gfp_mask |=3D GFP_TRANSHUGE;
> 	}
>
> How come it is safe to allocate an order-0 page if
> !thp_migration_supported() when we are about to migrate THP? This
> doesn't make any sense to me. Are we working around this somewhere else=
?
> Why shouldn't we simply return NULL here?

If !thp_migration_supported(), we will first split a THP and migrate its =
head page. This process
is done in unmap_and_move() after get_new_page() (the function pointer to=
 this new_page_nodemask())
is called. The situation can be PageTransHuge(page) is true here, but the=
 page is split
in unmap_and_move(), so we want to return a order-0 page here.

I think the confusion comes from that there is no guarantee of THP alloca=
tion when we are
doing THP migration. If we can allocate a THP during THP migration, we ar=
e good. Otherwise, we want to
fallback to the old way, splitting the original THP and migrating the hea=
d page, to preserve
the original code behavior.

Does it clarify your confusion?


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_5264ABDE-3473-4695-B0D4-900CEEEF86F0_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAloVQOsWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzFdVB/4+u+VxMIu6GCbIMo+ZyWyLNDXO
reD9pF9ihWMgNA38VvZoIOfr6trEVsGDXRav2ubAKjzFZf80mnW81CRl49mqhwZG
VedtKqbddDgBwEeuziZbKzJ+iBs8eRg7NWFCHqFoNFt3Fp/8dFBNI4PjVE1orwzI
fAtXCewjzIjxvcf5GNcryjZBNtuqs02gJK2mjIQ0AqfxpAomRFJ0txDHpzCCwZLE
5dKOOiBandf7+Xr+/ONQW8H0Kf7jAUF3Y/b04r2sRfBXwrfqCntjSc/BqXEJfskW
KnvTC9Wir/SuiKBIdkk2pYQes24BRfmJ7IrzK/6D56UOUrum2OzyLqhDhhGq
=OwLp
-----END PGP SIGNATURE-----

--=_MailMate_5264ABDE-3473-4695-B0D4-900CEEEF86F0_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
