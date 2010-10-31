Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6A00F8D005B
	for <linux-mm@kvack.org>; Sun, 31 Oct 2010 16:04:58 -0400 (EDT)
Date: Mon, 1 Nov 2010 04:03:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v4 11/11] memcg: check memcg dirty limits in page
 writeback
Message-ID: <20101031200341.GA455@localhost>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
 <1288336154-23256-12-git-send-email-gthelen@google.com>
 <20101029164835.06eef3cf.kamezawa.hiroyu@jp.fujitsu.com>
 <xr93eib9nfue.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93eib9nfue.fsf@ninji.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 30, 2010 at 12:06:33AM +0800, Greg Thelen wrote:
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > On Fri, 29 Oct 2010 00:09:14 -0700
> > Greg Thelen <gthelen@google.com> wrote:
> >
> >> If the current process is in a non-root memcg, then
> >> balance_dirty_pages() will consider the memcg dirty limits
> >> as well as the system-wide limits.  This allows different
> >> cgroups to have distinct dirty limits which trigger direct
> >> and background writeback at different levels.
> >> 
> >> Signed-off-by: Andrea Righi <arighi@develer.com>
> >> Signed-off-by: Greg Thelen <gthelen@google.com>
> >
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

The "check both memcg&global dirty limit" looks much more sane than
the V3 implementation. Although it still has misbehaviors in some
cases, it's generally a good new feature to have.

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

> > Ideally, I think some comments in the code for "why we need double-check system's
> > dirty limit and memcg's dirty limit" will be appreciated.
> 
> I will add to the balance_dirty_pages() comment.  It will read:
> /*
>  * balance_dirty_pages() must be called by processes which are generating dirty
>  * data.  It looks at the number of dirty pages in the machine and will force
>  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
                   ~~~~~~~~~~~~~~~~~                  ~~~~

To be exact, it tries to throttle the dirty speed so that
vm_dirty_ratio is not exceeded. In fact balance_dirty_pages() starts
throttling the dirtier slightly below vm_dirty_ratio.

>  * If we're over `background_thresh' then the writeback threads are woken to
>  * perform some writeout.  The current task may have per-memcg dirty
>  * limits, which are also checked.
>  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
