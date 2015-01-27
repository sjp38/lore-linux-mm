Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5446B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 05:34:06 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so17746440pad.7
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 02:34:06 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id e12si1164865pat.39.2015.01.27.02.34.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jan 2015 02:34:05 -0800 (PST)
Message-ID: <54C76995.70501@codeaurora.org>
Date: Tue, 27 Jan 2015 16:03:57 +0530
From: Vinayak Menon <vinmenon@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in too_many_isolated
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org> <20150114165036.GI4706@dhcp22.suse.cz> <54B7F7C4.2070105@codeaurora.org> <20150116154922.GB4650@dhcp22.suse.cz> <54BA7D3A.40100@codeaurora.org> <alpine.DEB.2.11.1501171347290.25464@gentwo.org> <20150126172832.GC22681@dhcp22.suse.cz>
In-Reply-To: <20150126172832.GC22681@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On 01/26/2015 10:58 PM, Michal Hocko wrote:
> On Sat 17-01-15 13:48:34, Christoph Lameter wrote:
>> On Sat, 17 Jan 2015, Vinayak Menon wrote:
>>
>>> which had not updated the vmstat_diff. This CPU was in idle for around 30
>>> secs. When I looked at the tvec base for this CPU, the timer associated with
>>> vmstat_update had its expiry time less than current jiffies. This timer had
>>> its deferrable flag set, and was tied to the next non-deferrable timer in the
>>
>> We can remove the deferrrable flag now since the vmstat threads are only
>> activated as necessary with the recent changes. Looks like this could fix
>> your issue?
>
> OK, I have checked the history and the deferrable behavior has been
> introduced by 39bf6270f524 (VM statistics: Make timer deferrable) which
> hasn't offered any numbers which would justify the change. So I think it
> would be a good idea to revert this one as it can clearly cause issues.
>
> Could you retest with this change? It still wouldn't help with the
> highly overloaded workqueues but that sounds like a bigger change and
> this one sounds like quite safe to me so it is a good start.

Sure, I can retest.
Even without highly overloaded workqueues, there can be a delay of HZ in 
updating the counters. This means reclaim path can be blocked for a 
second or more, when there aren't really any isolated pages. So we need 
the fix in too_many_isolated also right ?


-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
