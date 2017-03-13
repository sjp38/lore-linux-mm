Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECD66B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 10:16:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f21so300578274pgi.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:16:23 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e7si11588896pfd.150.2017.03.13.07.16.22
        for <linux-mm@kvack.org>;
        Mon, 13 Mar 2017 07:16:22 -0700 (PDT)
Date: Mon, 13 Mar 2017 14:16:04 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] mm, gup: fix typo in gup_p4d_range()
Message-ID: <20170313141603.GA10026@leverpostej>
References: <20170313052213.11411-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170313052213.11411-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 13, 2017 at 08:22:13AM +0300, Kirill A. Shutemov wrote:
> gup_p4d_range() should call gup_pud_range(), not itself.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
> Fixes: c2febafc6773 ("mm: convert generic code to 5-level paging")
> ---
>  mm/gup.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index c74bad1bf6e8..04aa405350dc 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1455,7 +1455,7 @@ static int gup_p4d_range(pgd_t pgd, unsigned long addr, unsigned long end,
>  			if (!gup_huge_pd(__hugepd(p4d_val(p4d)), addr,
>  					 P4D_SHIFT, next, write, pages, nr))
>  				return 0;
> -		} else if (!gup_p4d_range(p4d, addr, next, write, pages, nr))
> +		} else if (!gup_pud_range(p4d, addr, next, write, pages, nr))
>  			return 0;
>  	} while (p4dp++, addr = next, addr != end);

I just hit this on arm64, where the compiler was nice enough to warn me
that something was amiss:

mm/gup.c:1412:12: warning: 'gup_pud_range' defined but not used [-Wunused-function]
 static int gup_pud_range(p4d_t p4d, unsigned long addr, unsigned long end,
            ^

FWIW:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
