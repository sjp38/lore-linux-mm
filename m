Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C25B3C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:04:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A8CA21852
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:04:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A8CA21852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 111BC8E0003; Tue, 26 Feb 2019 07:04:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C1DB8E0001; Tue, 26 Feb 2019 07:04:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F40FD8E0003; Tue, 26 Feb 2019 07:04:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 876FB8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:04:36 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id v4so2199855ljc.21
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:04:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hTPoWQq2MfU4/cCivmJBNRwRs7kGpqA5Ff9iQJutTlQ=;
        b=rq03oJeq82Q259ghcO58Rb2RgJBsSj4btI173GQOKIt0HST8aN4hZH3UId4lgOgyBI
         HQmUH9CjiLyPvGjW5xmLb2St2WQeGBjjV4XNRNgYvOcFJMOqwJm57QLa93SGVrTXNHkZ
         YGF93tTP80jUVfSu0dJSHt0nuCD/dtPwv/ALWwZKrH9dObK1eCMnw4RmkWwvm3zIfZQJ
         nk+hqs9Ru+aoyvPAoVmZVd+qeiiCxf56eB5A3w1VQ6Ia6GPZk8+LJlbGdyhHDZkVU5Ew
         sB0TZXkQBSbuaETQvq+mubslQo8Q1I6lqXYWSuaG/Cs0mzNapvZQX7nkRdpuX2vIgnyO
         8bbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuYC1TlF5lPrv6X42TQNqq2acvacp51+lo3/6UxrdjtMtZvu12HP
	qZCHSOpQSJlLnb5hic/mtqFQh6LKYkHTaaMr7dMR7YHRO6Gr+L/hM1pQk9K490R9KrQuf+bjYHr
	WObLbAHfu326+ieLIQ/YzpyXv8zvv7vAdewC+nIy0mGJW670qCncmMcqGhNprWU4ErQ==
X-Received: by 2002:a2e:880a:: with SMTP id x10mr12367111ljh.12.1551182675915;
        Tue, 26 Feb 2019 04:04:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZouu2BJAOpzXTAa0H5wIUVVxJ0G5JORs87N/LT5E61+t3thdmq2E0JefHk+usIGJcuD95y
X-Received: by 2002:a2e:880a:: with SMTP id x10mr12367060ljh.12.1551182674797;
        Tue, 26 Feb 2019 04:04:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551182674; cv=none;
        d=google.com; s=arc-20160816;
        b=xVAJ2zEmgfemQ5RXnuDU8SBtUOrumysxuXfuMhsGkchbSGUxvSni94lMvtWoihj1W3
         uEgzz8z+GZxQxgDVQddN34/9+EiVmd1/MtlJF3pMjQg7AU1gfGomTqO/4F+wvxjQD6iN
         SxqnJ8Nlto2DYCXsUR05lx7H2kjFxdixW8UO3xp3/gfqbgmblzGSOHcvLNfvyyW/c/LS
         YX+buOTTD6VDCP3YvkZryoU3zduO+x9oMHEI8dUqtABvaI6FQw4ObgVC+3VeuU6oXkG1
         t0K3faCM2CP25NZTnYA5oT1UsiApu8msBukttU7KbsSvQACDI2NPPV86quNEGjKooaM+
         QnLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=hTPoWQq2MfU4/cCivmJBNRwRs7kGpqA5Ff9iQJutTlQ=;
        b=vtTGxL6OLkA4/qUIReSHG/oL0J1p2EBsfIXNXSNgCUNwwns7mJa8Oh+81DQz7Kkxiv
         z3io+BEGwO69fxe6+K5QyCDvPRfeoYlthuFs1qFAOnzdyn8vY578QlavTdaY5CADtiYw
         MJO1jfsBpvB1SiuOy9Qtc7Fo1bHv5RGRwqKTA6yvJJW9NVDCIX43JY+aUwXv6TclqGEj
         4jHKF37WW/SOjNet7wI4eFCc3Lesov663Cu6xMKq+DLbtDaGqCFbtTGmJh6cr8J7t7uU
         Njpam1JzvbYy3hw1r1JbTdppWcK07+VKc/LVvik/C0j0xo86pVklb+iuTz98fQ3Oid2p
         cF9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id w17si8646836lfe.74.2019.02.26.04.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 04:04:34 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gybTB-0007VM-To; Tue, 26 Feb 2019 15:04:22 +0300
