Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 173346B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 05:57:25 -0400 (EDT)
Message-ID: <51C18051.8070404@asianux.com>
Date: Wed, 19 Jun 2013 17:56:33 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmscan.c: 'lru' may be used without initialized after
 the patch "3abf380..." in next-20130607 tree
References: <51C155D1.3090304@asianux.com> <20130619085315.GK1875@suse.de>
In-Reply-To: <20130619085315.GK1875@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: hannes@cmpxchg.org, riel@redhat.com, mhocko@suse.cz, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 06/19/2013 04:53 PM, Mel Gorman wrote:
> On Wed, Jun 19, 2013 at 02:55:13PM +0800, Chen Gang wrote:
>> > 
>> > 'lru' may be used without initialized, so need regressing part of the
>> > related patch.
>> > 
>> > The related patch:
>> >   "3abf380 mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru"
>> > 
>> > 
>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> > ---
>> >  mm/vmscan.c |    1 +
>> >  1 files changed, 1 insertions(+), 0 deletions(-)
>> > 
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index fe73724..e92b1858 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -595,6 +595,7 @@ redo:
>> >  		 * unevictable page on [in]active list.
>> >  		 * We know how to handle that.
>> >  		 */
>> > +		lru = !!TestClearPageActive(page) + page_lru_base_type(page);
>> >  		lru_cache_add(page);
> Thanks for catching this but I have one question. Why are you clearing
> the active bit?
> 

Oh, it is my fault, I only want to regress part of the original patch,
did not notice clearing the active bit.


> Before 3abf380 we did
> 
> active = TestClearPageActive(page);
> lru = active + page_lru_base_type(page);
> lru_cache_add_lru(page, lru);
> 
> so if the page was active before then it gets added to the active list. When
> 3abf380 is applied. it becomes.
> 
> Leave PageActive alone
> lru_cache_add(page);
> .... until __pagevec_lru_add -> __pagevec_lru_add_fn
> int file = page_is_file_cache(page);
> int active = PageActive(page);
> enum lru_list lru = page_lru(page);
> 
> After your patch it's
> 
> Clear PageActive
> lru_cache_add(page)
> ......
> always add to inactive list
> 
> I do not think you intended to do this and if you did, it deserves far
> more comment than being a compile warning fix. In putback_lru_page we only
> care about whether the lru was unevictable or not. Hence I think what you
> meant to do was simply
> 
> 	lru = page_lru_base_type(page);
> 
> If you agree then can you resend a revised version to Andrew please?

Yes, I should do, but excuse me, I do not quite know about 'revised
version'.

I guess it means I need still send the related patch which base on the
original one, e.g. for next-20130618:

------------------------diff begin-------------------------------------

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fe73724..d03facb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -595,6 +595,7 @@ redo:
 		 * unevictable page on [in]active list.
 		 * We know how to handle that.
 		 */
+		lru = page_lru_base_type(page);
 		lru_cache_add(page);
 	} else {
 		/*

------------------------diff end---------------------------------------

Is it correct ?


Thanks.
-- 
Chen Gang

Asianux Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
