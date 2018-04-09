Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9FD6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 04:29:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id t133so3720634wmt.6
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 01:29:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o56si63703edc.525.2018.04.09.01.29.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 01:29:32 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w398JCxf100057
	for <linux-mm@kvack.org>; Mon, 9 Apr 2018 04:29:31 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h80dd9sgk-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 09 Apr 2018 04:29:30 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Mon, 9 Apr 2018 09:29:28 +0100
Subject: Re: [PATCH v2 9/9] perf probe: Support SDT markers having reference
 counter (semaphore)
References: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180404083110.18647-10-ravi.bangoria@linux.vnet.ibm.com>
 <20180409162856.df4c32b840eb5f2ef8c028f1@kernel.org>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Mon, 9 Apr 2018 13:59:16 +0530
MIME-Version: 1.0
In-Reply-To: <20180409162856.df4c32b840eb5f2ef8c028f1@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Message-Id: <643a8fb2-fb96-8dbe-9f36-2540bd8a1de5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

Hi Masami,

On 04/09/2018 12:58 PM, Masami Hiramatsu wrote:
> Hi Ravi,
>
> On Wed,  4 Apr 2018 14:01:10 +0530
> Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
>
>> @@ -2054,15 +2060,21 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
>>  	}
>>  
>>  	/* Use the tp->address for uprobes */
>> -	if (tev->uprobes)
>> +	if (tev->uprobes) {
>>  		err = strbuf_addf(&buf, "%s:0x%lx", tp->module, tp->address);
>> -	else if (!strncmp(tp->symbol, "0x", 2))
>> +		if (uprobe_ref_ctr_is_supported() &&
>> +		    tp->ref_ctr_offset &&
>> +		    err >= 0)
>> +			err = strbuf_addf(&buf, "(0x%lx)", tp->ref_ctr_offset);
> If the kernel doesn't support uprobe_ref_ctr but the event requires
> to increment uprobe_ref_ctr, I think we should (at least) warn user here.

pr_debug("A semaphore is associated with %s:%s and seems your kernel doesn't support it.\n"
A A A A A A A A  tev->group, tev->event);

Looks good?

>> @@ -776,14 +784,21 @@ static char *synthesize_sdt_probe_command(struct sdt_note *note,
>>  {
>>  	struct strbuf buf;
>>  	char *ret = NULL, **args;
>> -	int i, args_count;
>> +	int i, args_count, err;
>> +	unsigned long long ref_ctr_offset;
>>  
>>  	if (strbuf_init(&buf, 32) < 0)
>>  		return NULL;
>>  
>> -	if (strbuf_addf(&buf, "p:%s/%s %s:0x%llx",
>> -				sdtgrp, note->name, pathname,
>> -				sdt_note__get_addr(note)) < 0)
>> +	err = strbuf_addf(&buf, "p:%s/%s %s:0x%llx",
>> +			sdtgrp, note->name, pathname,
>> +			sdt_note__get_addr(note));
>> +
>> +	ref_ctr_offset = sdt_note__get_ref_ctr_offset(note);
>> +	if (uprobe_ref_ctr_is_supported() && ref_ctr_offset && err >= 0)
>> +		err = strbuf_addf(&buf, "(0x%llx)", ref_ctr_offset);
> We don't have to care about uprobe_ref_ctr support here, because
> this information will be just cached, not directly written to
> uprobe_events.

Sure, will remove the check.

Thanks for the review :).
Ravi
