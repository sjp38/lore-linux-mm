Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3675C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:10:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B1B821BF2
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 15:10:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="aEUlb5wI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B1B821BF2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04D816B0007; Wed,  7 Aug 2019 11:10:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F40336B0008; Wed,  7 Aug 2019 11:10:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB9D46B000A; Wed,  7 Aug 2019 11:10:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B234F6B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 11:10:39 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id b25so55214641otp.12
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 08:10:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=r5hYy0y7ReIvBBGIGF8JhtoWuvMamCNlmDIGrsGw3Ds=;
        b=Oe2xtElyeq2I3bNG8CfueE7/fEErpT9yc4aysuoFzq1REx3Cnge/UiV2Dwe9EMVUs3
         b4CxdRy9HI/PKKN7cK6Wpon3u9Z8erLe5dmi0kBHDC73JbALCUYBer0kCxMdX+Yk2sAg
         KzlBAEzynTqJzLPShkPqSQSSKtoUzYYz7wHFlr3ZbAbWwctOX9e1VgRQQfyapBAgoRze
         IC3mBmGmi4f3qJWrUmJ0QcbqHA/H546ZKECU119Qg8x3fQmCsJP2PbsiP+U1pXtNNCh9
         zt0rBI3jicBY+gxF3xE54i1wn/crk3lUTfMOoKXntBZAJcrVwADW/+J3B61i5eIuqkHv
         WgkQ==
X-Gm-Message-State: APjAAAV2youBXO+UedMgfOetFC37jnQGSamqQnDHS6BtrFyic/CU3rEO
	tEzx3rLpiSvU0ZSdeAqUaBCp6Pk3D+jNufmLjZ36xgpdq8KjnCrC1ZcCFPrSszpjRo02Dgi8uBf
	4shyJquv2T8ys0wMH118+fWtRLOtv3/8U97aXTo3SPpH4Cr+U+A3geMnnfcavzN86AA==
X-Received: by 2002:a05:6638:348:: with SMTP id x8mr2283554jap.31.1565190639337;
        Wed, 07 Aug 2019 08:10:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYghQUkAEti9yWol9eqL0gy11XGyZxmhByDWPxiPoj+29xqaFB43TP1baGh3Ybt5eHFVzj
X-Received: by 2002:a05:6638:348:: with SMTP id x8mr2283480jap.31.1565190638605;
        Wed, 07 Aug 2019 08:10:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565190638; cv=none;
        d=google.com; s=arc-20160816;
        b=wIwL2I8JKYBGKqxSLXoat+rIkTuBCZba0lgQatBHX1Y/DNgIo/WUT2vOWQCC7IT8to
         y261WceKMapQMNDl0yOuyKkImMzLZZsO+F6su+/e4xy/rpOCOXw7biwMeNTiqyItx0QH
         wqTELND5Ujo7nSvISVAyuqKGWbWXmM9i+qnomDE5yi+GWmHSeXYd8vAt4nIacss2t3iA
         viT8DMy0P7eJkv8b9/DNNQH8XYr2sojmOILSPbdOqcsmgoVVr1+jT/B8WouPlN2Wwq5e
         qKRaimngAsCl6fazZIbqgYhFLe3Fp3INB+Cps39Cccoi0D8p74FVtqrUhkjpVPNkRdlt
         HqwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=r5hYy0y7ReIvBBGIGF8JhtoWuvMamCNlmDIGrsGw3Ds=;
        b=xLC8VdcfvY5PuAyy8Z8wkP8MX5qnRAQR3lxodIp1XNVKWjaZY5UmZXPZ7I4qPMRhxW
         1sEujXy6w56yNenKenJxeClym5R0Tw+IbWWQdhUOksPLNpwMhrg6CzmgFq9GafvuMRgZ
         4zcRfdb8dWiN/CR38/Mas/OtEKd509OUNa8NnaTAwyfChce+vWAPxIWogKJSOdE3NUGw
         pvjiFGmp17ZrKUSd95ltdn1vSUO//mqqQxwYeujE7yduOkK20mZnEdPq8REWHZLjvQPn
         KofrBboIjfyaDCY3JsDYauQr8INSAwOR55t7PzEKZS+GQgVSOfnhAHV3GwGvlsaWa2+a
         bVGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=aEUlb5wI;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e10si1448670jac.49.2019.08.07.08.10.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 08:10:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=aEUlb5wI;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x77FANI8161267;
	Wed, 7 Aug 2019 15:10:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=r5hYy0y7ReIvBBGIGF8JhtoWuvMamCNlmDIGrsGw3Ds=;
 b=aEUlb5wIH9S5rzPKUC7S8GI7QZ0KJ3RFmchbm+rawRIhZBTgNBLAbEos0YKxw7F4nuK5
 KodWcMJ35Z+iHDFKKIJd5ICJpOhVm9lWPs9yaVL7HLRpjctzEYNcRjq+p3svxGYHd/1v
 xgft/+a8dSGx5Vj+pDOCUEdx/HYoGUNu+A8WR0UPAlepzh5y6wrdlxWjSc9d3E30wdqg
 biEJ78AWog3IsjJIpLTh6yx+Ax+pyQkwBEImXStJEnMCPy4ScpnHXcaO7KtPoFj77uv5
 BwiR17Iaie6u51h6oDTVDbea5ewTdcqPA9Voz7ukTIAfhHw96QTsSaZG6fsKubDZHrhg 5w== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2120.oracle.com with ESMTP id 2u52wrcyka-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Aug 2019 15:10:31 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x77FA9Ii172827;
	Wed, 7 Aug 2019 15:10:31 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2u763j04ue-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Aug 2019 15:10:30 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x77FATHA014733;
	Wed, 7 Aug 2019 15:10:29 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 07 Aug 2019 08:10:28 -0700
