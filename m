Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6C02C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:08:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 135302082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:08:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="S3eY2Ur7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 135302082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0F1E6B0010; Thu,  4 Apr 2019 12:08:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C01F6B0266; Thu,  4 Apr 2019 12:08:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83AFB6B0269; Thu,  4 Apr 2019 12:08:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4855B6B0010
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:08:10 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22so2081314plq.1
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:08:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MGMGGZZ9aj2k0vY79VyYkNIe8FXjpVyFBQkIPiblpXw=;
        b=eF/MXeml/REnYX3R7gdWb2Xs4Wkf2TYEMMPaGXuMDphwrxoUHEtyUVpom9j5yJe7KN
         rDlinUnrsOQnWLnhDGQdFsAm25Xqj8z3hdilF+mCURR/T9SMY/oZo0O7n24VDIhKW8vy
         bJtBiDsA791N7J0POAgmMfhtf5RG9mfm8dZih+gD1CO0htIdnnGl/KZvHFK+OneRWr/U
         dFg83R45p1H5Yjl0sZGmUy1VbkzfJM3HUXLEw2RVTzBlpofJvvHootiqdFC2UvaP903E
         YcoTOr8pegmrQ6OVSGqQxqbcAaAfB2d7TpQfFqjh1SLuTv4Z1vtTmjme/a12Fxs4vRRz
         hsyA==
X-Gm-Message-State: APjAAAXg12D0iWShMwSuZC0uDYf7MMz2m/VmC2XgOTqRz06uF2/mM6ri
	4/bd8hxW5AV35aNEnLJgMRJSju3Fpxt6gIwG0agt+ykka6z2Oq6BTF4E0FMxtJPPYtmXtTkUwXQ
	FSEATlPD9wqwESkr51yZCY4Rpq2aBvCxxwb2KpSkwuOVWp/N/dzInXqNdn1SoEJ2u3A==
X-Received: by 2002:a63:b305:: with SMTP id i5mr6386627pgf.274.1554394089644;
        Thu, 04 Apr 2019 09:08:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFVCnq4FSmh3H/9jXGmb9xeK4DmZxFPUIKvvtkXNmekBrmgt4CjjZi1stNl4QJW8Bl8w6p
X-Received: by 2002:a63:b305:: with SMTP id i5mr6386515pgf.274.1554394088322;
        Thu, 04 Apr 2019 09:08:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554394088; cv=none;
        d=google.com; s=arc-20160816;
        b=zWwkHBFxzxB1DIa7OiRAkF+Oic1l+w8PscdXbN8wbpQ0pSoFGGbmytcTkqXXnfvZam
         CyZVDmjCBnP80IZYh9mNiO7dpyGWmUee4WF9G/6Q/O4FYKCjvTBpmDWlV6NMKewufBtD
         DKH2hqpev5MbGwZULl9f1av1YDFaz5eJgQQDMMDrT+OVgmRp/7inlSKUw+ONR0FgFHWU
         L1BwY5zttqmZOFaHIELwXrl4TBAqHOnTtzPgOo3uS2WCEdREhGSnOfoErtTr/ncPj5C9
         rP9oApXSti62TracgOdKG4eK1Rk8USDZGPMLFkLqB74JYuAGd5+/auEviVpigPY7Qk8s
         Zr0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=MGMGGZZ9aj2k0vY79VyYkNIe8FXjpVyFBQkIPiblpXw=;
        b=rm2GEAw3sXWqHYqAWXIzIXrB2z2MNC7DaFC3tASCHjIfE8r5XC7gFECEOud9hnorRM
         yT4j2eJpQmd9RHU3eU+rx2iqmE2y6esnipmWpYvTMqEJONF6S4B/taQXydniJoLHA/+D
         mXEN6dEwajzSM2PNMfTDoBnTpArpA3qv9gHu5raudxVdnwiUodEOjNw6EJ5D+T1988xO
         s4Am6jr+HpjqdbRkFUls1M3y9QaRAQsaD+OKrmWcDe6O2K2aOlxQrF7vP/QSyXqndBQP
         fv1Xj2jLaM67fBoZLQ8tU2eK+4wLCy3XtZN5v3uLNxwNpgFw0EUvIowG4E+DRi34xSWp
         tOSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=S3eY2Ur7;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id x7si16653887pgg.565.2019.04.04.09.08.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 09:08:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=S3eY2Ur7;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34G4Ac9087830;
	Thu, 4 Apr 2019 16:07:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=MGMGGZZ9aj2k0vY79VyYkNIe8FXjpVyFBQkIPiblpXw=;
 b=S3eY2Ur7IoDOHxGm0rdU2sAczivmDbLu9AXPZQoB5K2GT1GIhc8xiNMW9429KbSmVWVs
 dtihnELl4UQK+NRoz/2igvYQ/MV17vAfGTpw1z8UNul6RnQAqKSl8C9j4XILWT6iDL6T
 SYkQYRiv6OGKQQl/dnB9i5mMmNB45oBxGPU5ZJ3DKNRuO3hEZqlZ9ap/1qTKqmz+33Mi
 yDkfRxvjooMdqd7nY+qkxe0ejnZV1MgMYVW4ztAkcw5HGiGDtXc0UYjpLLzi9neb16pW
 6+HEGgQ6ZKi7wav8P/64/tPZcON5B+Kkt/Vp0CXxNgHbZX+ToNL/82EdNMoJGgllSRKa nA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2rhwydg9p8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 16:07:05 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34G6FsD106877;
	Thu, 4 Apr 2019 16:07:04 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2rm8f5s09d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 16:07:04 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x34G6l5T009956;
	Thu, 4 Apr 2019 16:06:48 GMT
