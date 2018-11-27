Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 01CA26B4AB8
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:49:01 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id q8so6131588edd.8
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 13:49:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j5-v6si2287351ejz.265.2018.11.27.13.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 13:48:59 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wARLjJWV030135
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:48:58 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p1cgrkxem-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:48:58 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 27 Nov 2018 21:48:55 -0000
Date: Tue, 27 Nov 2018 23:48:45 +0200
In-Reply-To: <20181127211600.GB3235@lianli.shorne-pla.net>
References: <1543182277-8819-1-git-send-email-rppt@linux.ibm.com> <1543182277-8819-5-git-send-email-rppt@linux.ibm.com> <20181127211600.GB3235@lianli.shorne-pla.net>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 4/5] openrisc: simplify pte_alloc_one_kernel()
From: Mike Rapoport <rppt@linux.ibm.com>
Message-Id: <7843DE67-DCC3-48BF-873F-71D87B08EDA8@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stafford Horne <shorne@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org



On November 27, 2018 11:16:00 PM GMT+02:00, Stafford Horne <shorne@gmail=
=2Ecom> wrote:
>On Sun, Nov 25, 2018 at 11:44:36PM +0200, Mike Rapoport wrote:
>> The pte_alloc_one_kernel() function allocates a page using
>> __get_free_page(GFP_KERNEL) when mm initialization is complete and
>> memblock_phys_alloc() on the earlier stages=2E The physical address of
>the
>> page allocated with memblock_phys_alloc() is converted to the virtual
>> address and in the both cases the allocated page is cleared using
>> clear_page()=2E
>>=20
>> The code is simplified by replacing __get_free_page() with
>> get_zeroed_page() and by replacing memblock_phys_alloc() with
>> memblock_alloc()=2E
>
>Hello Mike,
>
>This looks fine to me=2E  How do you plan to get this merged?  Will you
>be taking
>care of the whole series or so you want me to queue this openrisc part?

I was thinking about merging via the -mm tree=2E
Andrew, would that be ok?

>> Signed-off-by: Mike Rapoport <rppt@linux=2Eibm=2Ecom>
>
>Acked-by: Stafford Horne <shorne@gmail=2Ecom>

Thanks!

>> ---
>>  arch/openrisc/mm/ioremap=2Ec | 11 ++++-------
>>  1 file changed, 4 insertions(+), 7 deletions(-)
>>=20
>> diff --git a/arch/openrisc/mm/ioremap=2Ec b/arch/openrisc/mm/ioremap=2E=
c
>> index c969752=2E=2Ecfef989 100644
>> --- a/arch/openrisc/mm/ioremap=2Ec
>> +++ b/arch/openrisc/mm/ioremap=2Ec
>> @@ -123,13 +123,10 @@ pte_t __ref *pte_alloc_one_kernel(struct
>mm_struct *mm,
>>  {
>>  	pte_t *pte;
>> =20
>> -	if (likely(mem_init_done)) {
>> -		pte =3D (pte_t *) __get_free_page(GFP_KERNEL);
>> -	} else {
>> -		pte =3D (pte_t *) __va(memblock_phys_alloc(PAGE_SIZE, PAGE_SIZE));
>> -	}
>> +	if (likely(mem_init_done))
>> +		pte =3D (pte_t *)get_zeroed_page(GFP_KERNEL);
>> +	else
>> +		pte =3D memblock_alloc(PAGE_SIZE, PAGE_SIZE);
>> =20
>> -	if (pte)
>> -		clear_page(pte);
>>  	return pte;
>>  }
>> --=20
>> 2=2E7=2E4
>>=20

--=20
Sincerely yours,
Mike=2E
