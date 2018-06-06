Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 146C66B0007
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 20:18:57 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x90-v6so894221lfi.17
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 17:18:57 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id j85-v6si10654625lje.333.2018.06.05.17.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jun 2018 17:18:55 -0700 (PDT)
From: Chris Mason <clm@fb.com>
Subject: Re: [Bug 199931] New: systemd/rtorrent file data corruption when
 using echo 3 >/proc/sys/vm/drop_caches
Date: Tue, 5 Jun 2018 20:18:37 -0400
Message-ID: <9C514595-AA27-4794-9831-BEF3A8A6787E@fb.com>
In-Reply-To: <20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
References: <bug-199931-27@https.bugzilla.kernel.org/>
 <20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, bugzilla.kernel.org@plan9.de, linux-btrfs@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>



On 5 Jun 2018, at 16:03, Andrew Morton wrote:

> (switched to email.  Please respond via emailed reply-to-all, not via 
> the
> bugzilla web interface).
>
> On Tue, 05 Jun 2018 18:01:36 +0000 bugzilla-daemon@bugzilla.kernel.org 
> wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=199931
>>
>>             Bug ID: 199931
>>            Summary: systemd/rtorrent file data corruption when using 
>> echo
>>                     3 >/proc/sys/vm/drop_caches
>
> A long tale of woe here.  Chris, do you think the pagecache corruption
> is a general thing, or is it possible that btrfs is contributing?
>
> Also, that 4.4 oom-killer regression sounds very serious.

This week I found a bug in btrfs file write with how we handle stable 
pages.  Basically it works like this:

write(fd, some bytes less than a page)
write(fd, some bytes into the same page)
     btrfs prefaults the userland page
     lock_and_cleanup_extent_if_need()	<- stable pages
		wait for writeback()
		clear_page_dirty_for_io()

At this point we have a page that was dirty and is now clean.  That's 
normally fine, unless our prefaulted page isn't in ram anymore.

	iov_iter_copy_from_user_atomic() <--- uh oh

If the copy_from_user fails, we drop all our locks and retry.  But along 
the way, we completely lost the dirty bit on the page.  If the page is 
dropped by drop_caches, the writes are lost.  We'll just read back the 
stale contents of that page during the retry loop.  This won't result in 
crc errors because the bytes we lost were never crc'd.

It could result in zeros in the file because we're basically reading a 
hole, and those zeros could move around in the page depending on which 
part of the page was dirty when the writes were lost.

I spent a morning trying to trigger this with drop_caches and couldn't 
make it happen, even with schedule_timeout()s inserted and other tricks. 
  But I was able to get corruptions if I manually invalidated pages in 
the critical section.

I'm working on a patch, and I'll check and see if any of the other 
recent fixes Dave integrated may have a less exotic explanation.

-chris
