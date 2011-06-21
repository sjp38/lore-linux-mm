Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 679F26B018B
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 08:56:01 -0400 (EDT)
Received: by iyl8 with SMTP id 8so6244479iyl.14
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 05:55:59 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: [PATCH 0/2 V2] ksm: take dirty bit as reference to avoid volatile pages scanning
Date: Tue, 21 Jun 2011 20:55:25 +0800
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201106212055.25400.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>

Compared to the first version, this patch set addresses the problem of
dirty bit updating of virtual machines, by adding two mmu_notifier interfaces.
So it can now track the volatile working set inside KVM guest OS.

V1 log:
Currently, ksm uses page checksum to detect volatile pages. Izik Eidus 
suggested that we could use pte dirty bit to optimize. This patch series
adds this new logic.

Preliminary benchmarks show that the scan speed is improved by up to 16 
times on volatile transparent huge pages and up to 8 times on volatile 
regular pages.

Following is the test program to show this top speed up (you need to make 
ksmd takes about more than 90% of the cpu and watch the ksm/full_scans).

  #include <stdio.h>
  #include <stdlib.h>
  #include <errno.h>
  #include <string.h>
  #include <unistd.h>
  #include <sys/mman.h>
  
  #define MADV_MERGEABLE   12
  
  
  #define SIZE (2000*1024*1024)
  #define PAGE_SIZE 4096
  
  int main(int argc, char **argv)
  {
        unsigned char *p;
        int j;
        int ret;
  
          p = mmap(NULL, SIZE, PROT_WRITE|PROT_READ,
                   MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
        
        if (p == MAP_FAILED) {
                printf("mmap error\n");
                return 0;
        }
      
          ret = madvise(p, SIZE, MADV_MERGEABLE);
      
          if (ret==-1) {
                  printf("madvise failed \n");
                  return 0;
          }
  
        
        memset(p, 1, SIZE);
  
        while (1) {
                for (j=0; j<SIZE; j+=PAGE_SIZE) {
                        *((long*)(p+j+PAGE_SIZE-4)) = random();
                }
        }
  
        return 0;
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
