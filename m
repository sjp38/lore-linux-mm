From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [BUG?] thp: too much anonymous hugepage caused 'khugepaged'
 thread stopped
Date: Sun, 7 Apr 2013 16:33:23 +0800
Message-ID: <46271.1723674603$1365323621@news.gmane.org>
References: <1101781431.260745.1365313808038.JavaMail.root@redhat.com>
 <338291050.277410.1365316170850.JavaMail.root@redhat.com>
 <20130407071047.GA8626@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UOl2d-0000rc-19
	for glkm-linux-mm-2@m.gmane.org; Sun, 07 Apr 2013 10:33:35 +0200
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 2FD9E6B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 04:33:32 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 7 Apr 2013 13:58:08 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6B28BE004A
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 14:05:12 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r378XMmJ1376538
	for <linux-mm@kvack.org>; Sun, 7 Apr 2013 14:03:22 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r378XPfC002117
	for <linux-mm@kvack.org>; Sun, 7 Apr 2013 18:33:25 +1000
Content-Disposition: inline
In-Reply-To: <20130407071047.GA8626@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sun, Apr 07, 2013 at 03:10:47PM +0800, Wanpeng Li wrote:
>On Sun, Apr 07, 2013 at 02:29:30AM -0400, Zhouping Liu wrote:
>>Hello All,
>>
>>When I did some testing to check thp's performance, the following
>>strange action occurred:
>>
>>when a process try to allocate 500+(or other large value)
>>anonymous hugepage, the 'khugepaged' thread will stop to
>>scan vma. the testing system has 2Gb RAM, and the thp
>>enabled value is 'always', set 0 to 'scan_sleep_millisecs'
>>
>>you can use the following steps to confirm the issue:
>>
>>---------------- example code ------------
>>/* file test_thp.c */
>>
>>#include <stdio.h>
>>#include <stdlib.h>
>>#include <string.h>
>>#include <sys/mman.h>
>>
>>int main(int argc, char *argv[])
>>{
>>	int nr_thps = 1000, ret = 0;
>>	unsigned long hugepagesize, size;
>>	void *addr;
>>
>>	hugepagesize = (1UL << 21);
>>
>>	if (argc == 2)
>>		nr_thps = atoi(argv[1]);
>>
>>	printf("try to allocate %d transparent hugepages\n", nr_thps);
>>	size = (unsigned long)nr_thps * hugepagesize;
>>
>>	ret = posix_memalign(&addr, hugepagesize, size);
>>	if (ret != 0) {
>>		printf("posix_memalign failed\n");
>>		return ret;
>>	}
>>
>>	memset (addr, 10, size);
>>
>>	sleep(50);
>>
>>	return ret;
>>}
>>-------- end example code -----------
>>
>>executing './test_thp 500' in a system with 2GB RAM, the values in
>>/sys/kernel/mm/transparent_hugepage/khugepaged/* will never change,
>>you can  repeatedly do '# cat /sys/kernel/mm/transparent_hugepage/khugepaged/*' to check this.
>>
>>as we know, when we set 0 to /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs,
>>the /sys/kernel/mm/transparent_hugepage/khugepaged/full_to_scans will increasing at least,
>>but the actual is opposite, the value is never change, so I checked 'khugepaged' thread,
>>and found the 'khugepaged' is stopped:
>># ps aux | grep -i hugepaged
>>root        67 10.9  0.0      0     0 ?        SN   Apr06 172:10 [khugepaged]
>>                                               ^^ 
>>also I did the same actions on some large machine, e.g on 16Gb RAM, 1000+ anonymous hugepages
>>will cause 'khugepaged' stopped, but there are 2Gb+ free memory, why is it? is that normal?
>>comments?
>
>khugepaged will preallocate one hugepage in NUMA case or alloc one 
>hugepage before collapse in UMA case. If the memory is serious

Sorry, it should be reverse. khugepaged will preallocate one hugepage 
in UMA case and alloc one hugepage before collapse in NUMA case.

Regards,
Wanpeng Li 

>fragmentation and can't successfully allocate hugepage, khugepaged 
>will go to sleep one minute. scan_sleep_millisecs determines how 
>many milliseconds to wait in khugepaged between each pass, however, 
>alloc_sleep_millisecs(default value is one minute) determines how 
>many milliseconds to wait in khugepaged if there's an hugepage 
>allocation failure to throttle the next allocation attempt.
>
>Regards,
>Wanpeng Li 
>
>>
>>-- 
>>Thanks,
>>Zhouping
>>
>>--
>>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>the body to majordomo@kvack.org.  For more info on Linux MM,
>>see: http://www.linux-mm.org/ .
>>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
