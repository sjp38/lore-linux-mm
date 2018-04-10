Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED14B6B0007
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 20:38:23 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id az8-v6so3748368plb.2
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 17:38:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f4-v6si1415307plm.378.2018.04.09.17.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 17:38:22 -0700 (PDT)
Date: Mon, 9 Apr 2018 17:38:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/3] mm/gup_benchmark: handle gup failures
Message-Id: <20180409173821.889f0a2dd4385ee2428c16b8@linux-foundation.org>
In-Reply-To: <20180408060935-mutt-send-email-mst@kernel.org>
References: <1522962072-182137-1-git-send-email-mst@redhat.com>
	<1522962072-182137-3-git-send-email-mst@redhat.com>
	<CA+55aFywfktB83dERzYaC1NCYxD+Lg+NRft5ypjmbbcM_qdxpQ@mail.gmail.com>
	<20180408060935-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>, stable <stable@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sun, 8 Apr 2018 06:12:13 +0300 "Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Sat, Apr 07, 2018 at 01:08:43PM -0700, Linus Torvalds wrote:
> > On Thu, Apr 5, 2018 at 2:03 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > >
> > >                 nr = get_user_pages_fast(addr, nr, gup->flags & 1, pages + i);
> > > -               i += nr;
> > > +               if (nr > 0)
> > > +                       i += nr;
> > 
> > Can we just make this robust while at it, and just make it
> > 
> >         if (nr <= 0)
> >                 break;
> > 
> > instead? Then it doesn't care about zero vs negative error, and
> > wouldn't get stuck in an endless loop if it got zero.
> > 
> >              Linus
> 
> I don't mind though it alredy breaks out on the next cycle:
> 
>                 if (nr != gup->nr_pages_per_call)
>                         break;
> 
> the only issue is i getting corrupted when nr < 0;
> 

It does help readability to have the thing bail out as soon as we see
something go bad.  This?

--- a/mm/gup_benchmark.c~mm-gup_benchmark-handle-gup-failures-fix
+++ a/mm/gup_benchmark.c
@@ -41,8 +41,9 @@ static int __gup_benchmark_ioctl(unsigne
 		}
 
 		nr = get_user_pages_fast(addr, nr, gup->flags & 1, pages + i);
-		if (nr > 0)
-			i += nr;
+		if (nr <= 0)
+			break;
+		i += nr;
 	}
 	end_time = ktime_get();
 
_
