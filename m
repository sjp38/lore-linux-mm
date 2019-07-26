Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C80F1C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:45:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B56A217D4
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:45:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B56A217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A9CD6B0005; Fri, 26 Jul 2019 03:45:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 081D96B0006; Fri, 26 Jul 2019 03:45:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED94B6B0007; Fri, 26 Jul 2019 03:45:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B699A6B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:45:44 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so27875332pla.7
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 00:45:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=TLeWTt3s6e58GuErShWUt67OkdocH7fatcRDcKC2JN4=;
        b=ZNU4092XYKqV9aB2sEaa4qa8jZGNohKHpZ5Bw7Yir4GHmkAM+TgcAo4fpXVXYfVFmN
         qJcuSNl9d7eHGidrAzIpju0PqQunLh4enjSwnf+tGMNNZuRjFn77bO5ZsXkITSmJyzFl
         JgakTosUsNZ8edyS/+OWpTopmS/O0d/larDxdYoBELLFtMcVXlQsVP0t2AYzXc8NlKhe
         wVqg4yQexSoJH/SgxGSstkuH/7SSrCdNGmjRqcU61T0RmrVDk0I5danRO9GuTBIEwXis
         J8COC029YfdXxTabnOjwbax9bsQH2ZLkX//Nxx3jKJHg+BigMnmOr/33eD9Ot3wi76Y6
         Md6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUhTJiXg0KVVL+Vc2aosb4gxU5XvqhCaPCWcpgivLWMf9ZMcskz
	DY7h1FIYpy4mhm2jlGU0jBfKOk4NLwcz1XVRxxCfizBxpKV8SOvIAfNV46ARIAZWdJSGh9kXsIH
	K2z7n/5VSLEWpVf66IQkXPStcyzZCtOmYCNYbDKImdpqka7Mj+EAvNI/VBAGzZUg/zQ==
X-Received: by 2002:a17:902:fa2:: with SMTP id 31mr96602688plz.38.1564127144395;
        Fri, 26 Jul 2019 00:45:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHag8QgGwIl7EUFTqybd5CFrR08n07nsDxEpix7ar36GUJzS2TO0BmsY+KckiUbRQ6c4g2
X-Received: by 2002:a17:902:fa2:: with SMTP id 31mr96602636plz.38.1564127143638;
        Fri, 26 Jul 2019 00:45:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564127143; cv=none;
        d=google.com; s=arc-20160816;
        b=mzkwOkBg3wbjPNhozB2ulrP4W3tuBnM/yr/DrjC0QWoL8pRhvGNR74ErWy+2xaRjb/
         8dy7ggzxmQw85MwiCOfJBfTh3cBNdmNVNeeJDATukVcxbjtVGrPxntkrfsNoLHoQjAmv
         KhxNfvYJfgX3Ngk/2MyB90TouW0ciE2JJl0e6VWKhBhNyN8gJG0UCMdyuNJgb7j6LZJ1
         fwcXciASYaSwYcenNlNmWogVGJX40AtII1Ia9dz8F/780KugICycHfZiDxYbcVW8Oe33
         sqe+NKXETcagtl4tcSlHX4MUnaT+ppldA1ysK/da6K7NbEL36mSeabtvqKeRDlOOEzcg
         qAFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=TLeWTt3s6e58GuErShWUt67OkdocH7fatcRDcKC2JN4=;
        b=u406+UELgwmuFhwZyhsOxIPKEByrHhEB2xIGRBgfsib1c9N0hPy6ndtL9KncpPIIJQ
         DZ8/OFjWIw1S9f7pGmt3yMGvenn1MYU+8aUVqOwrVRWtIaXy/9gZq6z8GPEGaE30svgD
         zQi7uaqShccN6gg/jhVuBM9GFKu38uYLZnemvpKTygv9NGLxdk/ez01NzGeAW9UsjMnW
         0PGVjOuPdYW2vlA175hyqEYmYZ6QehwTsrXLNlX5x+kqyJgqsM2H/NMAfk3etSNnzEuB
         Q+ATO4Ba2d1gJqADHjKv3qLqLKqtSegR/VNLi0bvljPiysepYA24rzBsfhp1DtGsee/Q
         edag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id l35si18182103plb.186.2019.07.26.00.45.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 00:45:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jul 2019 00:45:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,310,1559545200"; 
   d="scan'208";a="369456530"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by fmsmga005.fm.intel.com with ESMTP; 26 Jul 2019 00:45:40 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>,  Ingo Molnar <mingo@kernel.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Rik van Riel <riel@redhat.com>,  Mel Gorman <mgorman@suse.de>,  <jhladky@redhat.com>,  <lvenanci@redhat.com>,  Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] autonuma: Fix scan period updating
References: <20190725080124.494-1-ying.huang@intel.com>
	<20190725173516.GA16399@linux.vnet.ibm.com>
Date: Fri, 26 Jul 2019 15:45:39 +0800
In-Reply-To: <20190725173516.GA16399@linux.vnet.ibm.com> (Srikar Dronamraju's
	message of "Thu, 25 Jul 2019 23:05:16 +0530")
Message-ID: <87y30l5jdo.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Srikar,

Srikar Dronamraju <srikar@linux.vnet.ibm.com> writes:

