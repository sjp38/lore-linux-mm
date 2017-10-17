Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 447236B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 02:51:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o44so353112wrf.0
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 23:51:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e8si1442325wrd.327.2017.10.16.23.51.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 23:51:08 -0700 (PDT)
Subject: Re: [patch] mm, compaction: properly initialize alloc_flags in
 compact_control
References: <alpine.DEB.2.10.1710161503020.102726@chino.kir.corp.google.com>
 <20171016151252.ee4cc68f7e022bab447478d4@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cf51bc1a-8e12-8c91-3012-238a65ce1c55@suse.cz>
Date: Tue, 17 Oct 2017 08:51:07 +0200
MIME-Version: 1.0
In-Reply-To: <20171016151252.ee4cc68f7e022bab447478d4@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/17/2017 12:12 AM, Andrew Morton wrote:
> On Mon, 16 Oct 2017 15:03:37 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
>>
>> compaction_suitable() requires a useful cc->alloc_flags, otherwise the
>> results of compact_zone() can be indeterminate.  Kcompactd currently
>> checks compaction_suitable() itself with alloc_flags == 0, but passes an
>> uninitialized value from the stack to compact_zone(), which does its own
>> check.
>>
>> The same is true for compact_node() when explicitly triggering full node
>> compaction.
>>
>> Properly initialize cc.alloc_flags on the stack.
>>
> 
> The compiler will zero any not-explicitly-initialized fields in these
> initializers.

Right.

>> @@ -1945,8 +1947,8 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>>  		if (compaction_deferred(zone, cc.order))
>>  			continue;
>>  
>> -		if (compaction_suitable(zone, cc.order, 0, zoneid) !=
>> -							COMPACT_CONTINUE)
>> +		if (compaction_suitable(zone, cc.order, cc.alloc_flags,
>> +					zoneid) != COMPACT_CONTINUE)
>>  			continue;
> 
> So afaict the above hunk is the only functional change here.  It will
> propagate any of compact_zone()'s modifications to cc->alloc_flags into
> succeeding calls to compaction_suitable().  I suspect this is a
> no-op (didn't look), and it wasn't changelogged.

compact_zone() shouldn't modify cc->alloc_flags. Actually, it's even
declared as "const" in struct compact_control.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
