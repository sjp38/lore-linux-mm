Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 58C626B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 07:37:43 -0500 (EST)
Received: by lfdl133 with SMTP id l133so88943856lfd.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 04:37:42 -0800 (PST)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id h7si5410979lbd.91.2015.12.03.04.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 04:37:41 -0800 (PST)
Received: by lbbkw15 with SMTP id kw15so722301lbb.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 04:37:41 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
References: <20151125143010.GI27283@dhcp22.suse.cz>
	<1448899821-9671-1-git-send-email-vbabka@suse.cz>
	<87io4hi06n.fsf@rasmusvillemoes.dk> <565F55E6.6080201@suse.cz>
Date: Thu, 03 Dec 2015 13:37:39 +0100
In-Reply-To: <565F55E6.6080201@suse.cz> (Vlastimil Babka's message of "Wed, 2
	Dec 2015 21:34:46 +0100")
Message-ID: <87mvtrpv1o.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Wed, Dec 02 2015, Vlastimil Babka <vbabka@suse.cz> wrote:

>> [where I've assumed that the trace_print_flags array is terminated with
>> an entry with 0 mask. Passing its length is also possible, but maybe a
>> little awkward if the arrays are defined in mm/ and contents depend on
>> .config.] 
...
>
>> Rasmus
>
> Zero-terminated array is a good idea to get rid of the ARRAY_SIZE with helpers
> needing to live in the same .c file etc.
>
> But if I were to keep the array definitions in mm/debug.c with declarations
> (which don't know the size yet) in e.g. <linux/mmdebug.h> (which lib/vsnprintf.c
> would include so that format_flags() can reference them, is there a more elegant
> way than the one below?
>
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -7,6 +7,9 @@
>  struct page;
>  struct vm_area_struct;
>  struct mm_struct;
> +struct trace_print_flags; // can't include trace_events.h here
> +
> +extern const struct trace_print_flags *pageflag_names;
>
>  extern void dump_page(struct page *page, const char *reason);
>  extern void dump_page_badflags(struct page *page, const char *reason,
> diff --git a/mm/debug.c b/mm/debug.c
> index a092111920e7..1cbc60544b87 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -23,7 +23,7 @@ char *migrate_reason_names[MR_TYPES] = {
>  	"cma",
>  };
>
> -static const struct trace_print_flags pageflag_names[] = {
> +const struct trace_print_flags __pageflag_names[] = {
>  	{1UL << PG_locked,		"locked"	},
>  	{1UL << PG_error,		"error"		},
>  	{1UL << PG_referenced,		"referenced"	},
> @@ -59,6 +59,8 @@ static const struct trace_print_flags pageflag_names[] = {
>  #endif
>  };
>
> +const struct trace_print_flags *pageflag_names = &__pageflag_names[0];

Ugh. I think it would be better if either the definition of struct
trace_print_flags is moved somewhere where everybody can see it or to
make our own identical type definition. For now I'd go with the latter,
also since this doesn't really have anything to do with the tracing
subsystem. Then just declare the array in the header

extern const struct print_flags pageflag_names[];

(If you do the extra indirection thing, __pageflag_names could still be
static, and it would be best to declare the pointer itself const as
well, but I'd rather we don't go that way.)

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
