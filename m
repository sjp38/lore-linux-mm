Message-ID: <4737B4AD.9070809@pobox.com>
Date: Sun, 11 Nov 2007 21:04:29 -0500
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove nopage
References: <20071112015643.GA9291@wotan.suse.de>
In-Reply-To: <20071112015643.GA9291@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, rth@twiddle.net, Jaya Kumar <jayakumar.lkml@gmail.com>, krh@redhat.com, stefanr@s5r6.in-berlin.de, rolandd@cisco.com, mshefty@ichips.intel.com, hal.rosenstock@gmail.com, avi@qumranet.com, mchehab@infradead.org, dgilbert@interlog.com, Greg Kroah-Hartman <greg@kroah.com>, Takashi Iwai <tiwai@suse.de>, perex@perex.cz, Karsten Wiese <annabellesgarden@yahoo.de>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Index: linux-2.6/sound/oss/via82cxxx_audio.c
> ===================================================================
> --- linux-2.6.orig/sound/oss/via82cxxx_audio.c
> +++ linux-2.6/sound/oss/via82cxxx_audio.c
> @@ -2099,8 +2099,7 @@ static void via_dsp_cleanup (struct via_
>  }
>  
>  
> -static struct page * via_mm_nopage (struct vm_area_struct * vma,
> -				    unsigned long address, int *type)
> +static int via_mm_fault (struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	struct via_info *card = vma->vm_private_data;
>  	struct via_channel *chan = &card->ch_out;
> @@ -2108,22 +2107,14 @@ static struct page * via_mm_nopage (stru
>  	unsigned long pgoff;
>  	int rd, wr;
>  
> -	DPRINTK ("ENTER, start %lXh, ofs %lXh, pgoff %ld, addr %lXh\n",
> -		 vma->vm_start,
> -		 address - vma->vm_start,
> -		 (address - vma->vm_start) >> PAGE_SHIFT,
> -		 address);
> -
> -        if (address > vma->vm_end) {
> -		DPRINTK ("EXIT, returning NOPAGE_SIGBUS\n");
> -		return NOPAGE_SIGBUS; /* Disallow mremap */
> -	}
> +	DPRINTK ("ENTER, pgoff %ld\n", vmf->pgoff);
> +
>          if (!card) {
> -		DPRINTK ("EXIT, returning NOPAGE_SIGBUS\n");
> -		return NOPAGE_SIGBUS;	/* Nothing allocated */
> +		DPRINTK ("EXIT, returning VM_FAULT_SIGBUS\n");
> +		return VM_FAULT_SIGBUS;	/* Nothing allocated */
>  	}
>  
> -	pgoff = vma->vm_pgoff + ((address - vma->vm_start) >> PAGE_SHIFT);
> +	pgoff = vmf->pgoff;
>  	rd = card->ch_in.is_mapped;
>  	wr = card->ch_out.is_mapped;
>  
> @@ -2150,9 +2141,8 @@ static struct page * via_mm_nopage (stru
>  	DPRINTK ("EXIT, returning page %p for cpuaddr %lXh\n",
>  		 dmapage, (unsigned long) chan->pgtbl[pgoff].cpuaddr);
>  	get_page (dmapage);
> -	if (type)
> -		*type = VM_FAULT_MINOR;
> -	return dmapage;
> +	vmf->page = dmapage;
> +	return 0;
>  }


Although the overall concept looks nice (ACK, good work), the above 
change does not build.  The code continues to reference via_mm_nopage(), 
which has been renamed to via_mm_fault() in your patch.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
