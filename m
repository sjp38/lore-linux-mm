Message-ID: <44330DC6.1040805@yahoo.com.au>
Date: Wed, 05 Apr 2006 10:22:30 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2/3] mm: speculative get_page
References: <20060219020140.9923.43378.sendpatchset@linux.site> <20060219020159.9923.94877.sendpatchset@linux.site> <Pine.LNX.4.64.0604040814140.26807@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604040814140.26807@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Looks like the NoNewRefs flag is mostly == 
> spin_is_locked(mapping->tree_lock)? Would it not be better to check the 
> tree_lock?
> 

Well there are other uses for the tree_lock (eg. tag operations)
which do not need the "no new references" guarantee.

> 
> 
>>--- linux-2.6.orig/mm/migrate.c
>>+++ linux-2.6/mm/migrate.c
>> 
>>+	SetPageNoNewRefs(page);
>> 	write_lock_irq(&mapping->tree_lock);
> 
> 
> A dream come true! If this is really working as it sounds then we can 
> move the SetPageNoNewRefs up and avoid the final check under 
> mapping->tree_lock. Then keep SetPageNoNewRefs until the page has been 
> copied. It would basically play the same role as locking the page.
> 

Yes we could do that but at this stage I wouldn't like to seperate
SetPageNoNewRefs from tree_lock, as it is replacing a traditional
guarantee that tree_lock no longer provides.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
