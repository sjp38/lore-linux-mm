Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 482FA6B0044
	for <linux-mm@kvack.org>; Fri,  4 May 2012 00:26:51 -0400 (EDT)
Message-ID: <4FA35A85.4070804@kernel.org>
Date: Fri, 04 May 2012 13:26:45 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
References: <20120501132409.GA22894@lizard> <20120501132620.GC24226@lizard>
In-Reply-To: <20120501132620.GC24226@lizard>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On 05/01/2012 10:26 PM, Anton Vorontsov wrote:

> This is specially "blended" attribute, the event triggers when kernel
> decides that we're close to the low memory threshold. Userspace should
> not expect very precise meaning of low memory situation, mostly, it's
> just a guess on the kernel's side.
> 
> Well, this is the same as userland should not know or care how exactly
> kernel manages the memory, or assume that memory management behaviour
> is a part of the "ABI". So, all the 'low memory' is just guessing, but
> we're trying to do our best. It might be that we will end up with two
> or three variations of 'low memory' thresholds, and all of them would


First of all, your calculation for available pages is very simple and 
it's very specific of recent mobile phone.
But recent systems have various devices.
For example,

SSD : very fast server SSD which has lots of internal ram so that write is very fast.
thumb usb : very slow whihc has small ram 

1) We can consider anon pages and dirty pages as available pages.

       	SSD 	thumb usb	
rootfs 	 0
swap	 0

2) We can consider anon pages as available pages but dirty page doesn't

       	SSD 	thumb usb	
rootfs		   O 	 
swap	 0

3) We can consider dirty pages as available pages but anon doesn't

       	SSD 	thumb usb	
rootfs 	 O
swap	 	   O

4) We can't consider dirty pages and anon pages as available pages

       	SSD 	thumb usb	
rootfs 	 	   0
swap	 	   0

5) If we use zram as swap?
6) Another idea. If we use both zram and swap device(eMMC), then when zram is full,
   we writes zram pages into swap device with align cluster size?

I mean we can select various option to define low memory state.

> be useful for different use cases.


Why should we do it in kernel side?
If vmevent will have VMEVENT_ATTR_[FILE|MOCK|DIRTY|WRITEBACK|SHMEM|ANON|SWAP]_PAGES
and so on which is needed by calculation, we can calculate it in userspace without
forking /proc/vmstat to see it. So I think there is no problem to do it in userspace.

And even though we can solve above problem, it is possible to show up another new "blended" attribute
in future and it will suffer same problem, again. So IMHO, let's leave vmevent as it is which is 
very raw attribute and let's do blended attribute in user space.

