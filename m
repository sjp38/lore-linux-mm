Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 67C9D6B0036
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 11:06:52 -0400 (EDT)
Received: by mail-vc0-f170.google.com with SMTP id hy10so2443169vcb.1
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:06:52 -0700 (PDT)
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
        by mx.google.com with ESMTPS id sp1si1495701vec.83.2014.06.13.08.06.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 08:06:51 -0700 (PDT)
Received: by mail-ve0-f171.google.com with SMTP id jz11so3488603veb.16
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 08:06:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1402655819-14325-8-git-send-email-dh.herrmann@gmail.com>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com> <1402655819-14325-8-git-send-email-dh.herrmann@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 13 Jun 2014 08:06:31 -0700
Message-ID: <CALCETrWaUsq_D2Z1PwbbwQQWKrnsWTLOdUR6bqPuedi8ZHgvEQ@mail.gmail.com>
Subject: Re: [RFC v3 7/7] shm: isolate pinned pages when sealing files
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>

On Fri, Jun 13, 2014 at 3:36 AM, David Herrmann <dh.herrmann@gmail.com> wrote:
> When setting SEAL_WRITE, we must make sure nobody has a writable reference
> to the pages (via GUP or similar). We currently check references and wait
> some time for them to be dropped. This, however, might fail for several
> reasons, including:
>  - the page is pinned for longer than we wait
>  - while we wait, someone takes an already pinned page for read-access
>
> Therefore, this patch introduces page-isolation. When sealing a file with
> SEAL_WRITE, we copy all pages that have an elevated ref-count. The newpage
> is put in place atomically, the old page is detached and left alone. It
> will get reclaimed once the last external user dropped it.
>
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>

Won't this have unexpected effects?

Thread 1:  start read into mapping backed by fd

Thread 2:  SEAL_WRITE

Thread 1: read finishes.  now the page doesn't match the sealed page

Is this okay?  Or am I missing something?

Are there really things that keep unnecessary writable pins around?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
