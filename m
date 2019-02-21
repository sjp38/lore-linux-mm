Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 325D4C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 22:12:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7CEB20818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 22:12:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="bg01VyIz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7CEB20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A3678E00B8; Thu, 21 Feb 2019 17:12:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 252338E00B5; Thu, 21 Feb 2019 17:12:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F3528E00B8; Thu, 21 Feb 2019 17:12:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC0078E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 17:12:27 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id b10so138738pla.14
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 14:12:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=HCmVZI+GR5G5wAqDTWNvr8+k7CGJy/LU6FuN0FrxADg=;
        b=SFFQ7ARMABOMFYxrNbepkvPFh0wJOwzwypJt0f3JWN8znBxc25HlV/zUJQTFHpquOS
         fn6wejmiNTVsKrvtpAmns3xPMJIuveG7w1vjGM/Bh5xwuynaFxNmd5rxLhKkYnP4t9w9
         ys0GrK5jh1UN446yS3Ll5f6mn8L5b5Pardf222GGHOjsgLZdi87fgC+I5TU9YeUAanqB
         uwjh0KZJxazn6aYQEyBL6VswTUsCq0cgHcRvI9zGLXP2q9gLMnTStv2SGF1z6o59V7+N
         Q4X97jnmXwP2h9fYtbt9IP0u0g8nXz926ey2ZWFx/zm2rZyeZPKr3NPzSaCbsGZQ2eCX
         OHIQ==
X-Gm-Message-State: AHQUAuZs0NhbtC/t/KRGo0SGqX2Vwn062icAFb3Utd1e8a+dJt2HSiOJ
	AwY3dByACQur5kepRpj5LuIu6lRfJCz1St54dt8ku7W2OrsY9m21/HtZ4lenZgta5nSJWSZx6gI
	pt9lbLlVjVstWGcPYuOITiKeHbanFz0tiHkKCX/RHZAza7RR0eFLvo2HQk84MGt5QJA==
X-Received: by 2002:a62:18d8:: with SMTP id 207mr767566pfy.57.1550787147185;
        Thu, 21 Feb 2019 14:12:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYC/z0TjPh8bch5/MDXjk2WyDHZE4/2VRX9hMDEbzf+MyUwhF1n4f2A7ZvkwpiyNfCcMCik
X-Received: by 2002:a62:18d8:: with SMTP id 207mr767488pfy.57.1550787146063;
        Thu, 21 Feb 2019 14:12:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550787146; cv=none;
        d=google.com; s=arc-20160816;
        b=0F/NohcPdAk+5lSzuVMfPCLQ92U/1mC31Dn1bVAjJrEuPeJjhR9RMyR5Wb8FUa7Yzs
         hUrf5RN4n3EHvC6LepaZEODjcZBkdj0E6p9o3IfQw45OBi/Uoy+FQgKgxtIER6Zkz1yB
         GxEnLAQj+u7KR+XxlB805NPueXdTeUN9QtIXvHNoazRUbTTQqPS3BMvqdjDpXe9P4iRa
         6DAVvNXG5hh2mEZKRcFv0q4Q6WNTBRkvHxTulL5n3qzFft8EbYXdQNHCqFr5bnGKBj12
         OeX55AO8NB6iwBGSAmPDWxM+42Vn5T1DSrF6laq4WaEdBuO4sNrbt/C+bKL1npOdfw6O
         lmdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=HCmVZI+GR5G5wAqDTWNvr8+k7CGJy/LU6FuN0FrxADg=;
        b=Dv51nXDF+HkysWJtzC2CFdlKMcgOHSkEAOwvHpK9Esi/hwec6DHw9A/oLMj0RZOT7+
         T3hOfVBNs+sVxWolgeBw//qx203jnu+et/j9JiM4nZgPyS4SYmeDEZBjrhUVHNibDgga
         0gVNi8oObrczVBzrZ4ZJ3k/8F2sJ2rR9qN620KsaxMmEOkS8JB6BjHRCx4FuyNjeqoMu
         +TqJP/nOTjFWGg7XW7Gr/Mh6GNu+0BzMCjt+PXK15NrvWivdSX1YKjF3aBkTa7thJqzA
         i8+Pg36IQqBXbT0/bGdLrOvxVtd4qVXNXKWCBD7hh984Ca/kQcGVffyx8SoFr0GnLxwC
         mVvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bg01VyIz;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h1si63250pgv.0.2019.02.21.14.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 14:12:26 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bg01VyIz;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1LM9IlJ011007;
	Thu, 21 Feb 2019 22:12:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=HCmVZI+GR5G5wAqDTWNvr8+k7CGJy/LU6FuN0FrxADg=;
 b=bg01VyIzPI9uMfUxADlWLQE+6Wtng8Zr/CAYK93/dU1v1kNnFsQgHD01/dp8tZv9DcQJ
 2Fyak9kZor0m5gVCvEHUOEQL3CfPVEw8kDucJgmiVexDaHCPmygtn5JWyhHFu4Vfipt3
 O7Cl9AxcvOTaPBZZ6vpYX7t/fqguP+xCAtsSrF+/Jpf6fP2lH8aBMoPfZNCbu2CMFDVZ
 3PW6KGKNAQMb9fn0hHQMFctpqraREVUzOAcoHeX1SfXFLiZfONkA6s4Uu/4Y0qTe33QB
 XGO32zuBnoxcKQB52ixuNsO1ShRxqEWfNukalAKwvSVFmIuVg+h9s+XjDFD2eakCsVQf Ig== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2qp81ekap5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Feb 2019 22:12:24 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1LMCOSE021975
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 21 Feb 2019 22:12:24 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1LMCNAU029038;
	Thu, 21 Feb 2019 22:12:23 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 21 Feb 2019 14:12:23 -0800
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
To: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mhocko@suse.com, david@redhat.com
References: <20190221094212.16906-1-osalvador@suse.de>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c4fc87f2-9ff8-3bc1-e990-da97c56ba18f@oracle.com>
Date: Thu, 21 Feb 2019 14:12:19 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190221094212.16906-1-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9174 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902210151
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/21/19 1:42 AM, Oscar Salvador wrote:
> On x86_64, 1GB-hugetlb pages could never be offlined due to the fact
> that hugepage_migration_supported() returned false for PUD_SHIFT.
> So whenever we wanted to offline a memblock containing a gigantic
> hugetlb page, we never got beyond has_unmovable_pages() check.
> This changed with [1], where now we also return true for PUD_SHIFT.
> 
> After that patch, the check in has_unmovable_pages() and scan_movable_pages()
> returned true, but we still had a final barrier in do_migrate_range():
> 
> if (compound_order(head) > PFN_SECTION_SHIFT) {
> 	ret = -EBUSY;
> 	break;
> }
> 
> This is not really nice, and we do not really need it.
> It is perfectly possible to migrate a gigantic page as long as another node has
> a spare gigantic page for us.
> In alloc_huge_page_nodemask(), we calculate the __real__ number of free pages,
> and if any, we try to dequeue one from another node.
> 
> This all works fine when we do have another node with a spare gigantic page,
> but if that is not the case, alloc_huge_page_nodemask() ends up calling
> alloc_migrate_huge_page() which bails out if the wanted page is gigantic.
> That is mainly because finding a 1GB (or even 16GB on powerpc) contiguous
> memory is quite unlikely when the system has been running for a while.

