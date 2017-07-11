Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 713DB6810BE
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 18:08:20 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t194so407093oif.8
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:08:20 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k132si356554oia.74.2017.07.11.15.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 15:08:19 -0700 (PDT)
Received: from mail-vk0-f49.google.com (mail-vk0-f49.google.com [209.85.213.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B8E7122CAC
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 22:08:18 +0000 (UTC)
Received: by mail-vk0-f49.google.com with SMTP id 191so3204355vko.2
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:08:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170711191823.qthrmdgqcd3rygjk@suse.de>
References: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
 <20170711064149.bg63nvi54ycynxw4@suse.de> <D810A11D-1827-48C7-BA74-C1A6DCD80862@gmail.com>
 <20170711092935.bogdb4oja6v7kilq@suse.de> <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de> <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de> <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 11 Jul 2017 15:07:57 -0700
Message-ID: <CALCETrXvkF3rxLijtou3ndSxG9vu62hrqh1ZXkaWgWbL-wd+cg@mail.gmail.com>
Subject: Re: Potential race in TLB flush batching?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 11, 2017 at 12:18 PM, Mel Gorman <mgorman@suse.de> wrote:

I would change this slightly:

> +void flush_tlb_batched_pending(struct mm_struct *mm)
> +{
> +       if (mm->tlb_flush_batched) {
> +               flush_tlb_mm(mm);

How about making this a new helper arch_tlbbatch_flush_one_mm(mm);
The idea is that this could be implemented as flush_tlb_mm(mm), but
the actual semantics needed are weaker.  All that's really needed
AFAICS is to make sure that any arch_tlbbatch_add_mm() calls on this
mm that have already happened become effective by the time that
arch_tlbbatch_flush_one_mm() returns.

The initial implementation would be this:

struct flush_tlb_info info = {
  .mm = mm,
  .new_tlb_gen = atomic64_read(&mm->context.tlb_gen);
  .start = 0,
  .end = TLB_FLUSH_ALL,
};

and the rest is like flush_tlb_mm_range().  flush_tlb_func_common()
will already do the right thing, but the comments should probably be
updated, too.  The benefit would be that, if you just call this on an
mm when everything is already flushed, it will still do the IPIs but
it won't do the actual flush.

A better future implementation could iterate over each cpu in
mm_cpumask(), and, using either a new lock or very careful atomics,
check whether that CPU really needs flushing.  In -tip, all the
information needed to figure this out is already there in the percpu
state -- it's just not currently set up for remote access.

For backports, it would just be flush_tlb_mm().

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
