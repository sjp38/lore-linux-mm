Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6670A6B0036
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 20:39:30 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id q9so1620200ykb.0
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 17:39:30 -0800 (PST)
Received: from mail-yh0-x233.google.com (mail-yh0-x233.google.com [2607:f8b0:4002:c01::233])
        by mx.google.com with ESMTPS id n44si13297921yhn.115.2014.01.22.17.39.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 17:39:29 -0800 (PST)
Received: by mail-yh0-f51.google.com with SMTP id t59so487361yho.38
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 17:39:28 -0800 (PST)
Date: Wed, 22 Jan 2014 17:39:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: mm: BUG: Bad rss-counter state
In-Reply-To: <52E06B6F.90808@oracle.com>
Message-ID: <alpine.DEB.2.02.1401221735450.26172@chino.kir.corp.google.com>
References: <52E06B6F.90808@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: khlebnikov@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 22 Jan 2014, Sasha Levin wrote:

> Hi all,
> 
> While fuzzing with trinity running inside a KVM tools guest using latest -next
> kernel,
> I've stumbled on a "mm: BUG: Bad rss-counter state" error which was pretty
> non-obvious
> in the mix of the kernel spew (why?).
> 

It's not a fatal condition and there's only a few possible stack traces 
that could be emitted during the exit() path.  I don't see how we could 
make it more visible other than its log-level which is already KERN_ALERT.

> I've added a small BUG() after the printk() in check_mm(), and here's the full
> output:
> 

Worst place to add it :)  At line 562 of kernel/fork.c in linux-next 
you're going to hit BUG() when there may be other counters that are also 
bad and they don't get printed.  

> [  318.334905] BUG: Bad rss-counter state mm:ffff8801e6dec000 idx:0 val:1

So our mm has a non-zero MM_FILEPAGES count, but there's nothing that was 
cited that would tell us what that is so there's not much to go on, unless 
someone already recognizes this as another issue.  Is this reproducible on 
3.13 or only on linux-next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
