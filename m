Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id EC9046B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 17:07:33 -0400 (EDT)
Date: Thu, 17 May 2012 16:07:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Huge pages: Memory leak on mmap failure
Message-ID: <alpine.DEB.2.00.1205171605001.19076@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>


On 2.6.32 and 3.4-rc6 mmap failure of a huge page causes a memory
leak. The 32 byte kmalloc cache grows by 10 mio entries if running
the following code:

--------
#include <sys/mman.h>
#include <stdlib.h>

#ifndef MAP_HUGETLB
#define MAP_HUGETLB 0x0040000
#endif

int main() {
    for (int i=0; i!=10000000; ++i) {
        void* ptr=mmap(NULL, 2*1024*1024, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS|MAP_HUGETLB, 0, 0);
        if (ptr!=MAP_FAILED) abort();
    }
    return 0;
}

-------


g++ -O2 test.cpp && echo good
good

$ egrep 'SUnreclaim|HugePages_Total' /proc/meminfo
SUnreclaim:      1900756 kB
HugePages_Total:       0

$ ./a.out && echo good
good

$ egrep 'SUnreclaim|HugePages_Total' /proc/meminfo
SUnreclaim:      2213268 kB
HugePages_Total:       0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
