Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3626C6B0062
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 00:09:09 -0400 (EDT)
Message-ID: <4A5EA7E1.7030403@redhat.com>
Date: Thu, 16 Jul 2009 00:09:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] throttle direct reclaim when too many pages are isolated
 already (v3)
References: <20090715223854.7548740a@bree.surriel.com>	<20090715194820.237a4d77.akpm@linux-foundation.org>	<4A5E9A33.3030704@redhat.com>	<20090715202114.789d36f7.akpm@linux-foundation.org>	<4A5E9E4E.5000308@redhat.com>	<20090715203854.336de2d5.akpm@linux-foundation.org>	<20090715235318.6d2f5247@bree.surriel.com> <20090715210253.bc137b2d.akpm@linux-foundation.org>
In-Reply-To: <20090715210253.bc137b2d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> While I agree that handling fatal signals on the direct reclaim path
> is probably a good thing, this seems like a fairly random place at
> which to start the enhancement.

You are right, the direct reclaim path has one other
place where congestion_wait is called in a loop,
do_try_to_free_pages itself - we'll probably want to
break out of that loop too, if the task is about to
die and free all its memory.

> If we were to step back and approach this in a broader fashion, perhaps
> we would find some commonality with the existing TIF_MEMDIE handling,
> dunno.

Good point - what is it that makes TIF_MEMDIE special
wrt. other fatal signals, anyway?

I wonder if we should not simply "help along" any task
with fatal signals pending, anywhere in the VM (and maybe
other places in the kernel, too).

The faster we get rid of a killed process, the sooner its
resources become available to the other processes.

> And I question the testedness of v3 :)

No question about that :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