Subject: Re: [PATCH 5/5] mm/vmscan: don't forcely shrink active anon lru list
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
 Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
 Mel Gorman <mgorman@techsingularity.net>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
 <20190222174337.26390-5-aryabinin@virtuozzo.com>
 <20190222182249.GC15440@cmpxchg.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <ea0f769b-29e6-8787-7b18-cb7b24c1cda3@virtuozzo.com>
Date: Tue, 26 Feb 2019 15:04:40 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190222182249.GC15440@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/22/19 9:22 PM, Johannes Weiner wrote:
> On Fri, Feb 22, 2019 at 08:43:37PM +0300, Andrey Ryabinin wrote:
>> shrink_node_memcg() always forcely shrink active anon list.
>> This doesn't seem like correct behavior. If system/memcg has no swap, it's
>> absolutely pointless to rebalance anon lru lists.
>> And in case we did scan the active anon list above, it's unclear why would
>> we need this additional force scan. If there are cases when we want more
>> aggressive scan of the anon lru we should just change the scan target
>> in get_scan_count() (and better explain such cases in the comments).
>>
>> Remove this force shrink and let get_scan_count() to decide how
>> much of active anon we want to shrink.
> 
> This change breaks the anon pre-aging.
> 
> The idea behind this is that the VM maintains a small batch of anon
> reclaim candidates with recent access information. On every reclaim,
> even when we just trim cache, which is the most common reclaim mode,
> but also when we just swapped out some pages and shrunk the inactive
> anon list, at the end of it we make sure that the list of potential
> anon candidates is refilled for the next reclaim cycle.
> 
> The comments for this are above inactive_list_is_low() and the
> age_active_anon() call from kswapd.
> 
> Re: no swap, you are correct. We should gate that rebalancing on
> total_swap_pages, just like age_active_anon() does.
> 


I think we should leave anon aging only for !SCAN_FILE cases.
At least aging was definitely invented for the SCAN_FRACT mode which was the
main mode at the time it was added by the commit:

	556adecba110bf5f1db6c6b56416cfab5bcab698
	Author: Rik van Riel <riel@redhat.com>
	Date:   Sat Oct 18 20:26:34 2008 -0700

	    vmscan: second chance replacement for anonymous pages


Later we've got more of the SCAN_FILE mode usage, commit:

e9868505987a03a26a3979f27b82911ccc003752
Author: Rik van Riel <riel@redhat.com>
Date:   Tue Dec 11 16:01:10 2012 -0800

    mm,vmscan: only evict file pages when we have plenty


and I think would be reasonable to  avoid the anon aging in the SCAN_FILE case.
Because if workload generates enough inactive file pages we never go to the SCAN_FRACT,
so aging is just as useless as with no swap case.

So, how about something like bellow on top of the patch?

---
 mm/vmscan.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index efd10d6b9510..6c63adfee37b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2525,6 +2525,15 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 
 		nr[lru] = scan;
 	}
+
+	/*
+	 * Even if we did not try to evict anon pages at all, we want to
+	 * rebalance the anon lru active/inactive ratio to maintain
+	 * enough reclaim candidates for the next reclaim cycle.
+	 */
+	if (scan_balance != SCAN_FILE && inactive_list_is_low(lruvec,
+						false, memcg, sc, false))
+		nr[LRU_ACTIVE_ANON] += SWAP_CLUSTER_MAX;
 }
 
 /*
-- 
2.19.2




