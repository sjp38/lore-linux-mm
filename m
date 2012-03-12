Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 4CB336B0044
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 10:19:11 -0400 (EDT)
Message-ID: <1331562109.12037.54.camel@sauron.fi.intel.com>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
Date: Mon, 12 Mar 2012 16:21:49 +0200
In-Reply-To: <20120312140229.GG5998@quack.suse.cz>
References: <20120302095910.GB1744@quack.suse.cz>
	 <20120302103951.GA13378@localhost>
	 <20120302115700.7d970497.akpm@linux-foundation.org>
	 <20120303135558.GA9869@localhost>
	 <1331135301.32316.29.camel@sauron.fi.intel.com>
	 <20120309073113.GA5337@localhost> <20120309095135.GC21038@quack.suse.cz>
	 <1331309451.29445.42.camel@sauron.fi.intel.com>
	 <20120309211156.GA6262@quack.suse.cz>
	 <1331555774.12037.9.camel@sauron.fi.intel.com>
	 <20120312140229.GG5998@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Adrian Hunter <adrian.hunter@intel.com>

On Mon, 2012-03-12 at 15:02 +0100, Jan Kara wrote:
> > The second part of the overall deletion job will be when we commit - the
> > updated version of the FS index will be written to the flash media.
>   Oh, I see. This is what I was missing. And I presume you always make sure
> to have enough space for new FS index so it cannot deadlock when trying to
> push out dirty pages.

Yes, this is one of the hardest part and this is what the budgeting
subsystem does. Every VFS call (even unlink()) first invokes something
like 'ubifs_budget_space()' with arguments describing the space needs,
and the budgeting subsystem will account for the space, including the
possibility of the index growth. And the budgeting subsystem actually
forces write-back when it sees that there is not enough free space for
the operation. Because all the calculations are pessimistic, write-back
helps: the data nodes are compressed, and so on. The budgeting subsystem
may also force commit, which will clarify many unclarities and make the
calculations more precise. If nothing helps - ENOSPC is reported. For
deletions we also have a bit of reserve space to prevent -ENOSPC when
you actually want to delete a file on full file-system.

But the shorted answer: yes, we reserve 2 times the current index size
of the space for the index growths.

Long time ago I tried to describe this and the surrounding issues here:
http://www.linux-mtd.infradead.org/doc/ubifs.html#L_spaceacc

-- 
Best Regards,
Artem Bityutskiy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
