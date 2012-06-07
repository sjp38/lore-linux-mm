Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 738866B0070
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 15:06:19 -0400 (EDT)
Date: Thu, 7 Jun 2012 15:06:13 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: write-behind on streaming writes
Message-ID: <20120607190613.GC18538@redhat.com>
References: <20120605172302.GB28556@redhat.com>
 <20120605174157.GC28556@redhat.com>
 <20120605184853.GD28556@redhat.com>
 <20120605201045.GE28556@redhat.com>
 <20120606025729.GA1197@redhat.com>
 <CA+55aFyxucvhYhbk0yyNa1WSeYXgHHAyWRHPNWDwODQhyAWGww@mail.gmail.com>
 <20120606121408.GB4934@redhat.com>
 <20120606140058.GA8098@localhost>
 <20120606170428.GB8133@redhat.com>
 <20120607094504.GB25074@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120607094504.GB25074@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>

On Thu, Jun 07, 2012 at 11:45:04AM +0200, Jan Kara wrote:
[..]
> > Instead of above, I modified sync_file_range() to call
> > __filemap_fdatawrite_range(WB_SYNC_NONE) and I do see now ASYNC writes
> > showing up at elevator.
> > 
> > With 4 processes doing sync_file_range() now, firefox start time test
> > clocks around 18-19 seconds which is better than 30-35 seconds of 4
> > processes doing buffered writes. And system looks pretty good from
> > interactivity point of view.
>   So do you have any idea why is that? Do we drive shallower queues? Also
> how does speed of the writers compare to the speed with normal buffered
> writes + fsync (you'd need fsync for sync_file_range writers as well to
> make comparison fair)?

Ok, I did more tests and few odd things I noticed.

- Results are varying a lot. Sometimes with write+flush workload also firefox
  launched fast. So now it is hard to conclude things.

- For some reason I had nr_requests as 16K on my root drive. I have no
  idea who is setting it. Once I set it to 128, then firefox with
  write+flush workload performs much better and launch time are similar
  to sync_file_range.

- I tried to open new windows in firefox and browse web, load new
  websites. I would say sync_file_range() feels little better but
  I don't have any logical explanation and can't conclude anything yet
  by looking at traces. I am continuing to stare though.

So in summary, at this point of time I really can't conclude that
using sync_file_range() with ASYNC request is providing better latencies
in my setup.

I will keept at it though and if I notice something new, will write back.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
