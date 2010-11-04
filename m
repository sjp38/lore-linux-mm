Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8DE086B0085
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 01:59:03 -0400 (EDT)
Received: by qyk5 with SMTP id 5so884308qyk.14
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 22:59:01 -0700 (PDT)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: fadvise DONTNEED implementation (or lack thereof)
Date: Thu, 04 Nov 2010 01:58:58 -0400
Message-ID: <87lj597hp9.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've recently been trying to track down the root cause of my server's
persistent issue of thrashing horribly after being left inactive. It
seems that the issue is likely my nightly backup schedule (using rsync)
which traverses my entire 50GB home directory. I was surprised to find
that rsync does not use fadvise to notify the kernel of its use-once
data usage pattern.

It looks like a patch[1] was written (although never merged, it seems)
incorporating fadvise support, but I found its implementation rather
odd, using mincore() and FADV_DONTNEED to kick out only regions brought
in by rsync. It seemed to me the simpler and more appropriate solution
would be to simply flag every touched file with FADV_NOREUSE and let the
kernel manage automatically expelling used pages.

After looking deeper into the kernel implementation[2] of fadvise() the
reason for using DONTNEED became more apparant. It seems that the kernel
implements NOREUSE as a noop. A little googling revealed[3] that I not
the first person to encounter this limitation. It looks like a few
folks[4] have discussed addressing the issue in the past, but nothing
has happened as of 2.6.36. Are there plans to implement this
functionality in the near future? It seems like the utility of fadvise
is severely limited by lacking support for NOREUSE.

Cheers,

- Ben


[1] http://insights.oetiker.ch/linux/fadvise.html
[2] http://lxr.free-electrons.com/source/mm/fadvise.c?a=avr32
[3] https://issues.apache.org/jira/browse/CASSANDRA-1470
    http://chbits.blogspot.com/2010/06/lucene-and-fadvisemadvise.html
[4] http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg179576.html
    http://lkml.indiana.edu/hypermail/linux/kernel/0807.2/0442.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
