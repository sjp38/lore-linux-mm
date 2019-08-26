Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC883C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 13:49:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C9B921848
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 13:49:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C9B921848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D8AF6B0589; Mon, 26 Aug 2019 09:49:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3898B6B058A; Mon, 26 Aug 2019 09:49:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A0596B058B; Mon, 26 Aug 2019 09:49:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0157.hostedemail.com [216.40.44.157])
	by kanga.kvack.org (Postfix) with ESMTP id EFA916B0589
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 09:49:44 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 99987181AC9B6
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:49:44 +0000 (UTC)
X-FDA: 75864711888.15.news55_37ee7ca06c73a
X-HE-Tag: news55_37ee7ca06c73a
X-Filterd-Recvd-Size: 3518
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:49:44 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4DF8A307CDEA;
	Mon, 26 Aug 2019 13:49:43 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7B918608AB;
	Mon, 26 Aug 2019 13:49:39 +0000 (UTC)
Subject: Re: [PATCH v2] fs/proc/page: Skip uninitialized page when iterating
 page structures
From: Waiman Long <longman@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 Stephen Rothwell <sfr@canb.auug.org.au>, "Michael S. Tsirkin"
 <mst@redhat.com>
References: <20190826124336.8742-1-longman@redhat.com>
 <20190826132529.GC15933@bombadil.infradead.org>
 <60464cac-6319-c3c1-47b8-d9b5cf586754@redhat.com>
Organization: Red Hat
Message-ID: <18a20b0f-7ceb-94db-b885-e63db45ebaa9@redhat.com>
Date: Mon, 26 Aug 2019 09:49:38 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <60464cac-6319-c3c1-47b8-d9b5cf586754@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 26 Aug 2019 13:49:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/26/19 9:43 AM, Waiman Long wrote:
> On 8/26/19 9:25 AM, Matthew Wilcox wrote:
>>
>> Would this not work equally well?
>>
>> +++ b/fs/proc/page.c
>> @@ -46,7 +46,8 @@ static ssize_t kpagecount_read(struct file *file, char __user *buf,
>>                         ppage = pfn_to_page(pfn);
>>                 else
>>                         ppage = NULL;
>> -               if (!ppage || PageSlab(ppage) || page_has_type(ppage))
>> +               if (!ppage || PageSlab(ppage) || page_has_type(ppage) ||
>> +                               PagePoisoned(ppage))
>>                         pcount = 0;
>>                 else
>>                         pcount = page_mapcount(ppage);
>>
> That is my initial thought too. However, I couldn't find out where the
> memory of the uninitialized page structures may have been initialized
> somehow. The only thing I found is when vm_debug is on that the page
> structures are indeed poisoned. Without that it is probably just
> whatever the content that the memory have when booting up the kernel.
>
> It just happens on the test system that I used the memory of those page
> structures turned out to be -1. It may be different in other systems
> that can still crash the kernel, but not detected by the PagePoisoned()
> check. That is why I settle on the current scheme which is more general
> and don't rely on the memory get initialized in a certain way.

Actually, I have also thought about always poisoning the page
structures. However, that will introduce additional delay in the boot up
process which can be problematic especially if the system has large
amount of persistent memory.

Cheers,
Longman


