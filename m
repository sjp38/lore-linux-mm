Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id B21AA6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 17:41:47 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id b35so77356088qge.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:41:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z203si17374602qka.44.2016.01.29.14.41.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 14:41:47 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <20160128235815.GA5953@cmpxchg.org>
 <56AABA79.3030103@cisco.com> <56AAC085.9060509@cisco.com>
 <20160129015534.GA6401@cmpxchg.org>
From: Rik van Riel <riel@redhat.com>
Message-ID: <56ABEAA7.1020706@redhat.com>
Date: Fri, 29 Jan 2016 17:41:43 -0500
MIME-Version: 1.0
In-Reply-To: <20160129015534.GA6401@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Daniel Walker <danielwa@cisco.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

On 01/28/2016 08:55 PM, Johannes Weiner wrote:
> On Thu, Jan 28, 2016 at 05:29:41PM -0800, Daniel Walker wrote:
>> On 01/28/2016 05:03 PM, Daniel Walker wrote:
>> [regarding MemAvaiable]
>>
>> This new metric purportedly helps usrespace assess available memory. But,
>> its again based on heuristic, it takes 1/2 of page cache as reclaimable..
> 
> No, it takes the smaller value of cache/2 and the low watermark, which
> is a fraction of memory. Actually, that does look a little weird. Rik?

No, not quite.  The page cache calculation spans two lines:

        pagecache = pages[LRU_ACTIVE_FILE] + pages[LRU_INACTIVE_FILE];
        pagecache -= min(pagecache / 2, wmark_low);

The assumption is that ALL of active & inactive file LRUs are
freeable, except for the minimum of the low watermark, or
half the page cache.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
