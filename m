Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E0662280253
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 14:11:37 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u144so14292552wmu.1
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 11:11:37 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id g82si29480015wmc.54.2016.11.10.11.11.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 11:11:36 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id t79so51386576wmt.0
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 11:11:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161104144534.14790-2-juerg.haefliger@hpe.com>
References: <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20161104144534.14790-1-juerg.haefliger@hpe.com> <20161104144534.14790-2-juerg.haefliger@hpe.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 10 Nov 2016 11:11:34 -0800
Message-ID: <CAGXu5jKY56q3Kp+dB0i-jgo7UrujCqnqhzw80+n_7keioKxWkQ@mail.gmail.com>
Subject: Re: [RFC PATCH v3 1/2] Add support for eXclusive Page Frame Ownership (XPFO)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@hpe.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, linux-x86_64@vger.kernel.org, vpk@cs.columbia.edu

On Fri, Nov 4, 2016 at 7:45 AM, Juerg Haefliger <juerg.haefliger@hpe.com> wrote:
> This patch adds support for XPFO which protects against 'ret2dir' kernel
> attacks. The basic idea is to enforce exclusive ownership of page frames
> by either the kernel or userspace, unless explicitly requested by the
> kernel. Whenever a page destined for userspace is allocated, it is
> unmapped from physmap (the kernel's page table). When such a page is
> reclaimed from userspace, it is mapped back to physmap.
>
> Additional fields in the page_ext struct are used for XPFO housekeeping.
> Specifically two flags to distinguish user vs. kernel pages and to tag
> unmapped pages and a reference counter to balance kmap/kunmap operations
> and a lock to serialize access to the XPFO fields.

Thanks for keeping on this! I'd really like to see it land and then
get more architectures to support it.

> Known issues/limitations:
>   - Only supports x86-64 (for now)
>   - Only supports 4k pages (for now)
>   - There are most likely some legitimate uses cases where the kernel needs
>     to access userspace which need to be made XPFO-aware
>   - Performance penalty

In the Kconfig you say "slight", but I'm curious what kinds of
benchmarks you've done and if there's a more specific cost we can
declare, just to give people more of an idea what the hit looks like?
(What workloads would trigger a lot of XPFO unmapping, for example?)

Thanks!

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
