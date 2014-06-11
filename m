Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 025CC6B014C
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 07:24:48 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id p10so8776050wes.20
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 04:24:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id by5si41359773wjc.114.2014.06.11.04.24.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 04:24:47 -0700 (PDT)
Message-ID: <53983C7B.8040705@suse.cz>
Date: Wed, 11 Jun 2014 13:24:43 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] mm, compaction: periodically drop lock and restore
 IRQs in scanners
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-3-git-send-email-vbabka@suse.cz> <20140611013218.GD15630@bbox>
In-Reply-To: <20140611013218.GD15630@bbox>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/11/2014 03:32 AM, Minchan Kim wrote:
>> >+	if (cc->mode == MIGRATE_ASYNC) {
>> >+		if (need_resched()) {
>> >+			cc->contended = COMPACT_CONTENDED_SCHED;
>> >+			return true;
>> >  		}
>> >-
>> >+		if (spin_is_locked(lock)) {
> Why do you use spin_is_locked instead of spin_is_contended?

Because I know I have dropped the lock. AFAIK spin_is_locked() means 
somebody else is holding it, which would be a contention for me if I 
would want to take it back. spin_is_contended() means that somebody else 
#1 is holding it AND somebody else #2 is already waiting for it.

Previously in should_release_lock() the code assumed that it was me who 
holds the lock, so I check if somebody else is waiting for it, hence 
spin_is_contended().

But note that the assumption was not always true when 
should_release_lock() was called from compact_checklock_irqsave(). So it 
was another subtle suboptimality. In async compaction when I don't have 
the lock, I should be deciding if I take it based on if somebody else is 
holding it. Instead it was deciding based on if somebody else #1 is 
holding it and somebody else #2 is waiting.
Then there's still a chance of race between this check and call to 
spin_lock_irqsave, so I could spin on the lock even if I don't want to. 
Using spin_trylock_irqsave() instead is like checking spin_is_locked() 
and locking, without this race.

So even though I will probably remove the spin_is_locked() check per 
David's objection, the trylock will still nicely prevent waiting on the 
lock in async compaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
