Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 086738D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 07:23:02 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9TBMxNI029040
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 Oct 2010 20:23:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 92DAC45DE6E
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 20:22:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 72FD745DE4D
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 20:22:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CBF2EF8002
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 20:22:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E83CEF8001
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 20:22:59 +0900 (JST)
Date: Fri, 29 Oct 2010 20:17:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 06/11] memcg: add dirty page accounting
 infrastructure
Message-Id: <20101029201726.370e462b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101029111300.GB29774@localhost>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
	<1288336154-23256-7-git-send-email-gthelen@google.com>
	<20101029111300.GB29774@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 19:13:00 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Fri, Oct 29, 2010 at 03:09:09PM +0800, Greg Thelen wrote:
> 
> > +
> > +	case MEMCG_NR_FILE_DIRTY:
> > +		/* Use Test{Set,Clear} to only un/charge the memcg once. */
> > +		if (val > 0) {
> > +			if (TestSetPageCgroupFileDirty(pc))
> > +				val = 0;
> > +		} else {
> > +			if (!TestClearPageCgroupFileDirty(pc))
> > +				val = 0;
> > +		}
> 
> I'm wondering why TestSet/TestClear and even the cgroup page flags for
> dirty/writeback/unstable pages are necessary at all (it helps to
> document in changelog if there are any). For example, VFS will call
> TestSetPageDirty() before calling
> mem_cgroup_inc_page_stat(MEMCG_NR_FILE_DIRTY), so there should be no
> chance of false double counting.
> 

1. flag is necessary for moving accounting information between cgroups
   when account_move() occurs.

2. TestSet... is required because there are always race with page_cgroup_lock()'s
   lock bit.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
