Message-ID: <45BDCA8A.4050809@yahoo.com.au>
Date: Mon, 29 Jan 2007 21:20:58 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: page_mkwrite caller is racy?
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi,

After do_wp_page calls page_mkwrite on its target (old_page), it then drops the
reference to the page before locking the ptl and verifying that the pte points
to old_page.

Unfortunately, old_page may have been truncated and freed, or reclaimed, then
re-allocated and used again for the same pagecache position and faulted in
read-only into the same pte by another thread. Then you will have a situation
where page_mkwrite succeeds but the page we use is actually a readonly one.

Moving page_cache_release(old_page) to below the next statement will fix that
problem.

But it is sad that this thing got merged without any callers to even know how it
is intended to work. Must it be able to sleep?

Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
