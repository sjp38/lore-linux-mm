Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E00B1900086
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 21:45:10 -0400 (EDT)
Date: Sun, 17 Apr 2011 09:44:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/12] IO-less dirty throttling v7
Message-ID: <20110417014430.GA9419@localhost>
References: <20110416132546.765212221@intel.com>
 <BANLkTimY3t6Kc-+=00k3QR+AK2uqJpph4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
Content-Disposition: inline
In-Reply-To: <BANLkTimY3t6Kc-+=00k3QR+AK2uqJpph4g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Sedat,

On Sun, Apr 17, 2011 at 12:27:58AM +0800, Sedat Dilek wrote:

> I pulled your tree into linux-next (next-20110415) on an i386 Debian host.
> 
> My build breaks here:
> ...
>   MODPOST vmlinux.o
>   GEN     .version
>   CHK     include/generated/compile.h
>   UPD     include/generated/compile.h
>   CC      init/version.o
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> mm/built-in.o: In function `bdi_position_ratio':
> page-writeback.c:(.text+0x5c83): undefined reference to `__udivdi3'

Yes it can be fixed by the attached patch.

> mm/built-in.o: In function `calc_period_shift.part.10':
> page-writeback.c:(.text+0x6446): undefined reference to `____ilog2_NaN'

I cannot reproduce this error. In the git tree, calc_period_shift() is
actually quite simple:

static int calc_period_shift(void)                
{                                                 
        return 2 + ilog2(default_backing_dev_info.avg_write_bandwidth);
}

where avg_write_bandwidth is of type "unsigned long".

> make[4]: *** [.tmp_vmlinux1] Error
> 
> BTW, which kernel-config options have to be set besides
> CONFIG_BLK_DEV_THROTTLING=y?

No. I used your kconfig on 2.6.39-rc3 and it compiles OK for i386.

I've pushed two patches into the git tree fixing the compile errors.
Thank you for trying it out and report!

Thanks,
Fengguang

--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=bdi_position_ratio-__udivdi3-fix

Subject: writeback: i386 compile fix
Date: Sun Apr 17 09:04:44 CST 2011


mm/built-in.o: In function `bdi_position_ratio':
page-writeback.c:(.text+0x5c83): undefined reference to `__udivdi3'
mm/built-in.o: In function `calc_period_shift.part.10':
page-writeback.c:(.text+0x6446): undefined reference to `____ilog2_NaN'
make[4]: *** [.tmp_vmlinux1] Error

Reported-by: Sedat Dilek <sedat.dilek@googlemail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-04-17 09:02:32.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-17 09:03:58.000000000 +0800
@@ -634,9 +634,10 @@ static unsigned long bdi_position_ratio(
 	origin = bdi->avg_write_bandwidth + 2 * MIN_WRITEBACK_PAGES;
 	origin = min(origin, thresh - thresh / DIRTY_FULL_SCOPE);
 	if (bdi_dirty < origin) {
-		if (bdi_dirty > origin / 4)
-			bw = bw * origin / bdi_dirty;
-		else
+		if (bdi_dirty > origin / 4) {
+			bw *= origin;
+			do_div(bw, bdi_dirty);
+		} else
 			bw = bw * 4;
 	}
 

--NzB8fVQJ5HfG6fxh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
