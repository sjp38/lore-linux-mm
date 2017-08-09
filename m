Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33ACA6B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 09:26:02 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l3so8797132wrc.12
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 06:26:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 78si3077021wme.169.2017.08.09.06.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 06:26:00 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v79DNq6E110486
	for <linux-mm@kvack.org>; Wed, 9 Aug 2017 09:25:59 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c807u3k58-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 09 Aug 2017 09:25:58 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 9 Aug 2017 14:25:56 +0100
Subject: Re: [PATCH 13/16] perf: Add a speculative page fault sw events
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1502202949-8138-14-git-send-email-ldufour@linux.vnet.ibm.com>
 <87lgmsnalk.fsf@concordia.ellerman.id.au>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 9 Aug 2017 15:25:48 +0200
MIME-Version: 1.0
In-Reply-To: <87lgmsnalk.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <f934bc94-d250-1d43-d796-de39231ae713@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 09/08/2017 15:18, Michael Ellerman wrote:
> Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
> 
>> Add new software events to count succeeded and failed speculative page
>> faults.
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  include/uapi/linux/perf_event.h | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
>> index b1c0b187acfe..fbfb03dff334 100644
>> --- a/include/uapi/linux/perf_event.h
>> +++ b/include/uapi/linux/perf_event.h
>> @@ -111,6 +111,8 @@ enum perf_sw_ids {
>>  	PERF_COUNT_SW_EMULATION_FAULTS		= 8,
>>  	PERF_COUNT_SW_DUMMY			= 9,
>>  	PERF_COUNT_SW_BPF_OUTPUT		= 10,
>> +	PERF_COUNT_SW_SPF_DONE			= 11,
>> +	PERF_COUNT_SW_SPF_FAILED		= 12,
> 
> Can't you calculate:
> 
>   PERF_COUNT_SW_SPF_FAILED = PERF_COUNT_SW_PAGE_FAULTS - PERF_COUNT_SW_SPF_DONE
> 
> ie. do you need a separate event for it?

Unfortunately not, because PERF_COUNT_SW_PAGE_FAULTS counts also page
faults from the kernel space, while SPF is only concerning user space page
faults.

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
