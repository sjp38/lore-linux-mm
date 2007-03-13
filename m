Message-ID: <45F66D9B.7000301@yahoo.com.au>
Date: Tue, 13 Mar 2007 20:23:39 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/3] swsusp: Do not use page flags
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200703041507.57122.rjw@sisk.pl> <45F62CD2.5030103@yahoo.com.au> <200703131016.12935.rjw@sisk.pl>
In-Reply-To: <200703131016.12935.rjw@sisk.pl>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Pavel Machek <pavel@ucw.cz>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Johannes Berg <johannes@sipsolutions.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Rafael J. Wysocki wrote:
> On Tuesday, 13 March 2007 05:47, Nick Piggin wrote:
> 
>>Rafael J. Wysocki wrote:
>>
>>
>>> }
>>> 
>>> /**
>>>+ *	This structure represents a range of page frames the contents of which
>>>+ *	should not be saved during the suspend.
>>>+ */
>>>+
>>>+struct nosave_region {
>>>+	struct list_head list;
>>>+	unsigned long start_pfn;
>>>+	unsigned long end_pfn;
>>>+};
>>>+
>>>+static LIST_HEAD(nosave_regions);
>>>+
>>>+/**
>>>+ *	register_nosave_region - register a range of page frames the contents
>>>+ *	of which should not be saved during the suspend (to be used in the early
>>>+ *	initializatoion code)
>>>+ */
>>>+
>>>+void __init
>>>+register_nosave_region(unsigned long start_pfn, unsigned long end_pfn)
>>>+{
>>>+	struct nosave_region *region;
>>>+
>>>+	if (start_pfn >= end_pfn)
>>>+		return;
>>>+
>>>+	if (!list_empty(&nosave_regions)) {
>>>+		/* Try to extend the previous region (they should be sorted) */
>>>+		region = list_entry(nosave_regions.prev,
>>>+					struct nosave_region, list);
>>>+		if (region->end_pfn == start_pfn) {
>>>+			region->end_pfn = end_pfn;
>>>+			goto Report;
>>>+		}
>>>+	}
>>>+	/* This allocation cannot fail */
>>>+	region = alloc_bootmem_low(sizeof(struct nosave_region));
>>>+	region->start_pfn = start_pfn;
>>>+	region->end_pfn = end_pfn;
>>>+	list_add_tail(&region->list, &nosave_regions);
>>>+ Report:
>>>+	printk("swsusp: Registered nosave memory region: %016lx - %016lx\n",
>>>+		start_pfn << PAGE_SHIFT, end_pfn << PAGE_SHIFT);
>>>+}
>>
>>
>>I wonder why you reimplemented this and put it in snapshot.c, rather than
>>use my version which was nicely in its own file, had appropriate locking,
>>etc.?
> 
> 
> Well, the locking is not necessary and we only need a list for that.  Also,

I wouldn't say that. You're creating an interface here that is going to be
used outside swsusp. Users of that interface may not need locking now, but
that could cause problems down the line.

Sure you don't _need_ an rbtree, but our implementation makes it so simple
that there isn't much downside.

> mark_nosave_pages() refers to a function that's invisible outside snapshot.c
> and I didn't think it was a good idea to separate mark_nosave_pages()
> from register_nosave_region().

But that's because you even use mark_nosave_pages in your implementation.
Mine uses the nosave regions directly.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
