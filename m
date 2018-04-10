Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBFE26B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 07:06:39 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g2so8132005qtp.5
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 04:06:39 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 71si3189231qkp.287.2018.04.10.04.06.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 04:06:39 -0700 (PDT)
Date: Tue, 10 Apr 2018 13:06:33 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2 7/9] trace_uprobe/sdt: Fix multiple update of same
 reference counter
Message-ID: <20180410110633.GA29063@redhat.com>
References: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
 <20180404083110.18647-8-ravi.bangoria@linux.vnet.ibm.com>
 <20180409132928.GA25722@redhat.com>
 <84c1e60f-8aad-a0ce-59af-4fcb3f77df94@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84c1e60f-8aad-a0ce-59af-4fcb3f77df94@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: mhiramat@kernel.org, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com

Hi Ravi,

On 04/10, Ravi Bangoria wrote:
>
> > and what if __mmu_notifier_register() fails simply because signal_pending() == T?
> > see mm_take_all_locks().
> >
> > at first glance this all look suspicious and sub-optimal,
>
> Yes. I should have added checks for failure cases.
> Will fix them in v3.

And what can you do if it fails? Nothing except report the problem. But
signal_pending() is not the unlikely or error condition, it should not
cause the tracing errors.

Plus mm_take_all_locks() is very heavy... BTW, uprobe_mmap_callback() is
called unconditionally. Whatever it does, can we at least move it after
the no_uprobe_events() check? Can't we also check MMF_HAS_UPROBES?

Either way, I do not feel that mmu_notifier is the right tool... Did you
consider the uprobe_clear_state() hook we already have?

Oleg.
