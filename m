Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3F5A36B00E2
	for <linux-mm@kvack.org>; Wed, 13 May 2009 05:19:31 -0400 (EDT)
Date: Wed, 13 May 2009 11:19:42 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 3/6] mm, PM/Freezer: Disable OOM killer when tasks are
	frozen
Message-ID: <20090513091942.GC27261@elf.ucw.cz>
References: <200905070040.08561.rjw@sisk.pl> <200905101548.57557.rjw@sisk.pl> <200905131032.53624.rjw@sisk.pl> <200905131037.50011.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200905131037.50011.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed 2009-05-13 10:37:49, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Currently, the following scenario appears to be possible in theory:
> 
> * Tasks are frozen for hibernation or suspend.
> * Free pages are almost exhausted.
> * Certain piece of code in the suspend code path attempts to allocate
>   some memory using GFP_KERNEL and allocation order less than or
>   equal to PAGE_ALLOC_COSTLY_ORDER.
> * __alloc_pages_internal() cannot find a free page so it invokes the
>   OOM killer.
> * The OOM killer attempts to kill a task, but the task is frozen, so
>   it doesn't die immediately.
> * __alloc_pages_internal() jumps to 'restart', unsuccessfully tries
>   to find a free page and invokes the OOM killer.
> * No progress can be made.
> 
> Although it is now hard to trigger during hibernation due to the
> memory shrinking carried out by the hibernation code, it is
> theoretically possible to trigger during suspend after the memory
> shrinking has been removed from that code path.  Moreover, since
> memory allocations are going to be used for the hibernation memory
> shrinking, it will be even more likely to happen during hibernation.
> 
> To prevent it from happening, introduce the oom_killer_disabled
> switch that will cause __alloc_pages_internal() to fail in the
> situations in which the OOM killer would have been called and make
> the freezer set this switch after tasks have been successfully
> frozen.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Acked-by: Pavel Machek <pavel@ucw.cz>

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
