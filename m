Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E80EEC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 00:36:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6278D218D8
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 00:36:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="M4qJMULi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6278D218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7FF28E0003; Tue, 26 Feb 2019 19:36:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2BD08E0001; Tue, 26 Feb 2019 19:36:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A19FB8E0003; Tue, 26 Feb 2019 19:36:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 700708E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 19:36:10 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id d18so10927675ywb.2
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 16:36:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=rmm3/CCRUlU9Bp/KQmehXh2pN3XVn4/hWfL7F7CGYcg=;
        b=gjxC4DezMdaKi/jRSmjgUm+vRnYe/NKz7akXSnraivMQddGAnNNLnkAZ6bkAfHHMoQ
         j6IkpyAM251LrDvn23RDKgp8zb/XXxclDRqqW1fiecCr1a8HiL9JAVvRAuPhvz/ilxxh
         a+e35cAD824SEihhx7SxP9S2MdNUn/L4kn9XfJp2kuGM0hgoH8cbnyPAKdYrd2pQOdto
         IILiDwr7TBcPqcRZX/QCwFPMNFIVnMbfc4Ny9qd450yTH4pSZpyHWMIhzKXQPOl9pDXw
         G66HPiyGeQ72tHLU55WXHiqGmtZrNoFd9XRtnxG8oTbp+HAPgjassAui7ldHxN0chz+r
         rCkQ==
X-Gm-Message-State: AHQUAubkeOFhHqq+y19i2t2fV8ywfDIiWxAfiCGJ+hO8W/ID991EPaUT
	Ms8k2FgWeU/WunwgBZ6NhAZY8zBJ11kOHcJeZaU8WqwILoQxUVgUnEgY5Ui1YlHKicqb+kplJDP
	oYGueEQhmrE5wXWl9CPfVhE8dSQoPK3EJSHWU6AZMptA2XU27ltXpjwo7SKGnrhPN/w==
X-Received: by 2002:a25:3b8f:: with SMTP id i137mr20315211yba.386.1551227770168;
        Tue, 26 Feb 2019 16:36:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia5FMLI6l7YL7sh5Bhhp8iZIidfjBRnb7YA7jUokis1bMpe6yYEvmV0nHCXFjmFHQYd/7lv
X-Received: by 2002:a25:3b8f:: with SMTP id i137mr20315165yba.386.1551227768991;
        Tue, 26 Feb 2019 16:36:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551227768; cv=none;
        d=google.com; s=arc-20160816;
        b=QeUxaBnWNcp7DTo0g0TIbqhClyFnbIB3/jatbVDIUiXyVi58piAuKiOsvIUom5KdiQ
         DNbr69eW0WFct3XEIXZyKxChKfGb/myIgit+dMT9IiE5s68bp4Pr949TvJFjBoK0j5hR
         fRhkaS3gz+g4AlwY4I3deNqntwfBqM+mbzmO7QOQLiYy6d9qeh5DTXyIDDHf/jxC8kop
         alp4wK5WMfganTYpDDZY1FZBtmTol8v+b+aXoz7ExFU6EpSLrD3DyVpuFXDYb3u8aUcI
         ALyWDfPCjZPRjqdHFQS7HQO3IY6S5w2JM3vgspozhlh64nvKQmnBZ1rSgcD0yixkYXJT
         eSOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=rmm3/CCRUlU9Bp/KQmehXh2pN3XVn4/hWfL7F7CGYcg=;
        b=qanJdkU+rXqMUI27EgfsVJloPwa2ppHk4SmkmVBWS1124Rx32BOBfBfIGQ9fufuAsm
         pheyU/0eIAQz9gKnkB/w6pp7s00Uf26H/AuzXopB5WgYWcGff3JIyMpGPQfHnbN6MbIG
         8Q8IRYOh99uBzS8nOPf+wYIUbjPIZpVFv13NAC3b8QMdiB45WZwl1lHNttNai3Ln/pUn
         01Zap8xM5P9Ft3E/b1MvViQPi6uBztnm2ia7Spjd+WaUdSNcZ7UwF62hj7owHE+S+cgh
         HotSe4xWEzEE+mFsDwwTL1+IZG4K1T03Rd+vGFhf7JcbkoOrayQ0MYcqbBBzOlHGj5f7
         yLNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=M4qJMULi;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i123si8027150ywg.373.2019.02.26.16.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 16:36:08 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=M4qJMULi;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1R0ORnD050775;
	Wed, 27 Feb 2019 00:36:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=rmm3/CCRUlU9Bp/KQmehXh2pN3XVn4/hWfL7F7CGYcg=;
 b=M4qJMULiiPL/r3eBzb4JRGxqhme4iGkrMOMH3o9dlFpKlqtY18tjNUxj8fnTayyNnEKI
 kzhlboVFM5ArNvjUgThPtmxRjBgOy34fqGCYsRlx+ylqKnoql7UxoOWUSHiphaW0PEzl
 R3YIX78mi1A5M5aGxLC7LDBghkHxnJkGzBwaisVNF885TD3YypPGW1wrZjsKefPqbcT3
 lW5unAQVPKQOwVKu2LuVYahaDnmg60kIsUBdCYn+WAfOi/vJKIDb72c5OQH8UhDXM0+q
 sEnoqjSdTsfcCxwVJ4rA8AlyCgfPKb1wSpti7BNc+2jd0xPeUd/BqEzc36lOphCRK2G7 qg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qtupe845y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 00:36:03 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1R0a1Zt010203
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 00:36:02 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1R0a0Fb014821;
	Wed, 27 Feb 2019 00:36:00 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 26 Feb 2019 16:35:59 -0800
