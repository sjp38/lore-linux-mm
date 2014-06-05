Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD646B004D
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 00:40:46 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id x48so205874wes.9
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 21:40:45 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id ff4si39056926wib.70.2014.06.04.21.40.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 21:40:45 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id t60so427440wes.13
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 21:40:44 -0700 (PDT)
Message-ID: <538FF4C4.5090300@gmail.com>
Date: Thu, 05 Jun 2014 06:40:36 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: ima_mmap_file returning 0 to userspace as mmap result.
References: <20140604233122.GA19838@redhat.com>
In-Reply-To: <20140604233122.GA19838@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, zohar@linux.vnet.ibm.com
Cc: mtk.manpages@gmail.com

On 06/05/2014 01:31 AM, Dave Jones wrote:
> I just noticed that trinity was freaking out in places when mmap was
> returning zero.  This surprised me, because I had the mmap_min_addr
> sysctl set to 64k, so it wasn't a MAP_FIXED mapping that did it.
> 
> There's no mention of this return value in the man page, so I dug
> into the kernel code, and it appears that we do..
> 
> sys_mmap
> vm_mmap_pgoff
> security_mmap_file
> ima_file_mmap <- returns 0 if not PROT_EXEC
> 
> and then the 0 gets propagated up as a retval all the way to userspace.
> 
> It smells to me like we might be violating a standard or two here, and
> instead of 0 ima should be returning -Esomething
> 
> thoughts?

Seems like either EACCESS or ENOTSUP is appropriate; here's the pieces 
from POSIX:

       EACCES The  fildes argument is not open for read, regardless of
              the protection specified, or  fildes  is  not  open  for
              write and PROT_WRITE was specified for a MAP_SHARED type
              mapping.

       ENOTSUP
                   The implementation does not support the combination
                   of accesses requested in the prot argument.

ENOTSUP seems to be more appropriate in my reading of the above, though
I'd somehow more have expected EACCES.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
