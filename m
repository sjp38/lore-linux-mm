Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id BAA21118
	for <linux-mm@kvack.org>; Fri, 14 Feb 2003 01:57:39 -0800 (PST)
Date: Fri, 14 Feb 2003 01:58:02 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.60-mm2
Message-Id: <20030214015802.66800166.akpm@digeo.com>
In-Reply-To: <20030214093856.GC13845@codemonkey.org.uk>
References: <20030214013144.2d94a9c5.akpm@digeo.com>
	<20030214093856.GC13845@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Jones <davej@codemonkey.org.uk> wrote:
>
> On Fri, Feb 14, 2003 at 01:31:44AM -0800, Andrew Morton wrote:
> 
>  > . Considerable poking at the NFS MAP_SHARED OOM lockup.  It is limping
>  >   along now, but writeout bandwidth is poor and it is still struggling. 
>  >   Needs work.
>  > 
>  > . There's a one-liner which removes an O(n^2) search in the NFS writeback
>  >   path.  It increases writeout bandwidth by 4x and decreases CPU load from
>  >   100% to 3%.  Needs work.
> 
> I'm puzzled that you've had NFS stable enough to test these.

This was just writing out a single 400 megabyte file with `dd'.  I didn't try
anything fancier.

> How much testing has this stuff had? Here 2.5.60+bk clients fall over under
> moderate NFS load. (And go splat quickly under high load).
> 
> Trying to run things like dbench causes lockups, fsx/fstress made it
> reboot, plus the odd 'cheating' errors reported yesterday.

I have not tried pushing NFS with complex access patterns recently.


BTW, there's a little patch in there from Trond which I forgot to mention: it
implements sendfile for NFS, so loop-on-NFS works again.


But we have a refcounting bug somewhere:

# mount server:/dir /mnt/point
# losetup /dev/loop0 /mnt/point/file
# mount /dev/loop0 /mnt/loop0
# umount /mnt/loop0
# losetup -d /dev/loop0 
# umount /mnt/point
umount: /mnt/point: device is busy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
