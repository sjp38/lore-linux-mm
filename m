Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 900BF6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 16:03:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w1-v6so1293837pgr.7
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 13:03:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r3-v6si49554121plb.336.2018.06.05.13.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 13:03:31 -0700 (PDT)
Date: Tue, 5 Jun 2018 13:03:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 199931] New: systemd/rtorrent file data corruption when
 using echo 3 >/proc/sys/vm/drop_caches
Message-Id: <20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
In-Reply-To: <bug-199931-27@https.bugzilla.kernel.org/>
References: <bug-199931-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <clm@fb.com>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: bugzilla-daemon@bugzilla.kernel.org, bugzilla.kernel.org@plan9.de, linux-btrfs@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 05 Jun 2018 18:01:36 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=199931
> 
>             Bug ID: 199931
>            Summary: systemd/rtorrent file data corruption when using echo
>                     3 >/proc/sys/vm/drop_caches

A long tale of woe here.  Chris, do you think the pagecache corruption
is a general thing, or is it possible that btrfs is contributing?

Also, that 4.4 oom-killer regression sounds very serious.

>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.14.33
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: bugzilla.kernel.org@plan9.de
>         Regression: No
> 
> We found that
> 
>    echo 3 >/proc/sys/vm/drop_caches
> 
> causes file data corruption. We found this because we saw systemd journal
> corruption (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=897266) and
> tracked this to a cron job dropping caches every hour. The filesystem in use is
> btrfs, but I don't know if it only happens with this filesystem. btrfs scrub
> reports no problems, so this is not filesystem metdata corruption.
> 
> Basically:
> 
>    # journalctl --verify
>    [everything fine at this point]
>    # echo 3 >/proc/sys/vm/drop_caches
>    # journalctl --verify
>    [journalctl now reporting corruption problems]
> 
> This is not always reproducible, but when deleting our journal, creating log
> messages for a few hours and then doing the above manually has a ~50% chance of
> corrupting the journal.
> 
> After investigating we found that rtorrent also suffers from corrupted
> downloads when using the above echo - basically, downloading torrents is fine,
> except when executing the above echo a few times during a download, after which
> rtorrent very likely reports a failed hash check.
> 
> All of this is reproducible on two different boxes, so is unlikely to be a
> hardware issue.
> 
> On one affected server we have over 50TB of files, many that have been created
> with the cronjob in place, and none of them are corrupted (we have md5sums of
> everything), so it seems to be related to something that systemd and rtorrent
> do, rather than a generic file corruption issue.
> 
> I also was able to "cmp -l" two corrupted files with their correct version, and
> the corruption manifests itself as streaks of ~100-3000 zero bytes instead of
> the real data. The start offset sems random, but the end offset seems to be
> always aligned to a 4K offset - speculating without the hindrance of knowledge
> this feels like a race somewhere between writing to a mmapped area and freeing
> it, or so.
> 
> Here is the output of cmp -l between a working and a corrupted file, for two
> files:
> 
> http://data.plan9.de/01.cmp.txt
> http://data.plan9.de/02.cmp.txt
> 
> We also have a mysql database with hundreds of gigabytes of writes per day on
> one server which also does not seem to suffer from any corruption.
> 
> As for why we would do something silly as dropping the caches every hour (in a
> cronjob), we started doing this recently because after kernel 4.4, we got
> frequent OOM kills despite having gigabytes of available memory (e.g. 12GB in
> use, 20GB page cache and 16GB empty swap and bang, mysql gets killed). We found
> that that the debian 4.9 kernel is unusable, and 4.14 works, *iff* we use the
> above as an hourly cron job, so we did that, and afterwards run into
> rtorrent/journald corruption issues. Without the echo in place, mysql usually
> gets oom-killed after a few days of uptime.
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
