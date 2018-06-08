From: Duncan <1i5t5.duncan@cox.net>
Subject: Re: [Bug 199931] New: systemd/rtorrent file data corruption when
 using echo 3 >/proc/sys/vm/drop_caches
Date: Fri, 8 Jun 2018 07:18:44 +0000 (UTC)
Message-ID: <pan$a2388$84c4dee0$cda57858$77256a9d@cox.net>
References: <bug-199931-27@https.bugzilla.kernel.org/>
        <20180605130329.f7069e01c5faacc08a10996c@linux-foundation.org>
        <CA+X5Wn5_iJYS9MLFdArG9sDHQO2n=BkZmaYAOexhdoVc+tQnmw@mail.gmail.com>
        <20180606190635.meodcz3mchhtqprb@schmorp.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <linux-btrfs-owner@vger.kernel.org>
Sender: linux-btrfs-owner@vger.kernel.org
To: linux-btrfs@vger.kernel.org
Cc: linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Marc Lehmann posted on Wed, 06 Jun 2018 21:06:35 +0200 as excerpted:

> Not sure what exactly you mean with btrfs mirroring (there are many
> btrfs features this could refer to), but the closest thing to that that
> I use is dup for metadata (which is always checksummed), data is always
> single. All btrfs filesystems are on lvm (not mirrored), and most (but
> not all) are encrypted. One affected fs is on a hardware raid
> controller, one is on an ssd. I have a single btrfs fs in that box with
> raid1 for metadata, as an experiment, but I haven't used it for testing
> yet.

On the off chance, tho it doesn't sound like it from your description...

You're not doing LVM snapshots of the volumes with btrfs on them, 
correct?  Because btrfs depends on filesystem GUIDs being just that, 
globally unique, using them to find the possible multiple devices of a 
multi-device btrfs (normal single-device filesystems don't have the issue 
as they don't have to deal with multi-device as btrfs does), and btrfs 
can get very confused, with data-loss potential, if it sees multiple 
copies of a device with the same filesystem GUID, as can happen if lvm 
snapshots (which obviously have the same filesystem GUID as the original) 
are taken and both the snapshot and the source are exposed to btrfs 
device scan (which is auto-triggered by udev when the new device 
appears), with one of them mounted.

Presumably you'd consider lvm snapshotting a form of mirroring and you've 
already said you're not doing that in any form, but just in case, because 
this is a rather obscure trap people using lvm could find themselves in, 
without a clue as to the danger, and the resulting symptoms could be 
rather hard to troubleshoot if this possibility wasn't considered.

-- 
Duncan - List replies preferred.   No HTML msgs.
"Every nonfree program has a lord, a master --
and if you use the program, he is your master."  Richard Stallman

