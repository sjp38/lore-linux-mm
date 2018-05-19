Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C22A26B06A5
	for <linux-mm@kvack.org>; Fri, 18 May 2018 21:20:00 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l6-v6so6534923wrn.17
        for <linux-mm@kvack.org>; Fri, 18 May 2018 18:20:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v23-v6si6132406edr.266.2018.05.18.18.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 18:19:59 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4J1IdpJ118606
	for <linux-mm@kvack.org>; Fri, 18 May 2018 21:19:57 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j292va2df-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 May 2018 21:19:57 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 19 May 2018 02:19:54 +0100
Date: Fri, 18 May 2018 18:19:47 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com>
MIME-Version: 1.0
In-Reply-To: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com>
Message-Id: <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>

On Fri, May 18, 2018 at 04:27:14PM +0200, Florian Weimer wrote:
> This test program:
> 
> #include <errno.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/syscall.h>
> #include <err.h>
> 
> /* Return the value of the AMR register.  */
> static inline unsigned long int
> pkey_read (void)
> {
>   unsigned long int result;
>   __asm__ volatile ("mfspr %0, 13" : "=r" (result));
>   return result;
> }
> 
> /* Overwrite the AMR register with VALUE.  */
> static inline void
> pkey_write (unsigned long int value)
> {
>   __asm__ volatile ("mtspr 13, %0" : : "r" (value));
> }
> 
> int
> main (int argc, char **argv)
> {
>   printf ("AMR (PID %d): 0x%016lx\n", (int) getpid (), pkey_read());
>   if (argc > 1)
>     {
>       int key = syscall (__NR_pkey_alloc, 0, 0);
>       if (key < 0)
>         err (1, "pkey_alloc");
>       printf ("Allocated key (PID %d): %d\n", (int) getpid (), key);
>       return 0;
>     }
> 
>   pid_t pid = fork ();
>   if (pid == 0)
>     {
>       execl ("/proc/self/exe", argv[0], "subprocess", NULL);
>       _exit (1);
>     }
>   if (pid < 0)
>     err (1, "fork");
>   int status;
>   if (waitpid (pid, &status, 0) < 0)
>     err (1, "waitpid");
> 
>   int key = syscall (__NR_pkey_alloc, 0, 0);
>   if (key < 0)
>     err (1, "pkey_alloc");
>   printf ("Allocated key (PID %d): %d\n", (int) getpid (), key);
> 
>   unsigned long int amr = -1;
>   printf ("Setting AMR: 0x%016lx\n", amr);
>   pkey_write (amr);
>   printf ("New AMR value (PID %d, before execl): 0x%016lx\n",
>           (int) getpid (), pkey_read());
>   execl ("/proc/self/exe", argv[0], "subprocess", NULL);
>   err (1, "exec");
>   return 1;
> }
> 
> shows that the AMR register value is not reset on execve:
> 
> AMR (PID 112291): 0x0000000000000000
> AMR (PID 112292): 0x0000000000000000
> Allocated key (PID 112292): 2
> Allocated key (PID 112291): 2
> Setting AMR: 0xffffffffffffffff
> New AMR value (PID 112291, before execl): 0x0c00000000000000
> AMR (PID 112291): 0x0c00000000000000
> Allocated key (PID 112291): 2
> 
> I think this is a real bug and needs to be fixed even if the
> defaults are kept as-is (see the other thread).

The issue you may be talking about here is that  --

"when you set the AMR register to 0xffffffffffffffff, it 
just sets it to 0x0c00000000000000."

To me it looks like, exec/fork are not related to the issue.
Or are they also somehow connected to the issue?


The reason the AMR register does not get set to 0xffffffffffffffff,
is because none of those keys; except key 2, are active. So it ignores
all other bits and just sets the bits corresponding to key 2.

However the fundamental issue is still the same, as mentioned in the
other thread.

"Should the permissions on a key be allowed to be changed, if the key
is not allocated in the first place?".

my answer is NO. Lets debate :)
RP
