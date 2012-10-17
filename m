Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 200066B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 21:54:11 -0400 (EDT)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TOIpm-0007cp-3O
	for linux-mm@kvack.org; Wed, 17 Oct 2012 01:54:10 +0000
Received: by mail-ea0-f169.google.com with SMTP id k11so1844182eaa.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 18:54:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121016131933.c196457a.akpm@linux-foundation.org>
References: <1350403183-12650-1-git-send-email-ming.lei@canonical.com>
	<1350403183-12650-2-git-send-email-ming.lei@canonical.com>
	<20121016131933.c196457a.akpm@linux-foundation.org>
Date: Wed, 17 Oct 2012 09:54:09 +0800
Message-ID: <CACVXFVPRsHTf85bTsHUWgHV2b7LBASGQ2s_9Kx9-ZCHv5WDuQQ@mail.gmail.com>
Subject: Re: [RFC PATCH v1 1/3] mm: teach mm by current context info to not do
 I/O during memory allocation
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, Jiri Kosina <jiri.kosina@suse.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 17, 2012 at 4:19 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> The patch seems reasonable to me.  I'd like to see some examples of
> these resume-time callsite which are performing the GFP_KERNEL
> allocations, please.  You have found some kernel bugs, so those should
> be fully described.

There are two examples on 2/3 and 3/3 of the patchset, see below link:

        http://marc.info/?l=linux-kernel&m=135040325717213&w=2
        http://marc.info/?l=linux-kernel&m=135040327317222&w=2

Sorry for not Cc them to linux-mm because I am afraid of making noise
in mm list.

>
> This is just awful.  Why oh why do we write code in macros when we have
> a nice C compiler?

The two helpers are following style of local_irq_save() and
local_irq_restore(), so that people can use them easily, that is
why I define them as macro instead of inline.

>
> These can all be done as nice, clean, type-safe, documented C
> functions.  And if they can be done that way, they *should* be done
> that way!
>
> And I suggest that a better name for memalloc_noio_save() is
> memalloc_noio_set().  So this:

IMO, renaming as memalloc_noio_set() might not be better than _save
because the _set name doesn't indicate that the flag should be stored first.

>
> static inline unsigned memalloc_noio(void)
> {
>         return current->flags & PF_MEMALLOC_NOIO;
> }
>
> static inline unsigned memalloc_noio_set(unsigned flags)
> {
>         unsigned ret = memalloc_noio();
>
>         current->flags |= PF_MEMALLOC_NOIO;
>         return ret;
> }
>
> static inline unsigned memalloc_noio_restore(unsigned flags)
> {
>         current->flags = (current->flags & ~PF_MEMALLOC_NOIO) | flags;
> }
>
> (I think that's correct?  It's probably more efficient this way).

Yes, it is correct and more clean, and I will take it.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
