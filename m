Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 16BE28D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 10:14:54 -0400 (EDT)
Received: by pwi10 with SMTP id 10so805591pwi.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 07:14:38 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: [PATCH 0/2] ksm: take dirty bit as reference to avoid volatile pages
Date: Mon, 28 Mar 2011 22:14:18 +0800
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201103282214.19345.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Chris Wright <chrisw@sous-sol.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

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
