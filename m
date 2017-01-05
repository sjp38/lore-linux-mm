Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 51B7E6B0253
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 05:15:20 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so87447008wms.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 02:15:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i21si81278134wmf.35.2017.01.05.02.15.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 02:15:19 -0800 (PST)
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] slab reclaim
References: <20161228130949.GA11480@dhcp22.suse.cz>
 <20170102110257.GB18058@quack2.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b3e28101-1129-d2bc-8695-e7f7529a1442@suse.cz>
Date: Thu, 5 Jan 2017 11:15:17 +0100
MIME-Version: 1.0
In-Reply-To: <20170102110257.GB18058@quack2.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 01/02/2017 12:02 PM, Jan Kara wrote:
> Hi!
> 
> On Wed 28-12-16 14:09:51, Michal Hocko wrote:
>> I would like to propose the following for LSF/MM discussion. Both MM and
>> FS people should be involved.
>>
>> The current way of the slab reclaim is rather suboptimal from 2
>> perspectives.
>>
>> 1) The slab allocator relies on shrinkers to release pages but shrinkers
>> are object rather than page based. This means that the memory reclaim
>> asks to free some pages, slab asks shrinkers to free some objects
>> and the result might be that nothing really gets freed even though
>> shrinkers do their jobs properly because some objects are still pinning
>> the page. This is not a new problem and it has been discussed in the
>> past. Dave Chinner has even suggested a solution [1] which sounds like
>> the right approach. There was no follow up and I believe we should
>> into implementing it.
>>
>> 2) The way we scale slab reclaim pressure depends on the regular LRU
>> reclaim. There are workloads which do not general a lot of pages on LRUs
>> while they still consume a lot of slab memory. We can end up even going
>> OOM because the slab reclaim doesn't free up enough. I am not really
>> sure how the proper solution should look like but either we need some
>> way of slab consumption throttling or we need a more clever slab
>> pressure estimation.
>>
>> [1] https://lkml.org/lkml/2010/2/8/329.
> 
> I'm interested in this topic although I think it currently needs more
> coding and experimenting than discussions...

Yeah, some of the related stuff that was discussed at Kernel Summit [1]
would be nice to have at least prototyped, i.e. the dentry cache
separation and the slab helper for providing objects on the same page?

[1] https://lwn.net/Articles/705758/

> 
> 								Honza
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
