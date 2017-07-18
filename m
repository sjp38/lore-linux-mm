Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E21086B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 21:31:59 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q4so472372oif.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 18:31:59 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h77si517334oig.396.2017.07.17.18.31.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 18:31:59 -0700 (PDT)
Received: from mail-ua0-f169.google.com (mail-ua0-f169.google.com [209.85.217.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6AF4722C95
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 01:31:58 +0000 (UTC)
Received: by mail-ua0-f169.google.com with SMTP id 64so7245801uae.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 18:31:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170717180246.62277-1-namit@vmware.com>
References: <20170717180246.62277-1-namit@vmware.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jul 2017 18:31:36 -0700
Message-ID: <CALCETrW3XP-nE9MxzbZZ0DxxQYFJ848_afeDvQ8UzY=-gwBjmQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Prevent racy access to tlb_flush_pending
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Lutomirski <luto@kernel.org>

On Mon, Jul 17, 2017 at 11:02 AM, Nadav Amit <namit@vmware.com> wrote:
> Setting and clearing mm->tlb_flush_pending can be performed by multiple
> threads, since mmap_sem may only be acquired for read in task_numa_work.
> If this happens, tlb_flush_pending may be cleared while one of the
> threads still changes PTEs and batches TLB flushes.
>
> As a result, TLB flushes can be skipped because the indication of
> pending TLB flushes is lost, for instance due to race between
> migration and change_protection_range (just as in the scenario that
> caused the introduction of tlb_flush_pending).
>
> The feasibility of such a scenario was confirmed by adding assertion to
> check tlb_flush_pending is not set by two threads, adding artificial
> latency in change_protection_range() and using sysctl to reduce
> kernel.numa_balancing_scan_delay_ms.

This thing is logically a refcount.  Should it be refcount_t?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
