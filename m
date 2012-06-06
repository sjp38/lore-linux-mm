Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 789928D0001
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 08:14:14 -0400 (EDT)
Date: Wed, 6 Jun 2012 08:14:08 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: write-behind on streaming writes
Message-ID: <20120606121408.GB4934@redhat.com>
References: <CA+55aFxHt8q8+jQDuoaK=hObX+73iSBTa4bBWodCX3s-y4Q1GQ@mail.gmail.com>
 <20120529155759.GA11326@localhost>
 <CA+55aFykFaBhzzEyRYWRS9Qoy_q_R65Cuth7=XvfOZEMqjn6=w@mail.gmail.com>
 <20120530032129.GA7479@localhost>
 <20120605172302.GB28556@redhat.com>
 <20120605174157.GC28556@redhat.com>
 <20120605184853.GD28556@redhat.com>
 <20120605201045.GE28556@redhat.com>
 <20120606025729.GA1197@redhat.com>
 <CA+55aFyxucvhYhbk0yyNa1WSeYXgHHAyWRHPNWDwODQhyAWGww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyxucvhYhbk0yyNa1WSeYXgHHAyWRHPNWDwODQhyAWGww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>

On Tue, Jun 05, 2012 at 08:14:08PM -0700, Linus Torvalds wrote:
> On Tue, Jun 5, 2012 at 7:57 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> >
> > I had expected a bigger difference as sync_file_range() is just driving
> > max queue depth of 32 (total 16MB IO in flight), while flushers are
> > driving queue depths up to 140 or so. So in this paritcular test, driving
> > much deeper queue depths is not really helping much. (I have seen higher
> > throughputs with higher queue depths in the past. Now sure why don't we
> > see it here).
> 
> How did interactivity feel?
> 
> Because quite frankly, if the throughput difference is 12.5 vs 12
> seconds, I suspect the interactivity thing is what dominates.
> 
> And from my memory of the interactivity different was absolutely
> *huge*. Even back when I used rotational media, I basically couldn't
> even notice the background write with the sync_file_range() approach.
> While the regular writeback without the writebehind had absolutely
> *huge* pauses if you used something like firefox that uses fsync()
> etc. And starting new applications that weren't cached was noticeably
> worse too - and then with sync_file_range it wasn't even all that
> noticeable.
> 
> NOTE! For the real "firefox + fsync" test, I suspect you'd need to do
> the writeback on the same filesystem (and obviously disk) as your home
> directory is. If the big write is to another filesystem and another
> disk, I think you won't see the same issues.

Ok, I did following test on my single SATA disk and my root filesystem
is on this disk.

I dropped caches and launched firefox and monitored the time it takes
for firefox to start. (cache cold).

And my results are reverse of what you have been seeing. With
sync_file_range() running, firefox takes roughly 30 seconds to start and
with flusher in operation, it takes roughly 20 seconds to start. (I have
approximated the average of 3 runs for simplicity).

I think it is happening because sync_file_range() will send all
the writes as SYNC and it will compete with firefox IO. On the other
hand, flusher's IO will show up as ASYNC and CFQ  will be penalize it
heavily and firefox's IO will be prioritized. And this effect should
just get worse as more processes do sync_file_range().

So write-behind should provide better interactivity if writes submitted
are ASYNC and not SYNC.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
