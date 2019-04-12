Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B782BC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 23:40:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44E8120869
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 23:40:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Q4IX1pai"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44E8120869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B74086B0007; Fri, 12 Apr 2019 19:40:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B23E66B000A; Fri, 12 Apr 2019 19:40:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A13B46B000D; Fri, 12 Apr 2019 19:40:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB676B0007
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 19:40:14 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id w124so9396526qkb.12
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 16:40:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WIfCIXJ0j16Ob6z/4oTveGs1JdSH2kOg2zi1aqsSLzs=;
        b=MGygYpk5EAaH/nb+oTLhyGGSrqTKAEyM1RPpa5HVxp7jQRApCRPnsAO8LX13QfW01s
         jA5g7JbMvDO5ECf1LUngOkpEElkPiWW+3jgsLZYLUI6Egip42fepM7mHg60HtXQWlbBM
         wog7ME+3OudyRyulJljFBFB6p/MKkX2Yw7W+Q1yDglkzWJu1fVS+nJsltzXyvRfWpSY7
         aEO6fO2gf5TBJoqKQ/t4pub9CU8Mi8j7Bbof+krRvuVN2r1kxeinkFt3xD3gMH40t1BH
         o9mWiXcC6R9VhepDvKdtLU5nqIt87B9h9IxI12gTb0a8+d+kkz+1gn88bNC9P9VbTDEd
         ITgg==
X-Gm-Message-State: APjAAAXuQGFCJnZNucvZ9TbcJGWtiXL6dYyK0Y/7wYW7N+imkk5W6nDN
	0XhJlo3v2anD5VC5K14bmSyibZKux8ATqRnJKRK3M4Gs+uqdE7SOsyPtcxUhSDhv0My5DPo9Uko
	+56iTMhX4XkVQlsfsrGtPQdScxXrYKjSAkFrBiOolfklpjpQiptEx6rAcJAwQAdbQLg==
X-Received: by 2002:ae9:f50c:: with SMTP id o12mr23199746qkg.298.1555112414190;
        Fri, 12 Apr 2019 16:40:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeST3yuLQmzuxi1kFJQIoejMx0rTeSlHRsQycVk05iRzT5jX1dwftdoKTITe1IM/1W1Jvk
X-Received: by 2002:ae9:f50c:: with SMTP id o12mr23199685qkg.298.1555112413308;
        Fri, 12 Apr 2019 16:40:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555112413; cv=none;
        d=google.com; s=arc-20160816;
        b=yaHwYh3JAblxuMqGnyDXRNkEt9MxbfdilZ157Qf0JRHoK9k6pCbPaCcIxHZMtk4UDW
         bf2u70AIK0bXI+GaKDYzmt83aNkK/B7y+Jko4CsgDBjJ+01CIgAhYB659bvnn7pxTMTG
         QRyGnfxAJpH2CNUiY2vSP3hsHSEt3BVbBb2RfxZjgMwb5iMs3DYogTZ9pEmfKnjOdafF
         PnBgm+mlpDeFscFtrX+2hHd5xlv/6KwBh6b8HAYwgyvhTGE5lSNob/7/VivjjyoAYXGb
         0VBV6aPmy/tqBp3VA51S3oUh5ffuF9US0UqUoD3raSsUwo8HsDwihehHCHuZ/PsQDWJH
         Ch6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=WIfCIXJ0j16Ob6z/4oTveGs1JdSH2kOg2zi1aqsSLzs=;
        b=q11916JuN4HP3bj34V2IZdO98URyAtShKYsilJHSsYK7CfEB82Iy9pUTtEA6EM5TI9
         CN25prwVi3yFUx0jgSzDwuRFbLERkYQ+0+UgAMHlbQdVYQWO8bZrjZ8txjytqY4byguK
         IAhF6LNDstwq91gvP+Zh0/HZv+oCO/aTWuL3QIs78sj/MFLJpvZqiwJhiiV7m1DSZAlD
         zOr4SJO1sUJNiKVf4AcmH/e+quc9RkU47wnaoKlnCxuKjMbbaUNtlRcOLIMJbslAG/d/
         UblHgvhUw/AClMjwmodWIUtNEVYmP6pz5EuhQC9Djz9UYCQaESCPGZmUieL/RhvED2No
         Tj1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Q4IX1pai;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b202si3426848qkg.161.2019.04.12.16.40.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 16:40:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Q4IX1pai;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3CNdn67049240;
	Fri, 12 Apr 2019 23:40:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=WIfCIXJ0j16Ob6z/4oTveGs1JdSH2kOg2zi1aqsSLzs=;
 b=Q4IX1paiedN7idkG7gVsx9VJHvpstD9LL2uQIh94KKMwbpoKMWr7VmaUkzEASARzCA8K
 +HZbPa96+QWEmYu9vQ0FzM41QWYJLAJ4tmNUK1BzEoX+PYG7v6lIjkb5KW2CSrOgSsEz
 LnGy/djT7SIVRPLoy9BrPsjqXCF6oUY2vLpL8pi5Fc5+LNHVUMgYhlLNAEiao58fTGrX
 +gRBDtBBhe88kNQmfhe+3ZU/GMwMUzHUAYasgwgL/HvaG9d4OgA4KXywdbPBg9IhXAcE
 DO7mmf/8OShE5Xowk8BIPDf/53hSQRiXXTw+BkqfWWxNbpiJxgxOxbLun/pULNad0Oon Ng== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2rpkhtgwws-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Apr 2019 23:40:05 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3CNe21k055856;
	Fri, 12 Apr 2019 23:40:04 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2rpytdj7s7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Apr 2019 23:40:04 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3CNe2Sb025190;
	Fri, 12 Apr 2019 23:40:03 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Apr 2019 16:40:02 -0700
