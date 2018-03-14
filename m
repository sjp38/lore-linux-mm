Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C021E6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:10:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v64so1120625wma.4
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 08:10:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 88si268124edm.352.2018.03.14.08.10.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 08:10:25 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2EF9Qw3107147
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:10:24 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gq5awjqmu-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:10:23 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Wed, 14 Mar 2018 15:10:21 -0000
Subject: Re: [PATCH 5/8] trace_uprobe: Support SDT markers having reference
 count (semaphore)
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-6-ravi.bangoria@linux.vnet.ibm.com>
 <20180314224809.5ee4c8834bb366faa398e342@kernel.org>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Wed, 14 Mar 2018 20:42:24 +0530
MIME-Version: 1.0
In-Reply-To: <20180314224809.5ee4c8834bb366faa398e342@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <fabfad9d-a75e-0b18-1558-ce738b46e538@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

Hi Masami,

On 03/14/2018 07:18 PM, Masami Hiramatsu wrote:
> Hi Ravi,
>
> On Tue, 13 Mar 2018 18:26:00 +0530
> Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
>
>> Userspace Statically Defined Tracepoints[1] are dtrace style markers
>> inside userspace applications. These markers are added by developer at
>> important places in the code. Each marker source expands to a single
>> nop instruction in the compiled code but there may be additional
>> overhead for computing the marker arguments which expands to couple of
>> instructions. In case the overhead is more, execution of it can be
>> ommited by runtime if() condition when no one is tracing on the marker:
>>
>>     if (reference_counter > 0) {
>>         Execute marker instructions;
>>     }
>>
>> Default value of reference counter is 0. Tracer has to increment the
>> reference counter before tracing on a marker and decrement it when
>> done with the tracing.
>>
>> Implement the reference counter logic in trace_uprobe, leaving core
>> uprobe infrastructure as is, except one new callback from uprobe_mmap()
>> to trace_uprobe.
>>
>> trace_uprobe definition with reference counter will now be:
>>
>>   <path>:<offset>[(ref_ctr_offset)]
> Would you mean 
> <path>:<offset>(<ref_ctr_offset>)
> ?
>
> or use "[]" for delimiter?

[] indicates optional field.

> Since,
>
>> @@ -454,6 +458,26 @@ static int create_trace_uprobe(int argc, char **argv)
>>  		goto fail_address_parse;
>>  	}
>>  
>> +	/* Parse reference counter offset if specified. */
>> +	rctr = strchr(arg, '(');
> This seems you choose "()" for delimiter.

Correct.

>> +	if (rctr) {
>> +		rctr_end = strchr(arg, ')');
> 		rctr_end = strchr(rctr, ')');
>
> ? since we are sure rctr != NULL.

Yes. we can use rctr instead of arg.

>> +		if (rctr > rctr_end || *(rctr_end + 1) != 0) {
>> +			ret = -EINVAL;
>> +			pr_info("Invalid reference counter offset.\n");
>> +			goto fail_address_parse;
>> +		}
>
> Also
>
>> +
>> +		*rctr++ = 0;
>> +		*rctr_end = 0;
> Please consider to use '\0' for nul;

Sure. Will change it.

Thanks for the review :)
Ravi
