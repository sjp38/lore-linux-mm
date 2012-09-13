Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id D7C1C6B016D
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:27:39 -0400 (EDT)
Date: Thu, 13 Sep 2012 12:27:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] nommu: remap_pfn_range: fix addr parameter check
Message-Id: <20120913122738.04eaceb3.akpm@linux-foundation.org>
In-Reply-To: <1347504057-5612-1-git-send-email-lliubbo@gmail.com>
References: <1347504057-5612-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, bhupesh.sharma@st.com, laurent.pinchart@ideasonboard.com, uclinux-dist-devel@blackfin.uclinux.org, linux-media@vger.kernel.org, dhowells@redhat.com, geert@linux-m68k.org, gerg@uclinux.org, stable@kernel.org, gregkh@linuxfoundation.org, Hugh Dickins <hughd@google.com>

On Thu, 13 Sep 2012 10:40:57 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> The addr parameter may not page aligned eg. when it's come from
> vfb_mmap():vma->vm_start in video driver.
> 
> This patch fix the check in remap_pfn_range() else some driver like v4l2 will
> fail in this function while calling mmap() on nommu arch like blackfin and st.
> 
> Reported-by: Bhupesh SHARMA <bhupesh.sharma@st.com>
> Reported-by: Scott Jiang <scott.jiang.linux@gmail.com>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/nommu.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/nommu.c b/mm/nommu.c
> index d4b0c10..5d6068b 100644
> --- a/mm/nommu.c
> +++ b/mm/nommu.c
> @@ -1819,7 +1819,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
>  int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
>  		unsigned long pfn, unsigned long size, pgprot_t prot)
>  {
> -	if (addr != (pfn << PAGE_SHIFT))
> +	if ((addr & PAGE_MASK) != (pfn << PAGE_SHIFT))
>  		return -EINVAL;
>  
>  	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;

hm, what is the right thing to do here?

Yes, the MMU version of remap_pfn_range() does permit non-page-aligned
`addr' (at least, if the userspace maaping is a non-COW one).  But I
suspect that was an implementation accident - it is a nonsensical thing
to do, isn't it?  The MMU cannot map a bunch of kernel pages onto a
non-page-aligned userspace address.

So I'm thinking that we should declare ((addr & ~PAGE_MASK) != 0) to be
a caller bug, and fix up this regrettably unidentified v4l driver?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
