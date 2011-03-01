Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 500E58D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 23:50:38 -0500 (EST)
Received: by yxt33 with SMTP id 33so2364957yxt.14
        for <linux-mm@kvack.org>; Mon, 28 Feb 2011 20:50:37 -0800 (PST)
Date: Tue, 1 Mar 2011 13:50:25 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v5 3/9] writeback: convert variables to unsigned
Message-ID: <20110301045025.GC2107@barrios-desktop>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
 <1298669760-26344-4-git-send-email-gthelen@google.com>
 <20110227160721.GB3226@barrios-desktop>
 <AANLkTik7LfGfYpteufr68AqEe3wUriJKgAMkmT8pJSzZ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTik7LfGfYpteufr68AqEe3wUriJKgAMkmT8pJSzZ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Mon, Feb 28, 2011 at 03:52:53PM -0800, Greg Thelen wrote:
> On Sun, Feb 27, 2011 at 8:07 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > On Fri, Feb 25, 2011 at 01:35:54PM -0800, Greg Thelen wrote:
> >> Convert two balance_dirty_pages() page counter variables (nr_reclaimable
> >> and nr_writeback) from 'long' to 'unsigned long'.
> >>
> >> These two variables are used to store results from global_page_state().
> >> global_page_state() returns unsigned long and carefully sums per-cpu
> >> counters explicitly avoiding returning a negative value.
> >>
> >> Signed-off-by: Greg Thelen <gthelen@google.com>
> > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> >
> >> ---
> >> Changelog since v4:
> >> - Created this patch for clarity.  Previously this patch was integrated within
> >>   the "writeback: create dirty_info structure" patch.
> >>
> >>  mm/page-writeback.c |    6 ++++--
> >>  1 files changed, 4 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> >> index 2cb01f6..4408e54 100644
> >> --- a/mm/page-writeback.c
> >> +++ b/mm/page-writeback.c
> >> @@ -478,8 +478,10 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
> >>  static void balance_dirty_pages(struct address_space *mapping,
> >>                               unsigned long write_chunk)
> >>  {
> >> -     long nr_reclaimable, bdi_nr_reclaimable;
> >> -     long nr_writeback, bdi_nr_writeback;
> >> +     unsigned long nr_reclaimable;
> >> +     long bdi_nr_reclaimable;
> >> +     unsigned long nr_writeback;
> >> +     long bdi_nr_writeback;
> >>       unsigned long background_thresh;
> >>       unsigned long dirty_thresh;
> >>       unsigned long bdi_thresh;
> >> --
> >> 1.7.3.1
> >>
> > bdi_nr_[reclaimable|writeback] can return negative value?
> > When I just look through bdi_stat_sum, it uses *percpu_counter_sum_positive*.
> > So I guess it always returns positive value.
> > If it is right, could you change it, too?
> 
> Yes, I think we can also change bdi_nr_[reclaimable|writeback] to unsigned long.
> 
> bdi_stat_sum() and bdi_stat() both call percpu_counter_sum_positive(),
> which return a positive number.  bdi_stat[_sum]() return s64.  Should
> we also change bdi_stat[_sum]() to return unsigned long rather than
> s64?  I would like the return value type to match the type of the
> corresponding local variables in balance_dirty_pages().  All current
> callers appear to expect bdi_stat[_sum]() to return unsigned long.

Please, clear them, too.
But this patch could be orthogonal with your series so it's up to you. :)

> 
> > --
> > Kind regards,
> > Minchan Kim
> >

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
