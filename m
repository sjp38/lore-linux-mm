Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id E11786B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 10:46:29 -0500 (EST)
Message-ID: <1331135301.32316.29.camel@sauron.fi.intel.com>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
Date: Wed, 07 Mar 2012 17:48:21 +0200
In-Reply-To: <20120303135558.GA9869@localhost>
References: <20120228140022.614718843@intel.com>
	 <20120228144747.198713792@intel.com>
	 <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
	 <20120301123640.GA30369@localhost> <20120301163837.GA13104@quack.suse.cz>
	 <20120302044858.GA14802@localhost> <20120302095910.GB1744@quack.suse.cz>
	 <20120302103951.GA13378@localhost>
	 <20120302115700.7d970497.akpm@linux-foundation.org>
	 <20120303135558.GA9869@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Adrian Hunter <ext-adrian.hunter@nokia.com>, Artem Bityutskiy <Artem.Bityutskiy@nokia.com>

On Sat, 2012-03-03 at 21:55 +0800, Fengguang Wu wrote:
>   13   1125  /c/linux/fs/ubifs/file.c <<do_truncation>>   <===== deadlockable

Sorry, but could you please explain once again how the deadlock may
happen?

> It seems they are all safe except for ubifs. ubifs may actually
> deadlock from the above do_truncation() caller. However it should be
> fixable because the ubifs call for writeback_inodes_sb_nr() sounds
> very brute force writeback and wait and there may well be better way
> out.

I do not think this "fixable" - this is part of UBIFS design to force
write-back when we are not sure we have enough space.

The problem is that we do not know how much space the dirty data in RAM
will take on the flash media (after it is actually written-back) - e.g.,
because we compress all the data (UBIFS performs on-the-flight
compression). So we do pessimistic assumptions and allow dirtying more
and more data as long as we know for sure that there is enough flash
space on the media for the worst-case scenario (data are not
compressible). This is what the UBIFS budgeting subsystem does.

Once the budgeting sub-system sees that we are not going to have enough
flash space for the worst-case scenario, it starts forcing write-back to
push some dirty data out to the flash media and update the budgeting
numbers, and get more realistic picture.

So basically, before you can change _anything_ on UBIFS file-system, you
need to budget for the space. Even when you truncate - because
truncation is also about allocating more space for writing the updated
inode and update the FS index. (Remember, all writes are out-of-place in
UBIFS because we work with raw flash, not a block device).

-- 
Best Regards,
Artem Bityutskiy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
