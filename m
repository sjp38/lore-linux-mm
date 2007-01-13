Message-ID: <45A8387E.1050705@google.com>
Date: Fri, 12 Jan 2007 17:40:14 -0800
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: zonelist cache performance
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pj@sgi.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

improve performance with changes to the zonelist cache. But I don't 
claim to have tested on an extensive list of platforms and/or 
benchmarks, so I was hoping for feedback.

    The proposal is, essentially, to rip out the zonelist cache and 
replace it with a single int which caches the index i into the 
zonelist[i] for the most recently allocated page. Any future attempt to 
allocate a page starts at zonelist[i], with a failure reverting to a 
full scan of all zonelists. The theory is that this will succeed most of 
the time, and as such it should be as lightweight as possible. 
zonelist_cache is only fast if zonelist[0] has a free page.

    In the context of fake numa where numa=fake=<n> has a large <n>, 
zonelist[0] may well fill up quickly yet the system still has a lot of 
free memory. As such, starting the allocation at zonelist[i] seems 
faster. In the event the allocation fails, we do a slow, full search, so 
this only works if that's the rare case.

    As to the performance improvement, it improved kernbench by 6% with 
numa=fake=64 and 2% without fake numa.

    Thanks,
    -- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