Subject: Re: [PATCH] huegtlbfs: fix races and page leaks during migration
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso
 <dave@stgolabs.net>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
References: <803d2349-8911-0b47-bc5b-4f2c6cc3f928@oracle.com>
 <20190212221400.3512-1-mike.kravetz@oracle.com>
 <20190220220910.265bff9a7695540ee4121b80@linux-foundation.org>
 <7534d322-d782-8ac6-1c8d-a8dc380eb3ab@oracle.com>
 <20190226074430.GA17606@hori.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <420bcfd6-158b-38e4-98da-26d0cd85bd01@oracle.com>
Date: Tue, 26 Feb 2019 16:35:55 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190226074430.GA17606@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9179 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902270001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/25/19 11:44 PM, Naoya Horiguchi wrote:
> Hi Mike,
> 
> On Thu, Feb 21, 2019 at 11:11:06AM -0800, Mike Kravetz wrote:
...
>> From: Mike Kravetz <mike.kravetz@oracle.com>
>> Date: Thu, 21 Feb 2019 11:01:04 -0800
>> Subject: [PATCH] huegtlbfs: fix races and page leaks during migration
> 
> Subject still contains a typo.

Yes

>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
> ...
>> @@ -3863,6 +3864,11 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>>  	}
>>
>>  	spin_unlock(ptl);
>> +
>> +	/* Make newly allocated pages active */
> 
> You already have a perfect explanation about why we need this "if",
> 
>   > ... We could have got the page from the pagecache, and it could
>   > be that the page is !page_huge_active() because it has been isolated for
>   > migration.
> 
> so you could improve this comment with it.

You are correct, the explanation in the commit message should be in the
comment.

> Anyway, I agree to what/how you try to fix.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thank you for reviewing!

Andrew, I am not sure if this helps but I have updated the patch and
included below.  Changes are:
- Rebased on v5.0-rc6, so some context is different.
- Fixed subject typo and improved comment as suggested by Naoya
- Reformatted a couple paragraphs in commit message that had too long lines
If you prefer something else, let me know.


From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Tue, 26 Feb 2019 14:19:36 -0800
Subject: [PATCH] hugetlbfs: fix races and page leaks during migration

hugetlb pages should only be migrated if they are 'active'.  The routines
set/clear_page_huge_active() modify the active state of hugetlb pages.
When a new hugetlb page is allocated at fault time, set_page_huge_active
is called before the page is locked.  Therefore, another thread could
race and migrate the page while it is being added to page table by the
fault code.  This race is somewhat hard to trigger, but can be seen by
strategically adding udelay to simulate worst case scheduling behavior.
Depending on 'how' the code races, various BUG()s could be triggered.

To address this issue, simply delay the set_page_huge_active call until
after the page is successfully added to the page table.

Hugetlb pages can also be leaked at migration time if the pages are
associated with a file in an explicitly mounted hugetlbfs filesystem.
For example, consider a two node system with 4GB worth of huge pages
available.  A program mmaps a 2G file in a hugetlbfs filesystem.  It
then migrates the pages associated with the file from one node to
another.  When the program exits, huge page counts are as follows:

node0
1024    free_hugepages
1024    nr_hugepages

node1
0       free_hugepages
1024    nr_hugepages

Filesystem                         Size  Used Avail Use% Mounted on
nodev                              4.0G  2.0G  2.0G  50% /var/opt/hugepool

That is as expected.  2G of huge pages are taken from the free_hugepages
counts, and 2G is the size of the file in the explicitly mounted
filesystem.  If the file is then removed, the counts become:

node0
1024    free_hugepages
1024    nr_hugepages

node1
1024    free_hugepages
1024    nr_hugepages

Filesystem                         Size  Used Avail Use% Mounted on
nodev                              4.0G  2.0G  2.0G  50% /var/opt/hugepool

