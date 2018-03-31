Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C0E386B0276
	for <linux-mm@kvack.org>; Sat, 31 Mar 2018 01:44:53 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 12-v6so9350807itv.9
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 22:44:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v190sor4439385ioe.190.2018.03.30.22.44.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Mar 2018 22:44:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180330230733.2bf010f2@gandalf.local.home>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180330102038.2378925b@gandalf.local.home> <20180330205356.GA13332@bombadil.infradead.org>
 <20180330173031.257a491a@gandalf.local.home> <20180330174209.4cb77003@gandalf.local.home>
 <CAJWu+orx=NZrkAf7x_HqttnrMssmW7DPZOL1fxR=N6D_-fbmtw@mail.gmail.com>
 <20180330214151.415e90ea@gandalf.local.home> <20180331021857.GD13332@bombadil.infradead.org>
 <20180330230733.2bf010f2@gandalf.local.home>
From: Joel Fernandes <joelaf@google.com>
Date: Fri, 30 Mar 2018 22:44:51 -0700
Message-ID: <CAJWu+oovOOVX9UEw41L61NQ4Wyj+t513+E_tDfAqKik2+EP-Tg@mail.gmail.com>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Matthew Wilcox <willy@infradead.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>

On Fri, Mar 30, 2018 at 8:07 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Fri, 30 Mar 2018 19:18:57 -0700
> Matthew Wilcox <willy@infradead.org> wrote:
>
>> Again though, this is the same pattern as vmalloc.  There are any number
>> of places where userspace can cause an arbitrarily large vmalloc to be
>> attempted (grep for kvmalloc_array for a list of promising candidates).
>> I'm pretty sure that just changing your GFP flags to GFP_KERNEL |
>> __GFP_NOWARN will give you the exact behaviour that you want with no
>> need to grub around in the VM to find out if your huge allocation is
>> likely to succeed.
>
> Not sure how this helps. Note, I don't care about consecutive pages, so
> this is not an array. It's a link list of thousands of pages. How do
> you suggest allocating them? The ring buffer is a link list of pages.

Yeah I didn't understand the suggestion either. If I remember
correctly, not using either NO_RETRY or RETRY_MAY_FAIL, and just plain
GFP_KERNEL was precisely causing the buffer_size_kb write to cause an
OOM in my testing. So I think Steven's patch does the right thing in
checking in advance.

thanks,

- Joel
