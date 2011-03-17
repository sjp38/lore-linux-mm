Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 97EEC8D0046
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 13:12:38 -0400 (EDT)
Date: Thu, 17 Mar 2011 13:12:19 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-ID: <20110317171219.GD32392@redhat.com>
References: <20110311171006.ec0d9c37.akpm@linux-foundation.org>
 <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
 <20110314202324.GG31120@redhat.com>
 <AANLkTinDNOLMdU7EEMPFkC_f9edCx7ZFc7=qLRNAEmBM@mail.gmail.com>
 <20110315184839.GB5740@redhat.com>
 <20110316131324.GM2140@cmpxchg.org>
 <AANLkTim7q3cLGjxnyBS7SDdpJsGi-z34bpPT=MJSka+C@mail.gmail.com>
 <20110316215214.GO2140@cmpxchg.org>
 <AANLkTinCErw+0QGpXJ4+JyZ1O96BC7SJAyXaP4t5v17c@mail.gmail.com>
 <20110317144641.GC4116@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110317144641.GC4116@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Curt Wohlgemuth <curtw@google.com>

On Thu, Mar 17, 2011 at 03:46:41PM +0100, Jan Kara wrote:

[..]
> > - bdi writeback: will revert some of the mmotm memcg dirty limit changes to
> >   fs-writeback.c so that wb_do_writeback() will return to checking
> >   wb_check_background_flush() to check background limits and being
> > interruptible if
> >   sync flush occurs.  wb_check_background_flush() will check the global
> >   memcg_over_bg_limit list for memcg that are over their dirty limit.
> >   wb_writeback() will either (I am not sure):
> >   a) scan memcg's bdi_memcg list of inodes (only some of them are dirty)
> >   b) scan bdi dirty inode list (only some of them in memcg) using
> >      inode_in_memcg() to identify inodes to write.  inode_in_memcg(inode,memcg),
> >      would walk memcg- -> memcg_bdi -> memcg_mapping to determine if the memcg
> >      is caching pages from the inode.
> Hmm, both has its problems. With a) we could queue all the dirty inodes
> from the memcg for writeback but then we'd essentially write all dirty data
> for a memcg, not only enough data to get below bg limit. And if we started
> skipping inodes when memcg(s) inode belongs to get below bg limit, we'd
> risk copying inodes there and back without reason, cases where some inodes
> never get written because they always end up skipped etc. Also the question
> whether some of the memcgs inode belongs to is still over limit is the
> hardest part of solution b) so we wouldn't help ourselves much.

May be I am missing something but can't we just start traversing
through list of memcg_over_bg_list and take option a) to traverse
through list of inodes and write them till we are below limit of
that group. We of course skip inodes which are not dirty.

This is assuming that root group is also part of that list so that
inodes in root group do not starve writeback.

We still continue to have all the inodes on bdi wb structure and
memcg will just give us pointers to those inodes. So for background
write, instead of going serially through dirty inodes list, we
will first pick the cgroup to write and then inode to write. As
we will be doing round robin among cgroup list, it will make sure
that none of the cgroups (including root) as well as inode are not
starved.

What am I missing?

Thanks
Vivek 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
