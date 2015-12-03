Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3094E6B0253
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 08:46:15 -0500 (EST)
Received: by wmec201 with SMTP id c201so22809648wme.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 05:46:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k206si9264043wmf.116.2015.12.03.05.46.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 05:46:14 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
References: <20151125143010.GI27283@dhcp22.suse.cz>
 <1448899821-9671-1-git-send-email-vbabka@suse.cz>
 <87io4hi06n.fsf@rasmusvillemoes.dk> <565F55E6.6080201@suse.cz>
 <87mvtrpv1o.fsf@rasmusvillemoes.dk>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <566047A2.2050701@suse.cz>
Date: Thu, 3 Dec 2015 14:46:10 +0100
MIME-Version: 1.0
In-Reply-To: <87mvtrpv1o.fsf@rasmusvillemoes.dk>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On 12/03/2015 01:37 PM, Rasmus Villemoes wrote:
> On Wed, Dec 02 2015, Vlastimil Babka <vbabka@suse.cz> wrote:
>> --- a/include/linux/mmdebug.h
>> +++ b/include/linux/mmdebug.h
>> @@ -7,6 +7,9 @@
>>  struct page;
>>  struct vm_area_struct;
>>  struct mm_struct;
>> +struct trace_print_flags; // can't include trace_events.h here
>> +
>> +extern const struct trace_print_flags *pageflag_names;
>>
>>  extern void dump_page(struct page *page, const char *reason);
>>  extern void dump_page_badflags(struct page *page, const char *reason,
>> diff --git a/mm/debug.c b/mm/debug.c
>> index a092111920e7..1cbc60544b87 100644
>> --- a/mm/debug.c
>> +++ b/mm/debug.c
>> @@ -23,7 +23,7 @@ char *migrate_reason_names[MR_TYPES] = {
>>  	"cma",
>>  };
>>
>> -static const struct trace_print_flags pageflag_names[] = {
>> +const struct trace_print_flags __pageflag_names[] = {
>>  	{1UL << PG_locked,		"locked"	},
>>  	{1UL << PG_error,		"error"		},
>>  	{1UL << PG_referenced,		"referenced"	},
>> @@ -59,6 +59,8 @@ static const struct trace_print_flags pageflag_names[] = {
>>  #endif
>>  };
>>
>> +const struct trace_print_flags *pageflag_names = &__pageflag_names[0];
> 
> Ugh. I think it would be better if either the definition of struct
> trace_print_flags is moved somewhere where everybody can see it or to
> make our own identical type definition. For now I'd go with the latter,
> also since this doesn't really have anything to do with the tracing
> subsystem. Then just declare the array in the header
> 
> extern const struct print_flags pageflag_names[];

Ugh so yesterday I copy/pasted the definition and still got an error, which I
probably didn't read closely enough. I assumed that if it needs the full
definition of "struct trace_print_flags" here to know the size, it would also
need to know the lenght of the array as well.

But now it works. Well, copy/pasting the definition fails as long as both
headers are included and it's redefining the struct (even though it's the same
thing). But looks like I can move it from trace_events.h to tracepoint.h and it
won't blow off (knock knock).

I suck at C.

> (If you do the extra indirection thing, __pageflag_names could still be
> static, and it would be best to declare the pointer itself const as
> well, but I'd rather we don't go that way.)
> 
> Rasmus
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