Subject: =?UTF-8?Q?Re=3a_=5bMM_Bug=3f=5d_mmap=28=29_triggers_SIGBUS_while_do?=
 =?UTF-8?B?aW5nIHRoZeKAiyDigItudW1hX21vdmVfcGFnZXMoKSBmb3Igb2ZmbGluZWQgaHVn?=
 =?UTF-8?Q?epage_in_background?=
To: Michal Hocko <mhocko@suse.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Li Wang <liwang@redhat.com>,
        Linux-MM <linux-mm@kvack.org>, LTP List <ltp@lists.linux.it>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        Cyril Hrubis <chrubis@suse.cz>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
 <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
 <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com>
 <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
 <20190802041557.GA16274@hori.linux.bs1.fc.nec.co.jp>
 <54a5c9f5-eade-0d8f-24f9-bff6f19d4905@oracle.com>
 <20190805085740.GC7597@dhcp22.suse.cz>
 <7d78f6b9-afb8-79d1-003e-56de58fded00@oracle.com>
 <3c104b29-ffe2-07cb-440e-cb88d8e11acb@oracle.com>
 <20190807073909.GL11812@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <d2bb2c10-a08c-dfde-a51b-827a85b50946@oracle.com>
Date: Wed, 7 Aug 2019 08:10:27 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190807073909.GL11812@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9342 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908070160
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9342 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908070160
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/7/19 12:39 AM, Michal Hocko wrote:
> On Tue 06-08-19 17:07:25, Mike Kravetz wrote:
>> On 8/5/19 10:36 AM, Mike Kravetz wrote:
>>>>>>> Can you try this patch in your environment?  I am not sure if it will
>>>>>>> be the final fix, but just wanted to see if it addresses issue for you.
>>>>>>>
>>>>>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>>>>>>> index ede7e7f5d1ab..f3156c5432e3 100644
>>>>>>> --- a/mm/hugetlb.c
>>>>>>> +++ b/mm/hugetlb.c
>>>>>>> @@ -3856,6 +3856,20 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>>>>>>>  
>>>>>>>  		page = alloc_huge_page(vma, haddr, 0);
>>>>>>>  		if (IS_ERR(page)) {
>>>>>>> +			/*
>>>>>>> +			 * We could race with page migration (try_to_unmap_one)
>>>>>>> +			 * which is modifying page table with lock.  However,
>>>>>>> +			 * we are not holding lock here.  Before returning
>>>>>>> +			 * error that will SIGBUS caller, get ptl and make
>>>>>>> +			 * sure there really is no entry.
>>>>>>> +			 */
>>>>>>> +			ptl = huge_pte_lock(h, mm, ptep);
>>>>>>> +			if (!huge_pte_none(huge_ptep_get(ptep))) {
>>>>>>> +				ret = 0;
>>>>>>> +				spin_unlock(ptl);
>>>>>>> +				goto out;
>>>>>>> +			}
>>>>>>> +			spin_unlock(ptl);
>>>>>>
>>>>>> Thanks you for investigation, Mike.
>>>>>> I tried this change and found no SIGBUS, so it works well.
>>
>> Here is another way to address the issue.  Take the hugetlb fault mutex in
>> the migration code when modifying the page tables.  IIUC, the fault mutex
>> was introduced to prevent this same issue when there were two page faults
>> on the same page (and we were unable to allocate an 'extra' page).  The
>> downside to such an approach is that we add more hugetlbfs specific code
>> to try_to_unmap_one.
> 
> I would rather go with the hugetlb_no_page which is better isolated.

Sounds good.

And, after more thought modifying try_to_unmap_one will not work.  Why?
It violates lock ordering.  Current ordering is hugetlb_mutex, page lock
then page table lock.  The page lock is taken before calling try_to_unmap_one.
In addition, try_to_unmap is unmapping from multiple vmas so we can not
know the values for hugetlb hash before taking page lock as the hash values
are vma specific.  So, without many modifications we can not add hugetlb
fault mutex to this code path.
-- 
Mike Kravetz

