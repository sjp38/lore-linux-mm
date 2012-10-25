Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 3D3A86B0062
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 07:57:20 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 25 Oct 2012 05:57:19 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 8D2F619D8042
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 05:57:17 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9PBvHfR185418
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 05:57:17 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9PBvG8Z032073
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 05:57:17 -0600
Message-ID: <50892917.30201@linux.vnet.ibm.com>
Date: Thu, 25 Oct 2012 04:57:11 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add some drop_caches documentation and info messsge
References: <20121023164546.747e90f6.akpm@linux-foundation.org> <20121024062938.GA6119@dhcp22.suse.cz> <20121024125439.c17a510e.akpm@linux-foundation.org> <50884F63.8030606@linux.vnet.ibm.com> <20121024134836.a28d223a.akpm@linux-foundation.org> <20121024210600.GA17037@liondog.tnic> <50885B2E.5050500@linux.vnet.ibm.com> <20121024224817.GB8828@liondog.tnic> <5088725B.2090700@linux.vnet.ibm.com> <CAHGf_=pfdgoeG5pPJb+UgjqfieU1yxt=46FGW1=th0RbgVKNRQ@mail.gmail.com> <20121025092424.GA16601@liondog.tnic>
In-Reply-To: <20121025092424.GA16601@liondog.tnic>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On 10/25/2012 02:24 AM, Borislav Petkov wrote:
> But let's discuss this a bit further. So, for the benchmarking aspect,
> you're either going to have to always require dmesg along with
> benchmarking results or /proc/vmstat, depending on where the drop_caches
> stats end up.
> 
> Is this how you envision it?
> 
> And then there are the VM bug cases, where you might not always get
> full dmesg from a panicked system. In that case, you'd want the kernel
> tainting thing too, so that it at least appears in the oops backtrace.
> 
> Although the tainting thing might not be enough - a user could
> drop_caches at some point in time and the oops happening much later
> could be unrelated but that can't be expressed in taint flags.

Here's the problem: Joe Kernel Developer gets a bug report, usually
something like "the kernel is slow", or "the kernel is eating up all my
memory".  We then start going and digging in to the problem with the
usual tools.  We almost *ALWAYS* get dmesg, and it's reasonably common,
but less likely, that we get things like vmstat along with such a bug
report.

Joe Kernel Developer digs in the statistics or the dmesg and tries to
figure out what happened.  I've run in to a couple of cases in practice
(and I assume Michal has too) where the bug reporter was using
drop_caches _heavily_ and did not realize the implications.  It was
quite hard to track down exactly how the page cache and dentries/inodes
were getting purged.

There are rarely oopses involved in these scenarios.

The primary goal of this patch is to make debugging those scenarios
easier so that we can quickly realize that drop_caches is the reason our
caches went away, not some anomalous VM activity.  A secondary goal is
to tell the user: "Hey, maybe this isn't something you want to be doing
all the time."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
