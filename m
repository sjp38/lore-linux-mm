Message-ID: <482130D6.8020306@cn.fujitsu.com>
Date: Wed, 07 May 2008 12:32:22 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc.c: fix a typo
References: <4820272C.4060009@cn.fujitsu.com>	<482027E4.6030300@cn.fujitsu.com>	<482029E7.6070308@cn.fujitsu.com> <20080506071943.46641c26.akpm@linux-foundation.org> <4821057F.8090706@cn.fujitsu.com>
In-Reply-To: <4821057F.8090706@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index bdd5c43..d0ba10d 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -303,7 +303,7 @@ static void destroy_compound_page(struct page *page, unsigned long order)
>>>  	for (i = 1; i < nr_pages; i++) {
>>>  		struct page *p = page + i;
>>>  
>>> -		if (unlikely(!PageTail(p) |
>>> +		if (unlikely(!PageTail(p) ||
>>>  				(p->first_page != page)))
>>>  			bad_page(page);
>>>  		__ClearPageTail(p);
>> I have a vague memory that the "|" was deliberate.  Most of the time,
>> "!PageTail" will be false so most of the time we won't take the first
> 
> !PageTail will be true if nothing bad happened, corrected me if I'm wrong:
> 

Silly, I was wrong...

Christoph Lameter wrote:
> I think the | there was some developers attempt to avoid gcc generating 
> too many branches. I am fine either way.
> 

Yes, I found out it's 224abf92b2f439a9030f21d2926ec8047d1ffcdb :

[PATCH] mm: bad_page optimisation
Nick Piggin [Fri, 6 Jan 2006 08:11:11 +0000 (00:11 -0800)]

Cut down size slightly by not passing bad_page the function name (it should be
able to be determined by dump_stack()).  And cut down the number of printks in
bad_page.

Also, cut down some branching in the destroy_compound_page path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
