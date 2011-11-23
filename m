Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B22D16B00C5
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 21:01:56 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so1201208vcb.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 18:01:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1321945011.22361.335.camel@sli10-conroe>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
	<1321900608-27687-8-git-send-email-mgorman@suse.de>
	<1321945011.22361.335.camel@sli10-conroe>
Date: Wed, 23 Nov 2011 10:01:53 +0800
Message-ID: <CAPQyPG4DQCxDah5VYMU6PNgeuD_3WJ-zm8XpL7V7BK8hAF8OJg@mail.gmail.com>
Subject: Re: [PATCH 7/7] mm: compaction: Introduce sync-light migration for
 use by compaction
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 22, 2011 at 2:56 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Tue, 2011-11-22 at 02:36 +0800, Mel Gorman wrote:
>> This patch adds a lightweight sync migrate operation MIGRATE_SYNC_LIGHT
>> mode that avoids writing back pages to backing storage. Async
>> compaction maps to MIGRATE_ASYNC while sync compaction maps to
>> MIGRATE_SYNC_LIGHT. For other migrate_pages users such as memory
>> hotplug, MIGRATE_SYNC is used.
>>
>> This avoids sync compaction stalling for an excessive length of time,
>> particularly when copying files to a USB stick where there might be
>> a large number of dirty pages backed by a filesystem that does not
>> support ->writepages.
> Hi,
> from my understanding, with this, even writes
> to /proc/sys/vm/compact_memory doesn't wait for pageout, is this
> intended?
> on the other hand, MIGRATE_SYNC_LIGHT now waits for pagelock and buffer
> lock, so could wait on page read. page read and page out have the same
> latency, why takes them different?

So for the problem you raised, I think my suggestion to Mel is to adopt the
following logic:

           if (!trylock_page(page) && !PageUptodate(page))
                      we are quite likely to block on read, so we
                      depend on yet another MIGRATE_SYNC_MODE to decide
                      if we really want to lock_page() and wait for this IO.

How do you think ?


Thanks,

Nai
>
> Thanks,
> Shaohua
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
