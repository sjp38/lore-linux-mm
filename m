Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5348FC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 23:32:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02AD3217F9
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 23:32:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="y2nCTlnf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02AD3217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96AF86B0003; Thu,  9 May 2019 19:32:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F3F56B0006; Thu,  9 May 2019 19:32:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BA1C6B0007; Thu,  9 May 2019 19:32:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 57D1C6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 19:32:17 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t63so3767228qkh.0
        for <linux-mm@kvack.org>; Thu, 09 May 2019 16:32:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=C9aIasraSha+Unahg2EAZJgXu4Vii1PBVVz7t26PHMo=;
        b=fDfPeEb+hsWPJLkebENBrcQLIe4ZB3s1QdPY7QY+72xZEsz07o5e8A4RajiQrYhw/2
         oWcFwVUQvv8SuLgiAsQLPJltDwipnWO+/+Av5+FqOddyLKVnsTQrAvlVfwIxawGaQAFd
         QNMqVktWUAESk+aESTGrjG532xu755/C0zL0j+Wk7Xz3Ow7wYRsMsYeSAOL2B/B0HIqS
         xAtIRsldJuIg8Lx/6kXkhq/2Q9DSnpUyxRIp4xdjJzybK9ujiYYqLsYxgFixfuw3QiAf
         tqzSyNcNtC6aI+DKhlLseqAmRKLV2fv6wLK5lXYWhIWhb5d5OgEgfUq7Rxdvv9PgecZR
         vo2w==
X-Gm-Message-State: APjAAAXRPFVR4nv6FFw2Y+t4FghcLn9NBNY4iscBpmHbyo53nN/iqruk
	rxQQm8lvi9PD+/1Z30GChgy8ALAYs6eR89c5N3REuyma7lla8ETidQQhAncnRE8AgTc4QzP+RFb
	29Hx7yyLw+rng9fbCUNHDaeAyBryP2Gxnk7tIG6Zzh3qAkzlvQytkzY4XYlmJ9gKJtA==
X-Received: by 2002:a37:9103:: with SMTP id t3mr6212529qkd.78.1557444737067;
        Thu, 09 May 2019 16:32:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwC5UvqQExou7Q1pr88CoPAbKwD+eFtlkYBPRIjvWbbG70T9MlaBRwrA0Z9A+HtXmr+ghji
