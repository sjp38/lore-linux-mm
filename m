Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06D776B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 04:34:57 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id q132so1414889lfe.1
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 01:34:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q7sor117085lfq.42.2017.09.15.01.34.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Sep 2017 01:34:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170914141532.9339436e0fb0fd85b99b8dbf@linux-foundation.org>
References: <20170914155936.697bf347a00dacee7e7f3778@gmail.com> <20170914141532.9339436e0fb0fd85b99b8dbf@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 15 Sep 2017 10:34:53 +0200
Message-ID: <CAMJBoFPrf_O4SeE9ve0zo1qaZdocwq=u+mYVAFQTm2NNbx9xqg@mail.gmail.com>
Subject: Re: [PATCH] z3fold: fix stale list handling
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>, Oleksiy.Avramchenko@sony.com

Hi Andrew,

2017-09-14 23:15 GMT+02:00 Andrew Morton <akpm@linux-foundation.org>:
> On Thu, 14 Sep 2017 15:59:36 +0200 Vitaly Wool <vitalywool@gmail.com> wrote:
>
>> Fix the situation when clear_bit() is called for page->private before
>> the page pointer is actually assigned. While at it, remove work_busy()
>> check because it is costly and does not give 100% guarantee anyway.
>
> Does this fix https://bugzilla.kernel.org/show_bug.cgi?id=196877 ?  If
> so, the bugzilla references and a reported-by should be added.

I wish it did but it doesn't. The bug you are referring to happens
with the "unbuddied" list, and the current version of
z3fold_reclaim_page() just doesn't have that code.
This patch fixes the processing of "stale" lists, with stale lists
having been introduced with the per-CPU unbuddied lists patch, which
is pretty recent.
To fix https://bugzilla.kernel.org/show_bug.cgi?id=196877, we'll have
to either backport per-CPU unbuddied lists plus the two fixes, or
propose a separate fix.

> What are the end-user visible effects of the bug?  Please always
> include this info when fixing bugs.

If page is NULL, clear_bit for page->private will result in a kernel crash.

> Should this fix be backported into -stable kernels?

No, this patch fixes the code that is not in any released kernel yet.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
