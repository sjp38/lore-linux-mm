Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C49AC48BE7
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 05:20:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE80F20651
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 05:20:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE80F20651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0BBE68E000A; Mon,  8 Jul 2019 01:20:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06C5B8E0001; Mon,  8 Jul 2019 01:20:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC3E08E000A; Mon,  8 Jul 2019 01:20:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD1A38E0001
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 01:20:10 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id z19so17844590ioi.15
        for <linux-mm@kvack.org>; Sun, 07 Jul 2019 22:20:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-language:list-id:archived-at:list-archive:list-post
         :content-transfer-encoding;
        bh=AiRUpy1cHGrhMMx2uzz4fxUaIpUqebJ+fsjA0lYUxd0=;
        b=iqamWOhOMcxYV163RDFH8CBlvGOnFAA+i2ATkn1BusgkcG09dUsMm3/HbO2vl+j33H
         FLS0+fE/4O5zSFb76kk3KQ81+HqmFxWshjSkkZuGirNpktuxXGogBGnIjc07DllyJ/Xu
         +Xqgd6DyR8AwrzZPMjpofiPYoLcF4AxJM6w1zCvqMFQvKO+yss7nKiexfV/tpBQA3ry+
         ajvC8z0G65JwKdJh3UMqtngzTAK6cGFitjkj/Z5evSkC1cO1GtDgwSLfOjLTOAgctRH/
         qhsq+t/da96lk/lZHzFLPpsQ/n/vM0Ipa52NGvsf3n5bRpRkuW6eP32VgbngJhER05Om
         vOmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVu8ZlEH+djzM9gAejXzKehaT4v88SDtqxeXoH3veu63vrNCTzT
	3oroeYznvaOyO6YjyPEBp3H2moY8JSzC9v+2cfwxfz1Ip0AfvlvjtwPBskfzj42zLmoqAWuY4wa
	2wyqvK3zYJL11UspJtzOOBH8hpO1jo8L9JiDIR3o0cW5CcpgzoaMqHaORizv/RrD3pQ==
X-Received: by 2002:a5e:a710:: with SMTP id b16mr15868831iod.38.1562563210561;
        Sun, 07 Jul 2019 22:20:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyglgb9M6qfEM7Ol3AJlSvWF2W4ZabGbDBvsTuKA7k2kvd7J3tTNwyldLB0QvIlx0lX+rD
X-Received: by 2002:a5e:a710:: with SMTP id b16mr15868759iod.38.1562563209732;
        Sun, 07 Jul 2019 22:20:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562563209; cv=none;
        d=google.com; s=arc-20160816;
        b=wHi2j4suua0MYUnpFrMNa8hE7KJoAGdmHb1dwcwUB8OeezO3GQaxGVZIO1nVUJTW/c
         GeH5rPt0OZ0tC5wl1waVZrPkfDVcCsySIYeSKQoqfnQ/7pIDf4hK9CJo35uM7JL2RF73
         1rvi0FwHbgTz6t3aZehCOp5cu2jLn+4p08BTSdrWhEdDqeOpuALPWG1Jow/TvN5Y1Otd
         Wgm2yMt9wr9v5Fz1sE8Sa9BDBdoVAaAjbZ9rNayif0qDIA16LT+lhbLLvruQDz73uC+O
         iAVMS8dewYfdpskmwPVqETfjePQKPpzpGNr8ex7wjfq0rM+crgTkP/A5LQ+iiFK7GjIM
         2t3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:content-language:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=AiRUpy1cHGrhMMx2uzz4fxUaIpUqebJ+fsjA0lYUxd0=;
        b=0YxoDQeOcl0hFsvcr2vnwGfFrZCAEbVYkD6pZ2dWQnTe2KczuxHLUvCQvd+JycVakn
         zWIEbQ9wfx1Ce6gcbA3GMJM0M4s6yQze5sldnWKB81Trfo2OcQ0rfCazpDPeaTbOIQxX
         EHwqE6z+APXiiDtCh0PmGlQfmjXfMdhLsUYGiktvD21sZ+q2eXOVhyVwCdn62SbV498R
         Huo5mWC5Kq18YWcohuWfrxr1XxXYtr8l/1yccBnfNZ1Eck2QRMNTSOlARSjMQ2k1S1Nz
         09hro6x4kiRHh0CHhicZOL7/iXoB3TVsFbhwLyLuqXy1XCjtQuR37bKqeUZXxwsz8Ab6
         VPrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-213.sinamail.sina.com.cn (mail7-213.sinamail.sina.com.cn. [202.108.7.213])
        by mx.google.com with SMTP id w21si22516335ioc.134.2019.07.07.22.20.06
        for <linux-mm@kvack.org>;
        Sun, 07 Jul 2019 22:20:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) client-ip=202.108.7.213;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([222.131.65.54])
	by sina.com with ESMTP
	id 5D22D27A00005A4E; Mon, 8 Jul 2019 13:19:56 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 49088950200804