Note that the filesystem still shows 2G of pages used, while there
actually are no huge pages in use.  The only way to 'fix' the
filesystem accounting is to unmount the filesystem

If a hugetlb page is associated with an explicitly mounted filesystem,
this information in contained in the page_private field.  At migration
time, this information is not preserved.  To fix, simply transfer
page_private from old to new page at migration time if necessary.

There is a related race with removing a huge page from a file and
migration.  When a huge page is removed from the pagecache, the
page_mapping() field is cleared, yet page_private remains set until the
page is actually freed by free_huge_page().  A page could be migrated
while in this state.  However, since page_mapping() is not set the
hugetlbfs specific routine to transfer page_private is not called and
we leak the page count in the filesystem.  To fix, check for this
condition before migrating a huge page.  If the condition is detected,
return EBUSY for the page.

Cc: <stable@vger.kernel.org>
Fixes: bcc54222309c ("mm: hugetlb: introduce page_huge_active")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/hugetlbfs/inode.c | 12 ++++++++++++
 mm/hugetlb.c         | 16 +++++++++++++---
 mm/migrate.c         | 11 +++++++++++
 3 files changed, 36 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 32920a10100e..a7fa037b876b 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -859,6 +859,18 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
 	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
 	if (rc != MIGRATEPAGE_SUCCESS)
 		return rc;
+
+	/*
+	 * page_private is subpool pointer in hugetlb pages.  Transfer to
+	 * new page.  PagePrivate is not associated with page_private for
+	 * hugetlb pages and can not be set here as only page_huge_active
+	 * pages can be migrated.
+	 */
+	if (page_private(page)) {
+		set_page_private(newpage, page_private(page));
+		set_page_private(page, 0);
+	}
+
 	if (mode != MIGRATE_SYNC_NO_COPY)
 		migrate_page_copy(newpage, page);
 	else
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index afef61656c1e..8dfdffc34a99 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3624,7 +3624,6 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	copy_user_huge_page(new_page, old_page, address, vma,
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
-	set_page_huge_active(new_page);
 
 	mmu_notifier_range_init(&range, mm, haddr, haddr + huge_page_size(h));
 	mmu_notifier_invalidate_range_start(&range);
@@ -3645,6 +3644,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 				make_huge_pte(vma, new_page, 1));
 		page_remove_rmap(old_page, true);
 		hugepage_add_new_anon_rmap(new_page, vma, haddr);
+		set_page_huge_active(new_page);
 		/* Make the old page be freed below */
 		new_page = old_page;
 	}
@@ -3729,6 +3729,7 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	pte_t new_pte;
 	spinlock_t *ptl;
 	unsigned long haddr = address & huge_page_mask(h);
+	bool new_page = false;
 
 	/*
 	 * Currently, we are forced to kill the process in the event the
@@ -3790,7 +3791,7 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
 		__SetPageUptodate(page);
-		set_page_huge_active(page);
+		new_page = true;
 
 		if (vma->vm_flags & VM_MAYSHARE) {
 			int err = huge_add_to_page_cache(page, mapping, idx);
@@ -3861,6 +3862,15 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	}
 
 	spin_unlock(ptl);
+
+	/*
+	 * Only make newly allocated pages active.  Existing pages found
+	 * in the pagecache could be !page_huge_active() if they have been
+	 * isolated for migration.
+	 */
+	if (new_page)
+		set_page_huge_active(page);
+
 	unlock_page(page);
 out:
 	return ret;
@@ -4095,7 +4105,6 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	 * the set_pte_at() write.
 	 */
 	__SetPageUptodate(page);
-	set_page_huge_active(page);
 
 	mapping = dst_vma->vm_file->f_mapping;
 	idx = vma_hugecache_offset(h, dst_vma, dst_addr);
@@ -4163,6 +4172,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	update_mmu_cache(dst_vma, dst_addr, dst_pte);
 
 	spin_unlock(ptl);
+	set_page_huge_active(page);
 	if (vm_shared)
 		unlock_page(page);
 	ret = 0;
diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680be3b0..181f5d2718a9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1315,6 +1315,16 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		lock_page(hpage);
 	}
 
+	/*
+	 * Check for pages which are in the process of being freed.  Without
+	 * page_mapping() set, hugetlbfs specific move page routine will not
+	 * be called and we could leak usage counts for subpools.
+	 */
+	if (page_private(hpage) && !page_mapping(hpage)) {
+		rc = -EBUSY;
+		goto out_unlock;
+	}
+
 	if (PageAnon(hpage))
 		anon_vma = page_get_anon_vma(hpage);
 
@@ -1345,6 +1355,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		put_new_page = NULL;
 	}
 
+out_unlock:
 	unlock_page(hpage);
 out:
 	if (rc != -EAGAIN)
-- 
2.17.2

