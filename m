Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67696C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:43:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AB7720675
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:43:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AB7720675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9B246B0007; Mon, 20 May 2019 05:43:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4C596B0008; Mon, 20 May 2019 05:43:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9399D6B000A; Mon, 20 May 2019 05:43:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56DEB6B0007
	for <linux-mm@kvack.org>; Mon, 20 May 2019 05:43:26 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id o12so8822984pll.17
        for <linux-mm@kvack.org>; Mon, 20 May 2019 02:43:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=xZDVpBiCbKhW0ztl9c/KzoRWoPLi/5gF4Wahy6wk6d0=;
        b=uYoh3RAgIZXuJ+x14UzPLV1l9if3XACJxRk26ZqYMq6xEzqwT9a+fh98fO2GA6fGtN
         sS50gDC/8+F4JvegkRh0jRvcVXmTslbrhXy9zQNKOK66Uk5zeVZPbF7n7mLR5uhEJ5FQ
         OjH2Ji310nC2d628nIiBXEIV3ihPShcPnZiiBjjcPAeP5qqvABS63rsIvo/b6wA2sd6e
         Pp3ptXWlUudCQT6YRkQG46O/H4YvB2A9Z7H7U4y6kqta7vZG2vOwHsMO86rAJA7m1Puh
         CsC7vhCPRleirR1XP1hK/+YmksG1rlpcjYQbgIaoOu0znH/GuKfbKY9y1jYyEESQ0Qbn
         hVbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW7B7LMmApCs50N2aX4wYPJB8JCco3ITMDF6Ayw19Jg5+j5HLRc
	BPirkJ52bF4+Q2C6PrxXEMXYUgbg9mxTnwRWhtj4MLiU7jx4JmIfTIwgDhbMx5pFfy18PN3vvMC
	mmjTtjcBZD29YAW2JM9AcSMF3G4eeI6X0WayV1Uq874de0Y5LHCdPRCagBDKE8T/I3Q==
X-Received: by 2002:a62:d286:: with SMTP id c128mr80080494pfg.159.1558345405991;
        Mon, 20 May 2019 02:43:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXxxSHnn0sn/m5va2GuZt0eZb8y5eK2ffVNuVuXPf0yMbbOPN0hAiMJXfKPyvn+b29kEKd
X-Received: by 2002:a62:d286:: with SMTP id c128mr80080428pfg.159.1558345404985;
        Mon, 20 May 2019 02:43:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558345404; cv=none;
        d=google.com; s=arc-20160816;
        b=WVKTJsNdghYX6Pm6Kf2yI8x/+ba0CGh79WlIQbvPtoVtE0ZJ+cnCGK2PQ/BkJQcR4p
         s2leMo6r4NpVE/Fvv2fGC3/iuvSIQT8dK/eCxw4bZxcUL6E5XKBSsiBqWz/th6Z68teq
         tlwbE+LlEHN119hDiZFpvagY+g8nEe+T+btrEbUUuA+njAgES9V9IcZcB2YhZEPmsL26
         SpGJOx5dOUAVTAidlkfTb+OoWb6QFXeXrrWKS1tPRfojP9YsLACI9+amFpLmUOkQnCby
         VaHKcWy8wGSeDL8TQxx9ZcZqWtZs5dB6ctdx+3cakrm2FIZLqWRB+mv7N0wSuecaPOey
         53jQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=xZDVpBiCbKhW0ztl9c/KzoRWoPLi/5gF4Wahy6wk6d0=;
        b=hj6KHXADDxlI+hvSSiKVZePVfYPMxZIEYJDYUL+IUH53zBtI3ISEQoGkmSWAScj+31
         1uDyXgBoBAkd/gZszgRwENd0m/uPCSFY9KwD7hqmNwe5AZi27IDYS+9a5aUcmomwDY+U
         DzZxxJLXGDiXkNdeEP6ZcY/4noQKq35StMsimhLVHtb1nq4XUBPHE6iLS21yDaxbNdU5
         2+muBD86bcD53eCGeGaFd6tg+Q30gFKSQbBrHbR2C8Ldom5oqPHTXUeGOX/HSkgtT3yF
         oN8W1lT/FHGszDDCmXpH0rL3xAblyESh9k5qJbMP33oIu7rq008XpqAHd37HdNI8pvAp
         f2wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id f62si18039579plb.339.2019.05.20.02.43.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 02:43:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TSCntOc_1558345401;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSCntOc_1558345401)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 20 May 2019 17:43:22 +0800
