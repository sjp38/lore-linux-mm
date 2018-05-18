Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE73A6B05DA
	for <linux-mm@kvack.org>; Fri, 18 May 2018 10:27:18 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p190-v6so6950111qkc.17
        for <linux-mm@kvack.org>; Fri, 18 May 2018 07:27:18 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t79-v6si2245251qkl.273.2018.05.18.07.27.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 07:27:17 -0700 (PDT)
From: Florian Weimer <fweimer@redhat.com>
Subject: pkeys on POWER: Access rights not reset on execve
Message-ID: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com>
Date: Fri, 18 May 2018 16:27:14 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, Ram Pai <linuxram@us.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>

This test program:

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
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
   if (argc > 1)
     {
       int key = syscall (__NR_pkey_alloc, 0, 0);
       if (key < 0)
         err (1, "pkey_alloc");
       printf ("Allocated key (PID %d): %d\n", (int) getpid (), key);
       return 0;
     }

   pid_t pid = fork ();
   if (pid == 0)
     {
       execl ("/proc/self/exe", argv[0], "subprocess", NULL);
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
   printf ("New AMR value (PID %d, before execl): 0x%016lx\n",
           (int) getpid (), pkey_read());
   execl ("/proc/self/exe", argv[0], "subprocess", NULL);
   err (1, "exec");
   return 1;
}

shows that the AMR register value is not reset on execve:

AMR (PID 112291): 0x0000000000000000
AMR (PID 112292): 0x0000000000000000
Allocated key (PID 112292): 2
Allocated key (PID 112291): 2
Setting AMR: 0xffffffffffffffff
New AMR value (PID 112291, before execl): 0x0c00000000000000
AMR (PID 112291): 0x0c00000000000000
Allocated key (PID 112291): 2

I think this is a real bug and needs to be fixed even if the defaults 
are kept as-is (see the other thread).

(Seen on 4.17.0-rc5.)

Thanks,
Florian
