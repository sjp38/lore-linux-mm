Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACDDD6B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 11:45:58 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id l5so4652112qth.18
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 08:45:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r11si9738721qkk.187.2018.03.08.08.45.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 08:45:57 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w28GjUsU140100
	for <linux-mm@kvack.org>; Thu, 8 Mar 2018 11:45:56 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gk8hvh8y3-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Mar 2018 11:45:55 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 8 Mar 2018 16:45:53 -0000
Date: Thu, 8 Mar 2018 08:45:45 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [bug?] Access was denied by memory protection keys in
 execute-only address
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
 <871sguep4v.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <871sguep4v.fsf@concordia.ellerman.id.au>
Message-Id: <20180308164545.GM1060@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Li Wang <liwang@redhat.com>, Jan Stancek <jstancek@redhat.com>, ltp@lists.linux.it, linux-mm@kvack.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Thu, Mar 08, 2018 at 11:19:12PM +1100, Michael Ellerman wrote:
> Li Wang <liwang@redhat.com> writes:
> > Hi,
> >
> > ltp/mprotect04[1] crashed by SEGV_PKUERR on ppc64(LPAR on P730, Power 8
> > 8247-22L) with kernel-v4.16.0-rc4.
> >
> > 10000000-10020000 r-xp 00000000 fd:00 167223           mprotect04
> > 10020000-10030000 r--p 00010000 fd:00 167223           mprotect04
> > 10030000-10040000 rw-p 00020000 fd:00 167223           mprotect04
> > 1001a380000-1001a3b0000 rw-p 00000000 00:00 0          [heap]
> > 7fffa6c60000-7fffa6c80000 --xp 00000000 00:00 0 a??
> >
> > a??&exec_func = 0x10030170a??
> >
> > a??&func = 0x7fffa6c60170a??
> >
> > a??While perform a??
> > "(*func)();" we get the
> > a??segmentation fault.
> > a??
> >
> > a??strace log:a??
> >
> > -------------------
> > a??mprotect(0x7fffaed00000, 131072, PROT_EXEC) = 0
> > rt_sigprocmask(SIG_BLOCK, NULL, [], 8)  = 0
> > --- SIGSEGV {si_signo=SIGSEGV, si_code=SEGV_PKUERR, si_addr=0x7fffaed00170}
> > ---a??
> 
> Looks like a bug to me.
> 
> Please Cc linuxppc-dev on powerpc bugs.
> 
> I also can't reproduce this failure on my machine.
> Not sure what's going on?

I could reproduce it on a power7 lpar.  But not on a power8 lpar.

The problem seems to be that the cpu generates a key exception if
the page with Read/Write-disable-but-execute-enable key is executed
on power7. If I enable read on that key, the exception disappears.

BTW: the testcase executes mprotect(..,PROT_EXEC).
The mprotect(, PROT_EXEC) system call internally generates a
execute-only key and associates it with the pages in the address-range.

Now since Li Wang claims that he can reproduce it on power8 as well, i
am wondering if the slightly different cpu behavior is dependent on the
version of the firmware/microcode?


RP
