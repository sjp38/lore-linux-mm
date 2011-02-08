Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5A98D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 18:28:53 -0500 (EST)
MIME-Version: 1.0
Message-ID: <0d1aa13e-be1f-4e21-adf2-f0162c67ede3@default>
Date: Tue, 8 Feb 2011 15:27:30 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 2/3] drivers/staging: zcache: host services and PAM
 services
References: <20110207032608.GA27453@ca-server1.us.oracle.com
 AANLkTi=CEXiOdqPZgQZmQwatHqZ_nsnmnVhwpdt=7q3f@mail.gmail.com>
In-Reply-To: <AANLkTi=CEXiOdqPZgQZmQwatHqZ_nsnmnVhwpdt=7q3f@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: gregkh@suse.de, Chris Mason <chris.mason@oracle.com>, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@zeniv.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

Hi Minchan --

> First of all, thanks for endless effort.

Sometimes it does seem endless ;-)
=20
> I didn't look at code entirely but it seems this series includes
> frontswap.

The "new zcache" optionally depends on frontswap, but frontswap is
a separate patchset.  If the frontswap patchset is present
and configured, zcache will use it to dynamically compress swap pages.
If frontswap is not present or not configured, zcache will only
use cleancache to dynamically compress clean page cache pages.
For best results, both frontswap and cleancache should be enabled.
(and see the link in PATCH V2 0/3 for a monolithic patch against
2.6.37 that enabled both).

> Finally frontswap is to replace zram?

Nitin and I have agreed that, for now, both frontswap and zram
should continue to exist.  They have similar functionality but
different use models.  Over time we will see if they can be merged.

Nitin and I agreed offlist that the following summarizes the
differences between zram and frontswap:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Zram uses an asynchronous model (e.g. uses the block I/O subsystem)
and requires a device to be explicitly created.  When used for
swap, mkswap creates a fixed-size swap device (usually with higher
priority than any disk-based swap device) and zram is filled
until it is full, at which point other lower-priority (disk-based)
swap devices are then used.  So zram is well-suited for a fixed-
size-RAM machine with a known workload where an administrator
can pre-configure a zram device to improve RAM efficiency during
peak memory load.

Frontswap uses a synchronous model, circumventing the block I/O
subsystem.  The frontswap "device" is completely dynamic in size,
e.g. frontswap is queried for every individual page-to-be-swapped
and, if rejected, the page is swapped to the "real" swap device.
So frontswap is well-suited for highly dynamic conditions where
workload is unpredictable and/or RAM size may "vary" due to
circumstances not entirely within the kernel's control.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Does that make sense?

> Regardless of my suggestion, I will look at the this series in my spare
> time.

Thanks, we are looking forward to your always excellent and
thorough review!

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
