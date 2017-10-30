Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D02E66B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 05:44:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m72so5846685wmc.0
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 02:44:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p3si4400536edi.413.2017.10.30.02.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Oct 2017 02:44:46 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9U9hvJs066948
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 05:44:45 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dwxcuhnsu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 05:44:45 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 30 Oct 2017 09:44:43 -0000
Date: Mon, 30 Oct 2017 11:44:37 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] pids: introduce find_get_task_by_vpid helper
References: <1509126753-3297-1-git-send-email-rppt@linux.vnet.ibm.com>
 <CAKTCnzn1-MMK+o-u2F3gcvCaq7Upk-5M2qOS9XaGV6-gcJRqBw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnzn1-MMK+o-u2F3gcvCaq7Upk-5M2qOS9XaGV6-gcJRqBw@mail.gmail.com>
Message-Id: <20171030094436.GA3141@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Mon, Oct 30, 2017 at 07:51:42PM +1100, Balbir Singh wrote:
> On Sat, Oct 28, 2017 at 4:52 AM, Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > There are several functions that do find_task_by_vpid() followed by
> > get_task_struct(). We can use a helper function instead.
> >
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> 
> I did a quick grep and found other similar patterns in

(reordered the file list a bit)

> kernel/events/core.c,
> arch/x86/kernel/cpu/intel_rdt_rdtgroup.c,
> mm/mempolicy.c,

Those and mm/migrate.c indeed have a similar pattern, but they all do

	task = pid ? find_task_by_vpid(pid) : current;

And I don't see an elegant way to use find_get_task_by_vpid() in this case.

> kernel/kcmp.c,

kcmp gets both tasks between rcu_read_lock/unlock and I think it's better
to keep it this way.

> kernel/sys.c,

There is no get_task_struct() after find_task_by_vpid(), unless I've missed
something

> kernel/time/posix-cpu-timers.c,

Here the task is selected with more complex logic than just
find_task_by_vpid() 

> mm/process_vm_access.c,

Converted in the patch

> security/yama/yama_lsm.c,
> arch/ia64/kernel/perfmon.c

I've missed these two, indeed.

The arch/ia64/kernel/perfmon.c even still uses read_lock(&tasklist) rather
than rcu_read_lock()...
 
> Balbir Singh.
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
