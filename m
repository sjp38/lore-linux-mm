Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FD69C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 00:07:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 210442089E
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 00:07:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="3R53FdYb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 210442089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B085B6B0003; Tue,  6 Aug 2019 20:07:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB8E86B0006; Tue,  6 Aug 2019 20:07:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 959026B0007; Tue,  6 Aug 2019 20:07:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD6B6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 20:07:43 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id d13so51189906oth.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 17:07:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AIsoL8wBQu2vc4iTjiuL85c4WFOrTsYj/OoeOmTUV04=;
        b=onTIt0+4PJCMI4NDFv3z65blKLxjryQFJr0w259u0etoj9ZZmqIkC4yjN2dklALQBc
         44V0PdB8dfzI2nevnUCbuWNRn4SRYsMj6AzP0WTbmh/hgXz+gWySxzOluAHhknue8OmQ
         Cd+s6iDuZ2qnbPBRW9fcIrpTGxeH8Lgd+RcVcXJni4gOYBXEameDMbc8vx+qFxU5pgHr
         kd+9LN97iTRIxSd/AjcEqK8R0vqIeC7NmxyDJ8J+NkGuh+Iw/kAmztjUWPY8y2eAsDDQ
         /QC2rrc0b/K/s4dBjBs2Uh1b+BYnBPG92AlmKaATLr3Jy/i77wog40XqHARWN3ezE37q
         yYkg==
X-Gm-Message-State: APjAAAX606oL5l9qBJs93hBgu+Jm4qJtee32+FqSmlvAt0wyI5FsDLrg
	RU2UBjF1opm1lw5DgVPoN+Io5WoOp/Y0+8+xV62JW19I2d5Twnik1RUBjZioCsnVyBEUc7sgKJm
	/pu8yTIlGDxIP/41zXUlLv0GxD6llQbnC3QeM30SY4V6K0vxIiBOpupErlW9OOhmqog==
X-Received: by 2002:a02:3f1d:: with SMTP id d29mr7364291jaa.116.1565136463119;
        Tue, 06 Aug 2019 17:07:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAuN+REK3Kuki3f7Tqpm+tuYqxDcOL3a5nlryu/Jhg+CaVvE8OB4KLzxDqMJcJjG73hOmz
X-Received: by 2002:a02:3f1d:: with SMTP id d29mr7364232jaa.116.1565136462381;
        Tue, 06 Aug 2019 17:07:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565136462; cv=none;
        d=google.com; s=arc-20160816;
        b=r50cq6upOcbaSSAf0Y5NLk+Iw5Lm+tt38TzPjpW0MpxmvIYLm7PpqRExMHVphKyyBe
         EQoAFQkC1CUQ0YvX2C5LsBjvCoZxHJboeC+x1nwlVkM/DvL6uFV6hMdoJoZwQ7bF1/Ox
         11xUk2Qx5dJFVkbwqd0vCdP/YUBVp8HS8xympS77UflGsQfhNPEdJQly6G0xiUk2NaRH
         lToOsYQZt1cziLZkmtQq9kyFQ7oh9W3ykh3ZBiYXUA6spNZepsUzCHEVMJaltldl5+iX
         U0B32MP0Pn7/aFVk8Lp1GFRkdWMzYYFzw8dTCKsgzgAHtrylW38G2pPgMkS1jntGuh8j
         feZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=AIsoL8wBQu2vc4iTjiuL85c4WFOrTsYj/OoeOmTUV04=;
        b=dec0PbcrY/a9UAzqT9+G3QO0VmuK8d3EYTs1My7PjTfapgJC2uB/FDVQRuOlB3dQa+
         BtdqNgNn0c21GXur9uTJRvAZjGy9zpK4j0Dm/9rsa/VXZm4a0WqXnXTDXwDg01Hjp+O1
         HmBTI8eRx0QmmwWld+/hKZCm4hImCeiluPZfzuqOmggM7Ts0+8cXJeJ8k4IXJqzbQ2W0
         Z3R0VSKTLVJOy1MuNQ9BdHytSwj6S7P59CSyr6inKjkb4rMDAHZNxlKKTdy3YfzmwLkf
         mxmnirjgcLE/+VYmaOhFnyzAZ65CpQJ3kx4cTfcKAY6u261aO4nqoGFyAUt9jRhXRAEH
         q/WQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3R53FdYb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id l2si115574069jac.58.2019.08.06.17.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 17:07:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3R53FdYb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7703ipf027165;
	Wed, 7 Aug 2019 00:07:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=AIsoL8wBQu2vc4iTjiuL85c4WFOrTsYj/OoeOmTUV04=;
 b=3R53FdYbnHq32gvkH6ecMl+MlL5GANPBFc19pvu9hyqrxYTQWCLG8jeNPjzmbRQL6g7G
 4qTGPck/phr3GDQVMyDpQTnDDB2Rm+VwoI262envxmPpzb9Q7en61rSwBB054TJWJ4+T
 KX+/iJuEr9GFF3CXyknL9YVcBFzder8rzMQhg73cTBGHqsWlZH4go6+w5AXom5KpsA78
 z5RiBP2zH0/szCYPWEw0gnTzcYLThESfeH9sBfVsZwlGSGgV6FcBHNYE60b7awBvGwaJ
 ucufm/WYbBEAXEDlWdxG9FTkOP0ntHIuVQQmY73+RoZJnNomcQwvB3RMVuB0HBQI2Lh0 FA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2u52wr94y9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Aug 2019 00:07:32 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7702gsf048603;
	Wed, 7 Aug 2019 00:07:31 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2u766716ca-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Aug 2019 00:07:31 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7707R3E003180;
	Wed, 7 Aug 2019 00:07:27 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 06 Aug 2019 17:07:26 -0700
