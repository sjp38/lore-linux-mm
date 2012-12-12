Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 0AA206B006C
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 21:26:27 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fa1so134214pad.21
        for <linux-mm@kvack.org>; Tue, 11 Dec 2012 18:26:27 -0800 (PST)
Message-ID: <1355279182.1532.4.camel@kernel.cn.ibm.com>
Subject: Re: livelock in __writeback_inodes_wb ?
From: Simon Jeons <simon.jeons@gmail.com>
Date: Tue, 11 Dec 2012 20:26:22 -0600
In-Reply-To: <20121211142942.GA1943@redhat.com>
References: <20121128145515.GA26564@redhat.com>
	 <20121211082327.GA15706@localhost> <20121211142942.GA1943@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org

On Tue, 2012-12-11 at 09:29 -0500, Dave Jones wrote:
> On Tue, Dec 11, 2012 at 04:23:27PM +0800, Fengguang Wu wrote:
>  > On Wed, Nov 28, 2012 at 09:55:15AM -0500, Dave Jones wrote:
>  > > We had a user report the soft lockup detector kicked after 22
>  > > seconds of no progress, with this trace..
>  > 
>  > Where is the original report? The reporter may help provide some clues
>  > on the workload that triggered the bug.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=880949 
> 
>  > The bug reporter should know best whether there are heavy IO.
>  > 
>  > However I suspect it's not directly caused by heavy IO: we will
>  > release &wb->list_lock before each __writeback_single_inode() call,
>  > which starts writeback IO for each inode.
>  > 
>  > > Should there be something in this loop periodically poking
>  > > the watchdog perhaps ?
>  > 
>  > It seems we failed to release &wb->list_lock in wb_writeback() for
>  > long time (dozens of seconds). That is, the inode_sleep_on_writeback()
>  > is somehow not called. However it's not obvious to me how come this
>  > can happen..
> 
> Right, it seems that we only drop the lock when there is more work to do.
> And if there is no work to do, then we would have bailed from the loop.

If no work to do, lock will be dropped after for loop.

> 
> mysterious.
> 
> 	Dave
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
