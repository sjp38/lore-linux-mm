Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8CF6B0009
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 05:16:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v21so3606893wmh.9
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 02:16:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a38si178842edf.314.2018.03.19.02.16.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 02:16:25 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2J9EXj2025658
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 05:16:24 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gt9aa2mb3-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 05:16:23 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Mon, 19 Mar 2018 09:16:21 -0000
Subject: Re: [PATCH 6/8] trace_uprobe/sdt: Fix multiple update of same
 reference counter
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-7-ravi.bangoria@linux.vnet.ibm.com>
 <20180315144959.GB19643@redhat.com>
 <c93216a4-a4e1-dd8f-00be-17254e308cd1@linux.vnet.ibm.com>
 <20180316175030.GA28770@redhat.com>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Mon, 19 Mar 2018 14:48:35 +0530
MIME-Version: 1.0
In-Reply-To: <20180316175030.GA28770@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Message-Id: <4b337afd-fc5e-6110-888b-d4fa36a797ee@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

Hi Oleg,

On 03/16/2018 11:20 PM, Oleg Nesterov wrote:
> On 03/16, Ravi Bangoria wrote:
>> On 03/15/2018 08:19 PM, Oleg Nesterov wrote:
>>> On 03/13, Ravi Bangoria wrote:
>>>> For tiny binaries/libraries, different mmap regions points to the
>>>> same file portion. In such cases, we may increment reference counter
>>>> multiple times.
>>> Yes,
>>>
>>>> But while de-registration, reference counter will get
>>>> decremented only by once
>>> could you explain why this happens? sdt_increment_ref_ctr() and
>>> sdt_decrement_ref_ctr() look symmetrical, _decrement_ should see
>>> the same mappings?
> ...
>
>> A A A  # strace -o out python
>> A A  A A  mmap(NULL, 2738968, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fff92460000
>> A A A A A  mmap(0x7fff926a0000, 327680, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x230000) = 0x7fff926a0000
>> A A A A A  mprotect(0x7fff926a0000, 65536, PROT_READ) = 0
> Ah, in this case everything is clear, thanks.
>
> I was confused by the changelog, I misinterpreted it as if inc/dec are not
> balanced in case of multiple mappings even if the application doesn't play
> with mmap/mprotect/etc.
>
> And it seems that you are trying to confuse yourself, not only me ;) Just
> suppose that an application does mmap+munmap in a loop and the mapped region
> contains uprobe but not the counter.

this is fine because ...

>
> And this all makes me think that we should do something else. Ideally,
> install_breakpoint() and remove_breakpoint() should inc/dec the counter
> if they do not fail...

The whole point of adding this logic in trace_uprobe is we wanted to
decouple the counter inc/dec logic from uprobe patching. If user is just
doing mmap+munmap region in a loop which contains uprobe, the
instruction will be patched by the core uprobe infrastructure. Whenever
application mmap the region that holds to counter, it will be incremented.

Our initial design was to increment counter in install_breakpoint() but
uprobed instruction gets patched in a very early stage of binary loading
and vma that holds the counter may not be mapped yet.

>
> Btw, why do we need a counter, not a boolean? Who else can modify it?
> Or different uprobes can share the same counter?

Yes, multiple SDT markers can share the counter. Ex, there can be multiple
implementation of same function and thus each individual implementation
may contain marker which share the same counter. From mysql,

A  # readelf -n /usr/lib64/mysql/libmysqlclient.so.18.0.0 | grep -A2 Provider
A A A  Provider: mysql
A A A  Name: net__write__start
A A A  Location: 0x000000000003caa0, ..., Semaphore: 0x0000000000333532
A  --
A A A  Provider: mysql
A A A  Name: net__write__start
A A A  Location: 0x000000000003cd5c, ..., Semaphore: 0x0000000000333532

Here, both the markers has same name, but different location. Also they
share the counter (semaphore).

Apart from that, counter allows multiple tracers to trace on a single marker,
which is difficult with boolean flag.

Thanks,
Ravi