Subject: Re: [v2 PATCH] mm: vmscan: correct nr_reclaimed for THP
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Yang Shi <shy828301@gmail.com>,
 Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>,
 kirill.shutemov@linux.intel.com, Hugh Dickins <hughd@google.com>,
 Shakeel Butt <shakeelb@google.com>, william.kucharski@oracle.com,
 Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <1557505420-21809-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190513080929.GC24036@dhcp22.suse.cz>
 <c3c26c7a-748c-6090-67f4-3014bedea2e6@linux.alibaba.com>
 <20190513214503.GB25356@dhcp22.suse.cz>
 <CAHbLzkpUE2wBp8UjH72ugXjWSfFY5YjV1Ps9t5EM2VSRTUKxRw@mail.gmail.com>
 <20190514062039.GB20868@dhcp22.suse.cz>
 <509de066-17bb-e3cf-d492-1daf1cb11494@linux.alibaba.com>
 <20190516151012.GA20038@cmpxchg.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <cea2cdbf-640b-7e8e-7906-34ee3a7bb595@linux.alibaba.com>
Date: Mon, 20 May 2019 17:43:20 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190516151012.GA20038@cmpxchg.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/16/19 11:10 PM, Johannes Weiner wrote:
> On Tue, May 14, 2019 at 01:44:35PM -0700, Yang Shi wrote:
>> On 5/13/19 11:20 PM, Michal Hocko wrote:
>>> On Mon 13-05-19 21:36:59, Yang Shi wrote:
>>>> On Mon, May 13, 2019 at 2:45 PM Michal Hocko <mhocko@kernel.org> wrote:
>>>>> On Mon 13-05-19 14:09:59, Yang Shi wrote:
>>>>> [...]
>>>>>> I think we can just account 512 base pages for nr_scanned for
>>>>>> isolate_lru_pages() to make the counters sane since PGSCAN_KSWAPD/DIRECT
>>>>>> just use it.
>>>>>>
>>>>>> And, sc->nr_scanned should be accounted as 512 base pages too otherwise we
>>>>>> may have nr_scanned < nr_to_reclaim all the time to result in false-negative
>>>>>> for priority raise and something else wrong (e.g. wrong vmpressure).
>>>>> Be careful. nr_scanned is used as a pressure indicator to slab shrinking
>>>>> AFAIR. Maybe this is ok but it really begs for much more explaining
>>>> I don't know why my company mailbox didn't receive this email, so I
>>>> replied with my personal email.
>>>>
>>>> It is not used to double slab pressure any more since commit
>>>> 9092c71bb724 ("mm: use sc->priority for slab shrink targets"). It uses
>>>> sc->priority to determine the pressure for slab shrinking now.
>>>>
>>>> So, I think we can just remove that "double slab pressure" code. It is
>>>> not used actually and looks confusing now. Actually, the "double slab
>>>> pressure" does something opposite. The extra inc to sc->nr_scanned
>>>> just prevents from raising sc->priority.
>>> I have to get in sync with the recent changes. I am aware there were
>>> some patches floating around but I didn't get to review them. I was
>>> trying to point out that nr_scanned used to have a side effect to be
>>> careful about. If it doesn't have anymore then this is getting much more
>>> easier of course. Please document everything in the changelog.
>> Thanks for reminding. Yes, I remembered nr_scanned would double slab
>> pressure. But, when I inspected into the code yesterday, it turns out it is
>> not true anymore. I will run some test to make sure it doesn't introduce
>> regression.
> Yeah, sc->nr_scanned is used for three things right now:
>
> 1. vmpressure - this looks at the scanned/reclaimed ratio so it won't
> change semantics as long as scanned & reclaimed are fixed in parallel
>
> 2. compaction/reclaim - this is broken. Compaction wants a certain
> number of physical pages freed up before going back to compacting.
> Without Yang Shi's fix, we can overreclaim by a factor of 512.
>
> 3. kswapd priority raising - this is broken. kswapd raises priority if
> we scan fewer pages than the reclaim target (which itself is obviously
> expressed in order-0 pages). As a result, kswapd can falsely raise its
> aggressiveness even when it's making great progress.
>
> Both sc->nr_scanned & sc->nr_reclaimed should be fixed.

