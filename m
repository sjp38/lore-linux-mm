Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id E13B56B0037
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 12:21:22 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id l18so1412391wgh.35
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 09:21:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id dk2si15991511wib.78.2014.06.05.09.21.02
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 09:21:03 -0700 (PDT)
Date: Thu, 5 Jun 2014 12:20:45 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: ima_mmap_file returning 0 to userspace as mmap result.
Message-ID: <20140605162045.GA25474@redhat.com>
References: <20140604233122.GA19838@redhat.com>
 <538FF4C4.5090300@gmail.com>
 <20140605155658.GA22673@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140605155658.GA22673@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, zohar@linux.vnet.ibm.com

On Thu, Jun 05, 2014 at 11:56:58AM -0400, Dave Jones wrote:
 > On Thu, Jun 05, 2014 at 06:40:36AM +0200, Michael Kerrisk (man-pages) wrote:
 >  > On 06/05/2014 01:31 AM, Dave Jones wrote:
 >  > > I just noticed that trinity was freaking out in places when mmap was
 >  > > returning zero.  This surprised me, because I had the mmap_min_addr
 >  > > sysctl set to 64k, so it wasn't a MAP_FIXED mapping that did it.
 >  > > 
 >  > > There's no mention of this return value in the man page, so I dug
 >  > > into the kernel code, and it appears that we do..
 >  > > 
 >  > > sys_mmap
 >  > > vm_mmap_pgoff
 >  > > security_mmap_file
 >  > > ima_file_mmap <- returns 0 if not PROT_EXEC
 >  > > 
 >  > > and then the 0 gets propagated up as a retval all the way to userspace.
 > 
 > I just realised that this affects even kernels with CONFIG_IMA unset,
 > because there we just do 'return 0' unconditionally.
 > 
 > Also, it appears that kernels with CONFIG_SECURITY unset will also
 > return a zero for the same reason.

Hang on, I was misreading that whole security_mmap_file ret handling code.
There's something else at work here.  I'll dig and get a reproducer.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
