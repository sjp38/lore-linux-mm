Message-ID: <44330EF8.1040800@yahoo.com.au>
Date: Wed, 05 Apr 2006 10:27:36 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2/3] mm: speculative get_page
References: <20060219020140.9923.43378.sendpatchset@linux.site> <20060219020159.9923.94877.sendpatchset@linux.site> <Pine.LNX.4.64.0604040820540.26807@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0604040820540.26807@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 4 Apr 2006, Nick Piggin wrote:
> 
> 
>>+	/*
>>+	 * PageNoNewRefs is set in order to prevent new references to the
>>+	 * page (eg. before it gets removed from pagecache). Wait until it
>>+	 * becomes clear (and checks below will ensure we still have the
>>+	 * correct one).
>>+	 */
>>+	while (unlikely(PageNoNewRefs(page)))
>>+		cpu_relax();
> 
> 
> That part looks suspiciously like we need some sort of lock here.
> 

It's very light-weight now. A lock of course would only be page local,
so it wouldn't really harm scalability, however it would slow down the
single threaded case. At the moment, single threaded performance of
find_get_page is anywhere from about 15-100% faster than before the
lockless patches.

I don't see why you think there needs to be a lock? Before the write
side clears PageNoNewRefs, they will have moved 'page' out of pagecache,
so when this loop breaks, the subsequent test will fail and this
function will be repeated.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
