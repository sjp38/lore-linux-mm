Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB0D6C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:52:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 838A02133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:52:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uN4Vue1M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 838A02133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5217F6B026B; Thu, 11 Apr 2019 12:52:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CE606B026C; Thu, 11 Apr 2019 12:52:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BD106B026D; Thu, 11 Apr 2019 12:52:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 039CD6B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:52:57 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j18so4586340pfi.20
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:52:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Yv3it5g90Q6DzWTRs1XjFBzVfJIRZ9XI6opnvyFSXgo=;
        b=X3r9E7vsO316A7QV3iWsSEYzUK92y2Y4OH6XIsF9K+AqrCoIN/js4vOieLmS6bXa/2
         e3mquSCqXjK/oJzM3T2JiGoMDyLmVsqBtiu+IfI5tkunal/Y6aMv26l5g9miXPgl65CD
         hJ73Wsryp0oqe9VqIGYa0FKAWHTOosJw9gwi4J29fFZrVohE93iFTAcz8z3Ln1Kme9Qu
         XFjXSzolQ1nz733+8fe/QsgKmZxjnyijOvDb9PoYb+M71wCjyhrjD0M0xV/GoUcrjLLA
         GXr0VZCs3Mrx3a4lJFOXlAPctHMXitSJzJyh8wPRug37JAjlNTamaLY82xNd38bKhKWU
         DytQ==
X-Gm-Message-State: APjAAAUj+bClGifx1LX2c+bnrDdKnCV+YA48lbMB5LMRXsy1TEz1/EBc
	EdKqpZcfSPQopyBN6OkNd3I5sG824hyQ8SqpIUPhWxznZ0ri1r1wxSBL18DmicrPcRw7MlPGUSU
	zyqayNg2vqUA+T7M2lJKCtQJXrhmvGdhu8KzD4+X/hPqjn6klUvIOaP7fXZmGSQ4WsA==
X-Received: by 2002:a63:3c19:: with SMTP id j25mr48655776pga.365.1555001576538;
        Thu, 11 Apr 2019 09:52:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAWmpC0r91VGQAKbpkQQUKz6tfsf4+4QMzTkgGboT3FXTRBy+aWtM944ZK1pXoJE7fWvOl
X-Received: by 2002:a63:3c19:: with SMTP id j25mr48655717pga.365.1555001575745;
        Thu, 11 Apr 2019 09:52:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555001575; cv=none;
        d=google.com; s=arc-20160816;
        b=f7y27mbagpRttKsWnnwmFadX4TzOFiGBpShOvPkuh6HxCLBdqSh8rF0CMcsvyyxRk4
         PU1aJDHkuq8aMNRncQlxu+B+7dSFM6M5iDY/2ogHIYInqpAeE8F6tXctqH9L3HlcT9zm
         p0kHKirirTR8e7nz7uN4TmeF9KODu544snoNaBs4BDkPfzLxuZKrVbe0dPguS1dTuj9R
         xj395xPqt7UQjJPEJ6c8l7tLyRkJhMcQoWR8RKscatTR78keVw5Su0Bej6GJtXUfqVgh
         lH12HNQ7AmcVt8m3xL6IJ0C/Ff4oEcQj5lrpGsA0tHMckBkySq66PdXckJiycOpNNAwW
         Ofzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=Yv3it5g90Q6DzWTRs1XjFBzVfJIRZ9XI6opnvyFSXgo=;
        b=bMTHVR+VQ1FOz5LOyeTf3lqmDuNysV2/HBL2A8160rMyoEkPGn4idnlCUB+ldFxj77
         U1kux3L0eeh7kcIshG2s1NzGqIfln4lkaajEIS5Iheg4YUBdC2NXSAJMPWqxodaM0lyo
         3VKM+7QG7YP4aRCrD+wD9yEqt3szm/1RmAG1agoCN3jG2bt1lexeamQee3EZs+gGPJz9
         1/y/Ff3bHIeAn62uCyhopwbv7ssg030vfzxjIDds+5N9NSjJ2sWmwDagUcTGa9VZ+tab
         dn7X8iS29QiYdJ62Ji9T/+7SW8ut7roY5yx6SWGJergpP1hgkT20j6KcHbol0Mn8Fnjd
         hk7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uN4Vue1M;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id c3si14342400plo.243.2019.04.11.09.52.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 09:52:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uN4Vue1M;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3BGiwLH002833;
	Thu, 11 Apr 2019 16:52:47 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Yv3it5g90Q6DzWTRs1XjFBzVfJIRZ9XI6opnvyFSXgo=;
 b=uN4Vue1M43O0dbK5FL+0ArbPKQT5XlgoSfXsymhr83rVA4V02TWmB4Ywcwh3nwsnAJWB
 S5DCnssQnjHzFzyjCzAqz5yax7tuSsmZD6rEADsA3P508W7eE2YULXJAxUmqMeMHA5gd
 XW+Dp+uGtA5CI9JFLjO24CaAFlfW+Dm5tG+jx9kGGG5gCll8/o+JUZ1O9429y1G17jBi
 kn5lwFchSfuYavMKINBHjS1Rjduj+BJX2AHFNCuYYHb4jevMrdFysrFnfyB0ptpGW7Kw
 bAwu2yY9BkXdReK6d3xIWp6FTRgiZl0CL5rbpGh151yx/HGGXLXG5AecSCqdl7rbjBHE FQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2rphmetamj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Apr 2019 16:52:47 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3BGpgik105798;
	Thu, 11 Apr 2019 16:52:47 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2rpj5bts29-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Apr 2019 16:52:47 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3BGqkoX031959;
	Thu, 11 Apr 2019 16:52:46 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 11 Apr 2019 09:52:46 -0700
