Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52F7C6B0033
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 23:12:19 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d12so3616984qki.17
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 20:12:19 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 66si15325715qkx.160.2018.04.07.20.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Apr 2018 20:12:18 -0700 (PDT)
Date: Sun, 8 Apr 2018 06:12:13 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 1/3] mm/gup_benchmark: handle gup failures
Message-ID: <20180408060935-mutt-send-email-mst@kernel.org>
References: <1522962072-182137-1-git-send-email-mst@redhat.com>
 <1522962072-182137-3-git-send-email-mst@redhat.com>
 <CA+55aFywfktB83dERzYaC1NCYxD+Lg+NRft5ypjmbbcM_qdxpQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFywfktB83dERzYaC1NCYxD+Lg+NRft5ypjmbbcM_qdxpQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>, stable <stable@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sat, Apr 07, 2018 at 01:08:43PM -0700, Linus Torvalds wrote:
> On Thu, Apr 5, 2018 at 2:03 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> >                 nr = get_user_pages_fast(addr, nr, gup->flags & 1, pages + i);
> > -               i += nr;
> > +               if (nr > 0)
> > +                       i += nr;
> 
> Can we just make this robust while at it, and just make it
> 
>         if (nr <= 0)
>                 break;
> 
> instead? Then it doesn't care about zero vs negative error, and
> wouldn't get stuck in an endless loop if it got zero.
> 
>              Linus

I don't mind though it alredy breaks out on the next cycle:

                if (nr != gup->nr_pages_per_call)
                        break;

the only issue is i getting corrupted when nr < 0;
