Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62E2FC10F0E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 00:37:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13D362075B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 00:37:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PdDvC6RX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13D362075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 817B76B0003; Mon, 15 Apr 2019 20:37:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79EAE6B0006; Mon, 15 Apr 2019 20:37:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6185E6B0007; Mon, 15 Apr 2019 20:37:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2292F6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 20:37:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d1so11373775pgk.21
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 17:37:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8C2rpUhcM1NERLTBIRjCXSFvKzZ6vS+vOSLrZwh5lMg=;
        b=j5uNkqNAA1yYJ4TuD1NyHkDHRtfSZ/ISCPyy9m2yeeMTYPECav4+1K6ACms3ogcB7m
         yMcfBAwcIKI4O/4nLczQKl4MaG2lACyI5sX0m623nUG4qqlVZMJbkE1sDXoCUbNeB8tz
         73f2NCyHof+kUUNdsgcmcUGr+Pwon6KMH0kwNX7M4hsCQ8y+Ixjn2N5OW52oGrlONlv+
         ZttK+J2j9r9nKwZmh2nll62DfwzSU1J30mzi7j63m76T/CiB6vqW8SH96s+zDlT8AcQ0
         cVKjooj94wkJC47L42mepFFDpJYxYXdjGpFwzC3tduBnWCGjcUNk8S7OBZKRXy55GSb3
         +SRw==
X-Gm-Message-State: APjAAAWOQc8noQZpTyF4jGYjmIfrhqLnuNU5lGjEQV6ThNEifg5mSFAm
	RA9v1XLlO0CtTc2WXJhLKrmOd5wE1tImwOEX57z+BalPkPLb4wtKzsbyAEn6rzYuBlMRlVNN76s
	q5/UMEVn+VrW8UUmRJ3W3sHkh0Etl9mevEiq/pNVWtWJwCkiYbzqUzP+rNks/1/LQMA==
X-Received: by 2002:a63:8142:: with SMTP id t63mr69675668pgd.63.1555375045730;
        Mon, 15 Apr 2019 17:37:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzr1jVwud2qKwIYjYCXY/DCvb41D2CipFYR8wBoSpsCq9yxzwDuF2lmDh//tJJdUNQVJ69
X-Received: by 2002:a63:8142:: with SMTP id t63mr69675589pgd.63.1555375044676;
        Mon, 15 Apr 2019 17:37:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555375044; cv=none;
        d=google.com; s=arc-20160816;
        b=maz/rt1o4oz8ZGSoFT5tg9aXykZF14/tMGrJrK4wzli+hVnGaSCcjxR7CPhuFqGJEk
         /bdS4EuDaDenyl1rrq5jhwzfpy4S4j+DSKBuR9jkfrMRYkK5N9drXymvzCGM71RN7rIq
         +1zOgl5aL7AjcX9qslAQxJZahZvRQJrTjiGRhPUCJt3pZ+dzkBTbm/jZSK+hk6WpRvSs
         3C3BoSu0Tbm+rYl7zzNqcmCG1p2a+lSyI68NJlw5Bd1pNZyE+3CMvkc6YpykCVjT6LWD
         V/VHP+BmnNVUJwyXiqTSZziFSiUCVNpW6787nAv0BmR3rIWB6sbgMRVdVyBjQJznTMUk
         TIXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=8C2rpUhcM1NERLTBIRjCXSFvKzZ6vS+vOSLrZwh5lMg=;
        b=So0/xBAAesDCWgij0950aK35KH+8yEKppII2XeCkhiBnmfoKy85msAwCWiaIh76R21
         +VFzGWxZoTeR21BqLOx40zslGyAvrFCFApbkcJXvf7E47+bWMxtSUB/GaCYe9yn8USdf
         NnRqQ6NzSI7EMfjkPPJz+Vzs3Klue7/pPTN4Pq8/G01CzaM9Sc0vw8if+Kl8GEsUP8Mg
         i9puy6XAv32j7tGoW1TXtl93D5Cql6VEdfy0M50xnL7JqQMeznPwPNZBANPRvLTchuSx
         dJYHPriVZzZ15QDLlSKWQtXqepZ/xt6MGFXalgg1ViNMshLNJAJV+1+rCdDvHkZwJvHL
         rUOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PdDvC6RX;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m88si34647347pfi.280.2019.04.15.17.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 17:37:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PdDvC6RX;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3G0YE3P057340;
	Tue, 16 Apr 2019 00:37:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=8C2rpUhcM1NERLTBIRjCXSFvKzZ6vS+vOSLrZwh5lMg=;
 b=PdDvC6RXn6AIqwrQwBR7h+jtsDWp+zVR8aSsYwxdwd779eG/XXdD/Amx3FXdZvGYAxMD
 I7RgwjeiUdWG0xJLuFVgJCBELIzwrTpmhPw9ehFGdo4uxCbX33tQLMjUsv8ZXPCknl/K
 +da27Nmy1zcpsmdPv5PKMSaT3E84xq4B3WTBoc/0y+8rn2PlGUq9KM0Txcu2GkAdES9S
 jy2DhFQR4If27+znBL8O/3VpKJ3U7WuOGj95etglRmnQ9Cus1ik9n5Q9pQayclzy1pRP
 wNWRzTljPfZMqIym8j+UIMO6cDGhdG06xSkE0SwVx5oWonciYXt4JoD1MqRXOOIotuJR 0g== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2ru59d1qej-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 00:37:16 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3G0aLum161037;
	Tue, 16 Apr 2019 00:37:15 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2rubq61f90-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 00:37:15 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3G0bDFx013255;
	Tue, 16 Apr 2019 00:37:14 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 15 Apr 2019 17:37:13 -0700
