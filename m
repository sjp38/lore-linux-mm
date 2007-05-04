Date: Thu, 3 May 2007 20:28:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] MM: use DIV_ROUND_UP() in mm/memory.c
Message-Id: <20070503202808.4f835c8a.akpm@linux-foundation.org>
In-Reply-To: <200704241610.23342.eike-kernel@sf-tec.de>
References: <200704241610.23342.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2007 16:10:22 +0200 Rolf Eike Beer <eike-kernel@sf-tec.de> wrote:

> This should make no difference in behaviour.
> 
> Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de>
> 
> ---
> commit 64aa7c3136258d3abc76354b5f83b9a9575169c0
> tree 8037adc04b57cd6150456399b7caccf99489385a
> parent bf0bd376f79cadb4f8cd454db1723eb9be0aabc1
> author Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 24 Apr 2007 16:05:40 +0200
> committer Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 24 Apr 2007 16:05:40 
> +0200
> 
>  mm/memory.c |    7 +++----
>  1 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e7066e7..45bba1f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1838,12 +1838,11 @@ void unmap_mapping_range(struct address_space 
> *mapping,
>  {
>  	struct zap_details details;
>  	pgoff_t hba = holebegin >> PAGE_SHIFT;
> -	pgoff_t hlen = (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +	pgoff_t hlen = DIV_ROUND_UP(holelen, PAGE_SIZE);
>  
>  	/* Check for overflow. */
>  	if (sizeof(holelen) > sizeof(hlen)) {
> -		long long holeend =
> -			(holebegin + holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
> +		long long holeend = DIV_ROUND_UP(holebegin + holelen, PAGE_SIZE);
>  		if (holeend & ~(long long)ULONG_MAX)
>  			hlen = ULONG_MAX - hba + 1;
>  	}
> @@ -2592,7 +2591,7 @@ int make_pages_present(unsigned long addr, unsigned long 
> end)
>  	write = (vma->vm_flags & VM_WRITE) != 0;
>  	BUG_ON(addr >= end);
>  	BUG_ON(end > vma->vm_end);
> -	len = (end+PAGE_SIZE-1)/PAGE_SIZE-addr/PAGE_SIZE;
> +	len = DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;
>  	ret = get_user_pages(current, current->mm, addr,
>  			len, write, 0, NULL, NULL);
>  	if (ret < 0)

The patch is wordwrapped.  Please fix your MUA.

More seriously, on i386:

   text    data     bss     dec     hex filename
  15509      27      28   15564    3ccc mm/memory.o	(before)
  15561      27      28   15616    3d00 mm/memory.o	(after)

I'm not sure why - some of the quantities which we're dividing by there are
64-bit and perhaps the compiler has decided not to do shifting.

Please always check the before-and-after .text size from now on?

Now I'm worried about all the other DIV_ROUND_UP() conversions we did.  We
should get in there and work out why it went bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
