Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id ADEE9900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 19:46:42 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id eu11so6474924pac.2
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 16:46:42 -0700 (PDT)
Date: Mon, 27 Oct 2014 16:46:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 86831] New: wrong count of dirty pages when using AIO
Message-Id: <20141027164641.8d072f4aac4bca346fe7baf3@linux-foundation.org>
In-Reply-To: <bug-86831-27@https.bugzilla.kernel.org/>
References: <bug-86831-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.koenigshaus@wut.de
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 24 Oct 2014 15:33:02 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=86831
> 
>             Bug ID: 86831
>            Summary: wrong count of dirty pages when using AIO
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.14.21
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: m.koenigshaus@wut.de
>         Regression: No
> 
> Hello,
> 
> we use a ARM custom Board with mysqld. Shuting down mysqld (with IAO support,
> on a ext3 formatted Harddrive) leads to a negative number of dirty pages
> (underrun to the counter). The negative number results in a drastic reduction
> of the write performance because the page cache is not used, because the kernel
> thinks it is still 2 ^ 32 dirty pages open. I found, the problem is
> mm/truncate.c->cancel_dirty_page()
> 
> To reproduce,first change cancel_dirty_page()
> 
> [...]
> if (mapping && mapping_cap_account_dirty (mapping)) {
> ++WARN_ON ((int) global_page_state(NR_FILE_DIRTY) <0);
> dec_zone_page_state (page, NR_FILE_DIRTY);
> [...]
> 
> And test ->

hm, I wonder what AIO is doing differently - cancel_dirty_page() isn't
specific to aio - it's used by all truncations.

Just to sanity check, could you please try something like this?

--- a/include/linux/vmstat.h~a
+++ a/include/linux/vmstat.h
@@ -241,6 +241,8 @@ static inline void __inc_zone_state(stru
 static inline void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
 {
 	atomic_long_dec(&zone->vm_stat[item]);
+	WARN_ON_ONCE(item == NR_FILE_DIRTY &&
+		atomic_long_read(&zone->vm_stat[item]) < 0);
 	atomic_long_dec(&vm_stat[item]);
 }
 

That should catch the first offending decrement, although yes, it's
probably cancel_dirty_page().

(This assumes you're using an SMP kernel.  If not,
mm/vmstat.c:dec_zone_page_state() will need to be changed instead)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
