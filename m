Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E521828E1
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:52:47 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so155847620lfe.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:52:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id yf9si18928013wjb.249.2016.08.05.08.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 05 Aug 2016 08:52:46 -0700 (PDT)
Subject: Re: [PATCH] x86/mm: disable preemption during CR3 read+write
References: <1470404259-26290-1-git-send-email-bigeasy@linutronix.de>
 <CALCETrV9n=-Zi2KBT7i-WLrYGffXy1ha+M=_PhvnuOiG7pim8A@mail.gmail.com>
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Message-ID: <c0a89331-e6f1-5c71-b513-2ff55de392d4@linutronix.de>
Date: Fri, 5 Aug 2016 17:52:38 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrV9n=-Zi2KBT7i-WLrYGffXy1ha+M=_PhvnuOiG7pim8A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On 08/05/2016 05:42 PM, Andy Lutomirski wrote:
> 
> This should affect kernel threads too, right?

I don't think so because they don't have a MM in the first place so
they don't shouldn't need to flush a TLB. But then there is iounmap()
and vfree() for instance which does

vmap_debug_free_range()
{
   if (debug_pagealloc_enabled()) {
         vunmap_page_range(start, end);
         flush_tlb_kernel_range(start, end);
   }
}

so it looks like a candidate.

> Acked-by: Andy Lutomirski <luto@kernel.org>

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
