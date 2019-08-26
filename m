Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EB59C3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:33:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE19121852
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:33:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE19121852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63B766B056B; Mon, 26 Aug 2019 07:33:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C43B6B056D; Mon, 26 Aug 2019 07:33:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DA226B056E; Mon, 26 Aug 2019 07:33:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0101.hostedemail.com [216.40.44.101])
	by kanga.kvack.org (Postfix) with ESMTP id 2718B6B056B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:33:13 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id C53E1180AD7C1
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:33:12 +0000 (UTC)
X-FDA: 75864367824.12.dust15_1c006cd0e432b
X-HE-Tag: dust15_1c006cd0e432b
X-Filterd-Recvd-Size: 3124
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:33:12 +0000 (UTC)
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 42DD9217F5;
	Mon, 26 Aug 2019 11:33:10 +0000 (UTC)
Date: Mon, 26 Aug 2019 07:33:08 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Song Liu <songliubraving@fb.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, kernel-team@fb.com, stable@vger.kernel.org, Thomas
 Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Andy
 Lutomirski <luto@amacapital.net>, Nadav Amit <namit@vmware.com>, Daniel
 Bristot de Oliveira <bristot@redhat.com>
Subject: Re: [PATCH] x86/mm: Do not split_large_page() for
 set_kernel_text_rw()
Message-ID: <20190826073308.6e82589d@gandalf.local.home>
In-Reply-To: <20190823093637.GH2369@hirez.programming.kicks-ass.net>
References: <20190823052335.572133-1-songliubraving@fb.com>
	<20190823093637.GH2369@hirez.programming.kicks-ass.net>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Aug 2019 11:36:37 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Aug 22, 2019 at 10:23:35PM -0700, Song Liu wrote:
> > As 4k pages check was removed from cpa [1], set_kernel_text_rw() leads to
> > split_large_page() for all kernel text pages. This means a single kprobe
> > will put all kernel text in 4k pages:
> > 
> >   root@ ~# grep ffff81000000- /sys/kernel/debug/page_tables/kernel
> >   0xffffffff81000000-0xffffffff82400000     20M  ro    PSE      x  pmd
> > 
> >   root@ ~# echo ONE_KPROBE >> /sys/kernel/debug/tracing/kprobe_events
> >   root@ ~# echo 1 > /sys/kernel/debug/tracing/events/kprobes/enable
> > 
> >   root@ ~# grep ffff81000000- /sys/kernel/debug/page_tables/kernel
> >   0xffffffff81000000-0xffffffff82400000     20M  ro             x  pte
> > 
> > To fix this issue, introduce CPA_FLIP_TEXT_RW to bypass "Text RO" check
> > in static_protections().
> > 
> > Two helper functions set_text_rw() and set_text_ro() are added to flip
> > _PAGE_RW bit for kernel text.
> > 
> > [1] commit 585948f4f695 ("x86/mm/cpa: Avoid the 4k pages check completely")  
> 
> ARGH; so this is because ftrace flips the whole kernel range to RW and
> back for giggles? I'm thinking _that_ is a bug, it's a clear W^X
> violation.

Since ftrace did this way before text_poke existed and way before
anybody cared (back in 2007), it's not really a bug.

Anyway, I believe Nadav has some patches that converts ftrace to use
the shadow page modification trick somewhere.

Or we also need the text_poke batch processing (did that get upstream?).

Mapping in 40,000 pages one at a time is noticeable from a human stand
point.

-- Steve

