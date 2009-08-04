Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 45B3D6B005C
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 18:00:28 -0400 (EDT)
Date: Tue, 4 Aug 2009 14:59:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/12] ksm: keep quiet while list empty
Message-Id: <20090804145935.e258cd2f.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0908031313030.16754@sister.anvils>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
	<Pine.LNX.4.64.0908031313030.16754@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: ieidus@redhat.com, aarcange@redhat.com, riel@redhat.com, chrisw@redhat.com, nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 2009 13:14:03 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> +		if (ksmd_should_run()) {
>  			schedule_timeout_interruptible(
>  				msecs_to_jiffies(ksm_thread_sleep_millisecs));
>  		} else {
>  			wait_event_interruptible(ksm_thread_wait,
> -					(ksm_run & KSM_RUN_MERGE) ||
> -					kthread_should_stop());
> +				ksmd_should_run() || kthread_should_stop());
>  		}

Yields


		if (ksmd_should_run()) {
			schedule_timeout_interruptible(
				msecs_to_jiffies(ksm_thread_sleep_millisecs));
		} else {
			wait_event_interruptible(ksm_thread_wait,
				ksmd_should_run() || kthread_should_stop());
		}

can it be something like

		wait_event_interruptible_timeout(ksm_thread_wait,
			ksmd_should_run() || kthread_should_stop(),
			msecs_to_jiffies(ksm_thread_sleep_millisecs));

?

That would also reduce the latency in responding to kthread_should_stop().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
