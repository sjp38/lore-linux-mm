From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2] x86/mm/pat: Change free_memtype() to free shrinking
 range
Date: Sun, 20 Dec 2015 10:27:51 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1512201025050.28591@nanos>
References: <1449678368-31793-1-git-send-email-toshi.kani@hpe.com> <1449678368-31793-3-git-send-email-toshi.kani@hpe.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449678368-31793-3-git-send-email-toshi.kani@hpe.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mingo@redhat.com, hpa@zytor.com, bp@alien8.de, stsp@list.ru, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>
List-Id: linux-mm.kvack.org

Toshi,

On Wed, 9 Dec 2015, Toshi Kani wrote:
> diff --git a/arch/x86/mm/pat_rbtree.c b/arch/x86/mm/pat_rbtree.c
> index 6393108..d6faef8 100644
> --- a/arch/x86/mm/pat_rbtree.c
> +++ b/arch/x86/mm/pat_rbtree.c
> @@ -107,7 +112,12 @@ static struct memtype *memtype_rb_exact_match(struct rb_root *root,
>  	while (match != NULL && match->start < end) {
>  		struct rb_node *node;
>  
> -		if (match->start == start && match->end == end)
> +		if ((match_type == MEMTYPE_EXACT_MATCH) &&
> +		    (match->start == start) && (match->end == end))
> +			return match;
> +
> +		if ((match_type == MEMTYPE_SHRINK_MATCH) &&
> +		    (match->start < start) && (match->end == end))

Confused. If we shrink a mapping then I'd expect that the start of the
mapping stays the same and the end changes. I certainly miss something
here, but if the above is correct, then it definitely needs a big fat
comment explaining it.

Thanks,

	tglx
