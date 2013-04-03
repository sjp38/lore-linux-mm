Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 1A2306B00EF
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 08:05:34 -0400 (EDT)
Date: Wed, 3 Apr 2013 08:05:30 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130403120529.GA7741@thunk.org>
References: <20130402142717.GH32241@suse.de>
 <20130402150651.GB31577@thunk.org>
 <20130402151436.GC31577@thunk.org>
 <20130403101925.GA7341@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130403101925.GA7341@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Wed, Apr 03, 2013 at 11:19:25AM +0100, Mel Gorman wrote:
> 
> I'm running with -rc5 now. I have not noticed much interactivity problems
> as such but the stall detection script reported that mutt stalled for
> 20 seconds opening an inbox and imapd blocked for 59 seconds doing path
> lookups, imaps blocked again for 12 seconds doing an atime update, an RSS
> reader blocked for 3.5 seconds writing a file. etc.

If imaps blocked for 12 seconds during an atime update, combined with
everything else, at a guess it got caught by something holding up a
journal commit.  Could you try enabling the jbd2_run_stats tracepoint
and grabbing the trace log?  This will give you statistics on how long
(in milliseconds) each of the various phases of a jbd2 commit is
taking, i.e.:

    jbd2/sdb1-8-327   [002] .... 39681.874661: jbd2_run_stats: dev 8,17 tid 7163786 wait 0 request_delay 0 running 3530 locked 0 flushing 0 logging 0 handle_count 75 blocks 8 blocks_logged 9
     jbd2/sdb1-8-327   [003] .... 39682.514153: jbd2_run_stats: dev 8,17 tid 7163787 wait 0 request_delay 0 running 640 locked 0 flushing 0 logging 0 handle_count 39 blocks 12 blocks_logged 13
     jbd2/sdb1-8-327   [000] .... 39687.665609: jbd2_run_stats: dev 8,17 tid 7163788 wait 0 request_delay 0 running 5150 locked 0 flushing 0 logging 0 handle_count 60 blocks 13 blocks_logged 14
     jbd2/sdb1-8-327   [000] .... 39693.200453: jbd2_run_stats: dev 8,17 tid 7163789 wait 0 request_delay 0 running 4840 locked 0 flushing 0 logging 0 handle_count 53 blocks 10 blocks_logged 11
     jbd2/sdb1-8-327   [001] .... 39695.061657: jbd2_run_stats: dev 8,17 tid 7163790 wait 0 request_delay 0 running 1860 locked 0 flushing 0 logging 0 handle_count 124 blocks 19 blocks_logged 20

In the above sample each journal commit is running for no more than 5
seconds or so (since that's the default jbd2 commit timeout; if a
transaction is running for less than 5 seconds, then either we ran out
of room in the journal, and the blocks_logged number will be high, or
a commit was forced by something such as an fsync call).  

If an atime update is getting blocked by 12 seconds, then it would be
interesting to see if a journal commit is running for significantly
longer than 5 seconds, or if one of the other commit phases is taking
significant amounts of time.  (On the example above they are all
taking no time, since I ran this on a relatively uncontended system;
only a single git operation taking place.)

Something else that might be worth trying is grabbing a lock_stat
report and see if something is sitting on an ext4 or jbd2 mutex for a
long time.

Finally, as I mentioned I tried some rather simplistic tests and I
didn't notice any difference between a 3.2 kernel and a 3.8/3.9-rc5
kernel.  Assuming you can get a version of systemtap that
simultaneously works on 3.2 and 3.9-rc5 :-P, and chance you could do a
quick experiment and see if you're seeing a difference on your setup?

Thanks!!

					 - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
