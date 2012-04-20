Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 88F696B00E7
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:29:47 -0400 (EDT)
Date: Fri, 20 Apr 2012 15:29:30 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120420192930.GR22419@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
 <20120419183118.GM10216@redhat.com>
 <20120420124518.GA7133@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120420124518.GA7133@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Fri, Apr 20, 2012 at 08:45:18PM +0800, Fengguang Wu wrote:

[..]
> If still keep the global async queue, it can run small 40ms slices
> without defeating the flusher's 500ms granularity. After each slice
> it can freely switch to other cgroups with sync IOs, so is free from
> latency issues. After return, it will continue to serve the same
> inode. It will basically be working on behalf of one cgroup for 500ms
> data, working for another cgroup for 500ms data and so on. That
> behavior does not impact fairness, because it's still using small
> slices and its weight is computed system wide thus exhibits some kind
> of smooth/amortize effects over long period of time. It can naturally 
> serve the same inode after return.

Ok, So tejun did say that we will have a switch where we will allow
retaining the old behavior of keeping all async writes in root group
and not in individual group. So throughput sensitive users can make
use of that and there is no need to push proportional IO logic to
writeback layer for buffered writes?

I am personally is not too excited about the case of putting async IO
in separate groups due to the reason that async IO of one group will
start impacting latencies of sync IO of another group and in practice
it might not be desirable. But there are others who have use cases for
separate async IO queue. So as long as switch is there to change the
behavior, I am not too worried.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
