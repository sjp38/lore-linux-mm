Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E85D06B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 19:28:39 -0500 (EST)
Received: by iaek3 with SMTP id k3so9455162iae.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 16:28:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111116002235.GA10958@barrios-laptop.redhat.com>
References: <20111114140421.GA27150@suse.de>
	<CAEwNFnALUoeh5cEW=XZqy7Aab4hxtE11-mAjWB1c5eddzGuQFA@mail.gmail.com>
	<20111115173656.GJ27150@suse.de>
	<20111116002235.GA10958@barrios-laptop.redhat.com>
Date: Tue, 15 Nov 2011 16:28:36 -0800
Message-ID: <CAMbhsRSePzsN-4JXEEwFoaa9EhBfHQ11gsjqJCDzV2nonJ0DqQ@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Nov 15, 2011 at 4:22 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Tue, Nov 15, 2011 at 05:36:56PM +0000, Mel Gorman wrote:
>> On Wed, Nov 16, 2011 at 01:13:30AM +0900, Minchan Kim wrote:
>> The impact would be that during the time between processes been frozen
>> and storage being suspended, GFP_NOIO allocations that used to call
>> wait_iff_congested and retry while kswapd does its thing will return
>> failure instead. These GFP_NOIO allocations that used to succeed will
>> now fail in rare cases during suspend and I don't think we want that.
>>
>> Is this what you meant or had you something else in mind?
>>
>
> You read my mind exactly!
>
> I thought hibernation process is as follows,
>
> freeze user processes
> oom_disable
> hibernate_preallocate_memory
> freeze kernel processes(include kswapd)
> pm_restrict_gfp_mask
> swsusp_save
>
> My guessing is hibernate_prealocate_memory should reserve all memory needed
> for hibernation for reclaimaing pages of kswapd because kswapd just would be
> stopped so during swsusp_save, page reclaim should not be occured.
>
> But being see description of patch, my guess seems wrong.
> Now the problem happens and it means page reclaim happens during swsusp_save.
> Colin or someone could confirm this?

The problem I see is during suspend, not hibernation.  The particular
allocation that usually causes the problem is the pgd_alloc for page
tables when re-enabling the 2nd cpu during resume, which is odd as
those same page tables were freed during suspend.  I guess an
unfreezable kernel thread allocated that memory between the free and
re-allocation.

> If so, could we reserve more memory when we preallocate hibernation memory
> for avoiding page reclaim without kswapd?
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
