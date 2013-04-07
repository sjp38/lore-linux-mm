Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 8D7656B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 03:47:20 -0400 (EDT)
Message-ID: <51612408.5060306@redhat.com>
Date: Sun, 07 Apr 2013 15:45:12 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: [BUG?] thp: too much anonymous hugepage caused 'khugepaged' thread
 stopped
References: <1101781431.260745.1365313808038.JavaMail.root@redhat.com> <338291050.277410.1365316170850.JavaMail.root@redhat.com> <20130407071047.GA8626@hacker.(null)>
In-Reply-To: <20130407071047.GA8626@hacker.(null)>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 04/07/2013 03:10 PM, Wanpeng Li wrote:
> On Sun, Apr 07, 2013 at 02:29:30AM -0400, Zhouping Liu wrote:
>> Hello All,
>>
>> When I did some testing to check thp's performance, the following
>> strange action occurred:
>>
>> when a process try to allocate 500+(or other large value)
>> anonymous hugepage, the 'khugepaged' thread will stop to
>> scan vma. the testing system has 2Gb RAM, and the thp
>> enabled value is 'always', set 0 to 'scan_sleep_millisecs'
>>
>> you can use the following steps to confirm the issue:
>>
>> ---------------- example code ------------
>> /* file test_thp.c */
>>
>> #include <stdio.h>
>> #include <stdlib.h>
>> #include <string.h>
>> #include <sys/mman.h>
>>
>> int main(int argc, char *argv[])
>> {
>> 	int nr_thps = 1000, ret = 0;
>> 	unsigned long hugepagesize, size;
>> 	void *addr;
>>
>> 	hugepagesize = (1UL << 21);
>>
>> 	if (argc == 2)
>> 		nr_thps = atoi(argv[1]);
>>
>> 	printf("try to allocate %d transparent hugepages\n", nr_thps);
>> 	size = (unsigned long)nr_thps * hugepagesize;
>>
>> 	ret = posix_memalign(&addr, hugepagesize, size);
>> 	if (ret != 0) {
>> 		printf("posix_memalign failed\n");
>> 		return ret;
>> 	}
>>
>> 	memset (addr, 10, size);
>>
>> 	sleep(50);
>>
>> 	return ret;
>> }
>> -------- end example code -----------
>>
>> executing './test_thp 500' in a system with 2GB RAM, the values in
>> /sys/kernel/mm/transparent_hugepage/khugepaged/* will never change,
>> you can  repeatedly do '# cat /sys/kernel/mm/transparent_hugepage/khugepaged/*' to check this.
>>
>> as we know, when we set 0 to /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs,
>> the /sys/kernel/mm/transparent_hugepage/khugepaged/full_to_scans will increasing at least,
>> but the actual is opposite, the value is never change, so I checked 'khugepaged' thread,
>> and found the 'khugepaged' is stopped:
>> # ps aux | grep -i hugepaged
>> root        67 10.9  0.0      0     0 ?        SN   Apr06 172:10 [khugepaged]
>>                                                ^^
>> also I did the same actions on some large machine, e.g on 16Gb RAM, 1000+ anonymous hugepages
>> will cause 'khugepaged' stopped, but there are 2Gb+ free memory, why is it? is that normal?
>> comments?
> khugepaged will preallocate one hugepage in NUMA case or alloc one
> hugepage before collapse in UMA case. If the memory is serious
> fragmentation and can't successfully allocate hugepage, khugepaged
> will go to sleep one minute. scan_sleep_millisecs determines how
> many milliseconds to wait in khugepaged between each pass, however,
> alloc_sleep_millisecs(default value is one minute) determines how
> many milliseconds to wait in khugepaged if there's an hugepage
> allocation failure to throttle the next allocation attempt.

I see, I only set scan_sleep_millisecs, didn't care 
alloc_sleep_millisecs value.
yes, you are right, allocating memory failure made khugepaged stopped in 
my case.

Thanks very much :)

Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
