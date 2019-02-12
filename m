Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1092C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:46:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3672921773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 15:46:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="JGDUCiQb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3672921773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FF678E0002; Tue, 12 Feb 2019 10:46:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D65C8E0001; Tue, 12 Feb 2019 10:46:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8ED258E0002; Tue, 12 Feb 2019 10:46:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 516698E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:46:05 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id s27so2385167pgm.4
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 07:46:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=eMhNDOH++cdlbrqr2EGPEiewoTfXsUm8w7p7ZcMdX40=;
        b=JYa5z0mNlEKBbNkYxXlMWqpT3jLcmVHjYuPJnav6K+PCKul1Wl+9bHpqcXkM7tpkVr
         C4cC9mwlX803lJKH1WPQdRHHvcvJTwnKRHANf+t9cxymOLpGVSjr/L4RgpRpSKhUNABW
         gz1gTuWIPQ6tK1Mi5pGUyQZOn34OUxmezlETjA+ja090mKtP+ioN6+lSfmDilhLmvw2f
         2aZok2Vvj2uu2+Gby4IFtFO3MzT0EMFgR83obSwtHR+JhQqiZqSdCl8dfBPzNzwrD/7+
         xGv45Qn51IHPNlH0bJN0h5ljop83BQPKqqPSs31ipru3u/s6TzaunudyuhsYxLEtpeoY
         AgaQ==
X-Gm-Message-State: AHQUAuYzSCAVkGoJtGQZLrSE39aZJMizlUblcUMVhPsJoNGhqTksOVqS
	weo7rQDzBM/ApNLSp9MRb6eQ/kFpszUCuEtVuOgqcTLGl7QN1ZDPal6uODTuw7pU4WOBG8vyEio
	IxdYZpzqEYUHglCQ427XQlYRqnVHC8VvLabgDmUJauz+SQ8Sae2+9NUwqzJcNDFHung==
X-Received: by 2002:a62:d10b:: with SMTP id z11mr4593931pfg.84.1549986364697;
        Tue, 12 Feb 2019 07:46:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaVV5n5nzfS39B/b1OmXldNlsPAlVWRKJWEn6sDRyQUW2jSgFr7X4ccJX81FvCFTP67xDW9
X-Received: by 2002:a62:d10b:: with SMTP id z11mr4593889pfg.84.1549986363896;
        Tue, 12 Feb 2019 07:46:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549986363; cv=none;
        d=google.com; s=arc-20160816;
        b=c897/1zDRcGx9eBvT0uBqjjmWOSYo/Bui7w+l2EYRXOUUzN2jAXDFbZgiVX3rbilDT
         88vcfaM+bwyuWriAtqXvZGrgTRdWuI/lKkgJZ24KVfMVu1mKYWOAg4G3WIe0J7Rnxf6g
         6As8ek5KQKq3glr5q87Iac9p8gQExjo8qsuSyQtJOkrP2/o617RN84FH1IP+Xne8ViKh
         NBDpGEFbDbxfVDTZQoGaiBoK8KyJDhajyrkr/dFRG4EsgPGMKje54JsFWthaIcTOCage
         2iPCMnPkK0i1UFOTMnZoqasMticDb7TFKu8v75q6FI/O/6xl6l7KlACK8CvhB9tGQSjE
         WWdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:organization:from:references:cc:to:subject
         :dkim-signature;
        bh=eMhNDOH++cdlbrqr2EGPEiewoTfXsUm8w7p7ZcMdX40=;
        b=GtKRy2mV3eWrtvP1e6Mho19ICvp+bqWt3r2NDihkdNLLQtQ7o1iK/abDUBLg3K66iy
         m3w5Bg2DruGwQiJB4suE44/bnMs7I9yKsJi63HyMHI0whQtdCj2FvDgSJm9MvjFqWFmp
         7JsyFzt26oy/2mNnCYezuwdWTtl7O4fTbqDUu6ue/e+UTw3HeR8hsk+Mn6ECuGPIQEvD
         S2dXHgKDAXHdin8mNVGAois9YhE95uzYKqrKzHbY7LBAN3OmFHGIooalESzzEkPOG9MA
         6ebbdG0+ZohMxVETktxtP4t50LIbpIU5Mt3kCKd8rgBwSOFe0xrOoZ9HXvCZK55jfPkc
         pF/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=JGDUCiQb;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id q2si12343884pgv.124.2019.02.12.07.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 07:46:03 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=JGDUCiQb;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1CFcc8d089975;
	Tue, 12 Feb 2019 15:45:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type; s=corp-2018-07-02;
 bh=eMhNDOH++cdlbrqr2EGPEiewoTfXsUm8w7p7ZcMdX40=;
 b=JGDUCiQb/xJpqX0PjPgd7bAHaBgqPfkR/GezmtFYiDvY/U9Imbx/6mBdZnYHsOnRVJgy
 pV+jWhyrwNmBshdjBKFzVZt8M4ffSvq4w0rTQcoHbzfU2UrEYjVuAm8HVVHfXBESt46R
 sCSX0boiqaZeVJ5xg/foScJYudYByFbKxY7iWWlQewZj9/4lpC6Lg0CdpLT9JGDZgIu8
 zh7hlEDSlk/TmkWxdW/D7QWVmUB/REMoaW2BgoE3sH2Ne/VhhA2aZlWJ5pDUWkhA/gMj
 pfSggcLPK2Cw/tcLNAnn7ctrMCZRpmidKEuPmEDU3nx0N/lu61Ol7QmBtAolcF+6d3jS fA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2qhre5cpvn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 15:45:53 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1CFjlfn026656
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 15:45:47 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1CFjiHA008994;
	Tue, 12 Feb 2019 15:45:45 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 12 Feb 2019 07:45:44 -0800
