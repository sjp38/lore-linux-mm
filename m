From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: Transparent Hugepage impact on memcpy
Date: Tue, 4 Jun 2013 20:30:51 +0800
Message-ID: <2109.09282691336$1370349073@news.gmane.org>
References: <51ADAC15.1050103@huawei.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UjqOI-0003Ap-FJ
	for glkm-linux-mm-2@m.gmane.org; Tue, 04 Jun 2013 14:31:06 +0200
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id D5E156B0093
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 08:31:03 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 4 Jun 2013 17:55:30 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 2827C125804F
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 18:03:02 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r54CUnZ856361008
	for <linux-mm@kvack.org>; Tue, 4 Jun 2013 18:00:49 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r54CUrJF018270
	for <linux-mm@kvack.org>; Tue, 4 Jun 2013 22:30:53 +1000
Content-Disposition: inline
In-Reply-To: <51ADAC15.1050103@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, qiuxishi <qiuxishi@huawei.com>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 04, 2013 at 04:57:57PM +0800, Jianguo Wu wrote:
>Hi all,
>
>I tested memcpy with perf bench, and found that in prefault case, When Transparent Hugepage is on,
>memcpy has worse performance.
>
>When THP on is 3.672879 GB/Sec (with prefault), while THP off is 6.190187 GB/Sec (with prefault).
>

I get similar result as you against 3.10-rc4 in the attachment. This
dues to the characteristic of thp takes a single page fault for each 
2MB virtual region touched by userland.

>I think THP will improve performance, but the test result obviously not the case. 
>Andrea mentioned THP cause "clear_page/copy_page less cache friendly" in
>http://events.linuxfoundation.org/slides/2011/lfcs/lfcs2011_hpc_arcangeli.pdf.
>
>I am not quite understand this, could you please give me some comments, Thanks!
>
>I test in Linux-3.4-stable, and my machine info is:
>Intel(R) Xeon(R) CPU           E5520  @ 2.27GHz
>
>available: 2 nodes (0-1)
>node 0 cpus: 0 1 2 3 8 9 10 11
>node 0 size: 24567 MB
>node 0 free: 23550 MB
>node 1 cpus: 4 5 6 7 12 13 14 15
>node 1 size: 24576 MB
>node 1 free: 23767 MB
>node distances:
>node   0   1 
>  0:  10  20 
>  1:  20  10
>
>Below is test result:
>---with THP---
>#cat /sys/kernel/mm/transparent_hugepage/enabled
>[always] madvise never
>#./perf bench mem memcpy -l 1gb -o
># Running mem/memcpy benchmark...
># Copying 1gb Bytes ...
>
>       3.672879 GB/Sec (with prefault)
>
>#./perf stat ...
>Performance counter stats for './perf bench mem memcpy -l 1gb -o':
>
>          35455940 cache-misses              #   53.504 % of all cache refs     [49.45%]
>          66267785 cache-references                                             [49.78%]
>              2409 page-faults                                                 
>         450768651 dTLB-loads
>                                                  [50.78%]
>             24580 dTLB-misses
>              #    0.01% of all dTLB cache hits  [51.01%]
>        1338974202 dTLB-stores
>                                                 [50.63%]
>             77943 dTLB-misses
>                                                 [50.24%]
>         697404997 iTLB-loads
>                                                  [49.77%]
>               274 iTLB-misses
>              #    0.00% of all iTLB cache hits  [49.30%]
>
>       0.855041819 seconds time elapsed
>
>---no THP---
>#cat /sys/kernel/mm/transparent_hugepage/enabled
>always madvise [never]
>
>#./perf bench mem memcpy -l 1gb -o
># Running mem/memcpy benchmark...
># Copying 1gb Bytes ...
>
>       6.190187 GB/Sec (with prefault)
>
>#./perf stat ...
>Performance counter stats for './perf bench mem memcpy -l 1gb -o':
>
>          16920763 cache-misses              #   98.377 % of all cache refs     [50.01%]
>          17200000 cache-references                                             [50.04%]
>            524652 page-faults                                                 
>         734365659 dTLB-loads
>                                                  [50.04%]
>           4986387 dTLB-misses
>              #    0.68% of all dTLB cache hits  [50.04%]
>        1013408298 dTLB-stores
>                                                 [50.04%]
>           8180817 dTLB-misses
>                                                 [49.97%]
>        1526642351 iTLB-loads
>                                                  [50.41%]
>                56 iTLB-misses
>              #    0.00% of all iTLB cache hits  [50.21%]
>
>       1.025425847 seconds time elapsed
>
>Thanks,
>Jianguo Wu.
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=thp

---with THP---
#cat  /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never
# Running mem/memcpy benchmark...
# Copying 1gb Bytes ...

      12.208522 GB/Sec (with prefault)

 Performance counter stats for './perf bench mem memcpy -l 1gb -o':

        26,453,696 cache-misses              #   35.411 % of all cache refs     [57.66%]
        74,704,531 cache-references                                             [58.40%]
             2,297 page-faults                                                 
       146,567,960 dTLB-loads                                                   [58.64%]
       211,648,685 dTLB-stores                                                  [58.63%]
            14,533 dTLB-load-misses          #    0.01% of all dTLB cache hits  [57.46%]
               640 iTLB-loads                                                   [55.74%]
           270,881 iTLB-load-misses          #  42325.16% of all iTLB cache hits  [55.17%]

       0.232425109 seconds time elapsed

---no THP---
#cat  /sys/kernel/mm/transparent_hugepage/enabled
always madvise [never]

# Running mem/memcpy benchmark...
# Copying 1gb Bytes ...

      18.325087 GB/Sec (with prefault)

 Performance counter stats for './perf bench mem memcpy -l 1gb -o':

        28,498,544 cache-misses              #   86.167 % of all cache refs     [57.35%]
        33,073,611 cache-references                                             [57.71%]
           524,540 page-faults                                                 
       453,500,641 dTLB-loads                                                   [57.99%]
       409,255,606 dTLB-stores                                                  [57.99%]
         2,033,985 dTLB-load-misses          #    0.45% of all dTLB cache hits  [57.52%]
             1,180 iTLB-loads                                                   [56.69%]
           539,056 iTLB-load-misses          #  45682.71% of all iTLB cache hits  [56.02%]

       0.485932214 seconds time elapsed

--NzB8fVQJ5HfG6fxh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
