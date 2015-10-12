Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB2F6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 17:23:46 -0400 (EDT)
Received: by ignr19 with SMTP id r19so24037162ign.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 14:23:46 -0700 (PDT)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id 71si242216ior.25.2015.10.12.14.23.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 14:23:45 -0700 (PDT)
Received: by iow1 with SMTP id 1so1665986iow.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 14:23:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
References: <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
	<201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
	<201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
	<201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
Date: Mon, 12 Oct 2015 14:23:45 -0700
Message-ID: <CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com>
Subject: Re: Silent hang up caused by pages being not scanned?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>

On Mon, Oct 12, 2015 at 8:25 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> I examined this hang up using additional debug printk() patch. And it was
> observed that when this silent hang up occurs, zone_reclaimable() called from
> shrink_zones() called from a __GFP_FS memory allocation request is returning
> true forever. Since the __GFP_FS memory allocation request can never call
> out_of_memory() due to did_some_progree > 0, the system will silently hang up
> with 100% CPU usage.

I wouldn't blame the zones_reclaimable() logic itself, but yeah, that looks bad.

So the do_try_to_free_pages() logic that does that

        /* Any of the zones still reclaimable?  Don't OOM. */
        if (zones_reclaimable)
                return 1;

is rather dubious. The history of that odd line is pretty dubious too:
it used to be that we would return success if "shrink_zones()"
succeeded or if "nr_reclaimed" was non-zero, but that "shrink_zones()"
logic got rewritten, and I don't think the current situation is all
that sane.

And returning 1 there is actively misleading to callers, since it
makes them think that it made progress.

So I think you should look at what happens if you just remove that
illogical and misleading return value.

HOWEVER.

I think that it's very true that we have then tuned all our *other*
heuristics for taking this thing into account, so I suspect that we'll
find that we'll need to tweak other places. But this crazy "let's say
that we made progress even when we didn't" thing looks just wrong.

In particular, I think that you'll find that you will have to change
the heuristics in __alloc_pages_slowpath() where we currently do

        if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) || ..

when the "did_some_progress" logic changes that radically.

Because while the current return value looks insane, all the other
testing and tweaking has been done with that very odd return value in
place.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
