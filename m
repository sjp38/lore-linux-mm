Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5FD4C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:36:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71C372173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:36:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71C372173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05B8D8E0003; Tue, 26 Feb 2019 10:36:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F26818E0001; Tue, 26 Feb 2019 10:36:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEFA28E0003; Tue, 26 Feb 2019 10:36:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9818E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:36:36 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id m10so2391863lfk.6
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:36:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FmbORR29glRjvUF2UWvHeAnkgEj5K+ItpJ8AFL4loS8=;
        b=KV3N53Q1Ko4Mnuz1e23XXslApVL/HMpL0ymoWwGI42DQN19f2mEd07CQyHjTWRxCKl
         MgutgVCDEa5/bl2h6391B3WQJ9WmxWg++/dehGk8Y3oBBN5iR+qTGDUfR447kqq6C7gQ
         A6OBsk0Jh84VoUTr4Ly+/HoJJOyhYSPOYdRpeS+nzIA+3r0TKYK6CkyI0s6spj7jbuFp
         DV2m1NQc5rAfCtGMy2o4WlIyVY63F7IeDTLhFlGAvC5xjV+Q0b/qdy6OSXPFXIJ/BJu0
         0eaYmFyHqZ2MxhhwPK7fmFA9GSH66KdKAEHRIHF96EfWl7BtSn9PskJpskoOHRplfazI
         gl3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuZvtts/vAXRhCmXdwMI1/uXPXoytWXxXVB6Y4SFYFkueGbslSG6
	HJgG2kQT9nLOLDtGraDh6Xtgj6xVBrokBtKNT3B37z8Eh5bZc2ruOq5B41gO93KoKAYVqfF4AjS
	Df28P1nuvMoGqkvGva3bNzrPfpUqIaQnatQ/XUf6Ehe04N5ei2dIuRKq5qfTbXDb0yQ==
X-Received: by 2002:ac2:42c1:: with SMTP id n1mr12309404lfl.45.1551195395781;
        Tue, 26 Feb 2019 07:36:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib/rDuFnb5jLqq7fI/+Wd5PXsiNWJpMdvwavbkV3S5qfuK8bR+YunhHsEY3WNM/6jobLC+7
X-Received: by 2002:ac2:42c1:: with SMTP id n1mr12309360lfl.45.1551195394521;
        Tue, 26 Feb 2019 07:36:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551195394; cv=none;
        d=google.com; s=arc-20160816;
        b=s5grvwpe0dmH7TrS/WJlX+ue7AtQpe4TaZfi+QStuzwmBIXctaKZSKH14erHsaAE/0
         8DVk50kLO3+7ezqodTXJ1oM93b0wJ7VfT66rdpfKGUxG7C3755gLbxGb3YNzK+zAwQLP
         A7ScTnYtWJkqKtVEMPhPpqD9lA/uNpat+RmQD16rYARDAs8DM+FkwdwutEemEkDjFXlj
         +BSU6gUUNQR3pw/26Ea/WUI58y28CwTuP30UXRsVYZV+XLUcKrGhs8k+1fWYH+dWwmSg
         dH/GKhLmyLRFUV9OJirFuGp0Xuit6NmkFzAnwif6VEJk1b0WpvShNYOLWyJwSkvnWL0+
         fR8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=FmbORR29glRjvUF2UWvHeAnkgEj5K+ItpJ8AFL4loS8=;
        b=rp9BGJiVXan/eXDQo2BmGIbAci0VMNmToDCYA045/w0txMm1tDajVP5lUWNyCD93nm
         yznzDl8oJS4WjrsVzgHTJxd0dYHhsIUmyCbQ8sHBJOw4+Bau2P+3CnF6WHJwko7LjM/E
         8ljiublPTsJbMfcg/t6R/QauL8rqJe5Kv7yKAyUUW8HZlk+WCQNX/VDkr/tG5IU4a57R
         YP8KrzHQf6eMbGS5AdbS2Ld7U/54wzn9yNQTtkOXzMqAjXMcyFsIRS8iVoqMRDtTw78I
         h0WeeJtOVZ+04busEIOwtzwY7lCTaQLifGeAras29/aL/o/uACJvEtQDR+qfMk1qLQE+
         wsnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id d13si12190lfi.9.2019.02.26.07.36.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 07:36:34 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gyemJ-0000Cx-2M; Tue, 26 Feb 2019 18:36:19 +0300
Subject: Re: [PATCH RFC] mm/vmscan: try to protect active working set of
 cgroup from reclaim.
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
 Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>
References: <20190222175825.18657-1-aryabinin@virtuozzo.com>
 <20190225040255.GA31684@castle.DHCP.thefacebook.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <88207884-c643-eb2c-a784-6a7b11d0e7c7@virtuozzo.com>
Date: Tue, 26 Feb 2019 18:36:38 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190225040255.GA31684@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/25/19 7:03 AM, Roman Gushchin wrote:
> On Fri, Feb 22, 2019 at 08:58:25PM +0300, Andrey Ryabinin wrote:
>> In a presence of more than 1 memory cgroup in the system our reclaim
>> logic is just suck. When we hit memory limit (global or a limit on
>> cgroup with subgroups) we reclaim some memory from all cgroups.
>> This is sucks because, the cgroup that allocates more often always wins.
>> E.g. job that allocates a lot of clean rarely used page cache will push
>> out of memory other jobs with active relatively small all in memory
>> working set.
>>
>> To prevent such situations we have memcg controls like low/max, etc which
>> are supposed to protect jobs or limit them so they to not hurt others.
>> But memory cgroups are very hard to configure right because it requires
>> precise knowledge of the workload which may vary during the execution.
>> E.g. setting memory limit means that job won't be able to use all memory
>> in the system for page cache even if the rest the system is idle.
>> Basically our current scheme requires to configure every single cgroup
>> in the system.
>>
>> I think we can do better. The idea proposed by this patch is to reclaim
>> only inactive pages and only from cgroups that have big
>> (!inactive_is_low()) inactive list. And go back to shrinking active lists
>> only if all inactive lists are low.
> 
> Hi Andrey!
> 
> It's definitely an interesting idea! However, let me bring some concerns:
> 1) What's considered active and inactive depends on memory pressure inside
> a cgroup.

There is no such dependency. High memory pressure may be generated both
by active and inactive pages. We also can have a cgroup creating no pressure
with almost only active (or only inactive) pages.

> Actually active pages in one cgroup (e.g. just deleted) can be colder
> than inactive pages in an other (e.g. a memory-hungry cgroup with a tight
> memory.max).
> 

Well, yes, this is a drawback of having per-memcg lrus.

> Also a workload inside a cgroup can to some extend control what's going
> to the active LRU. So it opens a way to get more memory unfairly by
> artificially promoting more pages to the active LRU. So a cgroup
> can get an unfair advantage over other cgroups.
> 

Unfair is usually a negative term, but in this case it's very much depends on definition of what is "fair".

If fair means to put equal reclaim pressure on all cgroups, than yes, the patch
increases such unfairness, but such unfairness is a good thing.
Obviously it's more valuable to keep in memory actively used page than the page that not used.

> Generally speaking, now we have a way to measure the memory pressure
> inside a cgroup. So, in theory, it should be possible to balance
> scanning effort based on memory pressure.
> 

Simply by design, the inactive pages are the first candidates to reclaim.
Any decision that doesn't take into account inactive pages probably would be wrong.

E.g. cgroup A with active job loading a big and active working set which creates high memory pressure
and cgroup B - idle (no memory pressure) with a huge not used cache.
It's definitely preferable to reclaim from B rather than from A.

