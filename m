Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 309B66B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:07:14 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so74555786pac.3
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 12:07:13 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id ip1si21886112pbc.157.2015.11.12.12.07.11
        for <linux-mm@kvack.org>;
        Thu, 12 Nov 2015 12:07:12 -0800 (PST)
Date: Fri, 13 Nov 2015 07:06:41 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: memory reclaim problems on fs usage
Message-ID: <20151112200641.GR19199@dastard>
References: <201511102313.36685.arekm@maven.pl>
 <201511111719.44035.arekm@maven.pl>
 <201511120719.EBF35970.OtSOHOVFJMFQFL@I-love.SAKURA.ne.jp>
 <201511120706.10739.arekm@maven.pl>
 <56449E44.7020407@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <56449E44.7020407@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Arkadiusz =?utf-8?Q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>, linux-mm@kvack.org, xfs@oss.sgi.com

On Thu, Nov 12, 2015 at 11:12:20PM +0900, Tetsuo Handa wrote:
> On 2015/11/12 15:06, Arkadiusz MiA?kiewicz wrote:
> >On Wednesday 11 of November 2015, Tetsuo Handa wrote:
> >>Arkadiusz Mi?kiewicz wrote:
> >>>This patch is against which tree? (tried 4.1, 4.2 and 4.3)
> >>
> >>Oops. Whitespace-damaged. This patch is for vanilla 4.1.2.
> >>Reposting with one condition corrected.
> >
> >Here is log:
> >
> >http://ixion.pld-linux.org/~arekm/log-mm-1.txt.gz
> >
> >Uncompresses is 1.4MB, so not posting here.
> >
> Thank you for the log. The result is unexpected for me.
> 
> What I feel strange is that free: remained below min: level.
> While GFP_ATOMIC allocations can access memory reserves, I think that
> these free: values are too small. Memory allocated by GFP_ATOMIC should
> be released shortly, or any __GFP_WAIT allocations would stall for long.
> 
> [ 8633.753528] Node 0 Normal free:128kB min:7104kB low:8880kB
> high:10656kB active_anon:59008kB inactive_anon:75240kB
> active_file:14712kB inactive_file:3256960kB unevictable:0kB
....
> isolated(anon):0kB isolated(file):0kB present:5242880kB
> managed:5109980kB mlocked:0kB dirty:20kB writeback:0kB mapped:7368kB
....
> pages_scanned:176 all_unreclaimable? no

So: we have 3.2GB (800,000 pages) of immediately reclaimable page
cache in this zone (inactive_file) and a GFP_ATOMIC allocation
context so we can only really reclaim clean page cache pages
reliably.

So why have we only scanned *176* pages* during reclaim?  On other
OOM reports in this trace it's as low as 12.  Either that stat is
completely wrong, or we're not doing sufficient page LRU reclaim
scanning....

> [ 9662.234685] MemAlloc-Info: 3 stalling task, 0 dying task, 0 victim task.
> 
> vmstat_update() and submit_flushes() remained pending for about 110 seconds.
> If xlog_cil_push_work() were spinning inside GFP_NOFS allocation, it should be
> reported as MemAlloc: traces, but no such lines are recorded. I don't know why
> xlog_cil_push_work() did not call schedule() for so long.

I'd say it is repeatedly waiting for IO completion on log buffers to
write out the checkpoint. It's making progress, just if it's taking
multiple second per journal IO it will take a long time to write a
checkpoint. All the other blocked tasks in XFS inode reclaim are
either waiting directly on IO completion or waiting for the log to
complete a flush, so this really just looks like an overloaded IO
subsystem to me....

> Well, what steps should we try next for isolating the problem?

I think there's plenty that needs to be explained from this
information. We don't have a memory allocation livelock - slow
progress is being made on reclaiming inodes, but we
clearly have a zone imbalance and direct page reclaim is not freeing
clean inactive pages when there are huge numbers of them available
for reclaim. Somebody who understands the page reclaim code needs to
look closely at the code to explain this behaviour now, then we'll
know what information needs to be gathered next...

Cheers,

Dave.


-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
