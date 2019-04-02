Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A666C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 18:41:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D01772082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 18:41:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="gwQKBKaN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D01772082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F4756B0273; Tue,  2 Apr 2019 14:41:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 279DA6B0274; Tue,  2 Apr 2019 14:41:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F4EC6B0275; Tue,  2 Apr 2019 14:41:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E09746B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 14:41:29 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id j203so3644040itb.8
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 11:41:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=nzLm0OjyIrPaufp+45RiSA1Tm0FZroyUlXyqz6uPM4M=;
        b=qjmZW7j8HU3BwCVCDwjimiYas5yxP3g/i3tJX7YVClB7g7mtiEb0J7ORuR+zZNTG/Y
         KErF4wYtFVb6Or8x8kZVNHSf41QunfajrcI2uHhz60t63CnkHrykiCu9bCeCh/+a/ddR
         ptP46Pr1yW4EWzZ/OeEXf/YYZFWVQj5gR7oGdHulFSqmnvmcjKv9BQBCpSNcLnmfBep5
         TVPKdZJzKDQq3+EI0jyZ/hYbYcOC2gNkUuOhHMmzVlrLzQQYhT02BLaKbsitVyfVYlld
         BJNTyKW9evULsEFYnPHYzl4v7rZEro044qqE91QhDwdJlw5K/MXVN9vKaP0otpk+cbt4
         tg2w==
X-Gm-Message-State: APjAAAWqRBgWfG2cc4Om3oQUDet12Y6rRGU1YgDZbYyG/0NDfSBN4Sz/
	8DHIjnbmlpVNQ9OCl8M6EYVWt6FkJFlktvru10wtCj1vJbdoufZg/RNvK9XX/Poq8VwltWEsD6N
	rx7sEz5oI0PMegAcfDIdEGAD67Mte3osGI2fdXYSpRIca6wWw5N6jluMFzC56EeEF0A==
X-Received: by 2002:a24:6b84:: with SMTP id v126mr5627144itc.136.1554230489718;
        Tue, 02 Apr 2019 11:41:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyyDB6m7thegI+5NF/qlMxi5Mdhpj2s0VF21x7blP0rjSufqu82wRPgZlmVvH2tFXq1OQJ
X-Received: by 2002:a24:6b84:: with SMTP id v126mr5627090itc.136.1554230488776;
        Tue, 02 Apr 2019 11:41:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554230488; cv=none;
        d=google.com; s=arc-20160816;
        b=pJhMKyiRR04ai4FznqkPtTcy71YIIhhk6Vv59fP3aW3QMlKNwye+xpRq91V9kdJbFv
         WBGQx/4XJm37HVPwqhJ18i2cgacJ1G0/NYjL5IADW8andJ83zS1Vv6n97aiDa/Wtx9zV
         1fIrHjihZMH9C4IGviZ1W7BVj8BkazBOTAD0ROv44U4eZHySVI6x0kSoBmlYRvMBOfZE
         OVWKxcG9Y67D8AsyXWPfbKs1faYmnOZ0JhUfW5+oUAAo741bSsAktpkYGPBFCIECU6de
         zDre1yqRnK7IS8AaM81UcqATNgrRMHHSKNgg1HwvsGDxTmhW5HKYhVXRh+pUq0Ln4B10
         tL2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=nzLm0OjyIrPaufp+45RiSA1Tm0FZroyUlXyqz6uPM4M=;
        b=tNKNJSBYmwnnw1JfkitdI1rM1QMbw1TUVL4/6m+kIGX/ZjsMr+dZxTo1dtw0/Q/JiV
         5TvmKhQ9LDK++FDlv8yBk4K/OJkUQxPH8o1saBYkYo8WdIeaI0h5pKKruoBT5E58HW4T
         CVsmeIgouZ9ppge8b6PWxpUtRorwvHOvAAqBmIF9P+gmSPTuamzdNPw/D+p9lXvRi7ve
         pbfM1+BCYodxD7Y0H1SMDqGE26Uz9do7A5DtlIJwXexKfPFMuozC495jTE3NKTF7RNvn
         2oudnkIg+rN1dtkWhv1y76R2phiBWDatN8Jw7BLZUUwX9xa0cZTLaAz4OR1j3I9axCdC
         ZbEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=gwQKBKaN;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id o195si568752itb.85.2019.04.02.11.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 11:41:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=gwQKBKaN;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32IXiSl032070;
	Tue, 2 Apr 2019 18:41:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=nzLm0OjyIrPaufp+45RiSA1Tm0FZroyUlXyqz6uPM4M=;
 b=gwQKBKaNO0Rld4H9xBxYSHPyARFdqbfhgM6doGS1wet7d7T2zzaGSVkv4I3FA8F2lzpH
 ZJ2FHGt/7Yd/w5tWgKhCCFXMAk/pA2Dx3t1ZvUPMRK5dEb7VzGCQBFp41gnF3Ndrnpho
 ZOc3HLKhRKYg61WdthsEb4ewOodom11QNaR/JGW1pRwm8pU0syvJ9palKN+uoq/fuvOW
 VLqCOqn8OzJqNFRmipwEuaH6Dsxa/B8gdp0Jtu6XORmzj3qP0HyZ776SrkQAxXlw8/Qs
 Y9rNHyQQMwDLn82f4cfDopCja3WL2g2ezu1OrPIZvcUlw91Nwj4zApkHBUUqa70rG0Ka dg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2rj0dnk1b0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 18:41:24 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32IbImT008481;
	Tue, 2 Apr 2019 18:37:23 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2rm9mhmawe-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 18:37:23 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x32IbL9C017898;
	Tue, 2 Apr 2019 18:37:21 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 02 Apr 2019 11:37:21 -0700
Subject: Re: [PATCH] mm/hugetlb: Get rid of NODEMASK_ALLOC
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
References: <20190402133415.21983-1-osalvador@suse.de>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <8152cb75-da42-0fe7-9aac-82b1b8929f09@oracle.com>
Date: Tue, 2 Apr 2019 11:37:20 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190402133415.21983-1-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904020124
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904020124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/2/19 6:34 AM, Oscar Salvador wrote:
> NODEMASK_ALLOC is used to allocate a nodemask bitmap, ant it does it by
                                                          ^
> first determining whether it should be allocated in the stack or dinamically
                                                                    ^
> depending on NODES_SHIFT.
> Right now, it goes the dynamic path whenever the nodemask_t is above 32
> bytes.
> 
> Although we could bump it to a reasonable value, the largest a nodemask_t
> can get is 128 bytes, so since __nr_hugepages_store_common is called from
> a rather shore stack we can just get rid of the NODEMASK_ALLOC call here.
               ^
In addition, the possible call stacks after this routine are not too deep.
Worst case is high order page allocation.

> 
> This reduces some code churn and complexity.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Not a huge deal, but a few typos in the commit message.  Thanks for the
clean up.
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