Subject: Re: [RFC PATCH v7 05/16] arm64/mm: Add support for XPFO
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        torvalds@linux-foundation.org, liran.alon@oracle.com,
        keescook@google.com, Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Tycho Andersen <tycho@docker.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <89f03091af87f5ab27bd6cafb032236d5bd81d65.1547153058.git.khalid.aziz@oracle.com>
 <20190123142047.GB19289@Konrads-MacBook-Pro.local>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <0ea68b21-ac03-e9d1-3285-14e6084e10fa@oracle.com>
Date: Tue, 12 Feb 2019 08:45:41 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190123142047.GB19289@Konrads-MacBook-Pro.local>
Content-Type: multipart/mixed;
 boundary="------------CE9BD2F746D7F2667607891B"
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9165 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902120111
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------CE9BD2F746D7F2667607891B
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 1/23/19 7:20 AM, Konrad Rzeszutek Wilk wrote:
> On Thu, Jan 10, 2019 at 02:09:37PM -0700, Khalid Aziz wrote:
>> From: Juerg Haefliger <juerg.haefliger@canonical.com>
>>
>> Enable support for eXclusive Page Frame Ownership (XPFO) for arm64 and=

>> provide a hook for updating a single kernel page table entry (which is=

>> required by the generic XPFO code).
>>
>> v6: use flush_tlb_kernel_range() instead of __flush_tlb_one()
>>
>> CC: linux-arm-kernel@lists.infradead.org
>> Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
>> Signed-off-by: Tycho Andersen <tycho@docker.com>
>> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
>> ---
>>  arch/arm64/Kconfig     |  1 +
>>  arch/arm64/mm/Makefile |  2 ++
>>  arch/arm64/mm/xpfo.c   | 58 +++++++++++++++++++++++++++++++++++++++++=
+
>>  3 files changed, 61 insertions(+)
>>  create mode 100644 arch/arm64/mm/xpfo.c
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index ea2ab0330e3a..f0a9c0007d23 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -171,6 +171,7 @@ config ARM64
>>  	select SWIOTLB
>>  	select SYSCTL_EXCEPTION_TRACE
>>  	select THREAD_INFO_IN_TASK
>> +	select ARCH_SUPPORTS_XPFO
>>  	help
>>  	  ARM 64-bit (AArch64) Linux support.
>> =20
>> diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
>> index 849c1df3d214..cca3808d9776 100644
>> --- a/arch/arm64/mm/Makefile
>> +++ b/arch/arm64/mm/Makefile
>> @@ -12,3 +12,5 @@ KASAN_SANITIZE_physaddr.o	+=3D n
>> =20
>>  obj-$(CONFIG_KASAN)		+=3D kasan_init.o
>>  KASAN_SANITIZE_kasan_init.o	:=3D n
>> +
>> +obj-$(CONFIG_XPFO)		+=3D xpfo.o
>> diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
>> new file mode 100644
>> index 000000000000..678e2be848eb
>> --- /dev/null
>> +++ b/arch/arm64/mm/xpfo.c
>> @@ -0,0 +1,58 @@
>> +/*
>> + * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
>> + * Copyright (C) 2016 Brown University. All rights reserved.
>> + *
>> + * Authors:
>> + *   Juerg Haefliger <juerg.haefliger@hpe.com>
>> + *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
>> + *
>> + * This program is free software; you can redistribute it and/or modi=
fy it
>> + * under the terms of the GNU General Public License version 2 as pub=
lished by
>> + * the Free Software Foundation.
>> + */
>> +
>> +#include <linux/mm.h>
>> +#include <linux/module.h>
>> +
>> +#include <asm/tlbflush.h>
>> +
>> +/*
>> + * Lookup the page table entry for a virtual address and return a poi=
nter to
>> + * the entry. Based on x86 tree.
>> + */
>> +static pte_t *lookup_address(unsigned long addr)
>=20
> The x86 also has level. Would it make sense to include that in here?
>=20

Possibly. ARM64 does not define page levels (as in the enum for page
levels) at this time but that can be added easily. Adding level to
lookup_address() for arm will make it uniform with x86 but is there any
other rationale besides that? Do you see a future use for this
information? The only other architecture I could see that defines
lookup_address() is sh but it uses it for trapped io only.

Thanks,
Khalid

--------------CE9BD2F746D7F2667607891B
Content-Type: application/pgp-keys;
 name="pEpkey.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="pEpkey.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----

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
+Wrj8Rwom6h21PXZRKnlkis7ibQfE+TxqOI7vg=3D=3D
=3DnPqY
-----END PGP PUBLIC KEY BLOCK-----

--------------CE9BD2F746D7F2667607891B--

