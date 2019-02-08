Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B779EC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:50:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 645E721916
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 05:50:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="YBjgxW62"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 645E721916
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D85568E007C; Fri,  8 Feb 2019 00:50:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5A878E0079; Fri,  8 Feb 2019 00:50:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C24408E007C; Fri,  8 Feb 2019 00:50:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2078E0079
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 00:50:43 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id m200so1485459ybm.9
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 21:50:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ApExCUUIiNh51VY6PoBf3NHlLOlNUh1N7RqcvsWcFbk=;
        b=UwKfCCfSjSIVl+9ftZSDZecqb1BGHTl1ayMI5Q5g7z3dQB77ZRixDFgp9VMWU8QJGi
         3LynkN+s8nGfPsSgCt5QlNqgA3/7KU3MRg6dPQ76UhK1ZCUbkJDd9Avak8pPy+TGBtbo
         zy2BfCLL9u8rxnhQOjZ1YcLR/9ABxY+EqZTRv5STM65K/eUHnqhou75vojvFPg9H+Ae6
         MTS9iPAio3cHU5YGspzyTSgBUQ7BcWB4PgAm4QyhMa7xB9+y5lmzYTBOfluOn7JylO5s
         IugC6+w+OKtnfPy04gIRTXqVL2flCJAQTOVBYzd6CzP6tQy6xvZ1Ecgt5z9Q+VlFtfyo
         PQgA==
X-Gm-Message-State: AHQUAuacKgkRYwGpWN8WadaLXz8U/YaC9trbVCG8082iN4qanSCNf1G9
	HCbIecnnsY1rIkZ3hRlcByaSxxhYEGw44bQ8U8ry4ODMjyLR2+/LBEoy/QU+9dDRDbM32ewH7N2
	Zw4B1SmrvQb1rCqiefcxmvR9M5Qs6sNdtkAuMH7HQGO2LPYrrXi7w6ouK/z/YXjDxJw==
X-Received: by 2002:a25:9c42:: with SMTP id x2mr15540577ybo.199.1549605043210;
        Thu, 07 Feb 2019 21:50:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaGzCLIoprYwqqQF2QQIOVJimXjuSBs/74y/e2YP4ro81I3197Zov1MKQ+KFFfx69lZYSLu
X-Received: by 2002:a25:9c42:: with SMTP id x2mr15540556ybo.199.1549605042536;
        Thu, 07 Feb 2019 21:50:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549605042; cv=none;
        d=google.com; s=arc-20160816;
        b=CzXzDtutcsrzJfOb/8MAxuDYptZX0neoOwJdkqkTHzu5uh3UdlzAo047yqJJbGpXI/
         7qQ5YscyI7+F3fsOBc9fWd4Cl3vIKouvIjyZJTwavP30pwyQnW5z6iRsPk6sV/aWLWjW
         daAlkCqHMKiQLs+rAf4h591PjTXMGZtHjIRGRhlC9IM5vL1W/ufvR2JjaC+NJ8Uhwmrr
         Sxg1H7qFjU0h99MMKHlQTUu2pMBHZJHFbxddQq/u3n2dNHyGaSDLNxP1PnJ+JZpO/izd
         TxmUIBjLLPi/ll9cFFC+HyjSGr68q/u046a824H32+dIyAv5OXd9Ox1yPfZvbEDRu5kK
         vC/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=ApExCUUIiNh51VY6PoBf3NHlLOlNUh1N7RqcvsWcFbk=;
        b=WjeN/w+4udGd8DaqFTdUzXzwqhQ8K9lNdXoi8+p4E4kkWMzc5yUPW22UlND9LA1fXH
         G2LLc0qFWAS+2DS7kQ/ImRx/KLKcoLlFQu5rmsc/EgjpfkQkISfk8j7HYB9FzY6V87ai
         +n5zZl1zBvvF9ehg9WWx0xHTRudZFAPAFEAUJJTKBvMve9hqo6O3xMrp8AR0lsQ+aAW8
         Lv23X6yZ9FkygnBOOdZ6lTfKXxXlkI/Hl3NT+V+Lf7XUwib/L1GxpCTNQTYx6j1ai0Gp
         pCPo51mfaHpW/BxK46Zg+LUyA9G190viw/o3sPxgpCGMB+maSjmGPs40Sq76sqe/CM1h
         G0dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=YBjgxW62;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id w205si704846ybw.161.2019.02.07.21.50.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 21:50:42 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=YBjgxW62;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x185nAq6118609;
	Fri, 8 Feb 2019 05:50:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=ApExCUUIiNh51VY6PoBf3NHlLOlNUh1N7RqcvsWcFbk=;
 b=YBjgxW62E1LrbKUPvy1QrolD3UxbeeTfpDkTPjb13UTXSDQ2dhBF6+2IO3hK6CyvggeP
 n3uhkGE3YzbZ1SqCGv5W91hn/UP+5Dux9rBBPJZDiq/ZL5IaamHQOC8HhS6dGMIk1QpJ
 ihRUCijZUYgw3+AEG0WpWkww/LycKsgWrC3gDd1GaQoQu+NfXfat0R4uKhtWL7LgJxL/
 Lq1M+lk4tdB9ApkNsiyiOmT9VteQOJ2ACYv44u5ptzAIL9Qq5hVI44v/ZPxHaNsgNMBg
 fkehmdSBh/OSqKbZb8nsas1Sc4BK5NTWDtHeNclncswPGRc3+FHuRPWcbc0daL3CB76l UQ== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2qd97far4w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 08 Feb 2019 05:50:37 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x185oZBj023044
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 8 Feb 2019 05:50:35 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x185oYY6010905;
	Fri, 8 Feb 2019 05:50:34 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 07 Feb 2019 21:50:33 -0800
