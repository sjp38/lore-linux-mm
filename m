Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8316B025E
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 05:12:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so53803589wma.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 02:12:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 78si13701800wmq.114.2016.07.18.02.12.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 02:12:55 -0700 (PDT)
Subject: Re: [PATCH v3 09/17] mm, compaction: make whole_zone flag ignore
 cached scanner positions
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-10-vbabka@suse.cz>
 <20160706050939.GD23627@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1c0e2da2-115e-d676-cfec-e572270789ca@suse.cz>
Date: Mon, 18 Jul 2016 11:12:51 +0200
MIME-Version: 1.0
In-Reply-To: <20160706050939.GD23627@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 07/06/2016 07:09 AM, Joonsoo Kim wrote:
> On Fri, Jun 24, 2016 at 11:54:29AM +0200, Vlastimil Babka wrote:
>> A recent patch has added whole_zone flag that compaction sets when scanning
>> starts from the zone boundary, in order to report that zone has been fully
>> scanned in one attempt. For allocations that want to try really hard or cannot
>> fail, we will want to introduce a mode where scanning whole zone is guaranteed
>> regardless of the cached positions.
>>
>> This patch reuses the whole_zone flag in a way that if it's already passed true
>> to compaction, the cached scanner positions are ignored. Employing this flag
>
> Okay. But, please don't reset cached scanner position even if whole_zone
> flag is set. Just set cc->migrate_pfn and free_pfn, appropriately. With

Won't that result in confusion on cached position updates during 
compaction where it checks the previous cached position? I wonder what 
kinds of corner cases it can bring...

> your following patches, whole_zone could be set without any compaction
> try

I don't understand what you mean here? Even after whole series, 
whole_zone is only checked, and positions thus reset, after passing the 
compaction_suitable() call from compact_zone(). So at that point we can 
say that compaction is being actually tried and it's not a drive-by reset?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