X-Received: by 2002:a37:9103:: with SMTP id t3mr6212484qkd.78.1557444736468;
        Thu, 09 May 2019 16:32:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557444736; cv=none;
        d=google.com; s=arc-20160816;
        b=IHtwdOVFcNGyK98+uQa3Azs5xZCD9DqvcHrVK6pN/RYwGw7FIrQG2Y/EZDdvMwNGVB
         wwqgDjvOe1CA5PUuUv5mtt53GaJzMfzvH0N3WWUUejdz8zkJxgjHOBreDVK7LG5qZmZB
         ATcqWtfs06Es+LYzMv4SNGY7U2Zo2Nxtf9zdyviFC+M7xggv1c/xs8kMTPFJ9X9InFE4
         Ew/a3bfTlZAaALzPKOdHq0kKmHIfU2ButPc112BIeFmAzmLDmkVsDS+T75+mkbL8qur2
         cMV22kTZwCj4XCEvL/XCVL84rBwmQsCLUZLOSbaANHbeVtALAC0VBck8NexPi7isxibM
         WU4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=C9aIasraSha+Unahg2EAZJgXu4Vii1PBVVz7t26PHMo=;
        b=kxfwbWsqENLBr4yRC4FSkpGAA9nkRn+N+GXdzhdJXCFF5YkDQ2A17XeGiWOB3subkR
         FX6dEP3aOJ6B5+z9MDKdcYafrgskD6GHkYDtysfTAEavAxoyJA9C6owf4dL+H/gRDdp1
         m5ENsJKqOjkAMJMnRnbPy2bs6NlCXUenoi617+DQULdsVaqTYrZYW7botuWUCDfE4R/2
         md+uk2FTq5DXm+Kz3IDwCStmQ/eameMoMgT1vxnVOSMumWBWtL/EzrcOLuKJTNMVvlgb
         w8SZMY1WNyTxvMxDbpYOsXV8GP1Xgp2kMFnEQYROpEixr8tl5a+DZ30TbI308+wa9Ea6
         DvVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=y2nCTlnf;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id p51si2549020qvc.16.2019.05.09.16.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 16:32:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=y2nCTlnf;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x49NOFCS051217;
	Thu, 9 May 2019 23:32:07 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=C9aIasraSha+Unahg2EAZJgXu4Vii1PBVVz7t26PHMo=;
 b=y2nCTlnf47trHDM7FlSPumjUEArfp40Mam9pSSNWxp9tuaJdDpHfRlBbsNprh6FslJfZ
 CvffXORALuUweL8ITV6SGhxWVWMt2j6NrHdSPkZHRCipnwSD3grZ15DUe+bjBfe5am5x
 SXCqanmEWrfk9VJwiMvC25XHGG7jzJ5zPOQdrVRqQR2/I/MnYgCPVdAPNy8tW/rq8+qW
 zmNbRVRI0WtRAy0cYaYpH9+07mv5C38mtNYXtZpE0xWroBvWiWhm4bTc0qSaeSW6kFI7
 7M2N6W29+txJqiVcRhJ0MTLSmTxAHH1heZY68DbVfcRUPRsENUrC7pbw8x18yZp0yV76 +g== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2s94b6e0e9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 09 May 2019 23:32:07 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x49NVUVU125728;
	Thu, 9 May 2019 23:32:06 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2s94ah2qat-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 09 May 2019 23:32:05 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x49NW3rL010577;
	Thu, 9 May 2019 23:32:04 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 09 May 2019 16:32:03 -0700
Subject: Re: [PATCH] hugetlbfs: always use address space in inode for resv_map
 pointer
To: Andrew Morton <akpm@linux-foundation.org>
Cc: yuyufen <yuyufen@huawei.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        stable@vger.kernel.org
References: <20190416065058.GB11561@dhcp22.suse.cz>
 <20190419204435.16984-1-mike.kravetz@oracle.com>
 <fafe9985-7db1-b65c-523d-875ab4b3b3b8@huawei.com>
 <5d7dc0d5-7cd3-eb95-a1e7-9c68fe393647@oracle.com>
 <20190509161135.00b542e5b4d0996b5089ea02@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <31754605-5425-a2aa-b16f-ad89772c27b9@oracle.com>
Date: Thu, 9 May 2019 16:32:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190509161135.00b542e5b4d0996b5089ea02@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=735
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905090134
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=805 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905090134
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/9/19 4:11 PM, Andrew Morton wrote:
> On Wed, 8 May 2019 13:16:09 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>>> I think it is better to add fixes label, like:
>>> Fixes: 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
>>>
>>> Since the commit 58b6e5e8f1a has been merged to stable, this patch also be needed.
>>> https://www.spinics.net/lists/stable/msg298740.html
>>
>> It must have been the AI that decided 58b6e5e8f1a needed to go to stable.
> 
> grr.
> 
>> Even though this technically does not fix 58b6e5e8f1a, I'm OK with adding
>> the Fixes: to force this to go to the same stable trees.
> 
> Why are we bothering with any of this, given that
> 
> : Luckily, private_data is NULL for address spaces in all such cases
> : today but, there is no guarantee this will continue.
> 
> ?

You are right.  For stable releases, I do not see any way for this to
be an issue.  We are lucky today (and in the past).  The patch is there
to guard against code changes which may cause this condition to change
in the future.

Yufen Yu, do you see this actually fixing a problem in stable releases?
I believe you originally said this is not a problem today, which would
also imply older releases.  Just want to make sure I am not missing something.
-- 
Mike Kravetz

> Even though 58b6e5e8f1ad was inappropriately backported, the above
> still holds, so what problem does a backport of "hugetlbfs: always use
> address space in inode for resv_map pointer" actually solve?
> 
> And yes, some review of this would be nice

