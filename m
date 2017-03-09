Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE2DC2808C6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 08:02:44 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x63so110454700pfx.7
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 05:02:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n73si6384479pfb.276.2017.03.09.05.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 05:02:43 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v29CvM6d131753
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 08:02:43 -0500
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 292yce48yw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Mar 2017 08:02:43 -0500
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 9 Mar 2017 18:32:39 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v29D2bom13369510
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 18:32:37 +0530
Received: from d28av06.in.ibm.com (localhost [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v29D2Z4l014670
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 18:32:36 +0530
Subject: Re: [RFC PATCH 07/14] migrate: Add copy_page_lists_mthread()
 function.
References: <20170217150551.117028-1-zi.yan@sent.com>
 <20170217150551.117028-8-zi.yan@sent.com>
 <20170223085419.GA28246@hori1.linux.bs1.fc.nec.co.jp>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 9 Mar 2017 18:32:30 +0530
MIME-Version: 1.0
In-Reply-To: <20170223085419.GA28246@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Message-Id: <051b8789-f88b-0fdb-f150-7ef389fddae1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@sent.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "apopple@au1.ibm.com" <apopple@au1.ibm.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On 02/23/2017 02:24 PM, Naoya Horiguchi wrote:
> On Fri, Feb 17, 2017 at 10:05:44AM -0500, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>>
>> It supports copying a list of pages via multi-threaded process.
>> It evenly distributes a list of pages to a group of threads and
>> uses the same subroutine as copy_page_mthread()
> The new function has many duplicate lines with copy_page_mthread(),
> so please consider factoring out them into a common routine.
> That makes your code more readable/maintainable.

Though it looks very similar to each other. There are some
subtle differences which makes it harder to factor them out
in common functions.

int copy_pages_mthread(struct page *to, struct page *from, int nr_pages)

* This takes a single source page and single destination
  page and copies contiguous address data between these
  two pages. The size of the copy can be a single page
  for normal page or it can be multi pages if its a huge
  page.

* The work is split into PAGE_SIZE * nr_pages / threads and
  assigned to individual threads which is decided based on
  number of CPUs present on the target node. A single thread
  takes a single work queue job and executes it.

int copy_page_list_mt(struct page **to, struct page **from, int nr_pages)

* This takes multiple source pages and multiple destination
  pages and copies contiguous address data between two pages
  in a single work queue job. The size of the copy is decided
  based on type of page whether normal or huge.

* Each job does a single copy of a source page to destination
  page and we create as many jobs as number of pages though
  they are assigned to number of thread based on the number
  of CPUs present on the destination node. So one CPU can
  get more than one page copy job scheduled.

- Anshuman

 

  


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
