Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5E56B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 02:55:00 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so5802835lfi.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 23:55:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ze8si4741114wjb.11.2016.07.18.23.54.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 23:54:58 -0700 (PDT)
Subject: Re: [PATCH v3 09/17] mm, compaction: make whole_zone flag ignore
 cached scanner positions
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-10-vbabka@suse.cz>
 <20160706050939.GD23627@js1304-P5Q-DELUXE>
 <1c0e2da2-115e-d676-cfec-e572270789ca@suse.cz>
 <20160719064406.GB17479@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a0f361d0-1b38-5729-d9a7-0026f71b790e@suse.cz>
Date: Tue, 19 Jul 2016 08:54:55 +0200
MIME-Version: 1.0
In-Reply-To: <20160719064406.GB17479@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 07/19/2016 08:44 AM, Joonsoo Kim wrote:
> On Mon, Jul 18, 2016 at 11:12:51AM +0200, Vlastimil Babka wrote:
>> On 07/06/2016 07:09 AM, Joonsoo Kim wrote:
>>> On Fri, Jun 24, 2016 at 11:54:29AM +0200, Vlastimil Babka wrote:
>>>> A recent patch has added whole_zone flag that compaction sets when scanning
>>>> starts from the zone boundary, in order to report that zone has been fully
>>>> scanned in one attempt. For allocations that want to try really hard or cannot
>>>> fail, we will want to introduce a mode where scanning whole zone is guaranteed
>>>> regardless of the cached positions.
>>>>
>>>> This patch reuses the whole_zone flag in a way that if it's already passed true
>>>> to compaction, the cached scanner positions are ignored. Employing this flag
>>>
>>> Okay. But, please don't reset cached scanner position even if whole_zone
>>> flag is set. Just set cc->migrate_pfn and free_pfn, appropriately. With
>>
>> Won't that result in confusion on cached position updates during
>> compaction where it checks the previous cached position? I wonder
>> what kinds of corner cases it can bring...
>
> whole_zone would come along with ignore_skip_hint so I think that
> there is no problem on cached position updating.

Right, that's true.

>>
>>> your following patches, whole_zone could be set without any compaction
>>> try
>>
>> I don't understand what you mean here? Even after whole series,
>> whole_zone is only checked, and positions thus reset, after passing
>> the compaction_suitable() call from compact_zone(). So at that point
>> we can say that compaction is being actually tried and it's not a
>> drive-by reset?
>
> My point is that we should not initialize zone's cached pfn in case of
> the whole_zone because what compaction with COMPACT_PRIO_SYNC_FULL
> want is just to scan whole range. zone's cached pfn exists for
> efficiency and there is no reason to initialize it by compaction with
> COMPACT_PRIO_SYNC_FULL. If there are some parallel compaction users,
> they could be benefit from un-initialized zone's cached pfn so I'd
> like to leave them.

I doubt they will benefit much, but OK, I'll update the patch.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
