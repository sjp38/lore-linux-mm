Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 07EF16B0373
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 20:48:17 -0400 (EDT)
Date: Sat, 21 Aug 2010 08:48:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/4] writeback: nr_dirtied and nr_entered_writeback in
 /proc/vmstat
Message-ID: <20100821004804.GA11030@localhost>
References: <1282296689-25618-1-git-send-email-mrubin@google.com>
 <1282296689-25618-4-git-send-email-mrubin@google.com>
 <20100820100855.GC8440@localhost>
 <AANLkTi=+uNFq5=5gmjfAOhngXqR8RS3dX3E2uEWG33Ot@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=+uNFq5=5gmjfAOhngXqR8RS3dX3E2uEWG33Ot@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 21, 2010 at 07:51:38AM +0800, Michael Rubin wrote:
> On Fri, Aug 20, 2010 at 3:08 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > How about the names nr_dirty_accumulated and nr_writeback_accumulated?
> > It seems more consistent, for both the interface and code (see below).
> > I'm not really sure though.
> 
> Those names don't seem to right to me.
> I admit I like "nr_dirtied" and "nr_cleaned" that seems most
> understood. These numbers also get very big pretty fast so I don't
> think it's hard to infer.

That's fine. I like "nr_cleaned".

> >> In order to track the "cleaned" and "dirtied" counts we added two
> >> vm_stat_items. A Per memory node stats have been added also. So we can
> >> see per node granularity:
> >>
> >> A  A # cat /sys/devices/system/node/node20/writebackstat
> >> A  A Node 20 pages_writeback: 0 times
> >> A  A Node 20 pages_dirtied: 0 times
> >
> > I'd prefer the name "vmstat" over "writebackstat", and propose to
> > migrate items from /proc/zoneinfo over time. zoneinfo is a terrible
> > interface for scripting.
> 
> I like vmstat also. I can do that.

Thank you.

> > Also, are there meaningful usage of per-node writeback stats?
> 
> For us yes. We use fake numa nodes to implement cgroup memory isolation.
> This allows us to see what the writeback behaviour is like per cgroup.

That's sure convenient for you, for now. But it's special use case.

I wonder if you'll still stick to the fake NUMA scenario two years
later -- when memcg grows powerful enough. What do we do then? "Hey
let's rip these counters, their major consumer has dumped them.."

For per-job nr_dirtied, I suspect the per-process write_bytes and
cancelled_write_bytes in /proc/self/io will serve you well.

For per-job nr_cleaned, I suspect the per-zone nr_writeback will be
sufficient for debug purposes (in despite of being a bit different).

> > The numbers are naturally per-bdi ones instead. But if we plan to
> > expose them for each bdi, this patch will need to be implemented
> > vastly differently.
> 
> Currently I have no plans to do that.

Peter? :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
