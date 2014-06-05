Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC906B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 11:57:50 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id f8so3743906wiw.16
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 08:57:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id pg7si12112301wjb.56.2014.06.05.08.57.19
        for <linux-mm@kvack.org>;
        Thu, 05 Jun 2014 08:57:20 -0700 (PDT)
Date: Thu, 5 Jun 2014 11:56:58 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: ima_mmap_file returning 0 to userspace as mmap result.
Message-ID: <20140605155658.GA22673@redhat.com>
References: <20140604233122.GA19838@redhat.com>
 <538FF4C4.5090300@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <538FF4C4.5090300@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, zohar@linux.vnet.ibm.com

On Thu, Jun 05, 2014 at 06:40:36AM +0200, Michael Kerrisk (man-pages) wrote:
 > On 06/05/2014 01:31 AM, Dave Jones wrote:
 > > I just noticed that trinity was freaking out in places when mmap was
 > > returning zero.  This surprised me, because I had the mmap_min_addr
 > > sysctl set to 64k, so it wasn't a MAP_FIXED mapping that did it.
 > > 
 > > There's no mention of this return value in the man page, so I dug
 > > into the kernel code, and it appears that we do..
 > > 
 > > sys_mmap
 > > vm_mmap_pgoff
 > > security_mmap_file
 > > ima_file_mmap <- returns 0 if not PROT_EXEC
 > > 
 > > and then the 0 gets propagated up as a retval all the way to userspace.
 > > 
 > > It smells to me like we might be violating a standard or two here, and
 > > instead of 0 ima should be returning -Esomething
 > > 
 > > thoughts?
 > 
 > Seems like either EACCESS or ENOTSUP is appropriate; here's the pieces 
 > from POSIX:
 > 
 >        EACCES The  fildes argument is not open for read, regardless of
 >               the protection specified, or  fildes  is  not  open  for
 >               write and PROT_WRITE was specified for a MAP_SHARED type
 >               mapping.
 > 
 >        ENOTSUP
 >                    The implementation does not support the combination
 >                    of accesses requested in the prot argument.
 > 
 > ENOTSUP seems to be more appropriate in my reading of the above, though
 > I'd somehow more have expected EACCES.

I just realised that this affects even kernels with CONFIG_IMA unset,
because there we just do 'return 0' unconditionally.

Also, it appears that kernels with CONFIG_SECURITY unset will also
return a zero for the same reason.

This is kind of a mess, and has been that way for a long time.
Fixing this will require user-visible breakage, but in this case
I think it's justified as there's no way an app can do the right thing
if it gets a 0 back.  Linus ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
