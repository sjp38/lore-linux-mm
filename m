Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 251BFC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:00:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6E6E2147A
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 17:00:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PkQPMljf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6E6E2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C3B86B0005; Mon,  5 Aug 2019 13:00:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4722C6B0006; Mon,  5 Aug 2019 13:00:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 338CC6B0007; Mon,  5 Aug 2019 13:00:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08A446B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 13:00:48 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id b7so21174985vsr.18
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 10:00:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9pUfgziCq7pxPpZPM6g5Do4JMKoJYIw8oH79TZUxwXY=;
        b=OREzk0ea66FOmIV8EbWOjIjxTPLYqY2uyucFFqKdIwOOskIEq3E5VRML8YTYNgGNC1
         y1ZfRcFV1Ncp0oWV/vB2CbRSYkn0SYmNAEpgBS9wgOQdsgMKO9J4Gl8vv/lHv6GVXcLU
         9tZ1ZTQxGQh9L/LyikPkmTM9hsJTYYBmIH4zfXnj6GJJOXgQPX/qyMtzvG2gxGGGXZjV
         GWJKDOQWRPlrWyl+UOLCDE6ZJaA9MlWLaHdamHWXK+WA6F8NVDBR5dage1Gp4RGBiroi
         pkMok17giWdwmjAPcGdHzGkydxTtR2EPdG833IWUBOO8FhVEqqZIUvh6jWyi/cIHOt+2
         rf9Q==
X-Gm-Message-State: APjAAAUVranS9UyzFCFhCYjB3mswXtV8aoSdiG6NWEAxWAfLz73kUx1I
	b6TEWuKdPJm2rNH4QvbbxnlSW20I8lGnZG9tPhn6iPc6USnSDE/RNX6916c5unEAwRbbGOXQdLP
	E0uXk5Waata+uMN7bI06+SZo19eY50I53MZeFB9Gwg2EhugK3Wdi5lDSG++1qXPykNQ==
X-Received: by 2002:ab0:470e:: with SMTP id h14mr67201404uac.98.1565024447722;
        Mon, 05 Aug 2019 10:00:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkZVlqwSXou6egN0ftuDp9HEwvDl+LbVG8Az1zDO5lNJYLc/tbsaIy5u50XqKdQY/5wEIt
X-Received: by 2002:ab0:470e:: with SMTP id h14mr67201367uac.98.1565024447103;
        Mon, 05 Aug 2019 10:00:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565024447; cv=none;
        d=google.com; s=arc-20160816;
        b=XA5KGXWZ+/ggxesZXdxP3NpI6iip6R5GLv4zY6m1G55NmC6VxX8rfqUUQxJnBzCctZ
         hOrgXbk1/ujELxvU28AeB1KUFCZFAYmzsva3tTmsWtJVbV1PM0RdtTZPaxtk88RTkfLa
         jKeOapPqpYXrkh34VVhCuhjRwaFede4JzR7nNp7d0wqEx/Rq7GoASeUBa5GuTSTz5wxq
         1g03dJ3bqZH0yXHvsgwE4VBfEmMat3ZhvBQqa/I40QBEJAkEZ+qdC8A5KsnsL4kgJvPY
         G+FT1J652bPSWKflkGTAuhGd3LQQkdiRp2Q+rYTbSnYnneo6i6oim9I1WfvjEdnPrwzU
         e9TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=9pUfgziCq7pxPpZPM6g5Do4JMKoJYIw8oH79TZUxwXY=;
        b=ry3uTE/kvqu3urQoL5MTRuc4fY2XQEoUBaifC5zJH3RtaeHbhhvKw7eCC4Z7CaKtIf
         GnoApPEybW7qAcmOoe4u+9DPsbFDJ/cv8NvwBzUjw4ZZa1oW0Pwi+TS8tY5zRecMBkwt
         OjI8n9iOFZ/YbrHFxrqOeqQ1C7l+kgNffy1wJo3xkpb0EElnKDJqZMGnw+FfcRhlHgOe
         byXx2xdxlS1qqv/kMeQioqYEn8X3JN7j4sCpomqNAJm84IKZqK/YTyqrl4zH6+wYcusV
         Vxo0eTQfSA+FkNWkyQ7D2PjyqTUvSXze4COMamLKKgsDtcv+gRSAN9xIheFm5fHs/62L
         JMyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PkQPMljf;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id a190si1938156vsd.428.2019.08.05.10.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 10:00:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PkQPMljf;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x75Gj6IA113561;
	Mon, 5 Aug 2019 17:00:41 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=9pUfgziCq7pxPpZPM6g5Do4JMKoJYIw8oH79TZUxwXY=;
 b=PkQPMljfOmAIQpx501wtF+rIjs+mcgDoiMpircWo7jHH88A2tIpl4nnV8azMM1Dd66PX
 jqn9tc+tvmCDyOcUWjv9nI5xdOc9NBYzIuJHEzPiTNA0N6uZ9ETtevbC9N8RBHViNpaa
 YuFbP1C5k2riXhF6eKTP+ELkI8d/H5rWJC/7fm7nRcIeobm3rkyZRREKfYApppimsSbc
 3V4IvMw1i4FN8ZGz7rL5+kWYXrh9ex+JjsitLy7mh8fpEvJprSC+7AOLDU5PyQRb3aEi
 4Ix1s1in1si6pvznojlvamRz0YkPdffwvMSQJVI31ZumJNx9LbpgZvNQK9wwvD0drxSK Kg== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2u527pgf0t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 17:00:41 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x75GlBa3160930;
	Mon, 5 Aug 2019 16:58:40 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2u4ycu5ure-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 16:58:40 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x75Gwb6J022007;
	Mon, 5 Aug 2019 16:58:38 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 05 Aug 2019 09:58:37 -0700
