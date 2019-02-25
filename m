Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6982CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 16:49:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 254F820842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 16:49:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="o+sIwtjm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 254F820842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68AB88E000F; Mon, 25 Feb 2019 11:49:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63A778E000D; Mon, 25 Feb 2019 11:49:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5029F8E000F; Mon, 25 Feb 2019 11:49:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 20C278E000D
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:49:30 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id r8so6705144ywh.10
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 08:49:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2DavdlfEcPUnZ5zlrCm/gMnuNXvBK6a6jQ40MXyfRN4=;
        b=nVkWvLIYx9j/9UdRur9ifBoBQrWbevQ/xMm1m0SbPEZAORf+XcEySVt+xJgFCwgyNq
         3K23nkUgLy4nNzUmwSGRw+P5ljRYiJS5igeCvYOHH7NuYrHdQcOnQ1rqJXn1/4lbNx8R
         XjMi0ntfsXhhnGVS6RiPueYEpr6vtyoHNDtMsXKHodhvJC3QLXWWyPR/sk2VeCDUj/0e
         gS9d2mPPOhnVZTok9wwtsTWSaP/hIXYYxBrX6OyMuz6PfCi2d4UvxwnOoqogCDSBZCMF
         cZdTeygHzF54jd/VvkKFkrrM+llM0jRi7dZBTb5Ic/ByzBrp8KcXMn5Dyt3GN2r+nljw
         Pq8w==
X-Gm-Message-State: AHQUAuaB2sxc4CZml/JE2sXCHEE8s92FxMdawl2Zspjuuvpk0wRkOcAa
	Pin3xZxxoDWKneYBpqNEHth+c/ddCcOaFmope/+lyhdLo2UjU4pB3Ob8JFRSD2PQJQjTazthjqo
	egDIhwzkCo7C5xULz7POehiclpSaUOOuhkRP4sBzy6I4/IlNff79Lje9TEOrzmt2ZgQ==
X-Received: by 2002:a25:770f:: with SMTP id s15mr14725660ybc.47.1551113369719;
        Mon, 25 Feb 2019 08:49:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYFaRGIeeAI3YDEnwTQ4SRP72Qm43Nhge5necpxaUpP11CYjPV9Y8UuCng55D89PQ9MWOjT
X-Received: by 2002:a25:770f:: with SMTP id s15mr14725605ybc.47.1551113368815;
        Mon, 25 Feb 2019 08:49:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551113368; cv=none;
        d=google.com; s=arc-20160816;
        b=KL53Bc3JKBVJt/nGBJdJiZjtLE47x7w7dT7eOK+E+EGOfkf4/94os83SHjmXDh6Gvf
         U8o0fsWc0nz3g9VTt5HiQjeO9blNRBCpQLy7HED3uOa7byJpEnzdImvvnig6q4Ur136M
         b2Yn1a5LLkg5D7mmtkOq9TdXcCWnWz3cTvWvfktxloiX+RKYUx83uqIhoYNx8wU2e3jg
         WEsI2wEN+I1G9x5pyBA0on4TLHMLRwZVqgYwDxlMZ/8zlQyq9Wp+zZVgb0IJBCjVMbUM
         +1hDQ/+ww7A8QAAMoM5Hsk5Ugxbe6IIhwBG3mncZWsYW/c6Gd7mO97NWU4NAvImhDiUE
         BZhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=2DavdlfEcPUnZ5zlrCm/gMnuNXvBK6a6jQ40MXyfRN4=;
        b=NdSOABpADopOTBKTCwU2r6dP+SFBeetaub++XnOIEaXsBO//Jh/cKzWjAFgm+JMplZ
         OTIkjxdF7fPrX8g2LMEWbDUiXLqRdMqx1mSPCz+aNtvk7TVOpwAtjeroAKGZfQ06fi/R
         vjDxf2JjdfyO/0oSKJ9QcIqeZN3ZCjzGhrBWfGeiTng5wsQrOh7rx9k6X9dYFVbLMmZD
         mHLWYp26R/qWV4qnaY9QgCRwTZkXyJyDELHgwLzxiZQ2v/hpk9Ap3hj1GkfZykSeE/Hy
         o+z7UE8+DcfjACNp5Pe1msNIixiHE8UA/VUYow39TeTZPsxDWcMuel0JeoWHwwej+HmE
         CgrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=o+sIwtjm;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id k185si5809918ywg.357.2019.02.25.08.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 08:49:28 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=o+sIwtjm;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1PGi1fu068593;
	Mon, 25 Feb 2019 16:49:15 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=2DavdlfEcPUnZ5zlrCm/gMnuNXvBK6a6jQ40MXyfRN4=;
 b=o+sIwtjme3BGl5X7m88crmOr9mM+RYVdMKlB5tRKJTyW5GSs+1NPVHbFVM3kq82d+0Re
 OWptQ8ccl8MWYxNUxkjbYtdRTdoEfgyRgVr7zeaVTS+WDza8nuslcA3KDwxVmmrz9mUv
 y8mFGi8SqFhqTj8QxDHTbHFBDZi9dYoseBr8RyxbuppSJEicGyZdWOWxdhb5LyCF84LJ
 Jo8AeKK02wVuZQ5ctcs9HfVxSbGzQwUhzEXYqvoD12ANXZlbM3q30jxmwkVk+wGb8RAh
 KeE0Dn5ySuuz7nVIqy72r8JhOzbN2VAXj89i8qO1EorP9nG5dQnvAeCEggaOHDcp8M80 hg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2qtupdyg7h-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 25 Feb 2019 16:49:15 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1PGn9mB026766
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 25 Feb 2019 16:49:10 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1PGn78D019409;
	Mon, 25 Feb 2019 16:49:08 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 25 Feb 2019 08:49:07 -0800
