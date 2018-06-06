Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 057546B0003
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 16:33:26 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id m193-v6so4181048oig.10
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 13:33:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j7-v6sor11490428otd.198.2018.06.06.13.33.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Jun 2018 13:33:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180606190635.meodcz3mchhtqprb@schmorp.de>
References: <bug-199931-27@https.bugzilla.kernel.org/> <20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
 <CA+X5Wn5_iJYS9MLFdArG9sDHQO2n=BkZmaYAOexhdoVc+tQnmw@mail.gmail.com> <20180606190635.meodcz3mchhtqprb@schmorp.de>
From: james harvey <jamespharvey20@gmail.com>
Date: Wed, 6 Jun 2018 16:33:23 -0400
Message-ID: <CA+X5Wn6=HHONgxocJn4F4QYshzAh+yCRQP4MpTZ5TMiUnpALUA@mail.gmail.com>
Subject: Re: [Bug 199931] New: systemd/rtorrent file data corruption when
 using echo 3 >/proc/sys/vm/drop_caches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Lehmann <schmorp@schmorp.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, bugzilla.kernel.org@plan9.de, Btrfs BTRFS <linux-btrfs@vger.kernel.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Wed, Jun 6, 2018 at 3:06 PM, Marc Lehmann <schmorp@schmorp.de> wrote:
> On Tue, Jun 05, 2018 at 05:52:38PM -0400, james harvey <jamespharvey20@gmail.com> wrote:
>> >> This is not always reproducible, but when deleting our journal, creating log
>> >> messages for a few hours and then doing the above manually has a ~50% chance of
>> >> corrupting the journal.
>> ...
>>
>> My strong bet is you have a hardware issue.
>
> Strange, what kind of harwdare bug would affect multiple very different
> computers in exactly the same way?

Oops.  I missed when you clearly said: "All of this is reproducible on
two different boxes, so is unlikely to be a hardware issue."  I ran
into all these problems ultimately because of a badly designed Marvell
SATA controller.  I thought I had ruled out hardware issues by having
2 identical systems, and reproducing the problem on both.  Certainly
makes a hardware issue for you much less likely, especially if "very
different computers" means different motherboards.

FWIW, I have dropped caches a lot lately (not nearly as much as your
crons) and haven't had it corrupt anything, even in proximity to heavy
I/O.

>> going bad, bad cables, bad port, etc.  My strong bet is you're also
>> using BTRFS mirroring.
>
> Not sure what exactly you mean with btrfs mirroring (there are many btrfs
> features this could refer to), but the closest thing to that that I use is
> dup for metadata (which is always checksummed), data is always single. All
> btrfs filesystems are on lvm (not mirrored), and most (but not all) are
> encrypted. One affected fs is on a hardware raid controller, one is on an
> ssd. I have a single btrfs fs in that box with raid1 for metadata, as an
> experiment, but I haven't used it for testing yet.

Was referring to any type of data mirroring.  Data dup, btrfs
RAID1/5/6/10.  But, I see that's not the case here.

>> You're describing intermittent data corruption on files that I'm
>> thinking all have NOCOW turned on.
>
> The systemd journal files are nocow (I re-enabled that after I turned it
> off for a while), but the rtorrent directory (and the files in it) are
> not.
>
> I did experiment (a year ago) with nocow for torrent files and, more
> importantly, vm images, but it didn't really solve the "millions of
> fragments slow down" problem with btrfs, so I figured I can keep them cow
> and regularly copy them to defragment them. Thats why I am quite sure cow
> is switched on long before I booted my first 4.14 kernel (and it still
> is).

Yeah, with data single, you wouldn't be seeing intermittent problems
if it was related to the bugs I was talking about.

>> it's done writing to a journal file, but in a way that guarantees it
>> to fail.  This has been reported to systemd at
>> https://github.com/systemd/systemd/issues/9112 but poettering has
>
> I am aware that systemd tries to turn on nocow, and I think this is actually
> a bug, but this wouldn't have an an effect on rtorrent, which has corruption
> problems on a different fs. And boy would it be wonderufl if Debian switched
> away form systemd, I feel I personally ran into every single bug that
> exists...

systemd turning on NOCOW isn't a bug.  systemd 219 intentionally
turned on NOCOW for journal files, attempting to improve performance
on btrfs.  220 made it user-configurable, defaulting to turning on
NOCOW.  But, yeah, the bugs I was talking about wouldn't affect
rtorrent files on a different fs, since you have NOCOW off on them,
and since they're data single.

> However, no matter how much systemd plays with btrfs flags, it shouldn't
> corrupt data.

Yeah, it doesn't in itself.  Just makes them susceptible to one disk
corruption that btrfs would otherwise protect against with data
checksums.  And, if using compression and btrfs replace on current
kernels, guarantees them to be corrupted.
