Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 92D0C8D0005
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 02:28:07 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA97S4wb005366
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 16:28:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2313E45DE4F
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:28:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ECF3345DE50
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:28:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C14D11DB8048
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:28:03 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ED8CA1DB8042
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:28:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
In-Reply-To: <87lj597hp9.fsf@gmail.com>
References: <87lj597hp9.fsf@gmail.com>
Message-Id: <20101109162525.BC87.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 16:28:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I've recently been trying to track down the root cause of my server's
> persistent issue of thrashing horribly after being left inactive. It
> seems that the issue is likely my nightly backup schedule (using rsync)
> which traverses my entire 50GB home directory. I was surprised to find
> that rsync does not use fadvise to notify the kernel of its use-once
> data usage pattern.
> 
> It looks like a patch[1] was written (although never merged, it seems)
> incorporating fadvise support, but I found its implementation rather
> odd, using mincore() and FADV_DONTNEED to kick out only regions brought
> in by rsync. It seemed to me the simpler and more appropriate solution
> would be to simply flag every touched file with FADV_NOREUSE and let the
> kernel manage automatically expelling used pages.
> 
> After looking deeper into the kernel implementation[2] of fadvise() the
> reason for using DONTNEED became more apparant. It seems that the kernel
> implements NOREUSE as a noop. A little googling revealed[3] that I not
> the first person to encounter this limitation. It looks like a few
> folks[4] have discussed addressing the issue in the past, but nothing
> has happened as of 2.6.36. Are there plans to implement this
> functionality in the near future? It seems like the utility of fadvise
> is severely limited by lacking support for NOREUSE.

btw, Other OSs seems to also don't implement it.
example,

http://src.opensolaris.org/source/xref/onnv/onnv-gate/usr/src/lib/libc/port/gen/posix_fadvise.c

     35 /*
     36  * SUSv3 - file advisory information
     37  *
     38  * This function does nothing, but that's OK because the
     39  * Posix specification doesn't require it to do anything
     40  * other than return appropriate error numbers.
     41  *
     42  * In the future, a file system dependent fadvise() or fcntl()
     43  * interface, similar to madvise(), should be developed to enable
     44  * the kernel to optimize I/O operations based on the given advice.
     45  */
     46 
     47 /* ARGSUSED1 */
     48 int
     49 posix_fadvise(int fd, off_t offset, off_t len, int advice)
     50 {
     51 	struct stat64 statb;
     52 
     53 	switch (advice) {
     54 	case POSIX_FADV_NORMAL:
     55 	case POSIX_FADV_RANDOM:
     56 	case POSIX_FADV_SEQUENTIAL:
     57 	case POSIX_FADV_WILLNEED:
     58 	case POSIX_FADV_DONTNEED:
     59 	case POSIX_FADV_NOREUSE:
     60 		break;
     61 	default:
     62 		return (EINVAL);
     63 	}
     64 	if (len < 0)
     65 		return (EINVAL);
     66 	if (fstat64(fd, &statb) != 0)
     67 		return (EBADF);
     68 	if (S_ISFIFO(statb.st_mode))
     69 		return (ESPIPE);
     70 	return (0);
     71 }


So, I don't think application developers will use fadvise() aggressively
because we don't have a cross platform agreement of a fadvice behavior.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
