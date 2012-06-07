Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 0FCC76B006C
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 05:45:16 -0400 (EDT)
Date: Thu, 7 Jun 2012 11:45:04 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: write-behind on streaming writes
Message-ID: <20120607094504.GB25074@quack.suse.cz>
References: <20120530032129.GA7479@localhost>
 <20120605172302.GB28556@redhat.com>
 <20120605174157.GC28556@redhat.com>
 <20120605184853.GD28556@redhat.com>
 <20120605201045.GE28556@redhat.com>
 <20120606025729.GA1197@redhat.com>
 <CA+55aFyxucvhYhbk0yyNa1WSeYXgHHAyWRHPNWDwODQhyAWGww@mail.gmail.com>
 <20120606121408.GB4934@redhat.com>
 <20120606140058.GA8098@localhost>
 <20120606170428.GB8133@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120606170428.GB8133@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>

On Wed 06-06-12 13:04:28, Vivek Goyal wrote:
> On Wed, Jun 06, 2012 at 10:00:58PM +0800, Fengguang Wu wrote:
> > On Wed, Jun 06, 2012 at 08:14:08AM -0400, Vivek Goyal wrote:
> > > On Tue, Jun 05, 2012 at 08:14:08PM -0700, Linus Torvalds wrote:
> > > > On Tue, Jun 5, 2012 at 7:57 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> > > > >
> > > > > I had expected a bigger difference as sync_file_range() is just driving
> > > > > max queue depth of 32 (total 16MB IO in flight), while flushers are
> > > > > driving queue depths up to 140 or so. So in this paritcular test, driving
> > > > > much deeper queue depths is not really helping much. (I have seen higher
> > > > > throughputs with higher queue depths in the past. Now sure why don't we
> > > > > see it here).
> > > > 
> > > > How did interactivity feel?
> > > > 
> > > > Because quite frankly, if the throughput difference is 12.5 vs 12
> > > > seconds, I suspect the interactivity thing is what dominates.
> > > > 
> > > > And from my memory of the interactivity different was absolutely
> > > > *huge*. Even back when I used rotational media, I basically couldn't
> > > > even notice the background write with the sync_file_range() approach.
> > > > While the regular writeback without the writebehind had absolutely
> > > > *huge* pauses if you used something like firefox that uses fsync()
> > > > etc. And starting new applications that weren't cached was noticeably
> > > > worse too - and then with sync_file_range it wasn't even all that
> > > > noticeable.
> > > > 
> > > > NOTE! For the real "firefox + fsync" test, I suspect you'd need to do
> > > > the writeback on the same filesystem (and obviously disk) as your home
> > > > directory is. If the big write is to another filesystem and another
> > > > disk, I think you won't see the same issues.
> > > 
> > > Ok, I did following test on my single SATA disk and my root filesystem
> > > is on this disk.
> > > 
> > > I dropped caches and launched firefox and monitored the time it takes
> > > for firefox to start. (cache cold).
> > > 
> > > And my results are reverse of what you have been seeing. With
> > > sync_file_range() running, firefox takes roughly 30 seconds to start and
> > > with flusher in operation, it takes roughly 20 seconds to start. (I have
> > > approximated the average of 3 runs for simplicity).
> > > 
> > > I think it is happening because sync_file_range() will send all
> > > the writes as SYNC and it will compete with firefox IO. On the other
> > > hand, flusher's IO will show up as ASYNC and CFQ  will be penalize it
> > > heavily and firefox's IO will be prioritized. And this effect should
> > > just get worse as more processes do sync_file_range().
> > > 
> > > So write-behind should provide better interactivity if writes submitted
> > > are ASYNC and not SYNC.
> > 
> > Hi Vivek, thanks for testing all of these out! The result is
> > definitely interesting and a surprise: we overlooked the SYNC nature
> > of sync_file_range().
> > 
> > I'd suggest to use these calls to achieve the write-and-drop-behind
> > behavior, *with* WB_SYNC_NONE:
> > 
> >         posix_fadvise(fd, offset, len, POSIX_FADV_DONTNEED);
> >         sync_file_range(fd, offset, len, SYNC_FILE_RANGE_WAIT_AFTER);
> > 
> > The caveat is, the below bdi_write_congested() will never evaluate to
> > true since we are only filling the request queue with 8MB data.
> > 
> > SYSCALL_DEFINE(fadvise64_64):
> > 
> >         case POSIX_FADV_DONTNEED:
> >                 if (!bdi_write_congested(mapping->backing_dev_info))
> >                         __filemap_fdatawrite_range(mapping, offset, endbyte,
> >                                                    WB_SYNC_NONE);
> 
> Hi Fengguang,
> 
> Instead of above, I modified sync_file_range() to call
> __filemap_fdatawrite_range(WB_SYNC_NONE) and I do see now ASYNC writes
> showing up at elevator.
> 
> With 4 processes doing sync_file_range() now, firefox start time test
> clocks around 18-19 seconds which is better than 30-35 seconds of 4
> processes doing buffered writes. And system looks pretty good from
> interactivity point of view.
  So do you have any idea why is that? Do we drive shallower queues? Also
how does speed of the writers compare to the speed with normal buffered
writes + fsync (you'd need fsync for sync_file_range writers as well to
make comparison fair)?

								Honza
> ---
>  fs/sync.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/fs/sync.c
> ===================================================================
> --- linux-2.6.orig/fs/sync.c	2012-06-06 00:12:33.000000000 -0400
> +++ linux-2.6/fs/sync.c	2012-06-06 23:11:17.050691776 -0400
> @@ -342,7 +342,7 @@ SYSCALL_DEFINE(sync_file_range)(int fd, 
>  	}
>  
>  	if (flags & SYNC_FILE_RANGE_WRITE) {
> -		ret = filemap_fdatawrite_range(mapping, offset, endbyte);
> +		ret = __filemap_fdatawrite_range(mapping, offset, endbyte, WB_SYNC_NONE);
>  		if (ret < 0)
>  			goto out_put;
>  	}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
