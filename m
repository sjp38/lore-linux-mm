Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id CDED96B000D
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 09:55:18 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k129-v6so5253833itg.8
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 06:55:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j194-v6sor1977335itj.48.2018.06.06.06.55.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 06:55:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0909E1D8-D024-4667-A0E8-C1CF40E77683@fb.com>
References: <bug-199931-27@https.bugzilla.kernel.org/> <20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
 <9C514595-AA27-4794-9831-BEF3A8A6787E@fb.com> <CANQeFDBZp5b5MV_uk63ZPhvB2fnWc0hqsTCL6-7v8e-9LULVpQ@mail.gmail.com>
 <0909E1D8-D024-4667-A0E8-C1CF40E77683@fb.com>
From: Liu Bo <obuil.liubo@gmail.com>
Date: Wed, 6 Jun 2018 21:55:16 +0800
Message-ID: <CANQeFDAe5LOaTief5KBxtWb9ewJmRjmHvSnkdY_LrCX7-1rdkw@mail.gmail.com>
Subject: Re: [Bug 199931] New: systemd/rtorrent file data corruption when
 using echo 3 >/proc/sys/vm/drop_caches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <clm@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, bugzilla.kernel.org@plan9.de, linux-btrfs@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Wed, Jun 6, 2018 at 9:44 PM, Chris Mason <clm@fb.com> wrote:
> On 6 Jun 2018, at 9:38, Liu Bo wrote:
>
>> On Wed, Jun 6, 2018 at 8:18 AM, Chris Mason <clm@fb.com> wrote:
>>>
>>>
>>>
>>> On 5 Jun 2018, at 16:03, Andrew Morton wrote:
>>>
>>>> (switched to email.  Please respond via emailed reply-to-all, not via
>>>> the
>>>> bugzilla web interface).
>>>>
>>>> On Tue, 05 Jun 2018 18:01:36 +0000 bugzilla-daemon@bugzilla.kernel.org
>>>> wrote:
>>>>
>>>>> https://bugzilla.kernel.org/show_bug.cgi?id=199931
>>>>>
>>>>>             Bug ID: 199931
>>>>>            Summary: systemd/rtorrent file data corruption when using
>>>>> echo
>>>>>                     3 >/proc/sys/vm/drop_caches
>>>>
>>>>
>>>>
>>>> A long tale of woe here.  Chris, do you think the pagecache corruption
>>>> is a general thing, or is it possible that btrfs is contributing?
>>>>
>>>> Also, that 4.4 oom-killer regression sounds very serious.
>>>
>>>
>>>
>>> This week I found a bug in btrfs file write with how we handle stable
>>> pages.
>>> Basically it works like this:
>>>
>>> write(fd, some bytes less than a page)
>>> write(fd, some bytes into the same page)
>>>     btrfs prefaults the userland page
>>>     lock_and_cleanup_extent_if_need()   <- stable pages
>>>                 wait for writeback()
>>>                 clear_page_dirty_for_io()
>>>
>>> At this point we have a page that was dirty and is now clean.  That's
>>> normally fine, unless our prefaulted page isn't in ram anymore.
>>>
>>>         iov_iter_copy_from_user_atomic() <--- uh oh
>>>
>>> If the copy_from_user fails, we drop all our locks and retry.  But along
>>> the
>>> way, we completely lost the dirty bit on the page.  If the page is
>>> dropped
>>> by drop_caches, the writes are lost.  We'll just read back the stale
>>> contents of that page during the retry loop.  This won't result in crc
>>> errors because the bytes we lost were never crc'd.
>>>
>>
>> So we're going to carefully redirty the page under the page lock, right?
>
>
> I don't think we actually need to clean it.  We have the page locked,
> writeback won't start until we unlock.
>

My concern is that the buggy thing is similar to compression path,
where we also did the trick of clear_page_dirty_for_io and
redirty_pages to avoid any faults wandering in and changing pages
underneath, but seems here we're fine if pages get changed in between.

>>
>>> It could result in zeros in the file because we're basically reading a
>>> hole,
>>> and those zeros could move around in the page depending on which part of
>>> the
>>> page was dirty when the writes were lost.
>>>
>>
>> I got a question, while re-reading this page, wouldn't it read
>> old/stale on-disk data?
>
>
> If it was never written we should be treating it like a hole, but I'll
> double check.
>

Okay, I think this would also happen in the overwrite case, where
stale data lies on disk.

thanks,
liubo
