Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7C06B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:48:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j28so5520661wrd.17
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 06:48:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l26si1593250edf.443.2018.03.16.06.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 06:48:01 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2GDlxhc033979
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:48:00 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2grdvukeem-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 09:47:59 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Fri, 16 Mar 2018 13:47:31 -0000
Subject: Re: [PATCH 6/8] trace_uprobe/sdt: Fix multiple update of same
 reference counter
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-7-ravi.bangoria@linux.vnet.ibm.com>
 <20180315144959.GB19643@redhat.com>
 <c93216a4-a4e1-dd8f-00be-17254e308cd1@linux.vnet.ibm.com>
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Date: Fri, 16 Mar 2018 19:19:34 +0530
MIME-Version: 1.0
In-Reply-To: <c93216a4-a4e1-dd8f-00be-17254e308cd1@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Message-Id: <20efff94-de74-dcbe-68e4-a72476fab209@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>



On 03/16/2018 05:42 PM, Ravi Bangoria wrote:
>
> On 03/15/2018 08:19 PM, Oleg Nesterov wrote:
>> On 03/13, Ravi Bangoria wrote:
>>> For tiny binaries/libraries, different mmap regions points to the
>>> same file portion. In such cases, we may increment reference counter
>>> multiple times.
>> Yes,
>>
>>> But while de-registration, reference counter will get
>>> decremented only by once
>> could you explain why this happens? sdt_increment_ref_ctr() and
>> sdt_decrement_ref_ctr() look symmetrical, _decrement_ should see
>> the same mappings?
> Sorry, I thought this happens only for tiny binaries. But that is not the case.
> This happens for binary / library of any length.
>
> Also, it's not a problem with sdt_increment_ref_ctr() / sdt_increment_ref_ctr().
> The problem happens with trace_uprobe_mmap_callback().
>
> To illustrate in detail, I'm adding a pr_info() in trace_uprobe_mmap_callback():
>
> A A A A A A A A A A A A A A A  vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
> +A A A A A A A A A A A A  pr_info("0x%lx-0x%lx : 0x%lx\n", vma->vm_start, vma->vm_end, vaddr);
> A A A A A A A A A A A A A A A  sdt_update_ref_ctr(vma->vm_mm, vaddr, 1);
>
>
> Ok now, libpython has SDT markers with reference counter:
>
> A  A  # readelf -n /usr/lib64/libpython2.7.so.1.0 | grep -A2 Provider
> A  A  A  A  Provider: python
> A A A  A  A  Name: function__entry
> A A  A A A A  ... Semaphore: 0x00000000002899d8
>
> Probing on that marker:
>
> A  A  # cd /sys/kernel/debug/tracing/
> A A A  # echo "p:sdt_python/function__entry /usr/lib64/libpython2.7.so.1.0:0x16a4d4(0x2799d8)" > uprobe_events
> A A A  # echo 1 > events/sdt_python/function__entry/enable
>
> When I run python:
>
> A A A  # strace -o out python
> A A  A A  mmap(NULL, 2738968, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fff92460000
> A A A A A  mmap(0x7fff926a0000, 327680, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x230000) = 0x7fff926a0000
> A A A A A  mprotect(0x7fff926a0000, 65536, PROT_READ) = 0
>
> The first mmap() maps the whole library into one region. Second mmap()
> and third mprotect() split out the whole region into smaller vmas and sets
> appropriate protection flags.
>
> Now, in this case, trace_uprobe_mmap_callback() updates reference counter
> twice -- by second mmap() call and by third mprotect() call -- because both
> regions contain reference counter offset. This I can verify in dmesg:
>
> A A A  # dmesg | tail
> A A A A A  trace_kprobe: 0x7fff926a0000-0x7fff926f0000 : 0x7fff926e99d8
> A A A A A  trace_kprobe: 0x7fff926b0000-0x7fff926f0000 : 0x7fff926e99d8
>
> Final vmas of libpython:
>
> A A A  # cat /proc/`pgrep python`/maps | grep libpython
> A A A A A  7fff92460000-7fff926a0000 r-xp 00000000 08:05 403934A  /usr/lib64/libpython2.7.so.1.0
> A A A A A  7fff926a0000-7fff926b0000 r--p 00230000 08:05 403934A  /usr/lib64/libpython2.7.so.1.0
> A A A A A  7fff926b0000-7fff926f0000 rw-p 00240000 08:05 403934A  /usr/lib64/libpython2.7.so.1.0
>
>
> I see similar problem with normal binary as well. I'm using Brendan Gregg's
> example[1]:
>
> A A A  # readelf -n /tmp/tick | grep -A2 Provider
> A A A  A A A  Provider: tick
> A  A A  A A  Name: loop2
> A A A A A A A  ... Semaphore: 0x000000001005003c
>
> Probing that marker:
>
> A A A  # echo "p:sdt_tick/loop2 /tmp/tick:0x6e4(0x10036)" > uprobe_events
> A A A  # echo 1 > events/sdt_tick/loop2/enable
>
> Now when I run the binary
>
> A A A  # /tmp/tick
>
> load_elf_binary() internally calls mmap() and I see trace_uprobe_mmap_callback()
> updating reference counter twice:
>
> A A A  # dmesg | tail
> A A A A A  trace_kprobe: 0x10010000-0x10030000 : 0x10020036
> A A A A A  trace_kprobe: 0x10020000-0x10030000 : 0x10020036
>
> proc/<pid>/maps of the tick:
>
> A A A  # cat /proc/`pgrep tick`/maps
> A A A A A  10000000-10010000 r-xp 00000000 08:05 1335712A  /tmp/tick
> A A A  A  10010000-10020000 r--p 00000000 08:05 1335712A  /tmp/tick
> A A A A A  10020000-10030000 rw-p 00010000 08:05 1335712A  /tmp/tick
>
> [1] https://github.com/iovisor/bcc/issues/327#issuecomment-200576506

Also, while de-registration, we look for all existing mms using
uprobe_build_mmap_info() and decrement the counter in each
of the mm. i.e. we decrement the counter only once.

-Ravi