> 
> For this implementation, we assume that there's a low memory situation
> for the N pages threshold when we have neither N pages of completely
> free pages, nor we have N reclaimable pages in the cache. This
> effectively means, that if userland expects to allocate N pages, it
> would consume all the free pages, and any further allocations (above
> N) would start draining caches.
> 
> In the worst case, prior to hitting the threshold, we might have only
> N pages in cache, and nearly no memory as free pages.
> 
> The same 'low memory' meaning is used in the current Android Low
> Memory Killer driver.
> 
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
> ---
>  include/linux/vmevent.h              |    7 ++++++
>  mm/vmevent.c                         |   40 ++++++++++++++++++++++++++++++++++
>  tools/testing/vmevent/vmevent-test.c |   12 +++++++++-
>  3 files changed, 58 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
> index aae0d24..9bfa244 100644
> --- a/include/linux/vmevent.h
> +++ b/include/linux/vmevent.h
> @@ -10,6 +10,13 @@ enum {
>  	VMEVENT_ATTR_NR_AVAIL_PAGES	= 1UL,
>  	VMEVENT_ATTR_NR_FREE_PAGES	= 2UL,
>  	VMEVENT_ATTR_NR_SWAP_PAGES	= 3UL,
> +	/*
> +	 * This is specially blended attribute, the event triggers
> +	 * when kernel decides that we're close to the low memory threshold.
> +	 * Don't expect very precise meaning of low memory situation, mostly,
> +	 * it's just a guess on the kernel's side.
> +	 */
> +	VMEVENT_ATTR_LOWMEM_PAGES	= 4UL,
>  
>  	VMEVENT_ATTR_MAX		/* non-ABI */
>  };
> diff --git a/mm/vmevent.c b/mm/vmevent.c
> index b312236..d278a25 100644
> --- a/mm/vmevent.c
> +++ b/mm/vmevent.c
> @@ -68,10 +68,50 @@ static u64 vmevent_attr_avail_pages(struct vmevent_watch *watch,
>  	return totalram_pages;
>  }
>  
> +/*
> + * Here's some implementation details for the "low memory" meaning.
> + *
> + * (The explanation is not in the header file as userland should not
> + * know these details, nor it should assume that the meaning will
> + * always be the same. As well as it should not know how exactly kernel
> + * manages the memory, or assume that memory management behaviour is a
> + * part of the "ABI". So, all the 'low memory' is just guessing, but
> + * we're trying to do our best.)
> + *
> + * For this implementation, we assume that there's a low memory situation
> + * for the N pages threshold when we have neither N pages of completely
> + * free pages, nor we have N reclaimable pages in the cache. This
> + * effectively means, that if userland expects to allocate N pages, it
> + * would consume all the free pages, and any further allocations (above
> + * N) would start draining caches.
> + *
> + * In the worst case, prior hitting the threshold, we might have only
> + * N pages in cache, and nearly no memory as free pages.
> + */
> +static u64 vmevent_attr_lowmem_pages(struct vmevent_watch *watch,
> +				     struct vmevent_attr *attr)
> +{
> +	int free = global_page_state(NR_FREE_PAGES);
> +	int file = global_page_state(NR_FILE_PAGES) -
> +		   global_page_state(NR_SHMEM); /* TODO: account locked pages */
> +	int val = attr->value;
> +
> +	/*
> +	 * For convenience we return 0 or attr value (instead of 0/1), it
> +	 * makes it easier for vmevent_match() to cope with blended
> +	 * attributes, plus userland might use the value to find out which
> +	 * threshold triggered.
> +	 */
> +	if (free < val && file < val)
> +		return val;
> +	return 0;
> +}
> +
>  static vmevent_attr_sample_fn attr_samplers[] = {
>  	[VMEVENT_ATTR_NR_AVAIL_PAGES]   = vmevent_attr_avail_pages,
>  	[VMEVENT_ATTR_NR_FREE_PAGES]    = vmevent_attr_free_pages,
>  	[VMEVENT_ATTR_NR_SWAP_PAGES]    = vmevent_attr_swap_pages,
> +	[VMEVENT_ATTR_LOWMEM_PAGES]     = vmevent_attr_lowmem_pages,
>  };
>  
>  static u64 vmevent_sample_attr(struct vmevent_watch *watch, struct vmevent_attr *attr)
> diff --git a/tools/testing/vmevent/vmevent-test.c b/tools/testing/vmevent/vmevent-test.c
> index fd9a174..c61aed7 100644
> --- a/tools/testing/vmevent/vmevent-test.c
> +++ b/tools/testing/vmevent/vmevent-test.c
> @@ -33,7 +33,7 @@ int main(int argc, char *argv[])
>  
>  	config = (struct vmevent_config) {
>  		.sample_period_ns	= 1000000000L,
> -		.counter		= 6,
> +		.counter		= 7,
>  		.attrs			= {
>  			{
>  				.type	= VMEVENT_ATTR_NR_FREE_PAGES,
> @@ -59,6 +59,13 @@ int main(int argc, char *argv[])
>  				.type	= VMEVENT_ATTR_NR_SWAP_PAGES,
>  			},
>  			{
> +				.type	= VMEVENT_ATTR_LOWMEM_PAGES,
> +				.state	= VMEVENT_ATTR_STATE_VALUE_LT |
> +					  VMEVENT_ATTR_STATE_VALUE_EQ |
> +					  VMEVENT_ATTR_STATE_ONE_SHOT,
> +				.value	= phys_pages / 2,
> +			},
> +			{
>  				.type	= 0xffff, /* invalid */
>  			},
>  		},
> @@ -108,6 +115,9 @@ int main(int argc, char *argv[])
>  			case VMEVENT_ATTR_NR_SWAP_PAGES:
>  				printf("  VMEVENT_ATTR_NR_SWAP_PAGES: %Lu\n", attr->value);
>  				break;
> +			case VMEVENT_ATTR_LOWMEM_PAGES:
> +				printf("  VMEVENT_ATTR_LOWMEM_PAGES: %Lu\n", attr->value);
> +				break;
>  			default:
>  				printf("  Unknown attribute: %Lu\n", attr->value);
>  			}



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
