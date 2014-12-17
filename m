Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 998666B0075
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 07:11:36 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so16376964pad.10
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 04:11:36 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ty10si5423523pbc.66.2014.12.17.04.11.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Dec 2014 04:11:35 -0800 (PST)
Message-ID: <549172F1.5050303@codeaurora.org>
Date: Wed, 17 Dec 2014 17:41:29 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: Provide knob for force OOM into the memcg
References: <1418736335-30915-1-git-send-email-cpandya@codeaurora.org> <20141216165922.GA30984@phnom.home.cmpxchg.org>
In-Reply-To: <20141216165922.GA30984@phnom.home.cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: mhocko@suse.cz, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org


> Why do you move tasks around during runtime?  Rather than scanning
> thousands or millions of page table entries to relocate a task and its
> private memory to another configuration domain, wouldn't it be easier to
> just keep the task in a dedicated cgroup and reconfigure that instead?

Your suggestion is good. But in specific cases, we may have no choice 
but to migrate.

Take a case of an Android system where a process/app will never gets 
killed until there is really no scope of holding it any longer in RAM. 
So, when that process was running as a foreground process, it has to 
belong to a group which has no memory limit and cannot be killed. Now, 
when the same process goes into background and sits idle, it can be 
compressed and cached into some space in RAM. These cached processes are 
ever growing list and can be capped with some limit. Naturally, these 
processes belongs to different category and hence different cgroup which 
just controls such cached processes.

>
> There doesn't seem to be a strong usecase for charge migration that
> couldn't be solved by doing things slightly differently from userspace.
> Certainly not something that justifies the complexity that it adds to
> memcg model and it's synchronization requirements from VM hotpaths.
> Hence, I'm inclined to not add charge moving to version 2 of memcg.

Do you say charge migration is discouraged at runtime ? Difficult to 
live with this limitation.

-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