From: Hillf Danton <hdanton@sina.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@suse.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Question] Should direct reclaim time be bounded?
Date: Mon,  8 Jul 2019 13:19:46 +0800
Message-Id: <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
In-Reply-To: <20190701085920.GB2812@suse.de>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190708051946.bER1NpKpnH663PpCF1VjLChmGkn61iaoze7e3Z2wYzw@z>


On Mon, 01 Jul 2019 20:15:51 -0700 Mike Kravetz wrote:
>On 7/1/19 1:59 AM, Mel Gorman wrote:
>> On Fri, Jun 28, 2019 at 11:20:42AM -0700, Mike Kravetz wrote:
>>> On 4/24/19 7:35 AM, Vlastimil Babka wrote:
>>>> On 4/23/19 6:39 PM, Mike Kravetz wrote:
>>>>>> That being said, I do not think __GFP_RETRY_MAYFAIL is wrong here. It
>>>>>> looks like there is something wrong in the reclaim going on.
>>>>>
>>>>> Ok, I will start digging into that.  Just wanted to make sure before I got
>>>>> into it too deep.
>>>>>
>>>>> BTW - This is very easy to reproduce.  Just try to allocate more huge pages
>>>>> than will fit into memory.  I see this 'reclaim taking forever' behavior on
>>>>> v5.1-rc5-mmotm-2019-04-19-14-53.  Looks like it was there in v5.0 as well.
>>>>
>>>> I'd suspect this in should_continue_reclaim():
>>>>
>>>>         /* Consider stopping depending on scan and reclaim activity */
>>>>         if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
>>>>                 /*
>>>>                  * For __GFP_RETRY_MAYFAIL allocations, stop reclaiming if the
>>>>                  * full LRU list has been scanned and we are still failing
>>>>                  * to reclaim pages. This full LRU scan is potentially
>>>>                  * expensive but a __GFP_RETRY_MAYFAIL caller really wants to succeed
>>>>                  */
>>>>                 if (!nr_reclaimed && !nr_scanned)
>>>>                         return false;
>>>>
>>>> And that for some reason, nr_scanned never becomes zero. But it's hard
>>>> to figure out through all the layers of functions :/
>>>
>>> I got back to looking into the direct reclaim/compaction stalls when
>>> trying to allocate huge pages.  As previously mentioned, the code is
>>> looping for a long time in shrink_node().  The routine
>>> should_continue_reclaim() returns true perhaps more often than it should.
>>>
>>> As Vlastmil guessed, my debug code output below shows nr_scanned is remaining
>>> non-zero for quite a while.  This was on v5.2-rc6.
>>>
>> 
>> I think it would be reasonable to have should_continue_reclaim allow an
>> exit if scanning at higher priority than DEF_PRIORITY - 2, nr_scanned is
>> less than SWAP_CLUSTER_MAX and no pages are being reclaimed.
>
>Thanks Mel,
>
>I added such a check to should_continue_reclaim.  However, it does not
>address the issue I am seeing.  In that do-while loop in shrink_node,
>the scan priority is not raised (priority--).  We can enter the loop
>with priority == DEF_PRIORITY and continue to loop for minutes as seen
>in my previous debug output.
>
Does it help raise prioity in your case?

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2543,11 +2543,18 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	unsigned long pages_for_compaction;
 	unsigned long inactive_lru_pages;
 	int z;
+	bool costly_fg_reclaim = false;
 
 	/* If not in reclaim/compaction mode, stop */
 	if (!in_reclaim_compaction(sc))
 		return false;
 
+	/* Let compact determine what to do for high order allocators */
+	costly_fg_reclaim = sc->order > PAGE_ALLOC_COSTLY_ORDER &&
+				!current_is_kswapd();
+	if (costly_fg_reclaim)
+		goto check_compact;
+
 	/* Consider stopping depending on scan and reclaim activity */
 	if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
 		/*
@@ -2571,6 +2578,7 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 			return false;
 	}
 
+check_compact:
 	/*
 	 * If we have not reclaimed enough pages for compaction and the
 	 * inactive lists are large enough, continue reclaiming
@@ -2583,6 +2591,9 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 			inactive_lru_pages > pages_for_compaction)
 		return true;
 
+	if (costly_fg_reclaim)
+		return false;
+
 	/* If compaction would go ahead or the allocation would succeed, stop */
 	for (z = 0; z <= sc->reclaim_idx; z++) {
 		struct zone *zone = &pgdat->node_zones[z];
--

