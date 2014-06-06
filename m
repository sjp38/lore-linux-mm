Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5528E6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 21:49:35 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id j107so3089233qga.20
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 18:49:35 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id l10si13919930yhm.173.2014.06.05.18.49.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 18:49:34 -0700 (PDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zohar@linux.vnet.ibm.com>;
	Thu, 5 Jun 2014 19:49:32 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B5F863E40044
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 19:49:30 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s561mVsS7012738
	for <linux-mm@kvack.org>; Fri, 6 Jun 2014 03:48:32 +0200
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s561nUZu001431
	for <linux-mm@kvack.org>; Thu, 5 Jun 2014 19:49:30 -0600
Message-ID: <1402019369.5458.55.camel@dhcp-9-2-203-236.watson.ibm.com>
Subject: Re: ima_mmap_file returning 0 to userspace as mmap result.
From: Mimi Zohar <zohar@linux.vnet.ibm.com>
Date: Thu, 05 Jun 2014 21:49:29 -0400
In-Reply-To: <20140605162045.GA25474@redhat.com>
References: <20140604233122.GA19838@redhat.com> <538FF4C4.5090300@gmail.com>
	 <20140605155658.GA22673@redhat.com> <20140605162045.GA25474@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, 2014-06-05 at 12:20 -0400, Dave Jones wrote: 
> On Thu, Jun 05, 2014 at 11:56:58AM -0400, Dave Jones wrote:
>  > On Thu, Jun 05, 2014 at 06:40:36AM +0200, Michael Kerrisk (man-pages) wrote:
>  >  > On 06/05/2014 01:31 AM, Dave Jones wrote:
>  >  > > I just noticed that trinity was freaking out in places when mmap was
>  >  > > returning zero.  This surprised me, because I had the mmap_min_addr
>  >  > > sysctl set to 64k, so it wasn't a MAP_FIXED mapping that did it.
>  >  > > 
>  >  > > There's no mention of this return value in the man page, so I dug
>  >  > > into the kernel code, and it appears that we do..
>  >  > > 
>  >  > > sys_mmap
>  >  > > vm_mmap_pgoff
>  >  > > security_mmap_file
>  >  > > ima_file_mmap <- returns 0 if not PROT_EXEC
>  >  > > 
>  >  > > and then the 0 gets propagated up as a retval all the way to userspace.
>  > 
>  > I just realised that this affects even kernels with CONFIG_IMA unset,
>  > because there we just do 'return 0' unconditionally.
>  > 
>  > Also, it appears that kernels with CONFIG_SECURITY unset will also
>  > return a zero for the same reason.
> 
> Hang on, I was misreading that whole security_mmap_file ret handling code.
> There's something else at work here.  I'll dig and get a reproducer.

According to security.h, it should return 0 if permission is granted.
If IMA is not enabled, it should also return 0.  What exactly is the
problem?

thanks,

Mimi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
