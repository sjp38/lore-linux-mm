Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l2RA2iTa189562
	for <linux-mm@kvack.org>; Tue, 27 Mar 2007 20:02:44 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2R9mcxP111362
	for <linux-mm@kvack.org>; Tue, 27 Mar 2007 19:48:39 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2R9j5ho009000
	for <linux-mm@kvack.org>; Tue, 27 Mar 2007 19:45:07 +1000
Message-ID: <4608E799.2050801@linux.vnet.ibm.com>
Date: Tue, 27 Mar 2007 15:14:57 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3][RFC] Containers: Pagecache controller reclaim
References: <45ED251C.2010400@linux.vnet.ibm.com> <45ED266E.7040107@linux.vnet.ibm.com> <6d6a94c50703262044q22e94538i5e79a32a82f7c926@mail.gmail.com> <4608C4F6.4020407@linux.vnet.ibm.com> <6d6a94c50703270141u5e59f73dj8bef0de0cfed1924@mail.gmail.com>
In-Reply-To: <6d6a94c50703270141u5e59f73dj8bef0de0cfed1924@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Aubrey Li <aubreylee@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, ckrm-tech@lists.sourceforge.net, Balbir Singh <balbir@in.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>, devel@openvz.org, xemul@sw.ru, Paul Menage <menage@google.com>, Christoph Lameter <clameter@sgi.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


Aubrey Li wrote:
> On 3/27/07, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> wrote:
>> Correct, shrink_page_list() is called from shrink_inactive_list() but
>> the above code is patched in shrink_active_list().  The
>> 'force_reclaim_mapped' label is from function shrink_active_list() and
>> not in shrink_page_list() as it may seem in the patch file.
>>
>> While removing pages from active_list, we want to select only
>> pagecache pages and leave the remaining in the active_list.
>> page_mapped() pages are _not_ of interest to pagecache controller
>> (they will be taken care by rss controller) and hence we put it back.
>>  Also if the pagecache controller is below limit, no need to reclaim
>> so we put back all pages and come out.
> 
> Oh, I just read the patch, not apply it to my local tree, I'm working
> on 2.6.19 now.
> So the question is, when vfs pagecache limit is hit, the current
> implementation just reclaim few pages, so it's quite possible the
> limit is hit again, and hence the reclaim code will be called again
> and again, that will impact application performance.

Yes, you are correct.  So if we start reclaiming one page at a time,
then the cost of reclaim is very high and we would be calling the
reclaim code too often.  Hence we have a 'buffer zone' or 'reclaim
threshold' or 'push back' around the limit.  In the patch we have a 64
page (256KB) NR_PAGES_RECLAIM_THRESHOLD:

 int pagecache_acct_shrink_used(unsigned long nr_pages)
 {
 	unsigned long ret = 0;
 	atomic_inc(&reclaim_count);
+
+	/* Don't call reclaim for each page above limit */
+	if (nr_pages > NR_PAGES_RECLAIM_THRESHOLD) {
+		ret += shrink_container_memory(
+				RECLAIM_PAGECACHE_MEMORY, nr_pages, NULL);
+	}
+
 	return 0;
 }

Hence we do not call the reclaimer if the threshold is exceeded by
just 1 page... we wait for 64 pages or 256KB of pagecache memory to go
 overlimit and then call the reclaimer which will reclaim all 64 pages
in one shot.

This prevents the reclaim code from being called too often and it also
keeps the cost of reclaim low.

In future patches we are planing to have a percentage based reclaim
threshold so that it would scale well with the container size.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
