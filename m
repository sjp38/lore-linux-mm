Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CD8D46B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 12:27:58 -0400 (EDT)
Subject: vmalloc performance
From: Steven Whitehouse <swhiteho@redhat.com>
Content-Type: text/plain
Date: Mon, 12 Apr 2010 17:27:52 +0100
Message-Id: <1271089672.7196.63.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

I've noticed that vmalloc seems to be rather slow. I wrote a test kernel
module to track down what was going wrong. The kernel module does one
million vmalloc/touch mem/vfree in a loop and prints out how long it
takes.

The source of the test kernel module can be found as an attachment to
this bz: https://bugzilla.redhat.com/show_bug.cgi?id=581459

When this module is run on my x86_64, 8 core, 12 Gb machine, then on an
otherwise idle system I get the following results:

vmalloc took 148798983 us
vmalloc took 151664529 us
vmalloc took 152416398 us
vmalloc took 151837733 us

After applying the two line patch (see the same bz) which disabled the
delayed removal of the structures, which appears to be intended to
improve performance in the smp case by reducing TLB flushes across cpus,
I get the following results:

vmalloc took 15363634 us
vmalloc took 15358026 us
vmalloc took 15240955 us
vmalloc took 15402302 us

So thats a speed up of around 10x, which isn't too bad. The question is
whether it is possible to come to a compromise where it is possible to
retain the benefits of the delayed TLB flushing code, but reduce the
overhead for other users. My two line patch basically disables the delay
by forcing a removal on each and every vfree.

What is the correct way to fix this I wonder?

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
