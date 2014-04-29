Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CB1126B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 18:24:40 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kq14so946533pab.36
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 15:24:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id vw5si14447068pab.292.2014.04.29.15.24.39
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 15:24:39 -0700 (PDT)
Date: Tue, 29 Apr 2014 15:24:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on
 "Saving 506031 image data pages () ..."
Message-Id: <20140429152437.7324080a75d6fee914eb8307@linux-foundation.org>
In-Reply-To: <bug-75101-27@https.bugzilla.kernel.org/>
References: <bug-75101-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oliverml1@oli1170.net
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 29 Apr 2014 20:13:44 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=75101
> 
>             Bug ID: 75101
>            Summary: [bisected] s2disk / hibernate blocks on "Saving 506031
>                     image data pages () ..."
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: v3.14
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: oliverml1@oli1170.net
>         Regression: No
> 
> Created attachment 134271
>   --> https://bugzilla.kernel.org/attachment.cgi?id=134271&action=edit
> Full console trace with various SysRq outputs
> 
> Since v3.14 under normal desktop usage my s2disk/hibernate often blocks on the
> saving of the image data ("Saving 506031 image data pages () ...").

A means to reproduce as well as a bisection result.  Nice!  Thanks.

Johannes, could you please take a look?

> With following test I can reproduce the problem reliably:
> ---
> 0) Boot
> 
> 1) Fill ram with 2GiB (+50% in my case)
> 
> mount -t tmpfs tmpfs /media/test/
> dd if=/dev/zero of=/media/test/test0.bin bs=1k count=$[1024*1024]
> dd if=/dev/zero of=/media/test/test1.bin bs=1k count=$[1024*1024]
> 
> 2) Do s2disk 
> 
> s2disk
> 
> ---
> s2disk: Unable to switch virtual terminals, using the current console.
> s2disk: Snapshotting system
> s2disk: System snapshot ready. Preparing to write
> s2disk: Image size: 2024124 kilobytes
> s2disk: Free swap: 3791208 kilobytes
> s2disk: Saving 506031 image data pages (press backspace to abort) ...   0%
> 
> #Problem>: ... there is stays and blocks. SysRq still responds, so that I could
> trigger various debug outputs.
> ---
> 
> I've bisected this to following commit:
> ---
> commit a1c3bfb2f67ef766de03f1f56bdfff9c8595ab14 (HEAD, refs/bisect/bad)
> Author: Johannes Weiner <hannes@cmpxchg.org>
> Date:   Wed Jan 29 14:05:41 2014 -0800
> 
>     mm/page-writeback.c: do not count anon pages as dirtyable memory
> 
> [...]
> ---
> 
> Reverting a1c3bfb2 fixes s2disk for me again - so basically I'm ok ;). But
> maybe there is still another better solution.
> 
> Attached is a full console trace with various SysRq outputs, possibly useful
> for analyzing.
> 
> BR, Oliver
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
