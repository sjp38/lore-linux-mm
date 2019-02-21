Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07BDCC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 19:11:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DDF72081B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 19:11:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uC4I7ZqL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DDF72081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34F968E00AE; Thu, 21 Feb 2019 14:11:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 301328E00A9; Thu, 21 Feb 2019 14:11:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F0A28E00AE; Thu, 21 Feb 2019 14:11:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B80E08E00A9
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 14:11:20 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so12007740edd.2
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 11:11:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=H16q7+up/2qKMW2YUaPJBuKfTQzRtgk0+rB55Lwq8CE=;
        b=bWG6mYV7wDR4M5WEvto0kVO3XQPsT5tiKDzekTP5KSS9lxQhkCUB/cFs04bsN2ZECG
         NwumIt92efnwrggVdaDFrcwGzEfmmd5lGI13oLP3AyA1TdJwpSKYOiRTpuKYdeFoOIKF
         s7OU4Ink8T/OHIswkBJPyWLLuuH3YdCHTR80z6dDKP8PyOcJ5UUSW+xp/p1kgBaA3unB
         SHl7uE6sRSEn2TsJXNHMlrDD11/txSFmraJfVqw61DK+O+PiWgBH4eqKO6SmymD4ErzG
         ic3Y/2aqZg092PK+ciqy8e98wjiaEcJGDCxzC5CdECaiFV+CUCd6hXPGPKNlvRJbQs2P
         Cd4A==
X-Gm-Message-State: AHQUAuZh3zG76gbROtTMG+BLBinA08xzlF154bifhHvRMBhZXHw/ZBkj
	mWnbzYi9AN+Jgk4Ngtvxppkzep60oixDGW0q/NwJmwEWiXoLA8lgX8jE9pJNzkyFLQtRQVnJuj0
	d2cO3dcu+P9Y90R3Z1eRY0O2agerPpXpocaS+v/TiZfnrud63/1JsbW+xaTotMCxD2A==
X-Received: by 2002:a17:906:b857:: with SMTP id ga23mr77226ejb.60.1550776280026;
        Thu, 21 Feb 2019 11:11:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IallTjyatmdN1k94oE7GxdLnANqwA5UJKb3OzNU2wB7ZHXilhFLvBL9o+1uweb161UArbNP
X-Received: by 2002:a17:906:b857:: with SMTP id ga23mr77146ejb.60.1550776278533;
        Thu, 21 Feb 2019 11:11:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550776278; cv=none;
        d=google.com; s=arc-20160816;
        b=Y3OG6MydsR4QiTxfB7ts3+Y76bl6gWw1dyOflPMpog8GnZp3Rg3mchGz2iIX2QpUfy
         8UPEd0GuFpb0zkrtUGQz8fLoXeGb0wqJ30zSdV68QH/kmwlbi4p+0hvA7Nm3iqwF5UI7
         5KL/NWOeOInh+45RLEduFT2QOL05N3T1YySvVm0zxaVyugEt+TuW1EIyGYNx4l0Vklvj
         RhzvXVi3bm7Es8fZnH0zgSYiKY3AslpFlxtM9v0GJpo4W0xKKOYLp46AynINggBEPfLf
         mjX1iHZ6t3GN8xL0S8pouiROuGuai+pY8WaNqstGgZ3VSE9ZYDM0VAE1VwCCekFsUpdB
         VJKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=H16q7+up/2qKMW2YUaPJBuKfTQzRtgk0+rB55Lwq8CE=;
        b=TsapUAxbe6YUED8TF6/ImmRNOdkAXU+HCVmKvPOVc9+xJ55VPUNCWvY2FZfiimqadU
         J2CWDFCScCctR2uUCHXWK+2eo1zsoVlSzI07OKd9BjFyrsrD/c04SCVDbhNLX5MynAnr
         Bn33AjfdcEFr6CyoWAwFvUc9SPMC8mcWXnPpSL/wGf1iz5yVgQ5YTMG0iTfPcRJ0DvEN
         KID1mkLKh+nA2OZFEuJPzwLWgLUZXrm06tjxsuKY/D39XyyrYWe7ps7MOoxNSkzXMD49
         +S6vBKU6azq/t9caIea41wGtMhgmhZE9IPw+v6Aowy6ERPS8KBlEuRVJ1r5SW5bTGJfO
         Ockw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uC4I7ZqL;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i18si1480572edg.44.2019.02.21.11.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 11:11:18 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=uC4I7ZqL;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1LJ3lCY041814;
	Thu, 21 Feb 2019 19:11:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=H16q7+up/2qKMW2YUaPJBuKfTQzRtgk0+rB55Lwq8CE=;
 b=uC4I7ZqLR+3LVhNEyq6IGVn01YCChMx9C2SEnBwLTRSEhw7yqbHEP+eF/L34th+YwC5j
 bWelEmpD+xQlya27Q7eHA3+x8L3TbghAXEK5sokQ1UMwYEE04yhc4KKO/I96y2f3vJZE
 8MdmAHXrx061v8Y5/67mflwxG04J+4LDj5A0g2bFdej9hgV5nBeEDuCwjOp6R4abqxfV
 QxNFbADSOrCD0Zz/NwkUUkkm0PzF2MppDH0EOElsj2sXqfSZbE3W+vb4IhslHKKofqeU
 6YFKLPdM/mubvSykPIIDF4HD7zU87VEeBQgYM4CUXsX8gw+hTDKAqgVb+CWxDIYuZ52V fQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2qpb5rt219-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Feb 2019 19:11:12 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1LJBBkL021930
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Feb 2019 19:11:11 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1LJBAYE018966;
	Thu, 21 Feb 2019 19:11:10 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 21 Feb 2019 11:11:10 -0800