> * Huang, Ying <ying.huang@intel.com> [2019-07-25 16:01:24]:
>
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> From the commit log and comments of commit 37ec97deb3a8 ("sched/numa:
>> Slow down scan rate if shared faults dominate"), the autonuma scan
>> period should be increased (scanning is slowed down) if the majority
>> of the page accesses are shared with other processes.  But in current
>> code, the scan period will be decreased (scanning is speeded up) in
>> that situation.
>> 
>> The commit log and comments make more sense.  So this patch fixes the
>> code to make it match the commit log and comments.  And this has been
>> verified via tracing the scan period changing and /proc/vmstat
>> numa_pte_updates counter when running a multi-threaded memory
>> accessing program (most memory areas are accessed by multiple
>> threads).
>> 
>
> Lets split into 4 modes.
> More Local and Private Page Accesses:
> We definitely want to scan slowly i.e increase the scan window.
>
> More Local and Shared Page Accesses:
> We still want to scan slowly because we have consolidated and there is no
> point in scanning faster. So scan slowly + increase the scan window.
> (Do remember access on any active node counts as local!!!)
>
> More Remote + Private page Accesses:
> Most likely the Private accesses are going to be local accesses.
>
> In the unlikely event of the private accesses not being local, we should
> scan faster so that the memory and task consolidates.
>
> More Remote + Shared page Accesses: This means the workload has not
> consolidated and needs to scan faster. So we need to scan faster.

This sounds reasonable.  But

lr_ratio < NUMA_PERIOD_THRESHOLD

doesn't indicate More Remote.  If Local = Remote, it is also true.  If
there are also more Shared, we should slow down the scanning.  So, the
logic could be

if (lr_ratio >= NUMA_PERIOD_THRESHOLD)
    slow down scanning
else if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
    if (NUMA_PERIOD_SLOTS - lr_ratio >= NUMA_PERIOD_THRESHOLD)
        speed up scanning
    else
        slow down scanning
} else
   speed up scanning

This follows your idea better?

Best Regards,
Huang, Ying

> So I would think we should go back to before 37ec97deb3a8.
>
> i.e 
>
> 	int slot = lr_ratio - NUMA_PERIOD_THRESHOLD;
>
> 	if (!slot)
> 		slot = 1;
> 	diff = slot * period_slot;
>
>
> No?
>
>> Fixes: 37ec97deb3a8 ("sched/numa: Slow down scan rate if shared faults dominate")
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: jhladky@redhat.com
>> Cc: lvenanci@redhat.com
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>  kernel/sched/fair.c | 20 ++++++++++----------
>>  1 file changed, 10 insertions(+), 10 deletions(-)
>> 
>> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
>> index 036be95a87e9..468a1c5038b2 100644
>> --- a/kernel/sched/fair.c
>> +++ b/kernel/sched/fair.c
>> @@ -1940,7 +1940,7 @@ static void update_task_scan_period(struct task_struct *p,
>>  			unsigned long shared, unsigned long private)
>>  {
>>  	unsigned int period_slot;
>> -	int lr_ratio, ps_ratio;
>> +	int lr_ratio, sp_ratio;
>>  	int diff;
>>  
>>  	unsigned long remote = p->numa_faults_locality[0];
>> @@ -1971,22 +1971,22 @@ static void update_task_scan_period(struct task_struct *p,
>>  	 */
>>  	period_slot = DIV_ROUND_UP(p->numa_scan_period, NUMA_PERIOD_SLOTS);
>>  	lr_ratio = (local * NUMA_PERIOD_SLOTS) / (local + remote);
>> -	ps_ratio = (private * NUMA_PERIOD_SLOTS) / (private + shared);
>> +	sp_ratio = (shared * NUMA_PERIOD_SLOTS) / (private + shared);
>>  
>> -	if (ps_ratio >= NUMA_PERIOD_THRESHOLD) {
>> +	if (sp_ratio >= NUMA_PERIOD_THRESHOLD) {
>>  		/*
>> -		 * Most memory accesses are local. There is no need to
>> -		 * do fast NUMA scanning, since memory is already local.
>> +		 * Most memory accesses are shared with other tasks.
>> +		 * There is no point in continuing fast NUMA scanning,
>> +		 * since other tasks may just move the memory elsewhere.
>
> With this change, I would expect that with Shared page accesses,
> consolidation to take a hit.
>
>>  		 */
>> -		int slot = ps_ratio - NUMA_PERIOD_THRESHOLD;
>> +		int slot = sp_ratio - NUMA_PERIOD_THRESHOLD;
>>  		if (!slot)
>>  			slot = 1;
>>  		diff = slot * period_slot;
>>  	} else if (lr_ratio >= NUMA_PERIOD_THRESHOLD) {
>>  		/*
>> -		 * Most memory accesses are shared with other tasks.
>> -		 * There is no point in continuing fast NUMA scanning,
>> -		 * since other tasks may just move the memory elsewhere.
>> +		 * Most memory accesses are local. There is no need to
>> +		 * do fast NUMA scanning, since memory is already local.
>
> Comment wise this make sense.
>
>>  		 */
>>  		int slot = lr_ratio - NUMA_PERIOD_THRESHOLD;
>>  		if (!slot)
>> @@ -1998,7 +1998,7 @@ static void update_task_scan_period(struct task_struct *p,
>>  		 * yet they are not on the local NUMA node. Speed up
>>  		 * NUMA scanning to get the memory moved over.
>>  		 */
>> -		int ratio = max(lr_ratio, ps_ratio);
>> +		int ratio = max(lr_ratio, sp_ratio);
>>  		diff = -(NUMA_PERIOD_THRESHOLD - ratio) * period_slot;
>>  	}
>>  
>> -- 
>> 2.20.1
>> 