Received: from [10.65.181.191] (/10.65.181.191)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 04 Apr 2019 09:06:47 -0700
Subject: Re: [RFC PATCH v9 11/13] xpfo, mm: optimize spinlock usage in
 xpfo_kunmap
To: Peter Zijlstra <peterz@infradead.org>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
        liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, dave.hansen@intel.com,
        akpm@linux-foundation.org, alexander.h.duyck@linux.intel.com,
        aneesh.kumar@linux.ibm.com, arnd@arndb.de, bigeasy@linutronix.de,
        bp@alien8.de, catalin.marinas@arm.com, corbet@lwn.net,
        dan.j.williams@intel.com, gregkh@linuxfoundation.org, guro@fb.com,
        hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
        james.morse@arm.com, jannh@google.com, jkosina@suse.cz,
        jmorris@namei.org, joe@perches.com, jrdr.linux@gmail.com,
        jroedel@suse.de, keith.busch@intel.com, khlebnikov@yandex-team.ru,
        mark.rutland@arm.com, mgorman@techsingularity.net,
        Michal Hocko <mhocko@kernel.org>, mike.kravetz@oracle.com,
        mingo@redhat.com, mst@redhat.com, npiggin@gmail.com,
        paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
        rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
        rientjes@google.com, rostedt@goodmis.org, rppt@linux.vnet.ibm.com,
        will.deacon@arm.com, willy@infradead.org, yaojun8558363@gmail.com,
        ying.huang@intel.com, iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>,
        kernel-hardening@lists.openwall.com,
        "Vasileios P . Kemerlis" <vpk@cs.columbia.edu>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <5bab13e12d4215112ad2180106cc6bb9b513754a.1554248002.git.khalid.aziz@oracle.com>
 <20190404075648.GQ4038@hirez.programming.kicks-ass.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <89dd158f-c341-9dd9-d70c-787b5eb0b410@oracle.com>
Date: Thu, 4 Apr 2019 10:06:43 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190404075648.GQ4038@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904040103
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904040103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/4/19 1:56 AM, Peter Zijlstra wrote:
> On Wed, Apr 03, 2019 at 11:34:12AM -0600, Khalid Aziz wrote:
>> From: Julian Stecklina <jsteckli@amazon.de>
>>
>> Only the xpfo_kunmap call that needs to actually unmap the page
>> needs to be serialized. We need to be careful to handle the case,
>> where after the atomic decrement of the mapcount, a xpfo_kmap
>> increased the mapcount again. In this case, we can safely skip
>> modifying the page table.
>>
>> Model-checked with up to 4 concurrent callers with Spin.
>>
>> Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
>> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
>> Cc: Khalid Aziz <khalid@gonehiking.org>
>> Cc: x86@kernel.org
>> Cc: kernel-hardening@lists.openwall.com
>> Cc: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
>> Cc: Juerg Haefliger <juerg.haefliger@canonical.com>
>> Cc: Tycho Andersen <tycho@tycho.ws>
>> Cc: Marco Benatto <marco.antonio.780@gmail.com>
>> Cc: David Woodhouse <dwmw2@infradead.org>
>> ---
>>  include/linux/xpfo.h | 24 +++++++++++++++---------
>>  1 file changed, 15 insertions(+), 9 deletions(-)
>>
>> diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
>> index 2318c7eb5fb7..37e7f52fa6ce 100644
>> --- a/include/linux/xpfo.h
>> +++ b/include/linux/xpfo.h
>> @@ -61,6 +61,7 @@ static inline void xpfo_kmap(void *kaddr, struct pag=
e *page)
>>  static inline void xpfo_kunmap(void *kaddr, struct page *page)
>>  {
>>  	unsigned long flags;
>> +	bool flush_tlb =3D false;
>> =20
>>  	if (!static_branch_unlikely(&xpfo_inited))
>>  		return;
>> @@ -72,18 +73,23 @@ static inline void xpfo_kunmap(void *kaddr, struct=
 page *page)
>>  	 * The page is to be allocated back to user space, so unmap it from
>>  	 * the kernel, flush the TLB and tag it as a user page.
>>  	 */
>> -	spin_lock_irqsave(&page->xpfo_lock, flags);
>> -
>>  	if (atomic_dec_return(&page->xpfo_mapcount) =3D=3D 0) {
>> -#ifdef CONFIG_XPFO_DEBUG
>> -		WARN_ON(PageXpfoUnmapped(page));
>> -#endif
>> -		SetPageXpfoUnmapped(page);
>> -		set_kpte(kaddr, page, __pgprot(0));
>> -		xpfo_flush_kernel_tlb(page, 0);
>> +		spin_lock_irqsave(&page->xpfo_lock, flags);
>> +
>> +		/*
>> +		 * In the case, where we raced with kmap after the
>> +		 * atomic_dec_return, we must not nuke the mapping.
>> +		 */
>> +		if (atomic_read(&page->xpfo_mapcount) =3D=3D 0) {
>> +			SetPageXpfoUnmapped(page);
>> +			set_kpte(kaddr, page, __pgprot(0));
>> +			flush_tlb =3D true;
>> +		}
>> +		spin_unlock_irqrestore(&page->xpfo_lock, flags);
>>  	}
>> =20
>> -	spin_unlock_irqrestore(&page->xpfo_lock, flags);
>> +	if (flush_tlb)
>> +		xpfo_flush_kernel_tlb(page, 0);
>>  }
>=20
> This doesn't help with the TLB invalidation issue, AFAICT this is still=

> completely buggered. kunmap_atomic() can be called from IRQ context.
>=20

OK. xpfo_kmap/xpfo_kunmap need redesign.

--
Khalid

