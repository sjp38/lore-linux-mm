Received: by uproxy.gmail.com with SMTP id k40so79215ugc
        for <linux-mm@kvack.org>; Wed, 08 Feb 2006 23:00:47 -0800 (PST)
Message-ID: <aec7e5c30602082300i6257606csdc005e6a442bfec5@mail.gmail.com>
Date: Thu, 9 Feb 2006 16:00:47 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] Dynamically allocated pageflags
In-Reply-To: <200602022111.32930.ncunningham@cyclades.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <200602022111.32930.ncunningham@cyclades.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@cyclades.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Nigel,

On 2/2/06, Nigel Cunningham <ncunningham@cyclades.com> wrote:
> Hi everyone.
>
> This is my latest revision of the dynamically allocated pageflags patch.
>
> The patch is useful for kernel space applications that sometimes need to flag
> pages for some purpose, but don't otherwise need the retain the state. A prime
> example is suspend-to-disk, which needs to flag pages as unsaveable, allocated
> by suspend-to-disk and the like while it is working, but doesn't need to
> retain any of this state between cycles.
>
> Since the last revision, I have switched to using per-zone bitmaps within each
> bitmap.
>
> I know that I could still add hotplug memory support. Is there anything else
> missing?

I like the idea of the patch, but the code looks a bit too complicated
IMO. What is wrong with using vmalloc() to allocate a virtual
contiguous range of 0-order pages (one bit per page), and then use the
functions in linux/bitmap.h...? Or maybe I'm misunderstanding.

A system that has 2 GB RAM and 4 KB pages would use 64 KB per bitmap
(one bitmap per node), which is not so bad memory wise if you plan to
use all bits.

OTOH, if your plan is to use a single bit here and there, and leave
most of the bits unused then some kind of tree is probably better.

Or does the kernel already implement some kind of data structure that
never consumes _that_ much more space than a bitmap when fully used,
and saves a lot of memory when just sparsely populated?

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
