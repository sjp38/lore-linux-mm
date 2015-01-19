Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 27CB16B0032
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 23:27:18 -0500 (EST)
Received: by mail-ie0-f181.google.com with SMTP id vy18so6806196iec.12
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 20:27:17 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id a15si11841801icg.87.2015.01.18.20.27.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Jan 2015 20:27:17 -0800 (PST)
Message-ID: <54BC879C.90505@codeaurora.org>
Date: Mon, 19 Jan 2015 09:57:08 +0530
From: Vinayak Menon <vinmenon@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in too_many_isolated
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org> <20150114165036.GI4706@dhcp22.suse.cz> <54B7F7C4.2070105@codeaurora.org> <20150116154922.GB4650@dhcp22.suse.cz> <54BA7D3A.40100@codeaurora.org> <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On 01/18/2015 01:18 AM, Christoph Lameter wrote:
> On Sat, 17 Jan 2015, Vinayak Menon wrote:
>
>> which had not updated the vmstat_diff. This CPU was in idle for around 30
>> secs. When I looked at the tvec base for this CPU, the timer associated with
>> vmstat_update had its expiry time less than current jiffies. This timer had
>> its deferrable flag set, and was tied to the next non-deferrable timer in the
>
> We can remove the deferrrable flag now since the vmstat threads are only
> activated as necessary with the recent changes. Looks like this could fix
> your issue?
>

Yes, this should fix my issue.
But I think we may need the fix in too_many_isolated, since there can 
still be a delay of few seconds (HZ by default and even more because of 
reasons pointed out by Michal) which will result in reclaimers 
unnecessarily entering congestion_wait. No ?


-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
