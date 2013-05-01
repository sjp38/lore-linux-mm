Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 759F16B0179
	for <linux-mm@kvack.org>; Wed,  1 May 2013 07:05:41 -0400 (EDT)
Date: Wed, 1 May 2013 12:05:34 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH 5/9] ARM64: mm: Add support for flushing huge pages.
Message-ID: <20130501110534.GD22796@mudshark.cambridge.arm.com>
References: <1367339448-21727-1-git-send-email-steve.capper@linaro.org>
 <1367339448-21727-6-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367339448-21727-6-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <Catalin.Marinas@arm.com>

Hi Steve,

On Tue, Apr 30, 2013 at 05:30:44PM +0100, Steve Capper wrote:
> The code to flush the dcache of a dirty page, __flush_dcache_page,
> will only flush the head of a HugeTLB/THP page.
> 
> This patch adjusts __flush_dcache_page such that the order of the
> compound page is used to determine the size of area to flush.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>
> ---
>  arch/arm64/mm/flush.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
> index 88611c3..71c182d 100644
> --- a/arch/arm64/mm/flush.c
> +++ b/arch/arm64/mm/flush.c
> @@ -72,7 +72,8 @@ void copy_to_user_page(struct vm_area_struct *vma, struct page *page,
>  
>  void __flush_dcache_page(struct page *page)
>  {
> -	__flush_dcache_area(page_address(page), PAGE_SIZE);
> +	size_t page_size = PAGE_SIZE << compound_order(page);
> +	__flush_dcache_area(page_address(page), page_size);
>  }

This penalises flush_dcache_page, while it might only be required for
__sync_icache_dcache (called when installing executable ptes).

Now, the job of flush_dcache_page is to deal with D-side aliases between
concurrent user and kernel mappings. On arm64, D-side aliasing is not a
problem so in theory flush_dcache_page could be a nop (well, a clear_bit,
but close enough).

The reason that flush_dcache_page *isn't* currently a nop, is because we
have harvard caches, so if we end up in a situation where the kernel is
writing executable text to a page which is also mapped into userspace (i.e.
there won't be a subsequent call to set_pte), then the user will execute
junk if we don't flush/invalidate things here.

This might be overkill. I can't think of a scenario where the above is true,
but I'm no mm expert, so it would be great if somebody else could chime in
to confirm/rubbish out suspicions...

Cheers,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