Subject: Re: [PATCH] huegtlbfs: fix page leak during migration of file pages
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Davidlohr Bueso
 <dave@stgolabs.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
References: <20190130211443.16678-1-mike.kravetz@oracle.com>
 <917e7673-051b-e475-8711-ed012cff4c44@oracle.com>
 <20190208023132.GA25778@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <07ce373a-d9ea-f3d3-35cc-5bc181901caf@oracle.com>
Date: Thu, 7 Feb 2019 21:50:30 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190208023132.GA25778@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9160 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902080043
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/7/19 6:31 PM, Naoya Horiguchi wrote:
> On Thu, Feb 07, 2019 at 10:50:55AM -0800, Mike Kravetz wrote:
>> On 1/30/19 1:14 PM, Mike Kravetz wrote:
>>> +++ b/fs/hugetlbfs/inode.c
>>> @@ -859,6 +859,16 @@ static int hugetlbfs_migrate_page(struct address_space *mapping,
>>>  	rc = migrate_huge_page_move_mapping(mapping, newpage, page);
>>>  	if (rc != MIGRATEPAGE_SUCCESS)
>>>  		return rc;
>>> +
>>> +	/*
>>> +	 * page_private is subpool pointer in hugetlb pages, transfer
>>> +	 * if needed.
>>> +	 */
>>> +	if (page_private(page) && !page_private(newpage)) {
>>> +		set_page_private(newpage, page_private(page));
>>> +		set_page_private(page, 0);
> 
> You don't have to copy PagePrivate flag?
> 

Well my original thought was no.  For hugetlb pages, PagePrivate is not
associated with page_private.  It indicates a reservation was consumed.
It is set  when a hugetlb page is newly allocated and the allocation is
associated with a reservation and the global reservation count is
decremented.  When the page is added to the page cache or rmap,
PagePrivate is cleared.  If the page is free'ed before being added to page
cache or rmap, PagePrivate tells free_huge_page to restore (increment) the
reserve count as we did not 'instantiate' the page.

So, PagePrivate is only set from the time a huge page is allocated until
it is added to page cache or rmap.  My original thought was that the page
could not be migrated during this time.  However, I am not sure if that
reasoning is correct.  The page is not locked, so it would appear that it
could be migrated?  But, if it can be migrated at this time then perhaps
there are bigger issues for the (hugetlb) page fault code?

>>> +
>>> +	}
>>> +
>>>  	if (mode != MIGRATE_SYNC_NO_COPY)
>>>  		migrate_page_copy(newpage, page);
>>>  	else
>>> diff --git a/mm/migrate.c b/mm/migrate.c
>>> index f7e4bfdc13b7..0d9708803553 100644
>>> --- a/mm/migrate.c
>>> +++ b/mm/migrate.c
>>> @@ -703,8 +703,14 @@ void migrate_page_states(struct page *newpage, struct page *page)
>>>  	 */
>>>  	if (PageSwapCache(page))
>>>  		ClearPageSwapCache(page);
>>> -	ClearPagePrivate(page);
>>> -	set_page_private(page, 0);
>>> +	/*
>>> +	 * Unlikely, but PagePrivate and page_private could potentially
>>> +	 * contain information needed at hugetlb free page time.
>>> +	 */
>>> +	if (!PageHuge(page)) {
>>> +		ClearPagePrivate(page);
>>> +		set_page_private(page, 0);
>>> +	}
> 
> # This argument is mainly for existing code...
> 
> According to the comment on migrate_page():
> 
>     /*
>      * Common logic to directly migrate a single LRU page suitable for
>      * pages that do not use PagePrivate/PagePrivate2.
>      *
>      * Pages are locked upon entry and exit.
>      */
>     int migrate_page(struct address_space *mapping, ...
> 
> So this common logic assumes that page_private is not used, so why do
> we explicitly clear page_private in migrate_page_states()?

Perhaps someone else knows.  If not, I can do some git research and
try to find out why.

> buffer_migrate_page(), which is commonly used for the case when
> page_private is used, does that clearing outside migrate_page_states().
> So I thought that hugetlbfs_migrate_page() could do in the similar manner.
> IOW, migrate_page_states() should not do anything on PagePrivate.
> But there're a few other .migratepage callbacks, and I'm not sure all of
> them are safe for the change, so this approach might not fit for a small fix.

I will look at those as well unless someone knows without researching.

> 
> # BTW, there seems a typo in $SUBJECT.

Thanks!

-- 
Mike Kravetz

