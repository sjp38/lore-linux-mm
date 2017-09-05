Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A42828030E
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 03:23:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e64so3008862wmi.0
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 00:23:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l4si19608wml.66.2017.09.05.00.23.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 00:23:13 -0700 (PDT)
Date: Tue, 5 Sep 2017 09:23:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, memory_hotplug: remove timeout from
 __offline_memory
Message-ID: <20170905072310.6iuui7h7rwrrnxdy@dhcp22.suse.cz>
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-3-mhocko@kernel.org>
 <59AD15B6.7080304@huawei.com>
 <20170904090114.mrjxipvucieadxa6@dhcp22.suse.cz>
 <59AD174B.4020807@huawei.com>
 <20170904091505.xffd7orldpwlmrlx@dhcp22.suse.cz>
 <c217dbb1-6ee9-1401-04f1-a46f13488aaf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c217dbb1-6ee9-1401-04f1-a46f13488aaf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 05-09-17 11:16:57, Anshuman Khandual wrote:
> On 09/04/2017 02:45 PM, Michal Hocko wrote:
> > On Mon 04-09-17 17:05:15, Xishi Qiu wrote:
> >> On 2017/9/4 17:01, Michal Hocko wrote:
> >>
> >>> On Mon 04-09-17 16:58:30, Xishi Qiu wrote:
> >>>> On 2017/9/4 16:21, Michal Hocko wrote:
> >>>>
> >>>>> From: Michal Hocko <mhocko@suse.com>
> >>>>>
> >>>>> We have a hardcoded 120s timeout after which the memory offline fails
> >>>>> basically since the hot remove has been introduced. This is essentially
> >>>>> a policy implemented in the kernel. Moreover there is no way to adjust
> >>>>> the timeout and so we are sometimes facing memory offline failures if
> >>>>> the system is under a heavy memory pressure or very intensive CPU
> >>>>> workload on large machines.
> >>>>>
> >>>>> It is not very clear what purpose the timeout actually serves. The
> >>>>> offline operation is interruptible by a signal so if userspace wants
> >>>> Hi Michal,
> >>>>
> >>>> If the user know what he should do if migration for a long time,
> >>>> it is OK, but I don't think all the users know this operation
> >>>> (e.g. ctrl + c) and the affect.
> >>> How is this operation any different from other potentially long
> >>> interruptible syscalls?
> >>>
> >> Hi Michal,
> >>
> >> I means the user should stop it by himself if migration always retry in endless.
> > If the memory is migrateable then the migration should finish
> > eventually. It can take some time but it shouldn't be an endless loop.
> 
> But what if some how the temporary condition (page removed from the PCP
> LRU list and has not been freed yet to the buddy) happens again and again.

How would that happen? We have all pages in the range MIGRATE_ISOLATE so
no pages will get reallocated and we know that there are no unmigratable
pages in the range. So we only should have temporary failures for
migration. If that is not the case then we have a bug somewhere. 

> I understand we have schedule() and yield() to make sure that the context
> does not hold the CPU for ever but it can take theoretically very long
> time if not endless to finish. In that case sending signal to the user

I guess you meant to say signal from the user space...

> space process who initiated the offline request is the only way to stop
> this retry loop. I think this is still a better approach than the 120
> second timeout which was kind of arbitrary.

Yeah the context is interruptible so if the operation takes unbearably
too long then a watchdog can be setup trivially and to the user defined
value. There is a good reason we do not add hardocded timeouts to the
kernel.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
