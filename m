Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 517066B0028
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 16:08:46 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x7so1526724iob.21
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 13:08:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e84-v6sor5927785itd.0.2018.04.07.13.08.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Apr 2018 13:08:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1522962072-182137-3-git-send-email-mst@redhat.com>
References: <1522962072-182137-1-git-send-email-mst@redhat.com> <1522962072-182137-3-git-send-email-mst@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 7 Apr 2018 13:08:43 -0700
Message-ID: <CA+55aFywfktB83dERzYaC1NCYxD+Lg+NRft5ypjmbbcM_qdxpQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] mm/gup_benchmark: handle gup failures
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>, stable <stable@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Thu, Apr 5, 2018 at 2:03 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>
>                 nr = get_user_pages_fast(addr, nr, gup->flags & 1, pages + i);
> -               i += nr;
> +               if (nr > 0)
> +                       i += nr;

Can we just make this robust while at it, and just make it

        if (nr <= 0)
                break;

instead? Then it doesn't care about zero vs negative error, and
wouldn't get stuck in an endless loop if it got zero.

             Linus