Subject: Re: [PATCH] huegtlbfs: fix races and page leaks during migration
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Michal Hocko <mhocko@kernel.org>,
        Naoya Horiguchi
 <n-horiguchi@ah.jp.nec.com>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso
 <dave@stgolabs.net>, stable@vger.kernel.org
References: <803d2349-8911-0b47-bc5b-4f2c6cc3f928@oracle.com>
 <20190212221400.3512-1-mike.kravetz@oracle.com>
 <20190220220910.265bff9a7695540ee4121b80@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <7534d322-d782-8ac6-1c8d-a8dc380eb3ab@oracle.com>
Date: Thu, 21 Feb 2019 11:11:06 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190220220910.265bff9a7695540ee4121b80@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9174 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902210132
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/20/19 10:09 PM, Andrew Morton wrote:
> On Tue, 12 Feb 2019 14:14:00 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
> cc:stable.  It would be nice to get some review of this one, please?
> 
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index a80832487981..f859e319e3eb 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -3625,7 +3625,6 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>>  	copy_user_huge_page(new_page, old_page, address, vma,
>>  			    pages_per_huge_page(h));
>>  	__SetPageUptodate(new_page);
>> -	set_page_huge_active(new_page);
>>  
>>  	mmun_start = haddr;
>>  	mmun_end = mmun_start + huge_page_size(h);
>> @@ -3647,6 +3646,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>>  				make_huge_pte(vma, new_page, 1));
>>  		page_remove_rmap(old_page, true);
>>  		hugepage_add_new_anon_rmap(new_page, vma, haddr);
>> +		set_page_huge_active(new_page);
>>  		/* Make the old page be freed below */
>>  		new_page = old_page;
>>  	}
>> @@ -3792,7 +3792,6 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>>  		}
>>  		clear_huge_page(page, address, pages_per_huge_page(h));
>>  		__SetPageUptodate(page);
>> -		set_page_huge_active(page);
>>  
>>  		if (vma->vm_flags & VM_MAYSHARE) {
>>  			int err = huge_add_to_page_cache(page, mapping, idx);
>> @@ -3863,6 +3862,10 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
>>  	}
>>  
>>  	spin_unlock(ptl);
>> +
>> +	/* May already be set if not newly allocated page */
>> +	set_page_huge_active(page);
>> +

This is wrong.  We need to only set_page_huge_active() for newly allocated
pages.  Why?  We could have got the page from the pagecache, and it could
be that the page is !page_huge_active() because it has been isolated for
migration.  Therefore, we do not want to set it active here.

