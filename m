Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD616B000D
	for <linux-mm@kvack.org>; Tue,  8 May 2018 06:26:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n17-v6so3919684wmc.8
        for <linux-mm@kvack.org>; Tue, 08 May 2018 03:26:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t11-v6si2872606edr.278.2018.05.08.03.26.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 May 2018 03:26:42 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w48APFEw059923
	for <linux-mm@kvack.org>; Tue, 8 May 2018 06:26:40 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hu6kx24gn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 May 2018 06:26:40 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.ibm.com>;
	Tue, 8 May 2018 11:26:37 +0100
From: Ravi Bangoria <ravi.bangoria@linux.ibm.com>
Subject: Re: [PATCH v3 6/9] trace_uprobe: Support SDT markers having reference
 count (semaphore)
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180417043244.7501-7-ravi.bangoria@linux.vnet.ibm.com>
 <20180504134816.8633a157dd036489d9b0f1db@kernel.org>
 <206e4a16-ae21-7da3-f752-853dc2f51947@linux.ibm.com>
 <f3d066d2-a85a-bd21-d4f9-fc27e59135df@linux.ibm.com>
 <20180508005651.45553d3cf72521481d16b801@kernel.org>
Date: Tue, 8 May 2018 15:56:24 +0530
MIME-Version: 1.0
In-Reply-To: <20180508005651.45553d3cf72521481d16b801@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <d3635a76-29cc-887a-4740-89cbc8e768b1@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.ibm.com>

Hi Masami,

On 05/07/2018 09:26 PM, Masami Hiramatsu wrote:
> On Mon, 7 May 2018 13:51:21 +0530
> Ravi Bangoria <ravi.bangoria@linux.ibm.com> wrote:
>
>> Hi Masami,
>>
>> On 05/04/2018 07:51 PM, Ravi Bangoria wrote:
>>>>> +}
>>>>> +
>>>>> +static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
>>>>> +{
>>>>> +	struct uprobe_map_info *info;
>>>>> +
>>>>> +	uprobe_down_write_dup_mmap();
>>>>> +	info = uprobe_build_map_info(tu->inode->i_mapping,
>>>>> +				tu->ref_ctr_offset, false);
>>>>> +	if (IS_ERR(info))
>>>>> +		goto out;
>>>>> +
>>>>> +	while (info) {
>>>>> +		down_write(&info->mm->mmap_sem);
>>>>> +
>>>>> +		if (sdt_find_vma(tu, info->mm, info->vaddr))
>>>>> +			sdt_update_ref_ctr(info->mm, info->vaddr, 1);
>>>> Don't you have to handle the error to map pages here?
>>> Correct.. I think, I've to feedback error code to probe_event_{enable|disable}
>>> and handler failure there.
>> I looked at this. Actually, It looks difficult to feedback errors to
>> probe_event_{enable|disable}, esp. in the mmap() case.
> Hmm, can't you roll that back if sdt_increment_ref_ctr() fails?
> If so, how does sdt_decrement_ref_ctr() work in that case?

Yes, it's easy to rollback in sdt_increment_ref_ctr(). But not much can
be done if trace_uprobe_mmap() fails.

What would be good is, if we can feedback uprobe_mmap() failures
to the perf infrastructure, which can finally be parsed by perf record.
But that should be done as a separate work.

>> Is it fine if we just warn sdt_update_ref_ctr() failures in dmesg? I'm
>> doing this in [PATCH 7]. (Though, it makes more sense to do that in
>> [PATCH 6], will change it in next version).
> Of course we need to warn it at least, but the best is rejecting to
> enable it.

Yes, we can reject it for sdt_increment_ref_ctr() failures.

>> Any better ideas?
>>
>> BTW, same issue exists for normal uprobe. If uprobe_mmap() fails,
>> there is no feedback to trace_uprobe and no warnigns in dmesg as
>> well !! There was a patch by Naveen to warn such failures in dmesg
>> but that didn't go in: https://lkml.org/lkml/2017/9/22/155
> Oops, that's a real bug. It seems the ball is in Naveen's hand.
> Naveen, could you update it according to Oleg's comment, and resend it?
>
>> Also, I'll add a check in sdt_update_ref_ctr() to make sure reference
>> counter never goes to negative incase increment fails but decrement
>> succeeds. OTOH, if increment succeeds but decrement fails, the
>> counter remains >0 but there is no harm as such, except we will
>> execute some unnecessary code.
> I see. Please carefully clarify whether such case is kernel's bug or not.
> I would like to know what the condition causes that uneven behavior.

Sure, will do that.

Thanks,
Ravi
