Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E12CFC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:51:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70AA320840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:51:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Cgp7ojbY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70AA320840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF18D8E0003; Thu,  7 Mar 2019 18:51:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA0508E0002; Thu,  7 Mar 2019 18:51:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A691C8E0003; Thu,  7 Mar 2019 18:51:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 518518E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 18:51:10 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id h16so8894171edq.16
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 15:51:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:references:cc
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4bAgnaCZ4AZSn5kaF2eBKx8oWqAK20GUr15eBLtGPIU=;
        b=ClHa7NUeqCSGG2/BCDezxX/RhjZG4Dzo+vIlD19/ob7OqT+r5xH/OesATmBz1suvjc
         XnuZ+tGU3HXXKzwzG8Xje7oiTPUhpjlAaHK+msouWtcq6YNZ1jt3BnB+tyP5tZDLwqLJ
         sQi6frfzkFEtv5lXmmPh0zeK8U92ctIzUEqGP1mKRZvhCS8ClTNSPGGom8OH+ZKyJMbT
         UV5T51CYWl4bIHV0BgivZplGxZDFgJCU8aH8PYG00Brop35kYpTgzuOdJ42TaBAnv5rb
         bycLeCa57yV1as6zHm5dWVlBMeIQC1VI9TL/BkgeeoNWajEvoTsv5R4eWWG+97hYpHaB
         SPcQ==
X-Gm-Message-State: APjAAAXj6eghEYdeqBZ5b/wzFk5zi5SUv8Hc4nNg3VuvPqcwO0Xaq1fn
	/1LPCzpEZPLxXyAUBk/2/JjN4lekuFFHTW4jjiJK7k6mHGjdi/i5tHVHZva2JnJtslTuc6GO6+Q
	gS1RmZx75bZGX1j9aNsj8pdiPxkl+5a2UblQT9bR/4c7SvNJYjbZeHxsCh2nTTK2iAg==
X-Received: by 2002:a17:906:1d4c:: with SMTP id o12mr9469977ejh.234.1552002669684;
        Thu, 07 Mar 2019 15:51:09 -0800 (PST)
X-Google-Smtp-Source: APXvYqyHvwsXbWk3rxvoPfBC9rm1GodjfrQAPTYZ5HFbi2GMawvQW/Et2b+I+DHZxXD4HCxX+/Ru
X-Received: by 2002:a17:906:1d4c:: with SMTP id o12mr9469931ejh.234.1552002668438;
        Thu, 07 Mar 2019 15:51:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552002668; cv=none;
        d=google.com; s=arc-20160816;
        b=k7FgBMDukjEeNrJbhV+bVfzoyRS4ok5qvD4fXJXesi690KipBVBWiL3dLkuPzK80t0
         Rt9APkHYURgs7EBlUqd0+pgXKshOP/+WXszp/TKj+h5XjfnFelVg6ukQJBJ+d9ptypJM
         IeV/kCF9TLjCJBgnLW4jfy0zPVe8gS0Jz2foLznT1orjWQDEn83Y80K2e0bcC7qkStBX
         BYoku41OUgRiZkFZfo4psRcEQJKSq93diOgVs4iMsQ7jljyJxvUcQIruanDwE0PSn4ww
         dqSB8D/KxIlRgQe78pa0xBxwA6jgC8wB6K+/1flUKDY2jkL02D3Pdt/2OernMy2tHMV+
         osgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:cc:references:to:from:subject
         :dkim-signature;
        bh=4bAgnaCZ4AZSn5kaF2eBKx8oWqAK20GUr15eBLtGPIU=;
        b=iVvh1yrDXcyajCESfZd+z0SPmDY46AizLuJdk1Grfb3ldKCUmcM4CNxtZ33fsmuAkJ
         FdTbzwse9h4CXiKhxdasci7OZwsOJq/BF93f7xFJM7bTXB4EVKvB4WiSPqEMhwpJ6yM5
         pd+0g3y3qSU5f//wgXrYfjjxmLhlq6dDUjFLchu5w4JuH8puEfZtkt1H5P7AieofpGP2
         Rh8epCC6syrBDmOTJjgOzXjBe1MKC5Gr+eHQ/+SaDnmmAZ7Ey9OPx/caLT62aGG9rUQo
         6atg8jP7yobBkYTuyejQjnuDstwHae9ET5prfwMs6ZbEDrcfhuB3M+TMh69XbJJzKZ0w
         mtsw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Cgp7ojbY;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id p18si792929ejz.318.2019.03.07.15.51.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 15:51:08 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Cgp7ojbY;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x27NmaQJ117340;
	Thu, 7 Mar 2019 23:50:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 references : cc : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=4bAgnaCZ4AZSn5kaF2eBKx8oWqAK20GUr15eBLtGPIU=;
 b=Cgp7ojbYVt7O3TR9fgazyXJAtI+94+WM54ifEOClG3YQiludYTT9vuVQs7xw4PKIdIiy
 SbxCXalCxfAxvzqP0BrQw88oAFMN4e2yy2FgLjl3JsakA5mQsTGNejCrxIgIGfOJxhpN
 sfzWP6sZq0/Rd8TI/eqhC9Bc8EFs/xX/dkFlGJbqc0nBK6VqhkVgUYZlUOfhdzLdxBCQ
 FaAggmmSWmKNrFM5648Skd0r0pDBoiVvZJ/X/IpyzJl5K1zZb6k+aoMjRZtiwxVKUtlr
 P4QVHUBEVBwfbf1hfi/tcqIRCVx9JsLwn8D3HDW+y9Eb6+7AQh4jTfAvW3m9me70LRln QA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2qyjfrwc35-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 07 Mar 2019 23:50:58 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x27NovDx001288
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 7 Mar 2019 23:50:57 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x27Nou1D017505;
	Thu, 7 Mar 2019 23:50:56 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 07 Mar 2019 15:50:56 -0800
