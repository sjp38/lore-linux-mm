Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FBC26B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 03:37:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u138so26593730wmu.2
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 00:37:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n3si3315154edb.333.2017.10.09.00.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 00:37:52 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v997XlVb035086
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 03:37:50 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dg3xea6te-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Oct 2017 03:37:50 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 9 Oct 2017 08:37:48 +0100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v997bjCh22020284
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 07:37:46 GMT
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v997baZf013883
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 18:37:36 +1100
Subject: Re: [PATCH] page_alloc.c: inline __rmqueue()
References: <20171009054434.GA1798@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 9 Oct 2017 13:07:36 +0530
MIME-Version: 1.0
In-Reply-To: <20171009054434.GA1798@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <c1e5a3d4-c5ac-d6ee-88ab-d9e2aa433b16@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>

On 10/09/2017 11:14 AM, Aaron Lu wrote:
> __rmqueue() is called by rmqueue_bulk() and rmqueue() under zone->lock
> and that lock can be heavily contended with memory intensive applications.
> 
> Since __rmqueue() is a small function, inline it can save us some time.
> With the will-it-scale/page_fault1/process benchmark, when using nr_cpu
> processes to stress buddy:
> 
> On a 2 sockets Intel-Skylake machine:
>       base          %change       head
>      77342            +6.3%      82203        will-it-scale.per_process_ops
> 
> On a 4 sockets Intel-Skylake machine:
>       base          %change       head
>      75746            +4.6%      79248        will-it-scale.per_process_ops
> 
> This patch adds inline to __rmqueue().
> 
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>

Ran it through kernel bench and ebizzy micro benchmarks. Results
were comparable with and without the patch. May be these are not
the appropriate tests for this inlining improvement. Anyways it
does not have any performance degradation either.

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Tested-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
