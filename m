Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E234C6B0401
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 10:42:41 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o21so95574512qtb.13
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 07:42:41 -0700 (PDT)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id p51si14848092qtc.73.2017.06.21.07.42.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 07:42:40 -0700 (PDT)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [PATCH v7 06/10] mm: thp: check pmd migration entry in common
 path
Date: Wed, 21 Jun 2017 10:42:41 -0400
Message-ID: <0FF04F05-088F-413A-8F35-21668F520AC0@sent.com>
In-Reply-To: <20170621114920.mmbexy4dbgbb4juq@node.shutemov.name>
References: <20170620230715.81590-1-zi.yan@sent.com>
 <20170620230715.81590-7-zi.yan@sent.com>
 <20170621114920.mmbexy4dbgbb4juq@node.shutemov.name>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_394919B8-7410-4811-AFC0-839A51BB73D5_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_394919B8-7410-4811-AFC0-839A51BB73D5_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 21 Jun 2017, at 7:49, Kirill A. Shutemov wrote:

> On Tue, Jun 20, 2017 at 07:07:11PM -0400, Zi Yan wrote:
>> @@ -1220,6 +1238,9 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pm=
d_t orig_pmd)
>>  	if (unlikely(!pmd_same(*vmf->pmd, orig_pmd)))
>>  		goto out_unlock;
>>
>> +	if (unlikely(!pmd_present(orig_pmd)))
>> +		goto out_unlock;
>> +
>
> Hm. Shouldn't we wait for the page here?

Thanks for pointing this out.

This chunk is unnecessary, since do_huge_pmd_wp_page() is called by wp_hu=
ge_pmd(),
which is called only when orig_pmd is present. Thus, this code is useless=
=2E
And pmd_same() will also preclude vmf->pmd from not present.


>>  	page =3D pmd_page(orig_pmd);
>>  	VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>>  	/*
>> @@ -1556,6 +1577,12 @@ bool madvise_free_huge_pmd(struct mmu_gather *t=
lb, struct vm_area_struct *vma,
>>  	if (is_huge_zero_pmd(orig_pmd))
>>  		goto out;
>>
>> +	if (unlikely(!pmd_present(orig_pmd))) {
>> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
>> +				  !is_pmd_migration_entry(orig_pmd));
>> +		goto out;
>> +	}
>> +
>>  	page =3D pmd_page(orig_pmd);
>>  	/*
>>  	 * If other processes are mapping this page, we couldn't discard
>> @@ -1770,6 +1797,23 @@ int change_huge_pmd(struct vm_area_struct *vma,=
 pmd_t *pmd,
>>  	preserve_write =3D prot_numa && pmd_write(*pmd);
>>  	ret =3D 1;
>>
>> +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>> +	if (is_swap_pmd(*pmd)) {
>> +		swp_entry_t entry =3D pmd_to_swp_entry(*pmd);
>> +
>> +		VM_BUG_ON(IS_ENABLED(CONFIG_MIGRATION) &&
>> +				  !is_pmd_migration_entry(*pmd));
>> +		if (is_write_migration_entry(entry)) {
>> +			pmd_t newpmd;
>> +
>> +			make_migration_entry_read(&entry);
>> +			newpmd =3D swp_entry_to_pmd(entry);
>> +			set_pmd_at(mm, addr, pmd, newpmd);
>
> I was confused by this. Could you copy comment from change_pte_range()
> here?

Sure. Will do.

>> +		}
>> +		goto unlock;
>> +	}
>> +#endif
>> +
>>  	/*
>>  	 * Avoid trapping faults against the zero page. The read-only
>>  	 * data is likely to be read-cached on the local CPU and

Thanks for your review.

--
Best Regards
Yan Zi

--=_MailMate_394919B8-7410-4811-AFC0-839A51BB73D5_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZSoXhAAoJEEGLLxGcTqbMVscH/RHE3wlZalxoEeuiVFmKhYCk
UvJekWzPQCfMXs1hJogFaLRbds54a7O5j2rPZ25bJBAlYbdevrvtHTH/69qFPUM2
mNG6He4zHlr9W5YYxowoPft02q//NlNqetSEMZQuigfKlOzo/pyncLKDJg8h0M5r
J4Ach8K6QGjem6UaFauL/A7sF6RIHw29GQhD6M74oIzi1u2XtcOelqeOb67BVLMz
47qRx7lyXSnhFWxw9H4bkItrpPZ6448XWg0AG9c37AJBK0RjhjBmOcIWtg8Uw8an
RpDPDTxqV+p0mjekdeD2F0xSzyxHqFsYAw4xrUPpUzUXZ48czK3H/uqczM8tWV0=
=faMy
-----END PGP SIGNATURE-----

--=_MailMate_394919B8-7410-4811-AFC0-839A51BB73D5_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
