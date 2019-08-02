Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 507CDC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 17:42:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A0FF2183F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 17:42:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nOyiDmWM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A0FF2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 933346B0008; Fri,  2 Aug 2019 13:42:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BCFC6B000A; Fri,  2 Aug 2019 13:42:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 784806B0010; Fri,  2 Aug 2019 13:42:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5471F6B0008
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 13:42:57 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s83so83923076iod.13
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 10:42:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=qQ2degySGezHPZVUFes5RH7s/QM5AOAAph4PyTsDeb4=;
        b=Xr7KOVeO18mCChjJOYv/QljBIcBL1tqZb8yMYXi4GCvouXC2TgR7CNbVn1BLaPnTF+
         ild2w+A0XOkRZ41ILlMk0D7tpSxMNy3fUqd0dPftcS90qmzv3IeGqZd0vZX+eGcUn1Xd
         5EXtljULAMO12pE5QZIoIsgSaSVD9Z9SLavVYKnljxU/dvYDBvpuFk2Mt8Yms/EoaYqf
         q03reOmNLjNp3oG5bKdWwrRIn6IkD2dSIMCB4fzOEPiZ9WyHv6FSoUSSfnpAzdCW0y3z
         49NA++Du+/HRcqxtl9IcBJnvCSxLbjUhgrc5cCzYyeVrSnQLZ+MfbefTlRHNp3eWqDFY
         cbgA==
X-Gm-Message-State: APjAAAWOfr9L2xmCQ2vuEs4K7mO2xo3TBy03kOrEy1PsSx+on5XO91P5
	0W+k/Rll2PNWrNtcVjB73769tpFDtaX9mc1/hlYihpqqJg2mX4FCFyzd70J6BaEluBTKyzR0ruU
	4lNCjxBDpoqMrC322zkGF25zcSmUfPUD5EQR7yk6jSX1TOdsDQK/et23dJOP1dwfA9Q==
X-Received: by 2002:a5d:9416:: with SMTP id v22mr2720550ion.4.1564767775565;
        Fri, 02 Aug 2019 10:42:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYKqGIGlMBA8ntjVjuiTQZosvZzBDU8jzKzq0wnujE14xG4iIRxna5xN0hOC/k60hOXEdD
X-Received: by 2002:a5d:9416:: with SMTP id v22mr2720314ion.4.1564767773145;
        Fri, 02 Aug 2019 10:42:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564767773; cv=none;
        d=google.com; s=arc-20160816;
        b=QuPrNQbqTBMVylXlQI7RXz0Zzb3GXW6fritrVXnWaeBxrKp5e9Aurr2oSJqPsbrbkB
         rtM1cDXQ8By3f3v1Tjn2AUjTmARdbrbLIeitYwhXb7re/k1d3LTE+UYo8V3Geg0cU9Sm
         r+uKifWAYYmcLapEDZPUMWRCq3XPz73GItIfugkmyLLPIrvjoJhaDr6XObeJDlBON9q1
         yFPIigMeseU9Uke5OzRDSDecQSwUTGzLE/aliizA10TOscvmrSWCKCl4SIHGhjz+DUz7
         1YZiqPbSz+q3+MzuKd21XT/eOL7M0zjCQBvvBNo/VhUboGc8ND3+0FhDNtVd9/ZdW5QM
         Kw+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=qQ2degySGezHPZVUFes5RH7s/QM5AOAAph4PyTsDeb4=;
        b=RzbQyrjDJMATZ+IWo4gLsGB8SqZlDuUcPy9a7bYiieo7OYvZnDjSAAp6h0XWKmGnuS
         RrenDML6BaYXIipvGWdnJKJzX2776crOLhB8Wy6pKFIBK8PGSsURhvuVnxzYh4yTiDBG
         xwVKj92wAT3B8nesiTRL/17//3TexWRgBXYz3y9asR5x6THDLG9mLSBUFl2605mlAsae
         fBNLv5/yf4vX8TIwN65ms+sN/A80D6HZ4Uh+U4KwjtR6IutSXECThsbBUTOlOVB6Ywc1
         9BuBn0qYue1JyceHNC98sKAXOA5tfd2yB/zaP4tzegcnqa9alJSjz57ZOe854HwZaLyH
         LTTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nOyiDmWM;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id s132si106605168jaa.45.2019.08.02.10.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 10:42:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nOyiDmWM;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72HclqR169368;
	Fri, 2 Aug 2019 17:42:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=qQ2degySGezHPZVUFes5RH7s/QM5AOAAph4PyTsDeb4=;
 b=nOyiDmWMBdJpZJ6J8/AqC+RDETQN8h0mRNAHVtHlLGahut+ewZA7WtdQjJm+Rjlr6wae
 gxciS5F+fh+oKsckZxSaVMUofmxXB7la8lj8nqPzgn2yCfuHXaMrwcHqJt68yRz3pYWh
 dYCD+D9prsJ7Gf4CcfHjFI+SehCL8m7nj35KgCiBBWhIEJMxS3QXTzSkI7+iFWdLff5C
 w9HeW/6OwDNKJBYiwgHJS145bRDcmNLOQ20sc+h1MRlAEbnhZCahvxvN8HFHKmUaOHcp
 oT4CJ7dXEokiEIQ2Q2s8maUea8jGwyJdkYpq66bFxn4rujsgqpNMPfB8ClZGMK6vikM8 9w== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2u0ejq3kd5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 17:42:42 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x72HgfHn189167;
	Fri, 2 Aug 2019 17:42:41 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2u49hufg5k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 17:42:41 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x72HgZe0001558;
	Fri, 2 Aug 2019 17:42:35 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 02 Aug 2019 10:42:35 -0700
