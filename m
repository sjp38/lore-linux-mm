Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3528F6B02F7
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 02:02:41 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id w196so283150oia.17
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 23:02:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k35si127424otc.104.2018.01.02.23.02.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 23:02:40 -0800 (PST)
Date: Wed, 3 Jan 2018 01:02:38 -0600
From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: kernel BUG at ./include/linux/mm.h:LINE! (3)
Message-ID: <20180103010238.1e510ac2@lembas.zaitcev.lan>
In-Reply-To: <20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
References: <20171228160346.6406d52df0d9afe8cf7a0862@linux-foundation.org>
	<20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-usb@vger.kernel.org, zaitcev@redhat.com

On Fri, 29 Dec 2017 16:24:20 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Looks like MON_IOCT_RING_SIZE reallocates ring buffer without any
> serialization wrt mon_bin_vma_fault(). By the time of get_page() the page
> may be freed.

Okay. Who knew that you could fork while holding an open descriptor. :-)

> The patch below seems help the crash to go away, but I *think* more work
> is required. For instance, after ring buffer reallocation the old pages
> will stay mapped. Nothing pulls them.

You know, this bothered me all these years too, but I was assured
back in the day (as much as I can remember), that doing get_page()
in the .fault() is just the right thing. In my defense, you can
see other drivers doing it, such as:

./drivers/char/agp/alpha-agp.c
./drivers/hsi/clients/cmt_speech.c

I'd appreciate insight from someone who knows how VM subsystem works.

Now, about the code:

> diff --git a/drivers/usb/mon/mon_bin.c b/drivers/usb/mon/mon_bin.c
> index f6ae753ab99b..ac168fecf04f 100644
> --- a/drivers/usb/mon/mon_bin.c
> +++ b/drivers/usb/mon/mon_bin.c
> @@ -1228,15 +1228,24 @@ static void mon_bin_vma_close(struct vm_area_struct *vma)
>  static int mon_bin_vma_fault(struct vm_fault *vmf)
>  {
>  	struct mon_reader_bin *rp = vmf->vma->vm_private_data;
> -	unsigned long offset, chunk_idx;
> +	unsigned long offset, chunk_idx, flags;
>  	struct page *pageptr;
>  
> +	mutex_lock(&rp->fetch_lock);
> +	spin_lock_irqsave(&rp->b_lock, flags);
>  	offset = vmf->pgoff << PAGE_SHIFT;
> -	if (offset >= rp->b_size)
> +	if (offset >= rp->b_size) {
> +		spin_unlock_irqrestore(&rp->b_lock, flags);
> +		mutex_unlock(&rp->fetch_lock);
>  		return VM_FAULT_SIGBUS;
> +	}
>  	chunk_idx = offset / CHUNK_SIZE;
> +
>  	pageptr = rp->b_vec[chunk_idx].pg;
>  	get_page(pageptr);
> +	spin_unlock_irqrestore(&rp->b_lock, flags);
> +	mutex_unlock(&rp->fetch_lock);
> +
>  	vmf->page = pageptr;
>  	return 0;
>  }

I think that grabbing the spinlock is not really necessary in
this case. The ->b_lock is designed for things that are accessed
from interrupts that Host Controller Driver serves -- mostly
various pointers. By defintion it's not covering things that
are related to re-allocation. Now, the re-allocation itself
grabs it, because it resets indexes into the new buffer, but
does not appear to apply here, does it now?

-- Pete

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
