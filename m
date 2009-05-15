Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B7ABA6B004F
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:47:42 -0400 (EDT)
Message-Id: <6.2.5.6.2.20090515144058.03a55298@binnacle.cx>
Date: Fri, 15 May 2009 14:44:29 -0400
From: starlight@binnacle.cx
Subject: Re: [Bugme-new] [Bug 13302] New: "bad pmd" on fork() of
  process with hugepage shared memory segments attached
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=====================_1175564956==_"
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Adam Litke <agl@us.ibm.com>, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

--=====================_1175564956==_
Content-Type: text/plain; charset="us-ascii"

This was really bugging me, so I hacked out
the test case for the attach failure.

Hoses 2.6.29.1 100% every time.  Run it like this:

tcbm_att
tcbm_att -
tcbm_att -
tcbm_att -

It will break on the last iteration with ENOMEM
and ENOMEM is all any shmget() or shmat() call
gets forever more.

After removing the segments this appears:

HugePages_Total:    2048
HugePages_Free:     2048
HugePages_Rsvd:     1280
HugePages_Surp:        0

Even though no segments show in 'ipcs'.
--=====================_1175564956==_
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: attachment; filename="tcbm_att.C.txt"

extern "C" {
#include <errno.h>
#include <memory.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/shm.h>
}

int main(
   int          argc,
   const char** argv,
   const char** envp
)
{
   if (argc == 1) {

      int seg1id = shmget(0x12345600,
                          (size_t) 0x40000000,
                          IPC_CREAT|SHM_HUGETLB|0640
                         );
      if (seg1id == -1) {
         perror("shmget(1GB)");
         return 1;
      }
      void* seg1adr = shmat(seg1id, (void*) 0x400000000, 0);
      if (seg1adr == (void*) -1) {
         perror("shmat(1GB)");
         return 1;
      }

      int seg2id = shmget(0x12345601,
                          (size_t) 0x10000000,
                          IPC_CREAT|SHM_HUGETLB|0640
                         );
      if (seg2id == -1) {
         perror("shmget(256MB)");
         return 1;
      }
      void* seg2adr = shmat(seg2id, (void*) 0x580000000, 0);
      if (seg2adr == (void*) -1) {
         perror("shmat(256MB)");
         return 1;
      }

      char* seg_p = (char*) seg1adr;
      int i1 = 182;
      while (i1 > 0) {
         memset(seg_p, 0x55, 0x400000);
         seg_p += 0x400000;
         i1--;
      }

      seg_p = (char*) seg2adr;
      i1 = 6;
      while (i1 > 0) {
         memset(seg_p, 0xAA, 0x400000);
         seg_p += 0x400000;
         i1--;
      }

      if (shmdt((void*) 0x400000000) != 0) {
         perror("shmdt(1GB)");
         return 1;
      }

      if (shmdt((void*) 0x580000000) != 0) {
         perror("shmdt(256MB)");
         return 1;
      }

   } else {

      int seg1id = shmget(0x12345600, 0, 0);
      if (seg1id == -1) {
         perror("shmget(1GB)");
         return 1;
      }
      void* seg1adr = shmat(seg1id, (void*) 0x400000000, SHM_RDONLY);
      if (seg1adr == (void*) -1) {
         perror("shmat(1GB)");
         return 1;
      }

      int seg2id = shmget(0x12345601, 0, 0);
      if (seg2id == -1) {
         perror("shmget(256MB)");
         return 1;
      }
      void* seg2adr = shmat(seg2id, (void*) 0x580000000, SHM_RDONLY);
      if (seg2adr == (void*) -1) {
         perror("shmat(256MB)");
         return 1;
      }

      if (shmdt((void*) 0x400000000) != 0) {
         perror("shmdt(1GB)");
         return 1;
      }

      if (shmdt((void*) 0x580000000) != 0) {
         perror("shmdt(256MB)");
         return 1;
      }

   }

   return 0;
}

--=====================_1175564956==_
Content-Type: application/octet-stream; name="do_tcbm_att.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="do_tcbm_att.txt"

ZysrIC1XYWxsIC1nIC1vIHRjYm1fYXR0IHRjYm1fYXR0LkMK
--=====================_1175564956==_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