Subject: =?UTF-8?Q?Re=3a_=5bMM_Bug=3f=5d_mmap=28=29_triggers_SIGBUS_while_do?=
 =?UTF-8?B?aW5nIHRoZeKAiyDigItudW1hX21vdmVfcGFnZXMoKSBmb3Igb2ZmbGluZWQgaHVn?=
 =?UTF-8?Q?epage_in_background?=
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Li Wang <liwang@redhat.com>, Linux-MM <linux-mm@kvack.org>,
        LTP List <ltp@lists.linux.it>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        Cyril Hrubis <chrubis@suse.cz>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
 <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
 <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com>
 <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
 <20190802041557.GA16274@hori.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <54a5c9f5-eade-0d8f-24f9-bff6f19d4905@oracle.com>
Date: Fri, 2 Aug 2019 10:42:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190802041557.GA16274@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908020185
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908020184
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/1/19 9:15 PM, Naoya Horiguchi wrote:
> On Thu, Aug 01, 2019 at 05:19:41PM -0700, Mike Kravetz wrote:
>> There appears to be a race with hugetlb_fault and try_to_unmap_one of
>> the migration path.
>>
>> Can you try this patch in your environment?  I am not sure if it will
>> be the final fix, but just wanted to see if it addresses issue for you.
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index ede7e7f5d1ab..f3156c5432e3 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -3856,6 +3856,20 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>>  
>>  		page = alloc_huge_page(vma, haddr, 0);
>>  		if (IS_ERR(page)) {
>> +			/*
>> +			 * We could race with page migration (try_to_unmap_one)
>> +			 * which is modifying page table with lock.  However,
>> +			 * we are not holding lock here.  Before returning
>> +			 * error that will SIGBUS caller, get ptl and make
>> +			 * sure there really is no entry.
>> +			 */
>> +			ptl = huge_pte_lock(h, mm, ptep);
>> +			if (!huge_pte_none(huge_ptep_get(ptep))) {
>> +				ret = 0;
>> +				spin_unlock(ptl);
>> +				goto out;
>> +			}
>> +			spin_unlock(ptl);
> 
> Thanks you for investigation, Mike.
> I tried this change and found no SIGBUS, so it works well.
> 
> I'm still not clear about how !huge_pte_none() becomes true here,
> because we enter hugetlb_no_page() only when huge_pte_none() is non-null
> and (racy) try_to_unmap_one() from page migration should convert the
> huge_pte into a migration entry, not null.

Thanks for taking a look Naoya.

In try_to_unmap_one(), there is this code block:

		/* Nuke the page table entry. */
		flush_cache_page(vma, address, pte_pfn(*pvmw.pte));
		if (should_defer_flush(mm, flags)) {
			/*
			 * We clear the PTE but do not flush so potentially
			 * a remote CPU could still be writing to the page.
			 * If the entry was previously clean then the
			 * architecture must guarantee that a clear->dirty
			 * transition on a cached TLB entry is written through
			 * and traps if the PTE is unmapped.
			 */
			pteval = ptep_get_and_clear(mm, address, pvmw.pte);

			set_tlb_ubc_flush_pending(mm, pte_dirty(pteval));
		} else {
			pteval = ptep_clear_flush(vma, address, pvmw.pte);
		}

That happens before setting the migration entry.  Therefore, for a period
of time the pte is NULL (huge_pte_none() returns true).

try_to_unmap_one holds the page table lock, but hugetlb_fault does not take
the lock to 'optimistically' check huge_pte_none().  When huge_pte_none
returns true, it calls hugetlb_no_page which is where we try to allocate
a page and fails.

Does that make sense, or am I missing something?

The patch checks for this specific condition: someone changing the pte
from NULL to non-NULL while holding the lock.  I am not sure if this is
the best way to fix.  But, it may be the easiest.
-- 
Mike Kravetz