I have also found another race with migration when removing a page from
a file.  When a huge page is removed from the pagecache, the page_mapping()
field is cleared yet page_private continues to point to the subpool until
the page is actually freed by free_huge_page().  free_huge_page is what
adjusts the counts for the subpool.  A page could be migrated while in this
state.  However, since page_mapping() is not set the hugetlbfs specific
routine to transfer page_private is not called and we leak the page count
in the filesystem.  To fix, check for this condition before migrating a huge
page.  If the condition is detected, return EBUSY for the page.

Both issues are addressed in the updated patch below.

Sorry for the churn.  As I find and fix one issue I seem to discover another.
There is still at least one more issue with private pages when COW comes into
play.  I continue to work that.  I wanted to send this patch earlier as it
is pretty easy to hit the bugs if you try.  If you would prefer another
approach, let me know.

From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Thu, 21 Feb 2019 11:01:04 -0800
Subject: [PATCH] huegtlbfs: fix races and page leaks during migration

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
counts, and 2G is the size of the file in the explicitly mounted filesystem.
If the file is then removed, the counts become:

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

There is a related race with removing a huge page from a file migration.
When a huge page is removed from the pagecache, the page_mapping() field
is cleared yet page_private remains set until the page is actually freed
by free_huge_page().  A page could be migrated while in this state.
However, since page_mapping() is not set the hugetlbfs specific routine
to transfer page_private is not called and we leak the page count in the
filesystem.  To fix, check for this condition before migrating a huge
page.  If the condition is detected, return EBUSY for the page.

Cc: <stable@vger.kernel.org>
Fixes: bcc54222309c ("mm: hugetlb: introduce page_huge_active")
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 fs/hugetlbfs/inode.c | 12 ++++++++++++
 mm/hugetlb.c         | 12 +++++++++---
 mm/migrate.c         | 11 +++++++++++
 3 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 32920a10100e..a7fa037b876b 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -859,6 +859,18 @@ static int hugetlbfs_migrate_page(struct address_space
*mapping,
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
index a80832487981..e9c92e925b7e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3625,7 +3625,6 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct
vm_area_struct *vma,
 	copy_user_huge_page(new_page, old_page, address, vma,
 			    pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
-	set_page_huge_active(new_page);

 	mmun_start = haddr;
 	mmun_end = mmun_start + huge_page_size(h);
@@ -3647,6 +3646,7 @@ static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct
vm_area_struct *vma,
 				make_huge_pte(vma, new_page, 1));
 		page_remove_rmap(old_page, true);
 		hugepage_add_new_anon_rmap(new_page, vma, haddr);
+		set_page_huge_active(new_page);
 		/* Make the old page be freed below */
 		new_page = old_page;
 	}
@@ -3731,6 +3731,7 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	pte_t new_pte;
 	spinlock_t *ptl;
 	unsigned long haddr = address & huge_page_mask(h);
+	bool new_page = false;

 	/*
 	 * Currently, we are forced to kill the process in the event the
@@ -3792,7 +3793,7 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
 		__SetPageUptodate(page);
-		set_page_huge_active(page);
+		new_page = true;

 		if (vma->vm_flags & VM_MAYSHARE) {
 			int err = huge_add_to_page_cache(page, mapping, idx);
@@ -3863,6 +3864,11 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 	}

 	spin_unlock(ptl);
+
+	/* Make newly allocated pages active */
+	if (new_page)
+		set_page_huge_active(page);
+
 	unlock_page(page);
 out:
 	return ret;
@@ -4097,7 +4103,6 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	 * the set_pte_at() write.
 	 */
 	__SetPageUptodate(page);
-	set_page_huge_active(page);

 	mapping = dst_vma->vm_file->f_mapping;
 	idx = vma_hugecache_offset(h, dst_vma, dst_addr);
@@ -4165,6 +4170,7 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
 	update_mmu_cache(dst_vma, dst_addr, dst_pte);

 	spin_unlock(ptl);
+	set_page_huge_active(page);
 	if (vm_shared)
 		unlock_page(page);
 	ret = 0;
diff --git a/mm/migrate.c b/mm/migrate.c
index f7e4bfdc13b7..23d91146052b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1290,6 +1290,16 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
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

@@ -1320,6 +1330,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 		put_new_page = NULL;
 	}

+out_unlock:
 	unlock_page(hpage);
 out:
 	if (rc != -EAGAIN)
-- 
2.17.2