Subject: Re: [PATCH v2] hugetlbfs: fix memory leak for resv_map
From: Mike Kravetz <mike.kravetz@oracle.com>
To: Yufen Yu <yuyufen@huawei.com>, linux-mm@kvack.org,
        linux-kernel <linux-kernel@vger.kernel.org>
References: <20190306061007.61645-1-yuyufen@huawei.com>
 <ac030f5b-3d9c-9a71-bd39-1c1f707bc931@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Michal Hocko
 <mhocko@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Message-ID: <6aecc2e3-030b-5a3f-2fee-14ee90a47f5a@oracle.com>
Date: Thu, 7 Mar 2019 15:50:55 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <ac030f5b-3d9c-9a71-bd39-1c1f707bc931@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9188 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903070157
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adding others on Cc to see if they have comments or opinions.

On 3/6/19 3:52 PM, Mike Kravetz wrote:
> On 3/5/19 10:10 PM, Yufen Yu wrote:
>> When .mknod create a block device file in hugetlbfs, it will
>> allocate an inode, and kmalloc a 'struct resv_map' in resv_map_alloc().
>> For now, inode->i_mapping->private_data is used to point the resv_map.
>> However, when open the device, bd_acquire() will set i_mapping as
>> bd_inode->imapping, result in resv_map memory leak.
>>
>> We fix it by waiting until a call to hugetlb_reserve_pages() to allocate
>> the inode specific resv_map. We could then remove the resv_map allocation
>> at inode creation time.
>>
>> Programs to reproduce:
>> 	mount -t hugetlbfs nodev hugetlbfs
>> 	mknod hugetlbfs/dev b 0 0
>> 	exec 30<> hugetlbfs/dev
>> 	umount hugetlbfs/
>>
>> Signed-off-by: Yufen Yu <yuyufen@huawei.com>
> 
> Thank you.  That is the approach I had in mind.
> 
> Unfortunately, this patch causes several regressions in the libhugetlbfs
> test suite.  I have not debugged to determine exact cause.  
> 
> I was unsure about one thing with this approach.  We set
> inode->i_mapping->private_data while holding the inode lock, so there
> should be no problem there.  However, we access inode_resv_map() in the
> page fault path without the inode lock.  The page fault path should get
> NULL or a resv_map.  I just wonder if there may be some races where the
> fault path may still be seeing NULL.
> 
> I can do more debug, but it will take a couple days as I am busy with
> other things right now.

My apologies.  Calling resv_map_alloc() only from hugetlb_reserve_pages()
is not going to work.  The reason why is that the reserv_map is used to track
page allocations even if there are not reservations.  So, if reservations
are not created other huge page accounting is impacted.

Sorry for suggesting that approach.

As mentioned, I do not like your original approach as it adds an extra word
to every hugetlbfs inode.  How about something like the following which
only adds the resv_map to inodes which can have associated page allocations?
I have only done limited regression testing with this.

From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Thu, 7 Mar 2019 15:37:31 -0800
Subject: [PATCH] hugetlbfs: only allocate reserve map for inodes that can
 allocate pages

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index a7fa037b876b..a3a3d256fb0e 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -741,11 +741,17 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 					umode_t mode, dev_t dev)
 {
 	struct inode *inode;
-	struct resv_map *resv_map;
+	struct resv_map *resv_map = NULL;
 
-	resv_map = resv_map_alloc();
-	if (!resv_map)
-		return NULL;
+	/*
+	 * Reserve maps are only needed for inodes that can have associated
+	 * page allocations.
+	 */
+	if (S_ISREG(mode) || S_ISLNK(mode)) {
+		resv_map = resv_map_alloc();
+		if (!resv_map)
+			return NULL;
+	}
 
 	inode = new_inode(sb);
 	if (inode) {
@@ -780,8 +786,10 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 			break;
 		}
 		lockdep_annotate_inode_mutex_key(inode);
-	} else
-		kref_put(&resv_map->refs, resv_map_release);
+	} else {
+		if (resv_map)
+			kref_put(&resv_map->refs, resv_map_release);
+	}
 
 	return inode;
 }
-- 
2.17.2

