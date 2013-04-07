From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [BUG?] thp: too much anonymous hugepage caused 'khugepaged'
 thread stopped
Date: Sun, 7 Apr 2013 15:10:47 +0800
Message-ID: <26585.9079118401$1365318663@news.gmane.org>
References: <1101781431.260745.1365313808038.JavaMail.root@redhat.com>
 <338291050.277410.1365316170850.JavaMail.root@redhat.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UOjkj-0007sU-Av
	for glkm-linux-mm-2@m.gmane.org; Sun, 07 Apr 2013 09:11:01 +0200
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id DDA5A6B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 03:10:57 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 7 Apr 2013 12:37:59 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id AD4D33940057
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 12:40:50 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r377AiWE7143868
	for <linux-mm@kvack.org>; Sun, 7 Apr 2013 12:40:44 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r377An5r024865
	for <linux-mm@kvack.org>; Sun, 7 Apr 2013 17:10:49 +1000
Content-Disposition: inline
In-Reply-To: <338291050.277410.1365316170850.JavaMail.root@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sun, Apr 07, 2013 at 02:29:30AM -0400, Zhouping Liu wrote:
>Hello All,
>
>When I did some testing to check thp's performance, the following
>strange action occurred:
>
>when a process try to allocate 500+(or other large value)
>anonymous hugepage, the 'khugepaged' thread will stop to
>scan vma. the testing system has 2Gb RAM, and the thp
>enabled value is 'always', set 0 to 'scan_sleep_millisecs'
>
>you can use the following steps to confirm the issue:
>
>---------------- example code ------------
>/* file test_thp.c */
>
>#include <stdio.h>
>#include <stdlib.h>
>#include <string.h>
>#include <sys/mman.h>
>
>int main(int argc, char *argv[])
>{
>	int nr_thps = 1000, ret = 0;
>	unsigned long hugepagesize, size;
>	void *addr;
>
>	hugepagesize = (1UL << 21);
>
>	if (argc == 2)
>		nr_thps = atoi(argv[1]);
>
>	printf("try to allocate %d transparent hugepages\n", nr_thps);
>	size = (unsigned long)nr_thps * hugepagesize;
>
>	ret = posix_memalign(&addr, hugepagesize, size);
>	if (ret != 0) {
>		printf("posix_memalign failed\n");
>		return ret;
>	}
>
>	memset (addr, 10, size);
>
>	sleep(50);
>
>	return ret;
>}
>-------- end example code -----------
>
>executing './test_thp 500' in a system with 2GB RAM, the values in
>/sys/kernel/mm/transparent_hugepage/khugepaged/* will never change,
>you can  repeatedly do '# cat /sys/kernel/mm/transparent_hugepage/khugepaged/*' to check this.
>
>as we know, when we set 0 to /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs,
>the /sys/kernel/mm/transparent_hugepage/khugepaged/full_to_scans will increasing at least,
>but the actual is opposite, the value is never change, so I checked 'khugepaged' thread,
>and found the 'khugepaged' is stopped:
># ps aux | grep -i hugepaged
>root        67 10.9  0.0      0     0 ?        SN   Apr06 172:10 [khugepaged]
>                                               ^^ 
>also I did the same actions on some large machine, e.g on 16Gb RAM, 1000+ anonymous hugepages
>will cause 'khugepaged' stopped, but there are 2Gb+ free memory, why is it? is that normal?
>comments?

khugepaged will preallocate one hugepage in NUMA case or alloc one 
hugepage before collapse in UMA case. If the memory is serious 
fragmentation and can't successfully allocate hugepage, khugepaged 
will go to sleep one minute. scan_sleep_millisecs determines how 
many milliseconds to wait in khugepaged between each pass, however, 
alloc_sleep_millisecs(default value is one minute) determines how 
many milliseconds to wait in khugepaged if there's an hugepage 
allocation failure to throttle the next allocation attempt.

Regards,
Wanpeng Li 

>
>-- 
>Thanks,
>Zhouping
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
