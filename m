Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F1CE6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:13:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z83so2313509qka.7
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 08:13:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m43si1608101qtf.249.2018.03.14.08.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 08:13:15 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2EFAAl3052555
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:13:14 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gq2hbaud8-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:13:14 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Wed, 14 Mar 2018 15:13:10 -0000
Subject: Re: [PATCH 6/8] trace_uprobe/sdt: Fix multiple update of same
 reference counter
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-7-ravi.bangoria@linux.vnet.ibm.com>
 <20180314231540.b98c74a153255f59f54ebc46@kernel.org>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Wed, 14 Mar 2018 20:45:14 +0530
MIME-Version: 1.0
In-Reply-To: <20180314231540.b98c74a153255f59f54ebc46@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <1e51042b-d05b-dd55-82e6-818bb5be03d1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>



On 03/14/2018 07:45 PM, Masami Hiramatsu wrote:
> On Tue, 13 Mar 2018 18:26:01 +0530
> Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
>
>> For tiny binaries/libraries, different mmap regions points to the
>> same file portion. In such cases, we may increment reference counter
>> multiple times. But while de-registration, reference counter will get
>> decremented only by once leaving reference counter > 0 even if no one
>> is tracing on that marker.
>>
>> Ensure increment and decrement happens in sync by keeping list of
>> mms in trace_uprobe. Increment reference counter only if mm is not
>> present in the list and decrement only if mm is present in the list.
>>
>> Example
>>
>>   # echo "p:sdt_tick/loop2 /tmp/tick:0x6e4(0x10036)" > uprobe_events
>>
>> Before patch:
>>
>>   # perf stat -a -e sdt_tick:loop2
>>   # /tmp/tick
>>   # dd if=/proc/`pgrep tick`/mem bs=1 count=1 skip=$(( 0x10020036 )) 2>/dev/null | xxd
>>    0000000: 02                                       .
>>
>>   # pkill perf
>>   # dd if=/proc/`pgrep tick`/mem bs=1 count=1 skip=$(( 0x10020036 )) 2>/dev/null | xxd
>>   0000000: 01                                       .
>>
>> After patch:
>>
>>   # perf stat -a -e sdt_tick:loop2
>>   # /tmp/tick
>>   # dd if=/proc/`pgrep tick`/mem bs=1 count=1 skip=$(( 0x10020036 )) 2>/dev/null | xxd
>>   0000000: 01                                       .
>>
>>   # pkill perf
>>   # dd if=/proc/`pgrep tick`/mem bs=1 count=1 skip=$(( 0x10020036 )) 2>/dev/null | xxd
>>   0000000: 00                                       .
>>
>> Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
>> ---
>>  kernel/trace/trace_uprobe.c | 105 +++++++++++++++++++++++++++++++++++++++++++-
>>  1 file changed, 103 insertions(+), 2 deletions(-)
>>
>> diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
>> index b6c9b48..9bf3f7a 100644
>> --- a/kernel/trace/trace_uprobe.c
>> +++ b/kernel/trace/trace_uprobe.c
>> @@ -50,6 +50,11 @@ struct trace_uprobe_filter {
>>  	struct list_head	perf_events;
>>  };
>>  
>> +struct sdt_mm_list {
>> +	struct mm_struct *mm;
>> +	struct sdt_mm_list *next;
>> +};
> Oh, please use struct list_head instead of defining your own pointer-chain :(

Sure, will change it.

>> +
>>  /*
>>   * uprobe event core functions
>>   */
>> @@ -61,6 +66,8 @@ struct trace_uprobe {
>>  	char				*filename;
>>  	unsigned long			offset;
>>  	unsigned long			ref_ctr_offset;
>> +	struct sdt_mm_list		*sml;
>> +	struct rw_semaphore		sml_rw_sem;
> BTW, is there any reason to use rw_semaphore? (mutex doesn't fit?)

Hmm.. No specific reason.. will use a mutex instead.

Thanks for the review :)
Ravi