Subject: Re: [PATCH v2] hugetlbfs: fix protential null pointer dereference
To: Michal Hocko <mhocko@kernel.org>, Yufen Yu <yuyufen@huawei.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com,
        n-horiguchi@ah.jp.nec.com
References: <20190411035318.32976-1-yuyufen@huawei.com>
 <20190411081900.GP10383@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <b3287006-2d80-8ead-ea63-2047fc5ef602@oracle.com>
Date: Thu, 11 Apr 2019 09:52:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190411081900.GP10383@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9224 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904110112
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9224 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904110112
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/11/19 1:19 AM, Michal Hocko wrote:
> On Thu 11-04-19 11:53:18, Yufen Yu wrote:
>> This patch can avoid protential null pointer dereference for resv_map.
>>
>> As Mike Kravetz say:
>>     Even if we can not hit this condition today, I still believe it
>>     would be a good idea to make this type of change.  It would
>>     prevent a possible NULL dereference in case the structure of code
>>     changes in the future.
> 
> What kind of change would that be and wouldn't it require much more
> changes?
> 
> In other words it is not really clear why is this an improvement. Random
> checks for NULL that cannot happen tend to be more confusing long term
> because people will simply blindly follow them and build a cargo cult
> around.

Since that was my comment, I should reply.

You are correct in that it would require significant changes to hit this
issue.  I 'think' Yufen Yu came up with this patch by examining the hugetlbfs
code and noticing that this is the ONLY place where we do not check for
NULL.  Since I knew those other NULL checks were required, I was initially
concerned about this situation.  It took me some time and analysis to convince
myself that this was OK.  I don't want to make someone else repeat that.
Perhaps we should just comment this to avoid any confusion?

/*
 * resv_map can not be NULL here.  hugetlb_reserve_pages is only called from
 * two places:
 * 1) hugetlb_file_setup. In this case the inode is created immediately before
 *    the call with S_IFREG.  Hence a regular file so resv_map created.
 * 2) hugetlbfs_file_mmap called via do_mmap.  In do_mmap, there is the
 *    following check:
 *      if (!file->f_op->mmap)
 *              return -ENODEV;
 *    hugetlbfs_get_inode only assigns hugetlbfs_file_operations to S_IFREG
 *    inodes.  Hence, resv_map will not be NULL.
 */

Or, do you think that is too much?
Ideally, that comment should have been added as part of 58b6e5e8f1ad
("hugetlbfs: fix memory leak for resv_map") as it could cause one to wonder
if resv_map could be NULL.
-- 
Mike Kravetz

