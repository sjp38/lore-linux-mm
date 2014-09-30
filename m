Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id DB4176B0035
	for <linux-mm@kvack.org>; Tue, 30 Sep 2014 01:53:41 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so7583512lbi.27
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 22:53:41 -0700 (PDT)
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
        by mx.google.com with ESMTPS id lm5si16061627lac.87.2014.09.29.22.53.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 22:53:40 -0700 (PDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so3650041lbv.7
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 22:53:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1412052900-1722-1-git-send-email-danielmicay@gmail.com>
References: <1412052900-1722-1-git-send-email-danielmicay@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 29 Sep 2014 22:53:18 -0700
Message-ID: <CALCETrX6D7X7zm3qCn8kaBtYHCQvdR06LAAwzBA=1GteHAaLKA@mail.gmail.com>
Subject: Re: [PATCH v3] mm: add mremap flag for preserving the old mapping
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, jasone@canonware.com

On Mon, Sep 29, 2014 at 9:55 PM, Daniel Micay <danielmicay@gmail.com> wrote:
> This introduces the MREMAP_RETAIN flag for preserving the source mapping
> when MREMAP_MAYMOVE moves the pages to a new destination. Accesses to
> the source location will fault and cause fresh pages to be mapped in.
>
> For consistency, the old_len >= new_len case could decommit the pages
> instead of unmapping. However, userspace can accomplish the same thing
> via madvise and a coherent definition of the flag is possible without
> the extra complexity.

IMO this needs very clear documentation of exactly what it does.

Does it preserve the contents of the source pages?  (If so, why?
Aren't you wasting a bunch of time on page faults and possibly
unnecessary COWs?)

Does it work on file mappings?  Can it extend file mappings while it moves them?

If you MREMAP_RETAIN a partially COWed private mapping, what happens?

Does it work on special mappings?  If so, please prevent it from doing
so.  mremapping x86's vdso is a thing, and duplicating x86's vdso
should not become a thing, because x86_32 in particular will become
extremely confused.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
