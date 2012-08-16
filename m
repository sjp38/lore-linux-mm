Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 3BFA76B0044
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 15:20:25 -0400 (EDT)
Date: Thu, 16 Aug 2012 12:20:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH, RFC 0/9] Introduce huge zero page
Message-Id: <20120816122023.c0e9bbc0.akpm@linux-foundation.org>
In-Reply-To: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu,  9 Aug 2012 12:08:11 +0300
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> During testing I noticed big (up to 2.5 times) memory consumption overhead
> on some workloads (e.g. ft.A from NPB) if THP is enabled.
> 
> The main reason for that big difference is lacking zero page in THP case.
> We have to allocate a real page on read page fault.
> 
> A program to demonstrate the issue:
> #include <assert.h>
> #include <stdlib.h>
> #include <unistd.h>
> 
> #define MB 1024*1024
> 
> int main(int argc, char **argv)
> {
>         char *p;
>         int i;
> 
>         posix_memalign((void **)&p, 2 * MB, 200 * MB);
>         for (i = 0; i < 200 * MB; i+= 4096)
>                 assert(p[i] == 0);
>         pause();
>         return 0;
> }
> 
> With thp-never RSS is about 400k, but with thp-always it's 200M.
> After the patcheset thp-always RSS is 400k too.

That's a pretty big improvement for a rather fake test case.  I wonder
how much benefit we'd see with real workloads?

Things are rather quiet at present, with summer and beaches and Kernel
Summit coming up.  Please resend these patches early next month and
let's see if we can get a bit of action happening?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
