Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id A28BE6B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 02:33:08 -0400 (EDT)
Date: Tue, 17 Jul 2012 08:33:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH mmotm] memcg: further prevent OOM with too many dirty
 pages
Message-ID: <20120717063301.GA25435@tiehlicka.suse.cz>
References: <20120620101119.GC5541@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
 <20120712070501.GB21013@tiehlicka.suse.cz>
 <20120712141343.e1cb7776.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1207121539150.27721@eggly.anvils>
 <20120713082150.GA1448@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207160111280.3936@eggly.anvils>
 <alpine.LSU.2.00.1207160131120.3936@eggly.anvils>
 <20120716092631.GC14664@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207162135590.19938@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207162135590.19938@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Mon 16-07-12 21:52:51, Hugh Dickins wrote:
> On Mon, 16 Jul 2012, Michal Hocko wrote:
> > On Mon 16-07-12 01:35:34, Hugh Dickins wrote:
> > > But even so, the test still OOMs sometimes: when originally testing
> > > on 3.5-rc6, it OOMed about one time in five or ten; when testing
> > > just now on 3.5-rc6-mm1, it OOMed on the first iteration.
> > > 
> > > This residual problem comes from an accumulation of pages under
> > > ordinary writeback, not marked PageReclaim, so rightly not causing
> > > the memcg check to wait on their writeback: these too can prevent
> > > shrink_page_list() from freeing any pages, so many times that memcg
> > > reclaim fails and OOMs.
> > 
> > I guess you managed to trigger this with 20M limit, right?
> 
> That's right.
> 
> > I have tested
> > with different group sizes but the writeback didn't trigger for most of
> > them and all the dirty data were flushed from the reclaim.
> 
> I didn't examine writeback stats to confirm, but I guess that just
> occasionally it managed to come in and do enough work to confound us.
> 
> > Have you used any special setting the dirty ratio?
> 
> No, I wasn't imaginative enough to try that.
> 
> > Or was it with xfs (IIUC that one
> > does ignore writeback from the direct reclaim completely).
> 
> No, just ext4 at that point.
> 
> I have since tested the final patch with ext4, ext3 (by ext3 driver
> and by ext4 driver), ext2 (by ext2 driver and by ext4 driver), xfs,
> btrfs, vfat, tmpfs (with swap on the USB stick) and block device:
> about an hour on each, no surprises, all okay.
> 
> But I didn't experiment beyond the 20M memcg.

Great coverage anyway. Thanks a lot Hugh!

> 
> Hugh

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
