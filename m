Date: Mon, 29 Jan 2007 12:11:15 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-ID: <20070129111115.GA14504@wotan.suse.de>
References: <20070129081905.23584.97878.sendpatchset@linux.site> <20070129082030.23584.72376.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070129082030.23584.72376.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 29, 2007 at 11:33:03AM +0100, Nick Piggin wrote:
> +		} else {
> +			char *src, *dst;
> +			src = kmap(src_page);
> +			dst = kmap(page);
> +			memcpy(dst + offset,
> +				src + ((unsigned long)buf & ~PAGE_CACHE_MASK),
> +				bytes);
> +			kunmap(page);
> +			kunmap(src_page);
> +			copied = bytes;
> +		}
>  		flush_dcache_page(page);

Hmm, I guess these should use kmap_atomic with KM_USER[01]?

The kmap is from an earlier iteration that wanted to sleep
with the page mapped into kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
