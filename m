Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15FDF6B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 10:08:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v25so242769pgn.20
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 07:08:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b91-v6si416097plb.90.2018.04.09.07.08.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 07:08:36 -0700 (PDT)
Date: Mon, 9 Apr 2018 23:08:30 +0900
From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 9/9] perf probe: Support SDT markers having reference
 counter (semaphore)
Message-Id: <20180409230830.48118d3c32f7ec448936ed8a@kernel.org>
In-Reply-To: <643a8fb2-fb96-8dbe-9f36-2540bd8a1de5@linux.vnet.ibm.com>
References: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
	<20180404083110.18647-10-ravi.bangoria@linux.vnet.ibm.com>
	<20180409162856.df4c32b840eb5f2ef8c028f1@kernel.org>
	<643a8fb2-fb96-8dbe-9f36-2540bd8a1de5@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Cc: oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org, acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com

On Mon, 9 Apr 2018 13:59:16 +0530
Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:

> Hi Masami,
> 
> On 04/09/2018 12:58 PM, Masami Hiramatsu wrote:
> > Hi Ravi,
> >
> > On Wed,  4 Apr 2018 14:01:10 +0530
> > Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com> wrote:
> >
> >> @@ -2054,15 +2060,21 @@ char *synthesize_probe_trace_command(struct probe_trace_event *tev)
> >>  	}
> >>  
> >>  	/* Use the tp->address for uprobes */
> >> -	if (tev->uprobes)
> >> +	if (tev->uprobes) {
> >>  		err = strbuf_addf(&buf, "%s:0x%lx", tp->module, tp->address);
> >> -	else if (!strncmp(tp->symbol, "0x", 2))
> >> +		if (uprobe_ref_ctr_is_supported() &&
> >> +		    tp->ref_ctr_offset &&
> >> +		    err >= 0)
> >> +			err = strbuf_addf(&buf, "(0x%lx)", tp->ref_ctr_offset);
> > If the kernel doesn't support uprobe_ref_ctr but the event requires
> > to increment uprobe_ref_ctr, I think we should (at least) warn user here.
> 
> pr_debug("A semaphore is associated with %s:%s and seems your kernel doesn't support it.\n"
> A A A A A A A A  tev->group, tev->event);
> 
> Looks good?

I think it should be pr_warning() and return NULL, since user may not be able to
trace the event even if it is enabled.

> 
> >> @@ -776,14 +784,21 @@ static char *synthesize_sdt_probe_command(struct sdt_note *note,
> >>  {
> >>  	struct strbuf buf;
> >>  	char *ret = NULL, **args;
> >> -	int i, args_count;
> >> +	int i, args_count, err;
> >> +	unsigned long long ref_ctr_offset;
> >>  
> >>  	if (strbuf_init(&buf, 32) < 0)
> >>  		return NULL;
> >>  
> >> -	if (strbuf_addf(&buf, "p:%s/%s %s:0x%llx",
> >> -				sdtgrp, note->name, pathname,
> >> -				sdt_note__get_addr(note)) < 0)
> >> +	err = strbuf_addf(&buf, "p:%s/%s %s:0x%llx",
> >> +			sdtgrp, note->name, pathname,
> >> +			sdt_note__get_addr(note));
> >> +
> >> +	ref_ctr_offset = sdt_note__get_ref_ctr_offset(note);
> >> +	if (uprobe_ref_ctr_is_supported() && ref_ctr_offset && err >= 0)
> >> +		err = strbuf_addf(&buf, "(0x%llx)", ref_ctr_offset);
> > We don't have to care about uprobe_ref_ctr support here, because
> > this information will be just cached, not directly written to
> > uprobe_events.
> 
> Sure, will remove the check.

Thanks!

> 
> Thanks for the review :).
> Ravi
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