Subject: Re: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Michal Hocko <mhocko@kernel.org>, Yufen Yu <yuyufen@huawei.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
References: <20190412040240.29861-1-yuyufen@huawei.com>
 <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
 <20190415061618.GA16061@hori.linux.bs1.fc.nec.co.jp>
 <20190415091500.GG3366@dhcp22.suse.cz>
 <f063c3e7-1b37-7592-14c2-78b494dbd825@oracle.com>
 <20190415235946.GA4465@hori.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <134e8b96-1345-04cc-371e-2d340b374fd1@oracle.com>
Date: Mon, 15 Apr 2019 17:37:12 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190415235946.GA4465@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9228 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904160001
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9228 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904160002
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/15/19 4:59 PM, Naoya Horiguchi wrote:
> On Mon, Apr 15, 2019 at 10:11:39AM -0700, Mike Kravetz wrote:
>> Let me do a little more research.  I think this can all be cleaned up by
>> making hugetlbfs always operate on the address space embedded in the inode.
>> If nothing else, a change or explanation should be added as to why most code
>> operates on inode->mapping and one place operates on &inode->i_data.
> 
> Sounds nice, thank you.
> 
> (Just for sharing point, not intending to block the fix ...)
> My remaining concern is that this problem might not be hugetlbfs specific,
> because what triggers the issue seems to be the usage of inode->i_mapping.
> bd_acquire() are callable from any filesystem, so I'm wondering whether we
> have something to generally prevent this kind of issue?

I have gone through most of the filesystems and have not found any others
where this may be an issue.  From what I have seen, it is fairly common in
filesystem evict_inode routines to explicitly use &inode->i_data to get at
the address space passed to the truncate routine.  As mentioned, even
hugetlbfs does this in remove_inode_hugepages() which was previously part
of the evict_inode routine.  In tmpfs, the evict_inode routuine cleverly
checks the address space ops to determine if the address space is associated
with tmpfs.  If not, it does not call the truncate routine.

One of things different for hugetlbfs is that the resv_map structure hangs
off the address space within the inode.  Yufen Yu's approach was to move the
resv_map pointer into the hugetlbfs inode extenstion hugetlbfs_inode_info.
With that change, we could make the hugetlbfs evict_inode routine look more
like the tmpfs routine.  I do not really like the idea of increasing the size
of hugetlbfs inodes as we already have a place to store the pointer.  In
addition, the reserv_map is used with the mappings within the address space
so one could argue that it makes sense for them to be together.
-- 
Mike Kravetz

