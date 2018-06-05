Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 358276B0003
	for <linux-mm@kvack.org>; Tue,  5 Jun 2018 17:52:40 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y123-v6so2327378oie.5
        for <linux-mm@kvack.org>; Tue, 05 Jun 2018 14:52:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f34-v6sor24665660otc.52.2018.06.05.14.52.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Jun 2018 14:52:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
References: <bug-199931-27@https.bugzilla.kernel.org/> <20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
From: james harvey <jamespharvey20@gmail.com>
Date: Tue, 5 Jun 2018 17:52:38 -0400
Message-ID: <CA+X5Wn5_iJYS9MLFdArG9sDHQO2n=BkZmaYAOexhdoVc+tQnmw@mail.gmail.com>
Subject: Re: [Bug 199931] New: systemd/rtorrent file data corruption when
 using echo 3 >/proc/sys/vm/drop_caches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Mason <clm@fb.com>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, bugzilla.kernel.org@plan9.de, Btrfs BTRFS <linux-btrfs@vger.kernel.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Tue, Jun 5, 2018 at 4:03 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 05 Jun 2018 18:01:36 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=199931
>>
>>             Bug ID: 199931
>>            Summary: systemd/rtorrent file data corruption when using echo
>>                     3 >/proc/sys/vm/drop_caches
>
> A long tale of woe here.  Chris, do you think the pagecache corruption
> is a general thing, or is it possible that btrfs is contributing?
...
>> We found that
>>
>>    echo 3 >/proc/sys/vm/drop_caches
>>
>> causes file data corruption. We found this because we saw systemd journal
>> corruption (https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=897266) and
>> tracked this to a cron job dropping caches every hour. The filesystem in use is
>> btrfs, but I don't know if it only happens with this filesystem. btrfs scrub
>> reports no problems, so this is not filesystem metdata corruption.
...
>> This is not always reproducible, but when deleting our journal, creating log
>> messages for a few hours and then doing the above manually has a ~50% chance of
>> corrupting the journal.
...

This sounds a lot related to what Qu Wenruo (as the BTRFS expert and
patch writer) and I (from a reporter and research standpoint) have
been working on, but with a different twist.

My strong bet is you have a hardware issue.  Something like a drive
going bad, bad cables, bad port, etc.  My strong bet is you're also
using BTRFS mirroring.

You're describing intermittent data corruption on files that I'm
thinking all have NOCOW turned on.  On BTRFS, journald turns on NOCOW
for its journal files.  It makes an attempt to turn COW back on when
it's done writing to a journal file, but in a way that guarantees it
to fail.  This has been reported to systemd at
https://github.com/systemd/systemd/issues/9112 but poettering has
expressed the desire to leave it the way it is rather than fix it.
(Granted the situation is going to be improved in the context of the
compression/replace bugs described below, by submitted patches, but
leaving the situation of other on-disk data corruption.)  My bet is
your torrent downloads also have NOCOW turned on.

When NOCOW is turned on, BTRFS also stops performing checksumming of
the data.  (Associated metadata is still checksummed.)

If your BTRFS volume uses mirroring, and you have corruption on one
mirror but not the other, you will get correct or corrupted data
pseudo-randomly depending on which disk is read from.

If your BTRFS volume doesn't use mirroring, then if it's a new file
still in the cache, it won't be corrupted, and after dropping the
cache and re-reading it, if you have a hardware issue, you'll be
reading a corrupted copy.  But, I suspect you are using mirroring, or
else you'd probably be getting unfixable checksum errors on COW files
as well.

Where with checksums and mirroring BTRFS would automatically recognize
a bad read, try the other mirror, and correct the bad copy, with NOCOW
on, even with mirroring, BTRFS has no way to know the data read is
corrupted.

The context I ran into this problem was with several other bugs
interacting, that "btrfs replace" has been guaranteed to corrupt
non-checksummed (NOCOW) compressed data, which the combination of
those shouldn't happen, but does in some defragmentation situations
due to another bug.  In my situation, I don't have a hardware issue.



If you're using BTRFS mirroring, there's an easy way for you to see if
I'm right.  Additions to btrfs-tools are in the works to detect this,
but you can manually do it in the meantime.

Run "filefrag -v <path-filename a file you're having intermittent
corruption on>".

This isn't the ideal tool for the job (btrfs-debug tree is) but it
will more quickly show you the starting block number and length of
blocks for each extent of your file.

For each extent line listed, run 2 commands: "btrfs-map-logical -l
<4096 * physical_offset first (starting) number> -b <4096 * length> -c
1 -o <physical_offset>.1"; and the same but ending "-c 2 -o
<physical_offset>.2".

So, if filefrag shows:
0: 0.. 23: 1201616.. 1201639: 24: last,shared,eof

You'd run (again, for each extent line, with appropriate -l and -b
values and output file name):
btrfs-map-logical -l 4921819136 -b 98304 -c 1 -o 4921819136.1
btrfs-map-logical -l 4921819136 -b 98304 -c 2 -o 4921819136.2

(If you are using BTRFS compression, and a flags column includes
"encoded", you want to use "-b 4096" because filefrag doesn't report
the proper ending physical_offset and length in this situation, and
they're always 4096 bytes.)

This will read each of the extents in your file from both mirrored
copies, and write them to separate files.

Then compare each set of <physical_offset>.1 and <physical_offset>.2 files.

They should never be different.  If they are, for one reason or
another, your mirrored copies differ, and you've found why dropping
cache causes an intermittent problem.
