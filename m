Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 052996B0085
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 19:31:35 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id m15so209960wgh.8
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 16:31:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u2si8000778wjy.107.2014.06.04.16.31.33
        for <linux-mm@kvack.org>;
        Wed, 04 Jun 2014 16:31:34 -0700 (PDT)
Date: Wed, 4 Jun 2014 19:31:22 -0400
From: Dave Jones <davej@redhat.com>
Subject: ima_mmap_file returning 0 to userspace as mmap result.
Message-ID: <20140604233122.GA19838@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: mtk.manpages@gmail.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, zohar@linux.vnet.ibm.com

I just noticed that trinity was freaking out in places when mmap was
returning zero.  This surprised me, because I had the mmap_min_addr
sysctl set to 64k, so it wasn't a MAP_FIXED mapping that did it.

There's no mention of this return value in the man page, so I dug
into the kernel code, and it appears that we do..

sys_mmap
vm_mmap_pgoff
security_mmap_file
ima_file_mmap <- returns 0 if not PROT_EXEC

and then the 0 gets propagated up as a retval all the way to userspace.

It smells to me like we might be violating a standard or two here, and
instead of 0 ima should be returning -Esomething

thoughts?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
