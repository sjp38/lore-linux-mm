Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AAF3C49ED6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 03:27:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B72821479
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 03:27:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="a1wj+/qh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B72821479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2C066B0003; Wed, 11 Sep 2019 23:27:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADCA76B0005; Wed, 11 Sep 2019 23:27:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F2D56B0006; Wed, 11 Sep 2019 23:27:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id 7F28E6B0003
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 23:27:12 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 22D2A181AC9B4
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:27:12 +0000 (UTC)
X-FDA: 75924832704.16.yard58_790594c7f4d09
X-HE-Tag: yard58_790594c7f4d09
X-Filterd-Recvd-Size: 7109
Received: from userp2120.oracle.com (userp2120.oracle.com [156.151.31.85])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:27:11 +0000 (UTC)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8C3J1jA022705;
	Thu, 12 Sep 2019 03:27:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=QMDVUMqM06gwphXTaV7TFmdRzQlEQLTUvxgkvqTtVII=;
 b=a1wj+/qh5U15xvuEwNMrHT1AcL7PNDQbYMREoBhGEqzrBxvS4frsC+1J5HDTSwPU0g5V
 zywOvBKcUWmURxcuz5jBa1Gz4aFH2nXk5cMuKMbpTf/2y0GKBiJ2XrLAMLVTX0drACcT
 OxsYpd56Zg0vEkLn/JXoaMTi5KaLYrZ8hSrKtwbDdhAuURPuguUnMe70wkDm/Z5tcb8m
 RxPQ6rdijFqZF7xZoBS5KudNpzoY6CxI5nGgapsUoHewQBvQWjy3ZaZr17aa/Y2NPucN
 Wh1tR6tfvSovSYg0pF28+JFWHEcaLj0SoODZCsnHjUTCup6BxZ67/1VdCh36lO2dtTgm 9g== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2uw1jknpma-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 12 Sep 2019 03:27:01 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8C3Naoi038691;
	Thu, 12 Sep 2019 03:27:01 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2uy8w99ejc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 12 Sep 2019 03:27:01 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x8C3Qr3k002750;
	Thu, 12 Sep 2019 03:26:53 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 11 Sep 2019 20:26:53 -0700
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
To: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ae7edcb8-74e5-037c-17e7-01b3cf9320af@oracle.com>
Date: Wed, 11 Sep 2019 20:26:52 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190911150537.19527-6-longman@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9377 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1909120031
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9377 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1909120031
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/11/19 8:05 AM, Waiman Long wrote:
> When allocating a large amount of static hugepages (~500-1500GB) on a
> system with large number of CPUs (4, 8 or even 16 sockets), performance
> degradation (random multi-second delays) was observed when thousands
> of processes are trying to fault in the data into the huge pages. The
> likelihood of the delay increases with the number of sockets and hence
> the CPUs a system has.  This only happens in the initial setup phase
> and will be gone after all the necessary data are faulted in.
> 
> These random delays, however, are deemed unacceptable. The cause of
> that delay is the long wait time in acquiring the mmap_sem when trying
> to share the huge PMDs.
> 
> To remove the unacceptable delays, we have to limit the amount of wait
> time on the mmap_sem. So the new down_write_timedlock() function is
> used to acquire the write lock on the mmap_sem with a timeout value of
> 10ms which should not cause a perceivable delay. If timeout happens,
> the task will abandon its effort to share the PMD and allocate its own
> copy instead.
> 
<snip>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6d7296dd11b8..445af661ae29 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4750,6 +4750,8 @@ void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
>  	}
>  }
>  
> +#define PMD_SHARE_DISABLE_THRESHOLD	(1 << 8)
> +
>  /*
>   * Search for a shareable pmd page for hugetlb. In any case calls pmd_alloc()
>   * and returns the corresponding pte. While this is not necessary for the
> @@ -4770,11 +4772,24 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  	pte_t *spte = NULL;
>  	pte_t *pte;
>  	spinlock_t *ptl;
> +	static atomic_t timeout_cnt;
>  
> -	if (!vma_shareable(vma, addr))
> -		return (pte_t *)pmd_alloc(mm, pud, addr);
> +	/*
> +	 * Don't share if it is not sharable or locking attempt timed out
> +	 * after 10ms. After 256 timeouts, PMD sharing will be permanently
> +	 * disabled as it is just too slow.
> +	 */
> +	if (!vma_shareable(vma, addr) ||
> +	   (atomic_read(&timeout_cnt) >= PMD_SHARE_DISABLE_THRESHOLD))
> +		goto out_no_share;
> +
> +	if (!i_mmap_timedlock_write(mapping, ms_to_ktime(10))) {
> +		if (atomic_inc_return(&timeout_cnt) ==
> +		    PMD_SHARE_DISABLE_THRESHOLD)
> +			pr_info("Hugetlbfs PMD sharing disabled because of timeouts!\n");
> +		goto out_no_share;
> +	}
>  
> -	i_mmap_lock_write(mapping);

All this got me wondering if we really need to take i_mmap_rwsem in write
mode here.  We are not changing the tree, only traversing it looking for
a suitable vma.

Unless I am missing something, the hugetlb code only ever takes the semaphore
in write mode; never read.  Could this have been the result of changing the
tree semaphore to read/write?  Instead of analyzing all the code, the easiest
and safest thing would have been to take all accesses in write mode.

I can investigate more, but wanted to ask the question in case someone already
knows.

At one time, I thought it was safe to acquire the semaphore in read mode for
huge_pmd_share, but write mode for huge_pmd_unshare.  See commit b43a99900559.
This was reverted along with another patch for other reasons.

If we change change from write to read mode, this may have significant impact
on the stalls.
-- 
Mike Kravetz