Yes, v3 patch (sit in my local repo now) did fix both.

>
>> BTW, I noticed the counter of memory reclaim is not correct with THP swap on
>> vanilla kernel, please see the below:
>>
>> pgsteal_kswapd 21435
>> pgsteal_direct 26573329
>> pgscan_kswapd 3514
>> pgscan_direct 14417775
>>
>> pgsteal is always greater than pgscan, my patch could fix the problem.
> Ouch, how is that possible with the current code?
>
> I think it happens when isolate_lru_pages() counts 1 nr_scanned for a
> THP, then shrink_page_list() splits the THP and we reclaim tail pages
> one by one. This goes all the way back to the initial THP patch!

I think so. It does make sense. But, the weird thing is I just see this 
with synchronous swap device (some THPs got swapped out in a whole, some 
got split), but I've never seen this with rotate swap device (all THPs 
got split).

I haven't figured out why.

>
> isolate_lru_pages() needs to be fixed. Its return value, nr_taken, is
> correct, but its *nr_scanned parameter is wrong, which causes issues:
>
> 1. The trace point, as Yang Shi pointed out, will underreport the
> number of pages scanned, as it reports it along with nr_to_scan (base
> pages) and nr_taken (base pages)
>
> 2. vmstat and memory.stat count 'struct page' operations rather than
> base pages, which makes zero sense to neither user nor kernel
> developers (I routinely multiply these counters by 4096 to get a sense
> of work performed).
>
> All of isolate_lru_pages()'s accounting should be in base pages, which
> includes nr_scanned and PGSCAN_SKIPPED.
>
> That should also simplify the code; e.g.:
>
> 	for (total_scan = 0;
> 	     scan < nr_to_scan && nr_taken < nr_to_scan && !list_empty(src);
> 	     total_scan++) {
>
> scan < nr_to_scan && nr_taken >= nr_to_scan is a weird condition that
> does not make sense in page reclaim imo. Reclaim cares about physical
> memory - freeing one THP is as much progress for reclaim as freeing
> 512 order-0 pages.

Yes, I do agree. The v3 patch did this.

>
> IMO *all* '++' in vmscan.c are suspicious and should be reviewed:
> nr_scanned, nr_reclaimed, nr_dirty, nr_unqueued_dirty, nr_congested,
> nr_immediate, nr_writeback, nr_ref_keep, nr_unmap_fail, pgactivate,
> total_scan & scan, nr_skipped.

Some of them should be fine but I'm not sure the side effect. IMHO, 
let's fix the most obvious problem first.

>
> Yang Shi, it would be nice if you could convert all of these to base
> page accounting in one patch, as it's a single logical fix for the
> initial introduction of THP that had huge pages show up on the LRUs.\

Yes, sure.

>
> [ check_move_unevictable_pages() seems weird. It gets a pagevec from
>    find_get_entries(), which, if I understand the THP page cache code
>    correctly, might contain the same compound page over and over. It'll
>    be !unevictable after the first iteration, so will only run once. So
>    it produces incorrect numbers now, but it is probably best to ignore
>    it until we figure out THP cache. Maybe add an XXX comment. ]

