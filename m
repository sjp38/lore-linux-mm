Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f205.google.com (mail-pd0-f205.google.com [209.85.192.205])
	by kanga.kvack.org (Postfix) with ESMTP id 9C44F6B00DD
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 09:44:42 -0400 (EDT)
Received: by mail-pd0-f205.google.com with SMTP id z10so14045pdj.8
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 06:44:42 -0700 (PDT)
Received: from psmtp.com ([74.125.245.169])
        by mx.google.com with SMTP id zl9si11073953pbc.234.2013.10.22.02.35.58
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 02:35:59 -0700 (PDT)
Date: Tue, 22 Oct 2013 05:35:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
Message-ID: <20131022093512.GC707@cmpxchg.org>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
 <5264F353.1080603@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5264F353.1080603@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Oct 21, 2013 at 11:26:43AM +0200, Vlastimil Babka wrote:
> On 10/10/2013 11:46 PM, Johannes Weiner wrote:
> > Hi everyone,
> > 
> > here is an update to the cache sizing patches for 3.13.
> > 
> > 	Changes in this revision
> > 
> > o Drop frequency synchronization between refaulted and demoted pages
> >   and just straight up activate refaulting pages whose access
> >   frequency indicates they could stay in memory.  This was suggested
> >   by Rik van Riel a looong time ago but misinterpretation of test
> >   results during early stages of development took me a while to
> >   overcome.  It's still the same overall concept, but a little simpler
> >   and with even faster cache adaptation.  Yay!
> 
> Oh, I liked the previous approach with direct competition between the
> refaulted and demoted page :) Doesn't the new approach favor the
> refaulted page too much? No wonder it leads to faster cache adaptation,
> but could it also cause degradations for workloads that don't benefit
> from it? Were there any tests for performance regressions on workloads
> that were not the target of the patchset?

If anything, it's unfair to refaulting pages because it requires 3
references before they are activated instead of the regular 2.

We don't do the direct competition for regular in-core activation,
either, which has the same theoretical problem but was never an issue
in the real world.  Not that I know of anyway.

I ran a standard battery of mmtests (kernbench, dbench, postmark,
micro, fsmark, what have you) and did not notice any regressions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
