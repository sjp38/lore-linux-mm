Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27D2FC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 21:26:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE46822DBF
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 21:26:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="IRDB3EtH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE46822DBF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B80F6B0005; Tue,  3 Sep 2019 17:26:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1697B6B0006; Tue,  3 Sep 2019 17:26:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 056986B0007; Tue,  3 Sep 2019 17:26:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id D234E6B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 17:26:17 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 7DC4F181AC9B6
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 21:26:17 +0000 (UTC)
X-FDA: 75894892794.24.plate29_8e2e370f07334
X-HE-Tag: plate29_8e2e370f07334
X-Filterd-Recvd-Size: 6000
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 21:26:16 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x83LOAgJ108721;
	Tue, 3 Sep 2019 21:26:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=ZUSxy8swbo3YjFG5hrbyxkGQ0Fy8sGlGHn7XZkge1C8=;
 b=IRDB3EtHGCia/DW9zISe2m6ai47HEU5dvpdOBkPBTjSbtL+52mlwbDOBZPT/cQqyECRa
 W5I1tHvm9IAiWp107YTWJ8HcM+VHnr7MhqKnNWyq0dOMsqVl33+sfOHAVAuNqRsz/T3N
 yRi/p0umoPg77lYomERQgsJ7wZLSDqCLpr6/2XAyHZKY+yQF+SaPnXsyr6i0Uk/kKSsZ
 iIygeB+yPtDmG7S6D/yBh713e+rdOMKy8n6SJ0DkpmW+/V6Ud6DZnYDJeKXfcKaaIMMT
 2ea8uEIB4u7qZOTcEKojXu/vERg6+Rhjmpez0xza4V+0fA8Sh1lDRYXd68r0pQH5VKKd Yw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2usyy9r114-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 03 Sep 2019 21:26:12 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x83LNoLh142829;
	Tue, 3 Sep 2019 21:26:11 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2us5phbbrb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 03 Sep 2019 21:26:11 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x83LQ9PT028518;
	Tue, 3 Sep 2019 21:26:09 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 03 Sep 2019 14:26:09 -0700
Subject: Re: [PATCH v2] mm/hugetlb: avoid looping to the same hugepage if
 !pages and !vmas
To: Zhigang Lu <totty.lu@gmail.com>, luzhigang001@gmail.com,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zhigang Lu <tonnylu@tencent.com>
References: <1567086657-22528-1-git-send-email-totty.lu@gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <1f0e6e1a-c947-f389-801e-b1d748cb5bce@oracle.com>
Date: Tue, 3 Sep 2019 14:26:08 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <1567086657-22528-1-git-send-email-totty.lu@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9369 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1909030214
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9369 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1909030214
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/29/19 6:50 AM, Zhigang Lu wrote:
> From: Zhigang Lu <tonnylu@tencent.com>
> 
> When mmapping an existing hugetlbfs file with MAP_POPULATE, we find
> it is very time consuming. For example, mmapping a 128GB file takes
> about 50 milliseconds. Sampling with perfevent shows it spends 99%
> time in the same_page loop in follow_hugetlb_page().
> 
> samples: 205  of event 'cycles', Event count (approx.): 136686374
> -  99.04%  test_mmap_huget  [kernel.kallsyms]  [k] follow_hugetlb_page
>         follow_hugetlb_page
>         __get_user_pages
>         __mlock_vma_pages_range
>         __mm_populate
>         vm_mmap_pgoff
>         sys_mmap_pgoff
>         sys_mmap
>         system_call_fastpath
>         __mmap64
> 
> follow_hugetlb_page() is called with pages=NULL and vmas=NULL, so for
> each hugepage, we run into the same_page loop for pages_per_huge_page()
> times, but doing nothing. With this change, it takes less then 1
> millisecond to mmap a 128GB file in hugetlbfs.

Thanks for the analysis!

Just curious, do you have an application that does this (mmap(MAP_POPULATE)
for an existing hugetlbfs file), or was this part of some test suite or
debug code?

> Signed-off-by: Zhigang Lu <tonnylu@tencent.com>
> Reviewed-by: Haozhong Zhang <hzhongzhang@tencent.com>
> Reviewed-by: Zongming Zhang <knightzhang@tencent.com>
> Acked-by: Matthew Wilcox <willy@infradead.org>
> ---
>  mm/hugetlb.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6d7296d..2df941a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4391,6 +4391,17 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  				break;
>  			}
>  		}

It might be helpful to add a comment here to help readers of the code.
Something like:

		/*
		 * If subpage information not requested, update counters
		 * and skip the same_page loop below.
		 */
> +
> +		if (!pages && !vmas && !pfn_offset &&
> +		    (vaddr + huge_page_size(h) < vma->vm_end) &&
> +		    (remainder >= pages_per_huge_page(h))) {
> +			vaddr += huge_page_size(h);
> +			remainder -= pages_per_huge_page(h);
> +			i += pages_per_huge_page(h);
> +			spin_unlock(ptl);
> +			continue;
> +		}
> +
>  same_page:
>  		if (pages) {
>  			pages[i] = mem_map_offset(page, pfn_offset);
> 

With a comment added to the code,
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

