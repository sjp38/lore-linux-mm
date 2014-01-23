Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 64FE16B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 13:07:20 -0500 (EST)
Received: by mail-lb0-f176.google.com with SMTP id w7so1704783lbi.7
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 10:07:19 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id vr3si7255715lbb.61.2014.01.23.10.07.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 10:07:18 -0800 (PST)
Message-ID: <52E15A53.5020007@parallels.com>
Date: Thu, 23 Jan 2014 22:07:15 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Ignore VM_SOFTDIRTY on VMA merging, v2
References: <20140122190816.GB4963@suse.de> <20140122191928.GQ1574@moon> <20140122223325.GA30637@moon> <20140123095541.GD4963@suse.de> <20140123103606.GU1574@moon> <20140123121555.GV1574@moon> <20140123125543.GW1574@moon> <20140123151445.GX1574@moon>
In-Reply-To: <20140123151445.GX1574@moon>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, gnome@rvzt.net, grawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On 01/23/2014 07:14 PM, Cyrill Gorcunov wrote:

> I think setting up dirty bit inside vma_merge() body is a big hammer
> which should not be used, but it's up to caller of vma_merge() to figure
> out if dirty bit should be set or not if merge successed. Thus softdirty
> vma bit should be (and it already is) set at the end of mmap_region and do_brk
> routines. So patch could be simplified (below). Pavel, what do you think?

Looks correct, thank you!

Acked-by: Pavel Emelyanov <xemul@parallels,com>

> ---
> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Subject: [PATCH] mm: Ignore VM_SOFTDIRTY on VMA merging, v2
> 
> VM_SOFTDIRTY bit affects vma merge routine: if two VMAs has all
> bits in vm_flags matched except dirty bit the kernel can't longer
> merge them and this forces the kernel to generate new VMAs instead.
> 
> It finally may lead to the situation when userspace application
> reaches vm.max_map_count limit and get crashed in worse case
> 
>  | (gimp:11768): GLib-ERROR **: gmem.c:110: failed to allocate 4096 bytes
>  |
>  | (file-tiff-load:12038): LibGimpBase-WARNING **: file-tiff-load: gimp_wire_read(): error
>  | xinit: connection to X server lost
>  |
>  | waiting for X server to shut down
>  | /usr/lib64/gimp/2.0/plug-ins/file-tiff-load terminated: Hangup
>  | /usr/lib64/gimp/2.0/plug-ins/script-fu terminated: Hangup
>  | /usr/lib64/gimp/2.0/plug-ins/script-fu terminated: Hangup
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=67651
> https://bugzilla.gnome.org/show_bug.cgi?id=719619#c0
> 
> Initial problem came from missed VM_SOFTDIRTY in do_brk() routine
> but even if we would set up VM_SOFTDIRTY here, there is still a way to
> prevent VMAs from merging: one can call
> 
>  | echo 4 > /proc/$PID/clear_refs
> 
> and clear all VM_SOFTDIRTY over all VMAs presented in memory map,
> then new do_brk() will try to extend old VMA and finds that dirty
> bit doesn't match thus new VMA will be generated.
> 
> As discussed to Pavel, the right approach should be to ignore
> VM_SOFTDIRTY bit when we're trying to merge VMAs and if merge
> successed we mark extended VMA with dirty bit where needed.
> 
> v2: Don't mark VMA as dirty inside vma_merge() body, it's up
>     to calling code to set up dirty bit where needed.
> 
> Reported-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> CC: Pavel Emelyanov <xemul@parallels.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/mmap.c |   12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.git/mm/mmap.c
> ===================================================================
> --- linux-2.6.git.orig/mm/mmap.c
> +++ linux-2.6.git/mm/mmap.c
> @@ -893,7 +893,15 @@ again:			remove_next = 1 + (end > next->
>  static inline int is_mergeable_vma(struct vm_area_struct *vma,
>  			struct file *file, unsigned long vm_flags)
>  {
> -	if (vma->vm_flags ^ vm_flags)
> +	/*
> +	 * VM_SOFTDIRTY should not prevent from VMA merging, if we
> +	 * match the flags but dirty bit -- the caller should mark
> +	 * merged VMA as dirty. If dirty bit won't be excluded from
> +	 * comparison, we increase pressue on the memory system forcing
> +	 * the kernel to generate new VMAs when old one could be
> +	 * extended instead.
> +	 */
> +	if ((vma->vm_flags ^ vm_flags) & ~VM_SOFTDIRTY)
>  		return 0;
>  	if (vma->vm_file != file)
>  		return 0;
> @@ -1082,7 +1090,7 @@ static int anon_vma_compatible(struct vm
>  	return a->vm_end == b->vm_start &&
>  		mpol_equal(vma_policy(a), vma_policy(b)) &&
>  		a->vm_file == b->vm_file &&
> -		!((a->vm_flags ^ b->vm_flags) & ~(VM_READ|VM_WRITE|VM_EXEC)) &&
> +		!((a->vm_flags ^ b->vm_flags) & ~(VM_READ|VM_WRITE|VM_EXEC|VM_SOFTDIRTY)) &&
>  		b->vm_pgoff == a->vm_pgoff + ((b->vm_start - a->vm_start) >> PAGE_SHIFT);
>  }
>  
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
