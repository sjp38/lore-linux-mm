Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 9E5BA6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 14:35:21 -0400 (EDT)
Received: by mail-vb0-f52.google.com with SMTP id f12so66243vbg.11
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 11:35:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130814182756.GD24033@dhcp22.suse.cz>
References: <52050382.9060802@gmail.com>
	<520BB225.8030807@gmail.com>
	<20130814174039.GA24033@dhcp22.suse.cz>
	<CA+55aFwAz7GdcB6nC0Th42y8eAM591sKO1=mYh5SWgyuDdHzcA@mail.gmail.com>
	<20130814182756.GD24033@dhcp22.suse.cz>
Date: Wed, 14 Aug 2013 11:35:20 -0700
Message-ID: <CA+55aFxB6Wyj3G3Ju8E7bjH-706vi3vysuATUZ13h1tdYbCbnQ@mail.gmail.com>
Subject: Re: [Bug] Reproducible data corruption on i5-3340M: Please revert 53a59fc67!
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ben Tebulin <tebulin@googlemail.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Wed, Aug 14, 2013 at 11:28 AM, Michal Hocko <mhocko@suse.cz> wrote:
>
> OK that would suggest the issue has been introduced by 597e1c35:
> (mm/mmu_gather: enable tlb flush range in generic mmu_gather) in 3.6
> which is not 3.7 when Ben started seeing the issue but this definitely
> smells like a bug that would be amplified by the bisected patch.

Yes, the bug was originally introduced in 597e1c35, but in practice it
never happened, because the force_flush case would not ever really
trigger unless __get_free_pages(GFP_NOWAIT) returned NULL.

Which is *very* rare.

So the commit that Ben bisected things down to wasn't the one that
really introduced the bug, but it was the one that made
tlb_next_batch() much more likely to return failure, which in turn
made it much easier to *expose* the bug.

NOTE! I still absolutely want Ben to actually test that fix (ie
backport commit e6c495a96ce0 to his tree), because without testing
this is all just theoretical, and there might be other things hiding
here. But it makes sense to me, and I think this already-known bug
explains the symptoms.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
