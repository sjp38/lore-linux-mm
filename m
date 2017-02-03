Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 653F96B0253
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 22:24:14 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j13so10306647iod.6
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 19:24:14 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0138.outbound.protection.outlook.com. [104.47.37.138])
        by mx.google.com with ESMTPS id p69si397712ita.56.2017.02.02.19.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Feb 2017 19:24:13 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
Date: Thu, 2 Feb 2017 21:24:03 -0600
Message-ID: <75577D22-DDFB-4CAA-B272-B28CBC3FBE7F@cs.rutgers.edu>
In-Reply-To: <004601d27dcb$509327a0$f1b976e0$@alibaba-inc.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <b6f7dd5d-47aa-0ec2-b18a-bb4074ab2a2a@linux.vnet.ibm.com>
 <5890EB58.3050100@cs.rutgers.edu>
 <004601d27dcb$509327a0$f1b976e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_B5BB235C-6606-4538-B0D7-BF8540E684A2_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

--=_MailMate_B5BB235C-6606-4538-B0D7-BF8540E684A2_=
Content-Type: text/plain; markup=markdown

On 2 Feb 2017, at 21:12, Hillf Danton wrote:

> On February 01, 2017 3:54 AM Zi Yan wrote:
>>
>> I am also doing some tests on THP migration and discover that there are
>> some corner cases not handled in this patchset.
>>
>> For example, in handle_mm_fault, without taking pmd_lock, the kernel may
>> see pmd_none(*pmd) during THP migrations, which leads to
>> handle_pte_fault or even deeper in the code path. At that moment,
>> pmd_trans_unstable() will treat a pmd_migration_entry as pmd_bad and
>> clear it. This leads to application crashing and page table leaks, since
>> a deposited PTE page is not released when the application crashes.
>>
>> Even after I add is_pmd_migration_entry() into pmd_trans_unstable(), I
>> still see application data corruptions.
>>
>> I hope someone can shed some light on how to debug this. Should I also
>> look into pmd_trans_huge() call sites where pmd_migration_entry should
>> be handled differently?
>>
> Hm ... seems it helps more if you post your current works as RFC on
> top of the mm tree, and the relevant tests as well.
>

Thanks for replying. I find that data corruption is caused by that
set_pmd_migration_entry() did not flush TLB while changing pmd entries.
I fix it by using pmdp_huge_clear_flush() instead of pmdp_huge_get_and_clear().

The racy pmd check in zap_pmd_range() also causes pmd_bad() problem. I am going
to rebase Naoya's patches and send it again for comments.



> Hillf
>>
>> Anshuman Khandual wrote:
>>> On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
>>>> Hi everyone,
>>>>
>>>> I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27
>>>> with feedbacks for ver.1.
>>>
>>> Hello Noaya,
>>>
>>> I have been working with Zi Yan on the parallel huge page migration series
>>> (https://lkml.org/lkml/2016/11/22/457) and planning to post them on top of
>>> this THP migration enhancement series. Hence we were wondering if you have
>>> plans to post a new version of this series in near future ?
>>>
>>> Regards
>>> Anshuman
>>>
>>
>> --
>> Best Regards,
>> Yan Zi


--
Best Regards
Yan Zi

--=_MailMate_B5BB235C-6606-4538-B0D7-BF8540E684A2_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYk/fUAAoJEEGLLxGcTqbMcosH/3YBjWIpWurwYGqLgjAbnVot
3wOl5KXkVKm8fJKrjlqgGOk87fP5OvsQDSSzZb6B9Ejv3BkymySOqIgfZEH4PH6N
nVw+lKYHic3JnAMukEQbnXi4l37gZhhm1s9NWOqSg5xIzKiujkorgQ//H2HeH5h7
OlIdkJi83c/e/Vde9NzVBHyqQhP12IH/FeCqzA3IUc/d3rU6x1io36K965NTmgS6
eUyG+Q1zDOTFiCXFb0XfIDIsYmw0Kp2ekDSKajwgC5EP6wGTgaV9hvyEjmYoHF8z
zKW8NYsgAu6YtbxgT8wSi2CqiBCMcxE1/iOSZpwbKDMgqTbEGBRWTlH1NXj73tA=
=1oHD
-----END PGP SIGNATURE-----

--=_MailMate_B5BB235C-6606-4538-B0D7-BF8540E684A2_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
