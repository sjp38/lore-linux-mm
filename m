Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id A49616B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:19:34 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id p5so4175009ywg.5
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 08:19:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y133si583106ywd.292.2018.03.14.08.19.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 08:19:33 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2EFInvw106934
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:19:32 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gq5b831fd-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 11:19:31 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Wed, 14 Mar 2018 15:19:28 -0000
Subject: Re: [PATCH 7/8] perf probe: Support SDT markers having reference
 counter (semaphore)
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-8-ravi.bangoria@linux.vnet.ibm.com>
 <20180314230909.52963a161210294ea2fc0420@kernel.org>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Wed, 14 Mar 2018 20:51:32 +0530
MIME-Version: 1.0
In-Reply-To: <20180314230909.52963a161210294ea2fc0420@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <60a29e08-c4a4-4f9e-aca1-8dafdd064956@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>



On 03/14/2018 07:39 PM, Masami Hiramatsu wrote:
> Hi Ravi,
>
> This code logic looks good. I just have several small comments for style.
>
> On Tue, 13 Mar 2018 18:26:02 +0530
> Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
>
>> diff --git a/tools/perf/util/probe-event.c b/tools/perf/util/probe-event.c
>> index e1dbc98..2cbe68a 100644
>> --- a/tools/perf/util/probe-event.c
>> +++ b/tools/perf/util/probe-event.c
>> @@ -1832,6 +1832,12 @@ int parse_probe_trace_command(const char *cmd, struct probe_trace_event *tev)
>>  			tp->offset = strtoul(fmt2_str, NULL, 10);
>>  	}
>>  
>> +	if (tev->uprobes) {
>> +		fmt2_str = strchr(p, '(');
>> +		if (fmt2_str)
>> +			tp->ref_ctr_offset = strtoul(fmt2_str + 1, NULL, 0);
>> +	}
>> +
>>  	tev->nargs = argc - 2;
>>  	tev->args = zalloc(sizeof(struct probe_trace_arg) * tev->nargs);
>>  	if (tev->args == NULL) {
>> @@ -2054,15 +2060,22 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
>>  	}
>>  
>>  	/* Use the tp->address for uprobes */
>> -	if (tev->uprobes)
>> -		err = strbuf_addf(&buf, "%s:0x%lx", tp->module, tp->address);
>> -	else if (!strncmp(tp->symbol, "0x", 2))
>> +	if (tev->uprobes) {
>> +		if (tp->ref_ctr_offset)
>> +			err = strbuf_addf(&buf, "%s:0x%lx(0x%lx)", tp->module,
>> +					  tp->address, tp->ref_ctr_offset);
>> +		else
>> +			err = strbuf_addf(&buf, "%s:0x%lx", tp->module,
>> +					  tp->address);
>> +	} else if (!strncmp(tp->symbol, "0x", 2)) {
>>  		/* Absolute address. See try_to_find_absolute_address() */
>>  		err = strbuf_addf(&buf, "%s%s0x%lx", tp->module ?: "",
>>  				  tp->module ? ":" : "", tp->address);
>> -	else
>> +	} else {
>>  		err = strbuf_addf(&buf, "%s%s%s+%lu", tp->module ?: "",
>>  				tp->module ? ":" : "", tp->symbol, tp->offset);
>> +	}
> What the purpose of this {}?

The starting if has multiple statements and thus it needs braces. So I added
braces is all other conditions.

>> +
>>  	if (err)
>>  		goto error;
>>  
>> diff --git a/tools/perf/util/probe-event.h b/tools/perf/util/probe-event.h
>> index 45b14f0..15a98c3 100644
>> --- a/tools/perf/util/probe-event.h
>> +++ b/tools/perf/util/probe-event.h
>> @@ -27,6 +27,7 @@ struct probe_trace_point {
>>  	char		*symbol;	/* Base symbol */
>>  	char		*module;	/* Module name */
>>  	unsigned long	offset;		/* Offset from symbol */
>> +	unsigned long	ref_ctr_offset;	/* SDT reference counter offset */
>>  	unsigned long	address;	/* Actual address of the trace point */
>>  	bool		retprobe;	/* Return probe flag */
>>  };
>> diff --git a/tools/perf/util/probe-file.c b/tools/perf/util/probe-file.c
>> index 4ae1123..08ba3a6 100644
>> --- a/tools/perf/util/probe-file.c
>> +++ b/tools/perf/util/probe-file.c
>> @@ -701,6 +701,12 @@ static unsigned long long sdt_note__get_addr(struct sdt_note *note)
>>  		 : (unsigned long long)note->addr.a64[0];
>>  }
>>  
>> +static unsigned long long sdt_note__get_ref_ctr_offset(struct sdt_note *note)
>> +{
>> +	return note->bit32 ? (unsigned long long)note->addr.a32[2]
>> +		: (unsigned long long)note->addr.a64[2];
>> +}
> Could you please introduce an enum for specifying the index by name?
>
> e.g.
> enum {
> 	SDT_NOTE_IDX_ADDR = 0,
> 	SDT_NOTE_IDX_REFCTR = 2,
> };

That will be good. Will change it.

>> +
>>  static const char * const type_to_suffix[] = {
>>  	":s64", "", "", "", ":s32", "", ":s16", ":s8",
>>  	"", ":u8", ":u16", "", ":u32", "", "", "", ":u64"
>> @@ -776,14 +782,24 @@ static char *synthesize_sdt_probe_command(struct sdt_note *note,
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
>> +	ref_ctr_offset = sdt_note__get_ref_ctr_offset(note);
>> +
>> +	if (ref_ctr_offset)
>> +		err = strbuf_addf(&buf, "p:%s/%s %s:0x%llx(0x%llx)",
>>  				sdtgrp, note->name, pathname,
>> -				sdt_note__get_addr(note)) < 0)
>> +				sdt_note__get_addr(note), ref_ctr_offset);
>> +	else
>> +		err = strbuf_addf(&buf, "p:%s/%s %s:0x%llx",
>> +				sdtgrp, note->name, pathname,
>> +				sdt_note__get_addr(note));
> This can be minimized (and avoid repeating) by using 2 strbuf_addf()s, like
>
> 	err = strbuf_addf(&buf, "p:%s/%s %s:0x%llx",
> 			sdtgrp, note->name, pathname,
> 			sdt_note__get_addr(note));
> 	if (ref_ctr_offset && !err < 0)
> 		err = strbuf_addf("(0x%llx)", ref_ctr_offset);

Sure. Will change it.

>
>> +
>> +	if (err < 0)
>>  		goto error;
>>  
>>  	if (!note->args)
>> diff --git a/tools/perf/util/symbol-elf.c b/tools/perf/util/symbol-elf.c
>> index 2de7705..76c7b54 100644
>> --- a/tools/perf/util/symbol-elf.c
>> +++ b/tools/perf/util/symbol-elf.c
>> @@ -1928,6 +1928,16 @@ static int populate_sdt_note(Elf **elf, const char *data, size_t len,
>>  		}
>>  	}
>>  
>> +	/* Adjust reference counter offset */
>> +	if (elf_section_by_name(*elf, &ehdr, &shdr, SDT_PROBES_SCN, NULL)) {
>> +		if (shdr.sh_offset) {
>> +			if (tmp->bit32)
>> +				tmp->addr.a32[2] -= (shdr.sh_addr - shdr.sh_offset);
>> +			else
>> +				tmp->addr.a64[2] -= (shdr.sh_addr - shdr.sh_offset);
> Here we should use enum above too.

Sure.

Thanks for the review :)
Ravi
