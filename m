Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7386B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 15:34:52 -0500 (EST)
Received: by wmww144 with SMTP id w144so231154338wmw.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 12:34:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w10si45572721wma.83.2015.12.02.12.34.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 12:34:50 -0800 (PST)
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
References: <20151125143010.GI27283@dhcp22.suse.cz>
 <1448899821-9671-1-git-send-email-vbabka@suse.cz>
 <87io4hi06n.fsf@rasmusvillemoes.dk>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <565F55E6.6080201@suse.cz>
Date: Wed, 2 Dec 2015 21:34:46 +0100
MIME-Version: 1.0
In-Reply-To: <87io4hi06n.fsf@rasmusvillemoes.dk>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On 12/02/2015 12:01 PM, Rasmus Villemoes wrote:
> On Mon, Nov 30 2015, Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> I'd prefer to have the formatting code in vsprintf.c, so that we'd avoid
> having to call vsnprintf recursively (and repeatedly - not that this is
> going to be used in hot paths, but if the box is going down it might be
> nice to get the debug info out a few thousand cycles earlier). That'll
> also make it easier to avoid the bugs below.

OK, I'll try.

>> diff --git a/Documentation/printk-formats.txt b/Documentation/printk-formats.txt
>> index b784c270105f..4b5156e74b09 100644
>> --- a/Documentation/printk-formats.txt
>> +++ b/Documentation/printk-formats.txt
>> @@ -292,6 +292,20 @@ Raw pointer value SHOULD be printed with %p. The kernel supports
>>  
>>  	Passed by reference.
>>  
>> +Flags bitfields such as page flags, gfp_flags:
>> +
>> +	%pgp	0x1fffff8000086c(referenced|uptodate|lru|active|private)
>> +	%pgg	0x24202c4(GFP_USER|GFP_DMA32|GFP_NOWARN)
>> +	%pgv	0x875(read|exec|mayread|maywrite|mayexec|denywrite)
>> +
> 
> I think it would be better (and more flexible) if %pg* only stood for
> printing the | chain of strings. Let people pass the flags twice if they
> also want the numeric value; then they're also able to choose 0-padding
> and whatnot, can use other kinds of parentheses, etc., etc. So
> 
>   pr_emerg("flags: 0x%08lu [%pgp]\n", printflags, &printflags)

I had it initially like this, but then thought it was somewhat repetitive and
all current users did use the same format. But I agree it's more generic to do
it as you say so I'll change it.

>> @@ -1361,6 +1362,29 @@ char *clock(char *buf, char *end, struct clk *clk, struct printf_spec spec,
>>  	}
>>  }
>>  
>> +static noinline_for_stack
>> +char *flags_string(char *buf, char *end, void *flags_ptr,
>> +			struct printf_spec spec, const char *fmt)
>> +{
>> +	unsigned long flags;
>> +	gfp_t gfp_flags;
>> +
>> +	switch (fmt[1]) {
>> +	case 'p':
>> +		flags = *(unsigned long *)flags_ptr;
>> +		return format_page_flags(flags, buf, end);
>> +	case 'v':
>> +		flags = *(unsigned long *)flags_ptr;
>> +		return format_vma_flags(flags, buf, end);
>> +	case 'g':
>> +		gfp_flags = *(gfp_t *)flags_ptr;
>> +		return format_gfp_flags(gfp_flags, buf, end);
>> +	default:
>> +		WARN_ONCE(1, "Unsupported flags modifier: %c\n", fmt[1]);
>> +		return 0;
>> +	}
>> +}
>> +
> 
> That return 0 aka return NULL will lead to an oops when the next thing
> is printed. Did you mean 'return buf;'? 

Uh, right.

>>  
>> -static void dump_flag_names(unsigned long flags,
>> -			const struct trace_print_flags *names, int count)
>> +static char *format_flag_names(unsigned long flags, unsigned long mask_out,
>> +		const struct trace_print_flags *names, int count,
>> +		char *buf, char *end)
>>  {
>>  	const char *delim = "";
>>  	unsigned long mask;
>>  	int i;
>>  
>> -	pr_cont("(");
>> +	buf += snprintf(buf, end - buf, "%#lx(", flags);
> 
> Sorry, you can't do it like this. The buf you've been passed from inside
> vsnprintf may be beyond end

Ah, didn't realize that :/

> , so end-buf is a negative number which will
> (get converted to a huge positive size_t and) trigger a WARN_ONCE and
> get you a return value of 0.
> 
> 
>> +	flags &= ~mask_out;
>>  
>>  	for (i = 0; i < count && flags; i++) {
>> +		if (buf >= end)
>> +			break;
> 
> Even if you fix the above, this is also wrong. We have to return the
> length of the string that would be generated if there was room enough,
> so we cannot make an early return like this. As I said above, the
> easiest way to do that is to do it inside vsprintf.c, where we have
> e.g. string() available. So I'd do something like
> 
> 
> char *format_flags(char *buf, char *end, unsigned long flags,
>                    const struct trace_print_flags *names)
> {
>   unsigned long mask;
>   const struct printf_spec strspec = {/* appropriate defaults*/}
>   const struct printf_spec numspec = {/* appropriate defaults*/}
> 
>   for ( ; flags && names->mask; names++) {
>     mask = names->mask;
>     if ((flags & mask) != mask)
>       continue;
>     flags &= ~mask;
>     buf = string(buf, end, names->name, strspec);
>     if (flags) {
>       if (buf < end)
>         *buf = '|';
>       buf++;
>     }
>   }
>   if (flags)
>     buf = number(buf, end, flags, numspec);
>   return buf;
> }

Thanks a lot for your review and suggestions!

> [where I've assumed that the trace_print_flags array is terminated with
> an entry with 0 mask. Passing its length is also possible, but maybe a
> little awkward if the arrays are defined in mm/ and contents depend on
> .config.] 

> Then flags_string() would call this directly with an appropriate array
> for names, and we avoid the individual tiny helper
> functions. flags_string() can still do the mask_out thing for page
> flags, especially when/if the numeric and string representations are not
> done at the same time.
> 
> Rasmus

Zero-terminated array is a good idea to get rid of the ARRAY_SIZE with helpers
needing to live in the same .c file etc.

But if I were to keep the array definitions in mm/debug.c with declarations
(which don't know the size yet) in e.g. <linux/mmdebug.h> (which lib/vsnprintf.c
would include so that format_flags() can reference them, is there a more elegant
way than the one below?

--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -7,6 +7,9 @@
 struct page;
 struct vm_area_struct;
 struct mm_struct;
+struct trace_print_flags; // can't include trace_events.h here
+
+extern const struct trace_print_flags *pageflag_names;

 extern void dump_page(struct page *page, const char *reason);
 extern void dump_page_badflags(struct page *page, const char *reason,
diff --git a/mm/debug.c b/mm/debug.c
index a092111920e7..1cbc60544b87 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -23,7 +23,7 @@ char *migrate_reason_names[MR_TYPES] = {
 	"cma",
 };

-static const struct trace_print_flags pageflag_names[] = {
+const struct trace_print_flags __pageflag_names[] = {
 	{1UL << PG_locked,		"locked"	},
 	{1UL << PG_error,		"error"		},
 	{1UL << PG_referenced,		"referenced"	},
@@ -59,6 +59,8 @@ static const struct trace_print_flags pageflag_names[] = {
 #endif
 };

+const struct trace_print_flags *pageflag_names = &__pageflag_names[0];



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
