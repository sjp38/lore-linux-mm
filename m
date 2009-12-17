Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1D15B6B0092
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 09:45:21 -0500 (EST)
Message-ID: <4B2A438A.6000908@redhat.com>
Date: Thu, 17 Dec 2009 09:43:22 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: FWD:  [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091211164651.036f5340@annuminas.surriel.com> <1260810481.6666.13.camel@dhcp-100-19-198.bos.redhat.com> <20091217193818.9FA9.A69D9226@jp.fujitsu.com> <4B2A22C0.8080001@redhat.com>
In-Reply-To: <4B2A22C0.8080001@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lwoodman@redhat.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 12/17/2009 07:23 AM, Larry Woodman wrote:

>>> The system would not respond so I dont know whats going on yet. I'll
>>> add debug code to figure out why its in that state as soon as I get
>>> access to the hardware.
>
> This was in response to Rik's first patch and seems to be fixed by the
> latest path set.
>
> Finally, having said all that, the system still struggles reclaiming
> memory with
> ~10000 processes trying at the same time, you fix one bottleneck and it
> moves
> somewhere else. The latest run showed all but one running process
> spinning in
> page_lock_anon_vma() trying for the anon_vma_lock. I noticed that there are
> ~5000 vma's linked to one anon_vma, this seems excessive!!!

I have some ideas on how to keep processes waiting better
on the per zone reclaim_wait waitqueue.

For one, we should probably only do the lots-free wakeup
if we have more than zone->pages_high free pages in the
zone - having each of the waiters free some memory one
after another should not be a problem as long as we do
not have too much free memory in the zone.

Currently it's a hair trigger, with the threshold for
processes going into the page reclaim path and processes
exiting it "plenty free" being exactly the same.

Some hysteresis there could help.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
