Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 67CB66B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 13:50:38 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v80so6782854qka.3
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 10:50:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b57si4193061qtb.466.2018.03.16.10.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 10:50:37 -0700 (PDT)
Date: Fri, 16 Mar 2018 18:50:30 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 6/8] trace_uprobe/sdt: Fix multiple update of same
 reference counter
Message-ID: <20180316175030.GA28770@redhat.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180313125603.19819-7-ravi.bangoria@linux.vnet.ibm.com>
 <20180315144959.GB19643@redhat.com>
 <c93216a4-a4e1-dd8f-00be-17254e308cd1@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c93216a4-a4e1-dd8f-00be-17254e308cd1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com

On 03/16, Ravi Bangoria wrote:
>
> On 03/15/2018 08:19 PM, Oleg Nesterov wrote:
> > On 03/13, Ravi Bangoria wrote:
> >> For tiny binaries/libraries, different mmap regions points to the
> >> same file portion. In such cases, we may increment reference counter
> >> multiple times.
> > Yes,
> >
> >> But while de-registration, reference counter will get
> >> decremented only by once
> > could you explain why this happens? sdt_increment_ref_ctr() and
> > sdt_decrement_ref_ctr() look symmetrical, _decrement_ should see
> > the same mappings?

...

>     # strace -o out python
>       mmap(NULL, 2738968, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fff92460000
>       mmap(0x7fff926a0000, 327680, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x230000) = 0x7fff926a0000
>       mprotect(0x7fff926a0000, 65536, PROT_READ) = 0

Ah, in this case everything is clear, thanks.

I was confused by the changelog, I misinterpreted it as if inc/dec are not
balanced in case of multiple mappings even if the application doesn't play
with mmap/mprotect/etc.

And it seems that you are trying to confuse yourself, not only me ;) Just
suppose that an application does mmap+munmap in a loop and the mapped region
contains uprobe but not the counter.

And this all makes me think that we should do something else. Ideally,
install_breakpoint() and remove_breakpoint() should inc/dec the counter
if they do not fail...

Btw, why do we need a counter, not a boolean? Who else can modify it?
Or different uprobes can share the same counter?

Oleg.