Subject: Re: [PATCH v4] mm/hugetlb: Fix unsigned overflow in
 __nr_hugepages_store_common()
To: David Rientjes <rientjes@google.com>
Cc: Jing Xiangfeng <jingxiangfeng@huawei.com>, mhocko@kernel.org,
        akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org,
        n-horiguchi@ah.jp.nec.com, aarcange@redhat.com,
        kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org
References: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com>
 <388cbbf5-7086-1d04-4c49-049021504b9d@oracle.com>
 <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <8c167be7-06fa-a8c0-8ee7-0bfad41eaba2@oracle.com>
Date: Mon, 25 Feb 2019 08:49:06 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1902241913000.34632@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9178 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902250123
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/24/19 7:17 PM, David Rientjes wrote:
> On Sun, 24 Feb 2019, Mike Kravetz wrote:
> 
>>> User can change a node specific hugetlb count. i.e.
>>> /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
>>> the calculated value of count is a total number of huge pages. It could
>>> be overflow when a user entering a crazy high value. If so, the total
>>> number of huge pages could be a small value which is not user expect.
>>> We can simply fix it by setting count to ULONG_MAX, then it goes on. This
>>> may be more in line with user's intention of allocating as many huge pages
>>> as possible.
>>>
>>> Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
>>
>> Thank you.
>>
>> Acked-by: Mike Kravetz <mike.kravetz@oracle.com>
>>
>>> ---
>>>  mm/hugetlb.c | 7 +++++++
>>>  1 file changed, 7 insertions(+)
>>>
>>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>>> index afef616..6688894 100644
>>> --- a/mm/hugetlb.c
>>> +++ b/mm/hugetlb.c
>>> @@ -2423,7 +2423,14 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
>>>  		 * per node hstate attribute: adjust count to global,
>>>  		 * but restrict alloc/free to the specified node.
>>>  		 */
>>> +		unsigned long old_count = count;
>>>  		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
>>> +		/*
>>> +		 * If user specified count causes overflow, set to
>>> +		 * largest possible value.
>>> +		 */
>>> +		if (count < old_count)
>>> +			count = ULONG_MAX;
>>>  		init_nodemask_of_node(nodes_allowed, nid);
>>>  	} else
>>>  		nodes_allowed = &node_states[N_MEMORY];
>>>
> 
> Looks like this fixes the overflow issue, but isn't there already a 
> possible underflow since we don't hold hugetlb_lock?  Even if 
> count == 0, what prevents h->nr_huge_pages_node[nid] being greater than 
> h->nr_huge_pages here?  I think the per hstate values need to be read with 
> READ_ONCE() and stored on the stack to do any sane bounds checking.

Yes, without holding the lock there is the potential for issues.  Looking
back to when the node specific code was added there is a comment about
"re-use/share as much of the existing global hstate attribute initialization
and handling".  I suspect that is the reason for these calculations outside
the lock.

As you mention above, nr_huge_pages_node[nid] could be greater than
nr_huge_pages.  This is true even if we do READ_ONCE().  So, the code would
need to test for this condition and 'fix up' values or re-read.  It is just
racy without holding the lock.

If that is too ugly, then we could just add code for the node specific
adjustments.  set_max_huge_pages() is only called from here.  It would be
pretty easy to modify set_max_huge_pages() to take the node specific value
and do calculations/adjustments under the lock.
-- 
Mike Kravetz

