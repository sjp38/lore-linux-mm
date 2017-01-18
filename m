Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB6D46B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:50:28 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id an2so1476013wjc.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:50:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n107si28470800wrb.302.2017.01.18.01.50.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 01:50:27 -0800 (PST)
Subject: Re: [RFC 3/4] mm, page_alloc: move cpuset seqcount checking to
 slowpath
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-4-vbabka@suse.cz>
 <20170118094054.GJ7015@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7b984dde-78c5-2efc-daef-bcdcc51fc9cb@suse.cz>
Date: Wed, 18 Jan 2017 10:48:55 +0100
MIME-Version: 1.0
In-Reply-To: <20170118094054.GJ7015@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Ganapatrao Kulkarni <gpkulkarni@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/18/2017 10:40 AM, Michal Hocko wrote:
> On Tue 17-01-17 23:16:09, Vlastimil Babka wrote:
>> This is a preparation for the following patch to make review simpler. While
>> the primary motivation is a bug fix, this could also save some cycles in the
>> fast path.
>
> I cannot say I would be happy about this patch :/ The code is still very
> confusing and subtle. I really think we should get rid of
> synchronization with the concurrent cpuset/mempolicy updates instead.
> Have you considered that instead?

Not so thoroughly yet, but I already suspect it would be intrusive for stable. 
We could make copies of nodemask and mems_allowed and protect just the copying 
with seqcount, but that would mean overhead and stack space. Also we might try 
revert 682a3385e773 ("mm, page_alloc: inline the fast path of the zonelist 
iterator") ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
