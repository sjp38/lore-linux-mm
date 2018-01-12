Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B0B06B0253
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 18:37:38 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a141so3703323wma.8
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 15:37:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p86si3049893wma.42.2018.01.12.15.37.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 15:37:37 -0800 (PST)
Date: Fri, 12 Jan 2018 15:37:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] mm: initialize pages on demand during boot
Message-Id: <20180112153734.1780ccc00ebced508fad397a@linux-foundation.org>
In-Reply-To: <20180112183405.22193-1-pasha.tatashin@oracle.com>
References: <20180112183405.22193-1-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, mgorman@techsingularity.net, mgorman@suse.de, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Jan 2018 13:34:05 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> Deferred page initialization allows the boot cpu to initialize a small
> subset of the system's pages early in boot, with other cpus doing the rest
> later on.
> 
> It is, however, problematic to know how many pages the kernel needs during
> boot.  Different modules and kernel parameters may change the requirement,
> so the boot cpu either initializes too many pages or runs out of memory.
> 
> To fix that, initialize early pages on demand.  This ensures the kernel
> does the minimum amount of work to initialize pages during boot and leaves
> the rest to be divided in the multithreaded initialization path
> (deferred_init_memmap).
> 
> The on-demand code is permanently disabled using static branching once
> deferred pages are initialized.  After the static branch is changed to
> false, the overhead is up-to two branch-always instructions if the zone
> watermark check fails or if rmqueue fails.

Presumably this fixes some real-world problem which someone has observed?

Please describe that problem for us in lavish detail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
