Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E00C9C10F0E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 03:40:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A2502082E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 03:40:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="rRwR4Bkd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A2502082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D80C06B0003; Tue,  9 Apr 2019 23:40:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDF6F6B0005; Tue,  9 Apr 2019 23:40:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B33746B0006; Tue,  9 Apr 2019 23:40:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 749156B0003
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 23:40:49 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s19so653472plp.6
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 20:40:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Se3eqjiQ+KjWFbu2w1/InnBHreZHz/aMu1Zqi27aT5o=;
        b=SpXRGDfljdWiiU+ljhH9N4EvMrETLrE6CC8xUplKPHwjTBmjC9Roh6RWzhmlTfLX/i
         +FaAdlUWeydFFqct4M92dcNtvnO6zUdPSBrozZG8QcjYJTt/yCqBEhZYn3qswbQrReus
         Kr1jrufOyf8XxFcKqCqsSBLiOB0OU0+LzKlVmVmNeQ3L7ZmLlE/cqnPnhya8TjKNdTlj
         dc3/30DnPU3AA/Wf80q0wLGOeb9imKfcQ5vW/ELKF9yyJAIAGOOOfJRcFgez2lRYE4eg
         YkKPcrxNY4gGZxmzM0675tonWICTOV/FN233quH67TiDPyTQCe1r1QnqjxEEW++G1+Mo
         520w==
X-Gm-Message-State: APjAAAUSM4T3ifUuM4CI0e9tRkzLQCNgJDfHbNq3DbjWLHQ/vCvF9Zlv
	1D4NL0ZUKGkMS0smm8hLB6D8mkrMxrXd3HjngZzSpOCGdACiyOqKq52YKe/mkg0PTcRBBGrp8jP
	9r0qRYbnpZfxIlV/bHuPLIvVI1UtxMGFrS+n0EJPiADu8krHcD4ZI+tN3FR3s3qGk3A==
X-Received: by 2002:a17:902:8604:: with SMTP id f4mr30760471plo.245.1554867648745;
        Tue, 09 Apr 2019 20:40:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtQJ/h7Wq8fd+PZJWxlfVkGLZ9vOQnjGGzPajYujXHmfX1kVDs55RV6YnK+rc/2nJ8VK66
X-Received: by 2002:a17:902:8604:: with SMTP id f4mr30760405plo.245.1554867647621;
        Tue, 09 Apr 2019 20:40:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554867647; cv=none;
        d=google.com; s=arc-20160816;
        b=kyTUyiM+kmyYu1UDuOsiFKm3ZTPLbtM6FjMOy/s01x3phR5Tn3nj98+KgjCZXbYiMo
         ItmbXt/OtL94ZpsqW37/8RAT4jv4TIVvPxz9OBfnFHMYeKyDxuyrU+k7Ezrrd5NsiCm/
         ktt176dzquNYZMBKI+Z8B71xjytNDgSDrnV7jn4yjRFywo4MgAYk6RU7jODhp855Qomd
         ZjuG+kvU844W6hpfcUHLUqN9Ks5MvRfSWFmoundVZn5/wXxuDID+8gIOC6TyQCThoj2l
         mN4rLJXkyo/GgnY/ulWaJ5j+TQPxeGMcLlhrrhNLXnOD9+Piv1slcowUlg5bNdoW7dmQ
         OGQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=Se3eqjiQ+KjWFbu2w1/InnBHreZHz/aMu1Zqi27aT5o=;
        b=WNQ2u7nHn6d/opg4ZAGu5uRYM+IN/wUYMcuY6u06y8oUVtTUch9pQgH4Z83Tmn6Lp3
         nh+Ee53FHjblXzG06Y/mtCDbS3QBvQZjcvuQOh4FrnsXnN1rYpgQA1NoUmB9tlR9lJ4y
         8z6PXb2S8pnVjzFSlVDGmkdudpzg4hsZaebzWipv6NAMhA60NGdX0t1DYEGyDr2c2BrB
         xjfSt4u7zE4TGddkcdyq+P7pDoHfhdIl1kuBhIJbCrg3tQubNY0cLeJIMV6pdBCdtSsU
         F79Kl/1znbTg9vvT2WAsTBJ3dkf4YALuZeJ+/ETgZJMHu3ndB0QsG9C/anNHCmXkxtZq
         RSKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rRwR4Bkd;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id s35si31297579pgl.277.2019.04.09.20.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 20:40:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rRwR4Bkd;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3A3dC83154840;
	Wed, 10 Apr 2019 03:40:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Se3eqjiQ+KjWFbu2w1/InnBHreZHz/aMu1Zqi27aT5o=;
 b=rRwR4Bkdlj03ex4ljsKrGUzX0uHeWROPAfoqLLE1tCG6auKbQeGA5ByMe7J6hWwul3Bt
 kNNb4/BaQISVrxnLIWE/DQDqD6h3GVSlDnx1aFRpJoJwyet9RIn40JiafxuJGJoZUgEq
 nDti0eosOLbu6563lBtoC2gb1t4PlWzZRWoe47FayV0NHepCsgQEj0DfU+/Ymgkmayb7
 +ouQUqSXadVHsfv4e9y3WZ4fQjHERCBf0k4iUv60zpFpJlu5svwXbP+VWYt8GRiOxroQ
 0hOCWzFy/GqxzIKDAF5jH+cwP+EgMr8uFXqGY0EgSaTsbcU1UP1MV3fugQg/skRY9Q7e Bw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2rpkht0kf5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Apr 2019 03:40:38 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3A3bx2V050047;
	Wed, 10 Apr 2019 03:38:38 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2rpkejn6mk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Apr 2019 03:38:38 +0000
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3A3caPP011490;
	Wed, 10 Apr 2019 03:38:36 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 09 Apr 2019 20:38:36 -0700
Subject: Re: [PATCH] hugetlbfs: fix protential null pointer dereference
To: Yufen Yu <yuyufen@huawei.com>, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com,
        mhocko@kernel.org
References: <20190410025037.144872-1-yuyufen@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e8dd99bb-c357-962a-9f29-b7f25c636714@oracle.com>
Date: Tue, 9 Apr 2019 20:38:35 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190410025037.144872-1-yuyufen@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9222 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904100025
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9222 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904100026
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/9/19 7:50 PM, Yufen Yu wrote:
> After commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map"),
> i_mapping->private_data will be NULL for mode that is not regular and link.
> Then, it might cause NULL pointer derefernce in hugetlb_reserve_pages()
> when do_mmap. We can avoid protential null pointer dereference by
> judging whether it have been allocated.
> 
> Fixes: 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Yufen Yu <yuyufen@huawei.com>

Thanks for catching this.  I mistakenly thought all the code was checking
for NULL resv_map.  That certainly is one (and only) place where it is not
checked.  Have you verified that this is possible?  Should be pretty easy
to do.  If you have not, I can try to verify tomorrow.

> ---
>  mm/hugetlb.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 97b1e0290c66..15e4baf2aa7d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4465,6 +4465,8 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	 */
>  	if (!vma || vma->vm_flags & VM_MAYSHARE) {
>  		resv_map = inode_resv_map(inode);
> +		if (!resv_map)
> +			return -EOPNOTSUPP;

I'm not sure about the return code here.  Note that all callers of
hugetlb_reserve_pages() force return value of -ENOMEM if non-zero value
is returned.  I think we would like to return -EACCES in this situation.
The mmap man page says:

       EACCES A  file descriptor refers to a non-regular file.  Or ...
-- 
Mike Kravetz

>  
>  		chg = region_chg(resv_map, from, to);
>  
> 

