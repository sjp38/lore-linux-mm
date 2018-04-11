Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF8A6B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 00:28:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e6so4635490wmh.0
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 21:28:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r14si569075edm.281.2018.04.10.21.28.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 21:28:30 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3B4O0pD037171
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 00:28:29 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h97q4qa34-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 00:28:28 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Wed, 11 Apr 2018 05:28:26 +0100
Subject: Re: [PATCH v2 7/9] trace_uprobe/sdt: Fix multiple update of same
 reference counter
References: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180404083110.18647-8-ravi.bangoria@linux.vnet.ibm.com>
 <20180409132928.GA25722@redhat.com>
 <84c1e60f-8aad-a0ce-59af-4fcb3f77df94@linux.vnet.ibm.com>
 <20180410110633.GA29063@redhat.com>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Wed, 11 Apr 2018 09:58:13 +0530
MIME-Version: 1.0
In-Reply-To: <20180410110633.GA29063@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <c3bd7507-977e-67b5-9ab0-d70b4908a6f2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

Hi Oleg,

On 04/10/2018 04:36 PM, Oleg Nesterov wrote:
> Hi Ravi,
>
> On 04/10, Ravi Bangoria wrote:
>>> and what if __mmu_notifier_register() fails simply because signal_pending() == T?
>>> see mm_take_all_locks().
>>>
>>> at first glance this all look suspicious and sub-optimal,
>> Yes. I should have added checks for failure cases.
>> Will fix them in v3.
> And what can you do if it fails? Nothing except report the problem. But
> signal_pending() is not the unlikely or error condition, it should not
> cause the tracing errors.

...

> Plus mm_take_all_locks() is very heavy... BTW, uprobe_mmap_callback() is
> called unconditionally. Whatever it does, can we at least move it after
> the no_uprobe_events() check? Can't we also check MMF_HAS_UPROBES?

Sure, I'll move it after these conditions.

> Either way, I do not feel that mmu_notifier is the right tool... Did you
> consider the uprobe_clear_state() hook we already have?

Ah! This is really a good idea. We don't need mmu_notifier then.

Thanks for suggestion,
Ravi