Subject: Re: [PATCH] hugetlbfs: move resv_map to hugetlbfs_inode_info
To: Yufen Yu <yuyufen@huawei.com>, linux-mm@kvack.org
Cc: mhocko@kernel.org, n-horiguchi@ah.jp.nec.com,
        kirill.shutemov@linux.intel.com
References: <20190412040240.29861-1-yuyufen@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <83a4e275-405f-f1d8-2245-d597bef2ec69@oracle.com>
Date: Fri, 12 Apr 2019 16:40:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190412040240.29861-1-yuyufen@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9225 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904120155
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9225 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904120156
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/11/19 9:02 PM, Yufen Yu wrote:
> Commit 58b6e5e8f1ad ("hugetlbfs: fix memory leak for resv_map")
...
> However, for inode mode that is 'S_ISBLK', hugetlbfs_evict_inode() may
> free or modify i_mapping->private_data that is owned by bdev inode,
> which is not expected!
...
> We fix the problem by moving resv_map to hugetlbfs_inode_info. It may
> be more reasonable.

Your patches force me to consider these potential issues.  Thank you!

The root of all these problems (including the original leak) is that the
open of a block special inode will result in bd_acquire() overwriting the
value of inode->i_mapping.  Since hugetlbfs inodes normally contain a
resv_map at inode->i_mapping->private_data, a memory leak occurs if we do
not free the initially allocated resv_map.  In addition, when the
inode is evicted/destroyed inode->i_mapping may point to an address space
not associated with the hugetlbfs inode.  If code assumes inode->i_mapping
points to hugetlbfs inode address space at evict time, there may be bad
data references or worse.

This specific part of the patch made me think,

> @@ -497,12 +497,15 @@ static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
>  static void hugetlbfs_evict_inode(struct inode *inode)
>  {
>  	struct resv_map *resv_map;
> +	struct hugetlbfs_inode_info *info = HUGETLBFS_I(inode);
>  
>  	remove_inode_hugepages(inode, 0, LLONG_MAX);
> -	resv_map = (struct resv_map *)inode->i_mapping->private_data;
> +	resv_map = info->resv_map;
>  	/* root inode doesn't have the resv_map, so we should check it */
> -	if (resv_map)
> +	if (resv_map) {
>  		resv_map_release(&resv_map->refs);
> +		info->resv_map = NULL;
> +	}
>  	clear_inode(inode);
>  }

If inode->i_mapping may not be associated with the hugetlbfs inode, then
remove_inode_hugepages() will also have problems.  It will want to operate
on the address space associated with the inode.  So, there are more issues
than just the resv_map.  When I looked at the first few lines of
remove_inode_hugepages(), I was surprised to see:

	struct address_space *mapping = &inode->i_data;

So remove_inode_hugepages is explicitly using the original address space
that is embedded in the inode.  As a result, it is not impacted by changes
to inode->i_mapping.  Using git history I was unable to determine why
remove_inode_hugepages is the only place in hugetlbfs code doing this.

With this in mind, a simple change like the following will fix the original
leak issue as well as the potential issues mentioned in this patch.

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 53ea3cef526e..9f0719bad46f 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -511,6 +511,11 @@ static void hugetlbfs_evict_inode(struct inode *inode)
 {
 	struct resv_map *resv_map;
 
+	/*
+	 * Make sure we are operating on original hugetlbfs address space.
+	 */
+	inode->i_mapping = &inode->i_data;
+
 	remove_inode_hugepages(inode, 0, LLONG_MAX);
 	resv_map = (struct resv_map *)inode->i_mapping->private_data;
 	/* root inode doesn't have the resv_map, so we should check it */


I don't know why hugetlbfs code would ever want to operate on any address
space but the one embedded within the inode.  However, my uderstanding of
the vfs layer is somewhat limited.  I'm wondering if the hugetlbfs code
(helper routines mostly) should perhaps use &inode->i_data instead of
inode->i_mapping.  Does it ever make sense for hugetlbfs code to operate
on inode->i_mapping if inode->i_mapping != &inode->i_data ?
-- 
Mike Kravetz

