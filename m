Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 363166B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:58:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o23so1577795wrc.9
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:58:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g1si2767414edh.384.2018.03.20.14.58.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:58:39 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2KLqkM8045594
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:58:38 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2guakn05fc-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:58:37 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 20 Mar 2018 21:58:36 -0000
Date: Tue, 20 Mar 2018 14:58:28 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [bug?] Access was denied by memory protection keys in
 execute-only address
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <CAEemH2f0LDqyR5AmUYv17OuBc5-UycckDPWgk46XU_ghQo4diw@mail.gmail.com>
 <871sguep4v.fsf@concordia.ellerman.id.au>
 <20180308164545.GM1060@ram.oc3035372033.ibm.com>
 <CAEemH2czWDjvJLpL6ynV1+VxCFh_-A-d72tJhA5zwgrAES2nWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEemH2czWDjvJLpL6ynV1+VxCFh_-A-d72tJhA5zwgrAES2nWA@mail.gmail.com>
Message-Id: <20180320215828.GA5825@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Jan Stancek <jstancek@redhat.com>, ltp@lists.linux.it, linux-mm@kvack.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Fri, Mar 09, 2018 at 11:43:00AM +0800, Li Wang wrote:
>    On Fri, Mar 9, 2018 at 12:45 AM, Ram Pai <[1]linuxram@us.ibm.com> wrote:
> 
>      On Thu, Mar 08, 2018 at 11:19:12PM +1100, Michael Ellerman wrote:
>      > Li Wang <[2]liwang@redhat.com> writes:
>      > > Hi,
>      > >
>      > > ltp/mprotect04[1] crashed by SEGV_PKUERR on ppc64(LPAR on P730,
>      Power 8
>      > > 8247-22L) with kernel-v4.16.0-rc4.
>      > >
>      > > 10000000-10020000 r-xp 00000000 fd:00 167223A  A  A  A  A  A mprotect04
>      > > 10020000-10030000 r--p 00010000 fd:00 167223A  A  A  A  A  A mprotect04
>      > > 10030000-10040000 rw-p 00020000 fd:00 167223A  A  A  A  A  A mprotect04
>      > > 1001a380000-1001a3b0000 rw-p 00000000 00:00 0A  A  A  A  A  [heap]
>      > > 7fffa6c60000-7fffa6c80000 --xp 00000000 00:00 0 a??
>      > >
>      > > a??&exec_func = 0x10030170a??
>      > >
>      > > a??&func = 0x7fffa6c60170a??
>      > >
>      > > a??While perform a??
>      > > "(*func)();" we get the
>      > > a??segmentation fault.
>      > > a??
>      > >
>      > > a??strace log:a??
>      > >
>      > > -------------------
>      > > a??mprotect(0x7fffaed00000, 131072, PROT_EXEC) = 0
>      > > rt_sigprocmask(SIG_BLOCK, NULL, [], 8)A  = 0
>      > > --- SIGSEGV {si_signo=SIGSEGV, si_code=SEGV_PKUERR,
>      si_addr=0x7fffaed00170}
>      > > ---a??
>      >
>      > Looks like a bug to me.
>      >
>      > Please Cc linuxppc-dev on powerpc bugs.
>      >
>      > I also can't reproduce this failure on my machine.
>      > Not sure what's going on?
> 
>      I could reproduce it on a power7 lpar.A  But not on a power8 lpar.
> 
>      The problem seems to be that the cpu generates a key exception if
>      the page with Read/Write-disable-but-execute-enable key is executed
>      on power7. If I enable read on that key, the exception disappears.
> 
>    After adding read permission on that key, reproducer get PASS on my power8
>    machine too.a??
>    a??(a??mprotect(..,PROT_READ | PROT_EXEC))a??
>    A 
> 
>      BTW: the testcase executes
>      a??a??mprotect(..,PROT_EXEC).
>      The mprotect(, PROT_EXEC) system call internally generates a
>      execute-only key and associates it with the pages in the address-range.A 
> 
>      Now since Li Wang claims that he can reproduce it on power8 as well, i
>      am wondering if the slightly different cpu behavior is dependent on the
>      version of the firmware/microcode?
> 
>    a??I also run this reproducer on series ppc kvm machines, but none of them
>    get the FAIL.
>    If you need some more HW info, pls let me know.a??

Hi Li,

   Can you try the following patch and see if it solves your problem.


diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index c269817..184a10a 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -421,7 +421,7 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot,
 	 * The requested protection is execute-only. Hence let's use an
 	 * execute-only pkey.
 	 */
-	if (prot == PROT_EXEC) {
+	if (prot == PROT_EXEC && pkey_execute_disable_supported) {
 		pkey = execute_only_pkey(vma->vm_mm);
 		if (pkey > 0)
 			return pkey;


Thanks
RP
