Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CD3786B00A0
	for <linux-mm@kvack.org>; Fri, 15 May 2009 01:44:01 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090515012125.057a9c88@binnacle.cx>
Date: Fri, 15 May 2009 01:32:38 -0400
From: starlight@binnacle.cx
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of
  process with hugepage shared memory segments attached
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=====================_1128542308==_"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

--=====================_1128542308==_
Content-Type: text/plain; charset="us-ascii"

Whacked at a this, attempting to build a testcase from a 
combination of the original daemon strace in the bug report
and knowledge of what the daemon is doing.

What emerged is something that will destroy RHEL5 
2.6.18-128.1.6.el5 100% every time.  Completely fills the kernel 
message log with "bad pmd" errors and wrecks hugepages.

Unfortunately it only occasionally breaks 2.6.29.1.  Haven't
been able to produce "bad pmd" messages, but did get the
kernel to think it's out of large page memory when in
theory it was not.  Saw a lot of really strange accounting
in the hugepage section of /proc/meminfo.

For what it's worth, the testcase code is attached.

Note that hugepages=2048 is assumed--the bug seems to require 
use of more than 50% of large page memory.

Definately will be posted under the RHEL5 bug report, which is 
the more pressing issue here than far-future kernel support.

In addition, the original segment attach bug 
http://bugzilla.kernel.org/show_bug.cgi?id=12134 is still there 
and can be reproduced every time with the 'create_seg_strace' 
and 'access_seg_straceX' sequences.
--=====================_1128542308==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="do_tcbm.txt"

g++ -Wall -g -o tcbm tcbm.C

--=====================_1128542308==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="tcbm.C.txt"

extern "C" {
#include <errno.h>
#include <memory.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sched.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <sys/resource.h>
#include <sys/mman.h>
}

extern "C"
void child_signal_handler(
   const int
)
{
   int   errno_save;
   pid_t dead_pid;
   int   dead_status;

   errno_save = errno;

   do {
      dead_pid = waitpid(-1, &dead_status, WNOHANG);
      if (dead_pid == -1) {
         if (errno == ECHILD) break;
         perror("waitpid");
         exit(1);
      }
   } while (dead_pid != 0);

   errno = errno_save;

   return;
}

int rabbits(void)
{
   int pid = fork();
   if (pid != 0) {

      return 0;

   } else {

      const int sched_policy = sched_getscheduler(0);
      if (sched_policy == -1) {
         perror("sched_getscheduler");
      }
      if (sched_policy != SCHED_OTHER) {
         sched_param sched;
         memset(&sched, 0, sizeof(sched));
         sched.sched_priority = 0;
         if (sched_setscheduler(0, SCHED_OTHER, &sched) != 0) {
            perror("sched_setscheduler");
         }
      }
      errno = 0;                   // -1 return value legitimate
      const int nice = getpriority(PRIO_PROCESS, 0);
      if (errno != 0) {
         perror("getpriority");
      }
      if (nice < -10) {
         if (setpriority(PRIO_PROCESS, 0, -10) != 0) {   // somewhat elevated
            perror("setpriority");
         }
      }

      char* program;
      program = (char*) "script";
      char* pargs[2];
      pargs[0] = program;
      pargs[1] = NULL;
      execvp(program, pargs);
      perror("execvp");
      exit(1);

   }

}

int main(
   int          argc,
   const char** argv,
   const char** envp
)
{
#if 1
   sched_param sched;
   memset(&sched, 0, sizeof(sched));
   sched.sched_priority = 26;
   if (sched_setscheduler(0, SCHED_RR, &sched) != 0) {
      perror("sched_setscheduler(SCHED_RR, 26)");
      return 1;
   }
#endif

#if 0
   if (mlockall(MCL_CURRENT|MCL_FUTURE) != 0) {
      perror("mlockall");
      return 1;
   }
#endif

   struct sigaction sas_child;
   memset(&sas_child, 0, sizeof(sas_child));
   sas_child.sa_handler = child_signal_handler;
   if (sigaction(SIGCHLD, &sas_child, NULL) != 0) {
      perror("sigaction(SIGCHLD)");
      return 1;
   }

   int seg1id = shmget(0x12345600,
                       (size_t) 0xC0000000,
                       IPC_CREAT|SHM_HUGETLB|0640
                      );
   if (seg1id == -1) {
      perror("shmget(3GB)");
      return 1;
   }
   void* seg1adr = shmat(seg1id, (void*) 0x400000000, 0);
   if (seg1adr == (void*) -1) {
      perror("shmat(3GB)");
      return 1;
   }
#if 1
   memset(seg1adr, 0xFF, (size_t) 0x60000000);
   if (mlock(seg1adr, (size_t) 0xC0000000) != 0) {
      perror("mlock(3GB)");
      return 1;
   }
#endif

   int seg2id = shmget(0x12345601,
                       (size_t) 0x40000000,
                       IPC_CREAT|SHM_HUGETLB|0640
                      );
   if (seg2id == -1) {
      perror("shmget(1GB)");
      return 1;
   }
   void* seg2adr = shmat(seg2id, (void*) 0x500000000, 0);
   if (seg2adr == (void*) -1) {
      perror("shmat(1GB)");
      return 1;
   }
#if 1
   memset(seg2adr, 0xFF, (size_t) 0x40000000);
   if (mlock(seg2adr, (size_t) 0x40000000) != 0) {
      perror("mlock(1GB)");
      return 1;
   }
#endif

   for (int i1 = 0; i1 < 50; i1++) {
      void* mmtarg = mmap(NULL,
                          528384,
                          PROT_READ|PROT_WRITE,
                          MAP_PRIVATE|MAP_ANONYMOUS,
                          -1,
                          0
                         );
      if (mmtarg == (void*) -1) {
         perror("mmap");
         return 1;
      }
   }

   for (int i1 = 0; i1 < 50; i1++) {
      rabbits();
      usleep(500);
   }

   while (true) {
      pause();
   }

   return 0;
}

--=====================_1128542308==_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