Subject: =?UTF-8?Q?Re=3a_=5bMM_Bug=3f=5d_mmap=28=29_triggers_SIGBUS_while_do?=
 =?UTF-8?B?aW5nIHRoZeKAiyDigItudW1hX21vdmVfcGFnZXMoKSBmb3Igb2ZmbGluZWQgaHVn?=
 =?UTF-8?Q?epage_in_background?=
From: Mike Kravetz <mike.kravetz@oracle.com>
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
Message-ID: <3c104b29-ffe2-07cb-440e-cb88d8e11acb@oracle.com>
Date: Tue, 6 Aug 2019 17:07:25 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <7d78f6b9-afb8-79d1-003e-56de58fded00@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060212
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060212
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/5/19 10:36 AM, Mike Kravetz wrote:
>>>>> Can you try this patch in your environment?  I am not sure if it will
>>>>> be the final fix, but just wanted to see if it addresses issue for you.
>>>>>
>>>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>>>>> index ede7e7f5d1ab..f3156c5432e3 100644
>>>>> --- a/mm/hugetlb.c
>>>>> +++ b/mm/hugetlb.c
>>>>> @@ -3856,6 +3856,20 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>>>>>  
>>>>>  		page = alloc_huge_page(vma, haddr, 0);
>>>>>  		if (IS_ERR(page)) {
>>>>> +			/*
>>>>> +			 * We could race with page migration (try_to_unmap_one)
>>>>> +			 * which is modifying page table with lock.  However,
>>>>> +			 * we are not holding lock here.  Before returning
>>>>> +			 * error that will SIGBUS caller, get ptl and make
>>>>> +			 * sure there really is no entry.
>>>>> +			 */
>>>>> +			ptl = huge_pte_lock(h, mm, ptep);
>>>>> +			if (!huge_pte_none(huge_ptep_get(ptep))) {
>>>>> +				ret = 0;
>>>>> +				spin_unlock(ptl);
>>>>> +				goto out;
>>>>> +			}
>>>>> +			spin_unlock(ptl);
>>>>
>>>> Thanks you for investigation, Mike.
>>>> I tried this change and found no SIGBUS, so it works well.

Here is another way to address the issue.  Take the hugetlb fault mutex in
the migration code when modifying the page tables.  IIUC, the fault mutex
was introduced to prevent this same issue when there were two page faults
on the same page (and we were unable to allocate an 'extra' page).  The
downside to such an approach is that we add more hugetlbfs specific code
to try_to_unmap_one.

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index edf476c8cfb9..df0e74f9962e 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -485,6 +485,17 @@ static inline int hstate_index(struct hstate *h)
 	return h - hstates;
 }
 
+/*
+ * Convert the address within this vma to the page offset within
+ * the mapping, in pagecache page units; huge pages here.
+ */
+static inline pgoff_t vma_hugecache_offset(struct hstate *h,
+			struct vm_area_struct *vma, unsigned long address)
+{
+	return ((address - vma->vm_start) >> huge_page_shift(h)) +
+		(vma->vm_pgoff >> huge_page_order(h));
+}
+
 pgoff_t __basepage_index(struct page *page);
 
 /* Return page->index in PAGE_SIZE units */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ede7e7f5d1ab..959aed5b7969 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -615,17 +615,6 @@ static long region_count(struct resv_map *resv, long f, long t)
 	return chg;
 }
 
-/*
- * Convert the address within this vma to the page offset within
- * the mapping, in pagecache page units; huge pages here.
- */
-static pgoff_t vma_hugecache_offset(struct hstate *h,
-			struct vm_area_struct *vma, unsigned long address)
-{
-	return ((address - vma->vm_start) >> huge_page_shift(h)) +
-			(vma->vm_pgoff >> huge_page_order(h));
-}
-
 pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
 				     unsigned long address)
 {
diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..f8c95482c23e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1350,6 +1350,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	bool ret = true;
 	struct mmu_notifier_range range;
 	enum ttu_flags flags = (enum ttu_flags)arg;
+	u32 hugetlb_hash = 0;
 
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
@@ -1377,6 +1378,19 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				min(vma->vm_end, address +
 				    (PAGE_SIZE << compound_order(page))));
 	if (PageHuge(page)) {
+		struct hstate *h = hstate_vma(vma);
+
+		/*
+		 * Take the hugetlb fault mutex so that we do not race with
+		 * page faults while modifying page table.  Mutex must be
+		 * acquired before ptl below.
+		 */
+		hugetlb_hash = hugetlb_fault_mutex_hash(h,
+					vma->vm_file->f_mapping,
+					vma_hugecache_offset(h, vma, address),
+					address);
+		mutex_lock(&hugetlb_fault_mutex_table[hugetlb_hash]);
+
 		/*
 		 * If sharing is possible, start and end will be adjusted
 		 * accordingly.
@@ -1659,6 +1673,8 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	mmu_notifier_invalidate_range_end(&range);
+	if (PageHuge(page))
+		mutex_unlock(&hugetlb_fault_mutex_table[hugetlb_hash]);
 
 	return ret;
 }


Michal, Naoya any preferences on how this should be fixed?  I'll send a
proper patch if we agree on an approach.
-- 
Mike Kravetz

