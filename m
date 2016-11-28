Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 90C9D6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:11:56 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y71so363786599pgd.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:11:56 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0091.outbound.protection.outlook.com. [104.47.37.91])
        by mx.google.com with ESMTPS id a30si26966215pli.303.2016.11.28.07.11.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 07:11:55 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 5/5] mm: migrate: Add vm.accel_page_copy in sysfs to
 control whether to use multi-threaded to accelerate page copy.
Date: Mon, 28 Nov 2016 10:11:46 -0500
Message-ID: <68190E74-8C89-4A14-A1C3-435A306E46AC@cs.rutgers.edu>
In-Reply-To: <5836BC48.1080705@linux.vnet.ibm.com>
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-6-zi.yan@sent.com> <5836BC48.1080705@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_3FAD3B3F-A109-46D1-9C0C-CD11D5366BC1_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com

--=_MailMate_3FAD3B3F-A109-46D1-9C0C-CD11D5366BC1_=
Content-Type: text/plain

On 24 Nov 2016, at 5:09, Anshuman Khandual wrote:

> On 11/22/2016 09:55 PM, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>
>> From: Zi Yan <ziy@nvidia.com>
>>
>> Since base page migration did not gain any speedup from
>> multi-threaded methods, we only accelerate the huge page case.
>>
>> Signed-off-by: Zi Yan <ziy@nvidia.com>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  kernel/sysctl.c | 11 +++++++++++
>>  mm/migrate.c    |  6 ++++++
>>  2 files changed, 17 insertions(+)
>>
>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>> index d54ce12..6c79444 100644
>> --- a/kernel/sysctl.c
>> +++ b/kernel/sysctl.c
>> @@ -98,6 +98,8 @@
>>  #if defined(CONFIG_SYSCTL)
>>
>>
>> +extern int accel_page_copy;
>
> Hmm, accel_mthread_copy because this is achieved by a multi threaded
> copy mechanism.
>
>> +
>>  /* External variables not in a header file. */
>>  extern int suid_dumpable;
>>  #ifdef CONFIG_COREDUMP
>> @@ -1361,6 +1363,15 @@ static struct ctl_table vm_table[] = {
>>  		.proc_handler   = &hugetlb_mempolicy_sysctl_handler,
>>  	},
>>  #endif
>> +	{
>> +		.procname	= "accel_page_copy",
>> +		.data		= &accel_page_copy,
>> +		.maxlen		= sizeof(accel_page_copy),
>> +		.mode		= 0644,
>> +		.proc_handler	= proc_dointvec,
>> +		.extra1		= &zero,
>> +		.extra2		= &one,
>> +	},
>>  	 {
>>  		.procname	= "hugetlb_shm_group",
>>  		.data		= &sysctl_hugetlb_shm_group,
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 244ece6..e64b490 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -48,6 +48,8 @@
>>
>>  #include "internal.h"
>>
>> +int accel_page_copy = 1;
>> +
>
> So its enabled by default.
>
>>  /*
>>   * migrate_prep() needs to be called before we start compiling a list of pages
>>   * to be migrated using isolate_lru_page(). If scheduling work on other CPUs is
>> @@ -651,6 +653,10 @@ static void copy_huge_page(struct page *dst, struct page *src,
>>  		nr_pages = hpage_nr_pages(src);
>>  	}
>>
>> +	/* Try to accelerate page migration if it is not specified in mode  */
>> +	if (accel_page_copy)
>> +		mode |= MIGRATE_MT;
>
> So even if none of the system calls requested for a multi threaded copy,
> this setting will override every thing and make it multi threaded.

This only accelerates huge page copies and achieves much higher
throughput and lower copy time. It should be used most of the time.

As you suggested in other email, I will make this optimization a config option.
If people enable it, they expect it is working. The sysctl interface just let
them disable this optimization when they think it is not going to help.


--
Best Regards
Yan Zi

--=_MailMate_3FAD3B3F-A109-46D1-9C0C-CD11D5366BC1_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYPEkyAAoJEEGLLxGcTqbMDngH/2KzJJaiWfPxHEHMCxpTuW4/
aAppupsbAMPHpIjS0IVBHWuErj6xlek8eDx19kKv3i/xFwfJ6/vkWlH2RTHpRRKJ
f1kX9lq7ecZ9o/GXGeXFIWNzrroKFSl0KKmYAcxC22txui1IqYis27gBigrWktUH
cY3Vz6COg/UVIKubhB2PTALItgmVio3Fuk4Bn1R7JCTJ0DAMF2ZHqt8CV7nnT/X+
XNL4Lzt0qxKbEOT77eTSUH4Ij9Ok6pdzEf5fsq6DBNneQMgdJ+WVTIAgcEXUF9Eq
vcQMNggsO5PMhSBARR6L82tFF6B9VInJTSLYL/pz6B1WuKE033sS/wlwC2BZTUw=
=EENO
-----END PGP SIGNATURE-----

--=_MailMate_3FAD3B3F-A109-46D1-9C0C-CD11D5366BC1_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
