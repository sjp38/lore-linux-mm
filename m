Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13DB06B06CF
	for <linux-mm@kvack.org>; Sat, 19 May 2018 07:11:20 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l7-v6so4643348qkk.20
        for <linux-mm@kvack.org>; Sat, 19 May 2018 04:11:20 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j29-v6si3476728qtc.35.2018.05.19.04.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 May 2018 04:11:18 -0700 (PDT)
Subject: Re: pkeys on POWER: Access rights not reset on execve
References: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com>
 <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <c4e640be-3d82-c955-fc28-568ec13d378a@redhat.com>
Date: Sat, 19 May 2018 13:11:14 +0200
MIME-Version: 1.0
In-Reply-To: <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>

On 05/19/2018 03:19 AM, Ram Pai wrote:
> The issue you may be talking about here is that  --
> 
> "when you set the AMR register to 0xffffffffffffffff, it
> just sets it to 0x0c00000000000000."
> 
> To me it looks like, exec/fork are not related to the issue.
> Or are they also somehow connected to the issue?
> 
> 
> The reason the AMR register does not get set to 0xffffffffffffffff,
> is because none of those keys; except key 2, are active. So it ignores
> all other bits and just sets the bits corresponding to key 2.

Here's a slightly different test:

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <err.h>

/* Return the value of the AMR register.  */
static inline unsigned long int
pkey_read (void)
{
   unsigned long int result;
   __asm__ volatile ("mfspr %0, 13" : "=r" (result));
   return result;
}

/* Overwrite the AMR register with VALUE.  */
static inline void
pkey_write (unsigned long int value)
{
   __asm__ volatile ("mtspr 13, %0" : : "r" (value));
}

int
main (int argc, char **argv)
{
   printf ("AMR (PID %d): 0x%016lx\n", (int) getpid (), pkey_read());
   if (argc > 1 && strcmp (argv[1], "alloc") == 0)
     {
       int key = syscall (__NR_pkey_alloc, 0, 0);
       if (key < 0)
         err (1, "pkey_alloc");
       printf ("Allocated key in subprocess (PID %d): %d\n",
               (int) getpid (), key);
       return 0;
     }

   pid_t pid = fork ();
   if (pid == 0)
     {
       printf ("AMR after fork (PID %d): 0x%016lx\n",
               (int) getpid (), pkey_read());
       execl ("/proc/self/exe", argv[0], "alloc", NULL);
       _exit (1);
     }
   if (pid < 0)
     err (1, "fork");
   int status;
   if (waitpid (pid, &status, 0) < 0)
     err (1, "waitpid");

   int key = syscall (__NR_pkey_alloc, 0, 0);
   if (key < 0)
     err (1, "pkey_alloc");
   printf ("Allocated key (PID %d): %d\n", (int) getpid (), key);

   unsigned long int amr = -1;
   printf ("Setting AMR: 0x%016lx\n", amr);
   pkey_write (amr);
   printf ("New AMR value (PID %d): 0x%016lx\n",
           (int) getpid (), pkey_read());
   if (argc == 1)
     {
       printf ("About to call execl (PID %d) ...\n", (int) getpid ());
       execl ("/proc/self/exe", argv[0], "execl", NULL);
       err (1, "exec");
       return 1;
     }
   else
     return 0;
}

It produces:

AMR (PID 110163): 0x0000000000000000
AMR after fork (PID 110164): 0x0000000000000000
AMR (PID 110164): 0x0000000000000000
Allocated key in subprocess (PID 110164): 2
Allocated key (PID 110163): 2
Setting AMR: 0xffffffffffffffff
New AMR value (PID 110163): 0x0c00000000000000
About to call execl (PID 110163) ...
AMR (PID 110163): 0x0c00000000000000
AMR after fork (PID 110165): 0x0000000000000000
AMR (PID 110165): 0x0000000000000000
Allocated key in subprocess (PID 110165): 2
Allocated key (PID 110163): 2
Setting AMR: 0xffffffffffffffff
New AMR value (PID 110163): 0x0c00000000000000

A few things which are odd stand out (apart the wrong default for AMR 
and the AMR update restriction covered in the other thread):

* execve does not reset AMR (see after a??About to call execla??)
* fork resets AMR (see lines with PID 110165))
* After execve, a key with non-default access rights is allocated
   (see a??Allocated key (PID 110163): 2a??, second time, after execl)

No matter what you think about the AMR default, I posit that each of 
those are bugs (although the last one should be fixed by resetting AMR 
on execve).

Thanks,
Florian
