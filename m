Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9C76B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 10:53:51 -0500 (EST)
Received: by yenm7 with SMTP id m7so1060484yen.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 07:53:48 -0800 (PST)
Date: Wed, 9 Nov 2011 07:53:42 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] thp: reduce khugepaged freezing latency
Message-ID: <20111109155342.GA1260@google.com>
References: <4EB8E969.6010502@suse.cz>
 <1320766151-2619-1-git-send-email-aarcange@redhat.com>
 <1320766151-2619-2-git-send-email-aarcange@redhat.com>
 <4EB98A83.3040101@linux.vnet.ibm.com>
 <4EBA75F2.4080800@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EBA75F2.4080800@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Rafael J. Wysocki" <rjw@suse.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hello, Andrea, Srivatsa.

On Wed, Nov 09, 2011 at 06:15:38PM +0530, Srivatsa S. Bhat wrote:
> >> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> >> index 4298aba..67311d1 100644
> >> --- a/mm/huge_memory.c
> >> +++ b/mm/huge_memory.c
> >> @@ -2277,6 +2277,7 @@ static struct page *khugepaged_alloc_hugepage(void)
> >>  		if (!hpage) {
> >>  			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
> >>  			khugepaged_alloc_sleep();
> >> +			try_to_freeze();
> >>  		} else
> >>  			count_vm_event(THP_COLLAPSE_ALLOC);
> >>  	} while (unlikely(!hpage) &&
> >> @@ -2331,7 +2332,7 @@ static int khugepaged(void *none)
> >>  {
> >>  	struct mm_slot *mm_slot;
> >>
> >> -	set_freezable();
> >> +	set_freezable_with_signal();
> >>  	set_user_nice(current, 19);

Oooh, please don't do that.  It's already gone in the pm tree.  It
would be best if wait_event_freezable_timeout() can be used
(ie. wakeup condition should be set somewhere) but, if not, something
like the following sould work.

static void khugepaged_alloc_sleep(void)
{
	DEFINE_WAIT(wait);
	add_wait_queue(&khugepaged_wait, &wait);
	try_to_freeze();
	schedule_timeout_interruptible(
			msecs_to_jiffies(
				khugepaged_alloc_sleep_millisecs));
	try_to_freeze();
	remove_wait_queue(&khugepaged_wait, &wait);
}
												
Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