I suspect the reason for the check is that it was there before the ability
to migrate gigantic pages was added, and nobody thought to remove it.  As
you say, the likelihood of finding a gigantic page after running for some
time is not too good.  I wonder if we should remove that check?  Just trying
to create a gigantic page could result in a bunch of migrations which could
impact the system.  But, this is the result of a memory offline operation
which one would expect to have some negative impact.

> In that situation, we will keep looping forever because scan_movable_pages()
> will give us the same page and we will fail again because there is no node
> where we can dequeue a gigantic page from.
> This is not nice, and I wish we could differentiate a fatal error from a
> transient error in do_migrate_range()->migrate_pages(), but I do not really
> see a way now.

Michal may have some thoughts here.  Note that the repeat loop does not
even consider the return value from do_migrate_range().  Since this the the
result of an offline, I am thinking it was designed to retry forever.  But,
perhaps there are some errors/ret codes where we should give up?

> Anyway, I would tend say that this is the administrator's job, to make sure
> that the system can keep up with the memory to be offlined, so that would mean
> that if we want to use gigantic pages, make sure that the other nodes have at
> least enough gigantic pages to keep up in case we need to offline memory.
> 
> Just for the sake of completeness, this is one of the tests done:
> 
>  # echo 1 > /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
>  # echo 1 > /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/nr_hugepages
> 
>  # cat /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages
>    1
>  # cat /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/free_hugepages
>    1
> 
>  # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/nr_hugepages
>    1
>  # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/free_hugepages
>    1
> 
>  (hugetlb1gb is a program that maps 1GB region using MAP_HUGE_1GB)
> 
>  # numactl -m 1 ./hugetlb1gb
>  # cat /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/free_hugepages
>    0
>  # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/free_hugepages
>    1
> 
>  # offline node1 memory
>  # cat /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/free_hugepages
>    0
> 
> [1] https://lore.kernel.org/patchwork/patch/998796/
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/memory_hotplug.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d5f7afda67db..04f6695b648c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1337,8 +1337,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  		if (!PageHuge(page))
>  			continue;
>  		head = compound_head(page);
> -		if (hugepage_migration_supported(page_hstate(head)) &&
> -		    page_huge_active(head))
> +		if (page_huge_active(head))

I'm confused as to why the removal of the hugepage_migration_supported()
check is required.  Seems that commit aa9d95fa40a2 ("mm/hugetlb: enable
arch specific huge page size support for migration") should make the check
work as desired for all architectures.
-- 
Mike Kravetz

