Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 092E282F82
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:41:23 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id u63so13665422wmu.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 00:41:22 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id dk1si17397166wjb.36.2015.12.10.00.41.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 00:41:21 -0800 (PST)
Received: by wmec201 with SMTP id c201so14430687wme.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 00:41:20 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH v2 1/3] mm, printk: introduce new format string for flags
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
	<1449242195-16374-1-git-send-email-vbabka@suse.cz>
	<20151210025944.GB17967@js1304-P5Q-DELUXE>
	<20151210040456.GC7814@home.goodmis.org>
Date: Thu, 10 Dec 2015 09:41:18 +0100
In-Reply-To: <20151210040456.GC7814@home.goodmis.org> (Steven Rostedt's
	message of "Wed, 9 Dec 2015 23:04:56 -0500")
Message-ID: <87si3ay9u9.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Thu, Dec 10 2015, Steven Rostedt <rostedt@goodmis.org> wrote:

> On Thu, Dec 10, 2015 at 11:59:44AM +0900, Joonsoo Kim wrote:
>> 
>>   [page_ref:page_ref_unfreeze] bad op token &
>>   [page_ref:page_ref_set] bad op token &
>>   [page_ref:page_ref_mod_unless] bad op token &
>>   [page_ref:page_ref_mod_and_test] bad op token &
>>   [page_ref:page_ref_mod_and_return] bad op token &
>>   [page_ref:page_ref_mod] bad op token &
>>   [page_ref:page_ref_freeze] bad op token &
>> 
>> Following is the format I used.
>> 
>> TP_printk("pfn=0x%lx flags=%pgp count=%d mapcount=%d mapping=%p mt=%d val=%d ret=%d",
>>                 __entry->pfn, &__entry->flags, __entry->count,
>>                 __entry->mapcount, __entry->mapping, __entry->mt,
>>                 __entry->val, __entry->ret)
>> 
>> Could it be solved by 'trace-cmd' itself?
>> Or it's better to pass flags by value?
>> Or should I use something like show_gfp_flags()?
>
> Yes this can be solved in perf and trace-cmd via the parse-events.c file. And
> as soon as that happens, whatever method we decide upon becomes a userspace
> ABI. So don't think you can change it later.

So somewhat off-topic, but this reminds me of a question I've been
meaning to ask: What makes it safe to stash the pointer values in
vbin_printf and only dereference them later in bstr_printf? For plain
pointer printing (%p) it's of course not a problem, but quite a few of
the %p extensions do dereference the pointer in one way or another (at
least %p[dD], %p[mM], %p[iI], %ph, %pE, %pC, %pNF, %pU, %pa and probably
soon %pg).

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
