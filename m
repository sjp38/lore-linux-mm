Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 46F8A6B0037
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 12:13:24 -0400 (EDT)
Date: Tue, 23 Apr 2013 17:13:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
Message-ID: <20130423161319.GC2108@suse.de>
References: <20130410105608.GC1910@suse.de>
 <20130410131245.GC4862@thunk.org>
 <20130411170402.GB11656@suse.de>
 <20130411183512.GA12298@thunk.org>
 <20130411213335.GE9379@quack.suse.cz>
 <20130412025708.GB7445@thunk.org>
 <20130412094731.GI11656@suse.de>
 <20130421000522.GA5054@thunk.org>
 <20130423153305.GB2108@suse.de>
 <20130423155019.GH31170@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130423155019.GH31170@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>

On Tue, Apr 23, 2013 at 11:50:19AM -0400, Theodore Ts'o wrote:
> On Tue, Apr 23, 2013 at 04:33:05PM +0100, Mel Gorman wrote:
> > That's a pretty big drop but it gets bad again for the second worst stall --
> > wait_on_page_bit as a result of generic_file_buffered_write.
> > 
> > Vanilla kernel  1336064 ms stalled with 109 events
> > Patched kernel  2338781 ms stalled with 164 events
> 
> Do you have the stack trace for this stall?  I'm wondering if this is
> caused by the waiting for stable pages in write_begin() , or something
> else.
> 

[<ffffffff81110238>] wait_on_page_bit+0x78/0x80
[<ffffffff815af294>] kretprobe_trampoline+0x0/0x4c
[<ffffffff81110e84>] generic_file_buffered_write+0x114/0x2a0
[<ffffffff81111ccd>] __generic_file_aio_write+0x1bd/0x3c0
[<ffffffff81111f4a>] generic_file_aio_write+0x7a/0xf0
[<ffffffff811ee639>] ext4_file_write+0x99/0x420
[<ffffffff81174d87>] do_sync_write+0xa7/0xe0
[<ffffffff81175447>] vfs_write+0xa7/0x180
[<ffffffff811758cd>] sys_write+0x4d/0x90
[<ffffffff815b3eed>] system_call_fastpath+0x1a/0x1f
[<ffffffffffffffff>] 0xffffffffffffffff

The processes that stalled in this particular trace are wget, latency-output,
tar and tclsh. Most of these are sequential writers except for tar which
is both a sequential reader and sequential writers.

> If it is blocking caused by stable page writeback that's interesting,
> since it would imply that something in your workload is trying to
> write to a page that has already been modified (i.e., appending to a
> log file, or updating a database file).  Does that make sense given
> what your workload might be running?
> 

I doubt it is stable write consider the type of processes that are running. I
would expect the bulk of the activity to be sequential readers or writers
of multiple files. The summarised report from the raw data is now at

http://www.csn.ul.ie/~mel/postings/ext4tag-20130423/dstate-summary-vanilla
http://www.csn.ul.ie/~mel/postings/ext4tag-20130423/dstate-summary-ext4tag

It's an aside but the worst of the stalls are incurred by systemd-tmpfile
which were not a deliberate part of the test and yet another thing that
I would not have caught unless I was running tests on my laptop. Looking
closer at that thing, the default configuration is to run the service 15
minutes after boot and after that it runs once a day. It looks like the
bulk of the scanning would be in /var/tmp/ looking at systemds own files
(over 3000 of them) which I'm a little amused by.

My normal test machines would not hit this because they are not systemd
based but the existance of thing thing is worth noting. Any IO-based tests
run on systemd-based distributions may give different results depending
on whether this service triggered during the test or not.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