Subject: Re: [PATCH 1/3] mm, reclaim: make should_continue_reclaim perform
 dryrun detection
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
        Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes
 <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190802223930.30971-1-mike.kravetz@oracle.com>
 <20190802223930.30971-2-mike.kravetz@oracle.com>
 <bb16d3f0-0984-be32-4346-358abad92c4c@suse.cz>
 <0d31cc14-13cd-13e0-cf2d-dd8a8d3049ff@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <b4dbe25f-4499-af28-94bb-d12147505326@oracle.com>
Date: Mon, 5 Aug 2019 09:58:36 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <0d31cc14-13cd-13e0-cf2d-dd8a8d3049ff@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=927
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908050184
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=965 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908050184
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/5/19 3:57 AM, Vlastimil Babka wrote:
> On 8/5/19 10:42 AM, Vlastimil Babka wrote:
>> On 8/3/19 12:39 AM, Mike Kravetz wrote:
>>> From: Hillf Danton <hdanton@sina.com>
>>>
>>> Address the issue of should_continue_reclaim continuing true too often
>>> for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
>>> This could happen during hugetlb page allocation causing stalls for
>>> minutes or hours.
>>>
>>> We can stop reclaiming pages if compaction reports it can make a progress.
>>> A code reshuffle is needed to do that.
>>
>>> And it has side-effects, however,
>>> with allocation latencies in other cases but that would come at the cost
>>> of potential premature reclaim which has consequences of itself.
>>
>> Based on Mel's longer explanation, can we clarify the wording here? e.g.:
>>
>> There might be side-effect for other high-order allocations that would
>> potentially benefit from more reclaim before compaction for them to be
>> faster and less likely to stall, but the consequences of
>> premature/over-reclaim are considered worse.
>>
>>> We can also bail out of reclaiming pages if we know that there are not
>>> enough inactive lru pages left to satisfy the costly allocation.
>>>
>>> We can give up reclaiming pages too if we see dryrun occur, with the
>>> certainty of plenty of inactive pages. IOW with dryrun detected, we are
>>> sure we have reclaimed as many pages as we could.
>>>
>>> Cc: Mike Kravetz <mike.kravetz@oracle.com>
>>> Cc: Mel Gorman <mgorman@suse.de>
>>> Cc: Michal Hocko <mhocko@kernel.org>
>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Signed-off-by: Hillf Danton <hdanton@sina.com>
>>> Tested-by: Mike Kravetz <mike.kravetz@oracle.com>
>>> Acked-by: Mel Gorman <mgorman@suse.de>
>>
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>> I will send some followup cleanup.
> 
> How about this?
> ----8<----
> From 0040b32462587171ad22395a56699cc036ad483f Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Mon, 5 Aug 2019 12:49:40 +0200
> Subject: [PATCH] mm, reclaim: cleanup should_continue_reclaim()
> 
> After commit "mm, reclaim: make should_continue_reclaim perform dryrun
> detection", closer look at the function shows, that nr_reclaimed == 0 means
> the function will always return false. And since non-zero nr_reclaimed implies
> non_zero nr_scanned, testing nr_scanned serves no purpose, and so does the
> testing for __GFP_RETRY_MAYFAIL.
> 
> This patch thus cleans up the function to test only !nr_reclaimed upfront, and
> remove the __GFP_RETRY_MAYFAIL test and nr_scanned parameter completely.
> Comment is also updated, explaining that approximating "full LRU list has been
> scanned" with nr_scanned == 0 didn't really work.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mike Kravetz <mike.kravetz@oracle.com>

Would you like me to add this to the series, or do you want to send later?
-- 
Mike Kravetz

