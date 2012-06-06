Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 065CB6B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 23:14:29 -0400 (EDT)
Received: by wibhn14 with SMTP id hn14so4038677wib.2
        for <linux-mm@kvack.org>; Tue, 05 Jun 2012 20:14:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120606025729.GA1197@redhat.com>
References: <20120528114124.GA6813@localhost> <CA+55aFxHt8q8+jQDuoaK=hObX+73iSBTa4bBWodCX3s-y4Q1GQ@mail.gmail.com>
 <20120529155759.GA11326@localhost> <CA+55aFykFaBhzzEyRYWRS9Qoy_q_R65Cuth7=XvfOZEMqjn6=w@mail.gmail.com>
 <20120530032129.GA7479@localhost> <20120605172302.GB28556@redhat.com>
 <20120605174157.GC28556@redhat.com> <20120605184853.GD28556@redhat.com>
 <20120605201045.GE28556@redhat.com> <20120606025729.GA1197@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 5 Jun 2012 20:14:08 -0700
Message-ID: <CA+55aFyxucvhYhbk0yyNa1WSeYXgHHAyWRHPNWDwODQhyAWGww@mail.gmail.com>
Subject: Re: write-behind on streaming writes
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>

On Tue, Jun 5, 2012 at 7:57 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
>
> I had expected a bigger difference as sync_file_range() is just driving
> max queue depth of 32 (total 16MB IO in flight), while flushers are
> driving queue depths up to 140 or so. So in this paritcular test, driving
> much deeper queue depths is not really helping much. (I have seen higher
> throughputs with higher queue depths in the past. Now sure why don't we
> see it here).

How did interactivity feel?

Because quite frankly, if the throughput difference is 12.5 vs 12
seconds, I suspect the interactivity thing is what dominates.

And from my memory of the interactivity different was absolutely
*huge*. Even back when I used rotational media, I basically couldn't
even notice the background write with the sync_file_range() approach.
While the regular writeback without the writebehind had absolutely
*huge* pauses if you used something like firefox that uses fsync()
etc. And starting new applications that weren't cached was noticeably
worse too - and then with sync_file_range it wasn't even all that
noticeable.

NOTE! For the real "firefox + fsync" test, I suspect you'd need to do
the writeback on the same filesystem (and obviously disk) as your home
directory is. If the big write is to another filesystem and another
disk, I think you won't see the same issues.

Admittedly, I have not really touched anything with a rotational disk
for the last few years, nor do I ever want to see those rotating
pieces of high-tech rust ever again. And maybe your SAN has so good
latency even under load that it doesn't really matter. I remember it
mattering a lot back when..

Of course, back when I did that testing and had rotational media, we
didn't have the per-bdi writeback logic with the smart speed-dependent
depths etc, so it may be that we're just so much better at writeback
these days that it's not nearly as noticeable any more.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
