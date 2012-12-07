Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 103066B006C
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 18:57:14 -0500 (EST)
MIME-Version: 1.0
Message-ID: <c8728036-07da-49ce-b4cb-c3d800790b53@default>
Date: Fri, 7 Dec 2012 15:57:08 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: zram /proc/swaps accounting weirdness
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>
Cc: Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org

While playing around with zcache+zram (see separate thread),
I was watching stats with "watch -d".

It appears from the code that /sys/block/num_writes only
increases, never decreases.  In my test, num_writes got up
to 1863.  /sys/block/disksize is 104857600.

I have two swap disks, one zram (pri=3D60), one real (pri=3D-1),
and as a I watched /proc/swaps, the "Used" field grew rapidly
and reached the Size (102396k) of the zram swap, and then
the second swap disk (a physical disk partition) started being
used.  Then for awhile, the Used field for both swap devices
was changing (up and down).

Can you explain how this could happen if num_writes never
exceeded 1863?  This may be harmless in the case where
the only swap on the system is zram; or may indicate a bug
somewhere?

It looks like num_writes is counting bio's not pages...
which would imply the bio's are potentially quite large
(and I'll guess they are of size SWAPFILE_CLUSTER which is
defined to be 256).  Do large clusters make sense with zram?

Late on a Friday so sorry if I am incomprehensible...

P.S. The corresponding stat for zcache indicates that
it failed 8852 stores, so I would have expected zram
to deal with no more than 8852 compressions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
