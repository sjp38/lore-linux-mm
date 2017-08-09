Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4557A6B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 21:44:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u199so51443567pgb.13
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 18:44:00 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j2si1784498pli.1040.2017.08.08.18.43.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 18:43:59 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v791hpBt047215
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 21:43:58 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c7k46rvw7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 21:43:58 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 9 Aug 2017 11:43:55 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v791hqIB28508176
	for <linux-mm@kvack.org>; Wed, 9 Aug 2017 11:43:53 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v791hpOC028550
	for <linux-mm@kvack.org>; Wed, 9 Aug 2017 11:43:52 +1000
Subject: Re: [PATCH 16/16] perf tools: Add support for SPF events
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1502202949-8138-17-git-send-email-ldufour@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 9 Aug 2017 07:13:36 +0530
MIME-Version: 1.0
In-Reply-To: <1502202949-8138-17-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <c6468c4e-d704-d71a-6b00-e72977fbf68f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 08/08/2017 08:05 PM, Laurent Dufour wrote:
> Add support for the new speculative faults events.
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  tools/include/uapi/linux/perf_event.h | 2 ++
>  tools/perf/util/evsel.c               | 2 ++
>  tools/perf/util/parse-events.c        | 8 ++++++++
>  tools/perf/util/parse-events.l        | 2 ++
>  tools/perf/util/python.c              | 2 ++
>  5 files changed, 16 insertions(+)
> 
> diff --git a/tools/include/uapi/linux/perf_event.h b/tools/include/uapi/linux/perf_event.h
> index b1c0b187acfe..fbfb03dff334 100644
> --- a/tools/include/uapi/linux/perf_event.h
> +++ b/tools/include/uapi/linux/perf_event.h
> @@ -111,6 +111,8 @@ enum perf_sw_ids {
>  	PERF_COUNT_SW_EMULATION_FAULTS		= 8,
>  	PERF_COUNT_SW_DUMMY			= 9,
>  	PERF_COUNT_SW_BPF_OUTPUT		= 10,
> +	PERF_COUNT_SW_SPF_DONE			= 11,
> +	PERF_COUNT_SW_SPF_FAILED		= 12,
>  

PERF_COUNT_SW_SPF_FAULTS makes sense but not the FAILED one. IIRC,
there are no error path counting in perf SW events at the moment.
SPF_FAULTS and SPF_FAILS are VM internal events like THP collapse
etc. IMHO it should be added as a VM statistics counter or as a
trace point event instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
