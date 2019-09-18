Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.4 required=3.0 tests=BODY_QUOTE_MALF_MSGID,
	DKIMWL_WL_HIGH,DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EFE3C4CEC9
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 21:20:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C70C20640
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 21:20:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="JatzXqCM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C70C20640
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 858ED6B0301; Wed, 18 Sep 2019 17:20:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 808E16B0302; Wed, 18 Sep 2019 17:20:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F79C6B0303; Wed, 18 Sep 2019 17:20:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0085.hostedemail.com [216.40.44.85])
	by kanga.kvack.org (Postfix) with ESMTP id 518C86B0301
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 17:20:17 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C70F9181AC9AE
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:20:16 +0000 (UTC)
X-FDA: 75949309632.05.wine79_59aa3d8d4c817
X-HE-Tag: wine79_59aa3d8d4c817
X-Filterd-Recvd-Size: 5768
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:20:16 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8ILFwLj028166;
	Wed, 18 Sep 2019 21:19:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2019-08-05;
 bh=SHIr7v5/VhsvE1HrP26cNJDt2q5w3JJJSs8BfYB3edo=;
 b=JatzXqCMUzo29NRn8U2IWi1EPuA2hDrG9Gg7/law6+GgLnVQ8EMEmfUdYCPnslgld0ne
 Q8AyBxam+JFB6zwGP1GegAqW00t07Kgqgeg7KgPcph7nVeNI1eBEeN4zhsRldPOKiEQp
 XCPqvhaq/OHSclgYC/OcubVuNEamJOJscvS4dYU4vYHkgobkvZv+h3jXhHpQ5d4jtllb
 9uVaIYiMgljV8kHgyyDuMa8vUv6BlohM84NbwKm8coSmQT/w2wWhtbAHNG3rbV6vpNxW
 733vDsdS5aoXzy23h0UuQURaT6ghFI2fAwc4zzo84AwZAS3SDTYaFVHD1oQMu2lDHx0l 2g== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2v3vb4g0jv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 18 Sep 2019 21:19:58 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8ILGTPo032449;
	Wed, 18 Sep 2019 21:17:58 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2v3vbqr1be-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 18 Sep 2019 21:17:58 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x8ILHuBA006285;
	Wed, 18 Sep 2019 21:17:57 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 18 Sep 2019 14:17:56 -0700
Date: Wed, 18 Sep 2019 14:17:55 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, hch@lst.de, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH v2 2/5] mm: Add file_offset_of_ helpers
Message-ID: <20190918211755.GC2229799@magnolia>
References: <20190821003039.12555-1-willy@infradead.org>
 <20190821003039.12555-3-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821003039.12555-3-willy@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9384 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1908290000 definitions=main-1909180182
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9384 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1908290000
 definitions=main-1909180182
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 05:30:36PM -0700, Matthew Wilcox wrote:
> From: "Matthew Wilcox (Oracle)" <willy@infradead.org>
> 
> The page_offset function is badly named for people reading the functions
> which call it.  The natural meaning of a function with this name would
> be 'offset within a page', not 'page offset in bytes within a file'.
> Dave Chinner suggests file_offset_of_page() as a replacement function
> name and I'm also adding file_offset_of_next_page() as a helper for the
> large page work.  Also add kernel-doc for these functions so they show
> up in the kernel API book.
> 
> page_offset() is retained as a compatibility define for now.

No SOB?

Looks fine to me, and I appreciate the much less confusing name.  I was
hoping for a page_offset conversion for fs/iomap/ (and not a treewide
change because yuck), but I guess that can be done if and when this
lands.

--D

> ---
>  include/linux/pagemap.h | 25 ++++++++++++++++++++++---
>  1 file changed, 22 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 2728f20fbc49..84f341109710 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -436,14 +436,33 @@ static inline pgoff_t page_to_pgoff(struct page *page)
>  	return page_to_index(page);
>  }
>  
> -/*
> - * Return byte-offset into filesystem object for page.
> +/**
> + * file_offset_of_page - File offset of this page.
> + * @page: Page cache page.
> + *
> + * Context: Any context.
> + * Return: The offset of the first byte of this page.
>   */
> -static inline loff_t page_offset(struct page *page)
> +static inline loff_t file_offset_of_page(struct page *page)
>  {
>  	return ((loff_t)page->index) << PAGE_SHIFT;
>  }
>  
> +/* Legacy; please convert callers */
> +#define page_offset(page)	file_offset_of_page(page)
> +
> +/**
> + * file_offset_of_next_page - File offset of the next page.
> + * @page: Page cache page.
> + *
> + * Context: Any context.
> + * Return: The offset of the first byte after this page.
> + */
> +static inline loff_t file_offset_of_next_page(struct page *page)
> +{
> +	return ((loff_t)page->index + compound_nr(page)) << PAGE_SHIFT;
> +}
> +
>  static inline loff_t page_file_offset(struct page *page)
>  {
>  	return ((loff_t)page_index(page)) << PAGE_SHIFT;
> -- 
> 2.23.0.rc1
> 

