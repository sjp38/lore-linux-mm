Date: Thu, 15 Mar 2007 15:55:08 -0400 (EDT)
From: Ashif Harji <asharji@cs.uwaterloo.ca>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
In-Reply-To: <20070315162944.GI8321@wotan.suse.de>
Message-ID: <Pine.GSO.4.64.0703151532530.29483@cpu102.cs.uwaterloo.ca>
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca>
 <20070312142012.GH30777@atrey.karlin.mff.cuni.cz> <20070312143900.GB6016@wotan.suse.de>
 <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca>
 <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca>
 <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca>
 <45F96CCB.4000709@redhat.com> <20070315162944.GI8321@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Chuck Ebbert <cebbert@redhat.com>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.orgAndrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


On Thu, 15 Mar 2007, Nick Piggin wrote:

> On Thu, Mar 15, 2007 at 11:56:59AM -0400, Chuck Ebbert wrote:
>> Ashif Harji wrote:
>>>
>>> This patch unconditionally calls mark_page_accessed to prevent pages,
>>> especially for small files, from being evicted from the page cache
>>> despite frequent access.
>>>
>>> Signed-off-by: Ashif Harji <asharji@beta.uwaterloo.ca>
>>>
>>
>> I like mine better -- it leaves the comment:
>
> How about this? It also doesn't break the use-once heuristic.
>
> --
> A change to make database style random read() workloads perform better, by
> calling mark_page_accessed for some non-page-aligned reads broke the case of
> < PAGE_CACHE_SIZE files, which will not get their prev_index moved past the
> first page.
>
> Combine both heuristics for marking the page accessed.
>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
>
> Index: linux-2.6/mm/filemap.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap.c
> +++ linux-2.6/mm/filemap.c
> @@ -929,7 +929,7 @@ page_ok:
> 		 * When (part of) the same page is read multiple times
> 		 * in succession, only mark it as accessed the first time.
> 		 */
> -		if (prev_index != index)
> +		if (prev_index != index || !offset)
> 			mark_page_accessed(page);
> 		prev_index = index;
>
>

It sounds like people are happy with the fix suggested by Nick.  That fix 
is okay with me as it fixes the problem I am having.

I suspect, however, that by not directly detecting the problematic access 
pattern, where the file is accessed sequentially in small hunks, other 
applications may experience performance problems related to caching. For 
example, if an application frequently and non-sequentially reads from the 
same page.  This is especially true for files of size < PAGE_CACHE_SIZE.
But, I'm not sure if such an access pattern likely.

ashif.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
