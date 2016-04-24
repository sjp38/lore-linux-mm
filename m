Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1D496B0005
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 14:49:21 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id fn8so159736576igb.1
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 11:49:21 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id l132si8316762ioa.213.2016.04.24.11.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Apr 2016 11:49:20 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id u185so21288285iod.2
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 11:49:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <146148524340.530.2185181436065386014.stgit@zurg>
References: <146148524340.530.2185181436065386014.stgit@zurg>
Date: Sun, 24 Apr 2016 11:49:20 -0700
Message-ID: <CA+55aFzPY23bL7oRaH8=C=CQ5egcWCEwieD5rhm5xV=Rv7T7RQ@mail.gmail.com>
Subject: Re: [PATCH] mm: enable RLIMIT_DATA by default with workaround for valgrind
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Christian Borntraeger <borntraeger@de.ibm.com>

On Sun, Apr 24, 2016 at 1:07 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>
> This patch checks current usage also against rlim_max if rlim_cur is zero.
> Size of brk is still checked against rlim_cur, so this part is completely
> compatible - zero rlim_cur forbids brk() but allows private mmap().

The logic looks reasonable to me. My first reaction was that "but then
any process can set the limit to zero, and actually increase limits",
but witht he hard limit always being checked that's ok - the process
could have just set the soft limit to the hard limit instead.

The only part I don't like in that patch is the disgusting line breaking.

Breaking lines in the middle of a comparison is just nasty and wrong.
That code should have been written as

        if (rlimit(RLIMIT_DATA) != 0)
                return false;
        return mm->data_vm + npages <= rlimit_max(RLIMIT_DATA) >> PAGE_SHIFT;

or something like that. Since you removed the pr_warn_once(), you
should remove ignore_rlimit_data too.

Alternatively, if you want to keep ignore_rlimit_data, then you should
have kept the warning too. Making the actual rlimit data check an
inline helper function and having the ignore_rlimit_data check (and
printout) in the caller would make it pretty.

Because breaking lines in the middle of an actual expression is just
completely wrong. It's much worse than having a long line.

(The exception to that "middle of an expression" is breaking lines at
logical expression boundaries: things like adding up several
independent expressions, and having it be

     sum = a +
           b +
           c;

or be something like

     if (a ||
        b ||
        c)
            do_something():

where 'a', 'b' and 'c' are complex but fairly independent expressions).

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
