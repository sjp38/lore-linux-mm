Message-ID: <42C14D93.7090303@yahoo.com.au>
Date: Tue, 28 Jun 2005 23:16:03 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2] mm: speculative get_page
References: <42BF9CD1.2030102@yahoo.com.au> <42BF9D67.10509@yahoo.com.au> <42BF9D86.90204@yahoo.com.au> <42C14662.40809@shadowen.org>
In-Reply-To: <42C14662.40809@shadowen.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> Nick Piggin wrote:
> 
> 
>> #define PG_free			20	/* Page is on the free lists */
>>+#define PG_freeing		21	/* PG_refcount about to be freed */
> 
> 
> Wow this needs two new page bits.  That might be a problem ongoing.
> There are only 24 of these puppies and this takes us to just two
> remaining.  Do we really need _two_ to track free?
> 

Yeah they are kind of different. PG_freeing isn't a really good
description for it. Basically it is set to guarantee a page won't
gain any more references (real, not speculative) than what page_count
returns.

I'm in the process of recovering one of those with an earlier set
of patches (PG_reserved).

> One obvious area of overlap might be the PG_nosave_free which seems to
> be set on free pages for software suspend.  Perhaps that and PG_free
> will be equivalent in intent (though maintained differently) and allow
> us to recover a bit?
> 

PG_free can't be shared with anything else, unfortunately. It doesn't
need to be an atomic flag though, so it can be an "impossible"
combination of flags.

> There are a couple of bits which imply ownership such as PG_slab,
> PG_swapcache and PG_reserved which to my mind are all exclusive.
> Perhaps those plus the PG_free could be combined into a owner field.  I
> am unsure if the PG_freeing can be 'backed out' if not it may also combine?
> 

I think there are a a few ways that bits can be reclaimed if we
start digging. swsusp uses 2 which seems excessive though may be
fully justified. Can PG_private be replaced by (!page->private)?
Can filesystems easily stop using PG_checked?

OK, I'll cut the hand-waving: PG_free used to be derived from
PG_private && page_count == 0, so it could instead be
PG_active && !PG_lru quite easily AFAIKS. If this patchset ever
looks like being merged you can take me up on it ;)

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
