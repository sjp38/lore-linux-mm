Received: by wx-out-0506.google.com with SMTP id h31so1983235wxd.11
        for <linux-mm@kvack.org>; Thu, 03 Jan 2008 12:24:11 -0800 (PST)
Date: Thu, 3 Jan 2008 15:24:06 -0500
From: Steven Walter <stevenrwalter@gmail.com>
Subject: Erroneous VM_MINOR_FAULT return from filemap_fault?
Message-ID: <20080103202406.GA30573@dervierte>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There appears to be a path through filemap_fault such that the function
returns VM_MINOR_FAULT, even though disk IO was performed.  Suppose that
the page in question is not already in the page cache (find_lock_page
returns NULL) and we trip the MMAP_LOTSAMISS logic, ending up at
no_cached_page.  Immediately page_cache_read is called, but ret was
never set to VM_MAJOR_FAULT (still at the default of VM_MINOR_FAULT).
Control jumps back to retry_find, find_lock_page returns the page, and
eventually the function returns VM_MINOR_FAULT.

Is there some assumption I'm missing where the execution path I
summarized couldn't actually happen?  Perhaps this behavior is
intentional?  Certainly it seems that if IO is performed, the fault
should be considered a major fault.
-- 
-Steven Walter <stevenrwalter@gmail.com>
Freedom is the freedom to say that 2 + 2 = 4
B2F1 0ECC E605 7321 E818  7A65 FC81 9777 DC28 9E8F 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
