Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id AF5B36B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 16:45:11 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id 6so699556bkj.1
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 13:45:11 -0800 (PST)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id ar3si358148bkc.223.2014.01.23.13.45.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 13:45:10 -0800 (PST)
Received: by mail-lb0-f182.google.com with SMTP id w7so1894687lbi.41
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 13:45:10 -0800 (PST)
Date: Fri, 24 Jan 2014 01:45:05 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Ignore VM_SOFTDIRTY on VMA merging, v2
Message-ID: <20140123214505.GA1992@moon>
References: <20140122190816.GB4963@suse.de>
 <20140122191928.GQ1574@moon>
 <20140122223325.GA30637@moon>
 <20140123095541.GD4963@suse.de>
 <20140123103606.GU1574@moon>
 <20140123121555.GV1574@moon>
 <20140123125543.GW1574@moon>
 <20140123151445.GX1574@moon>
 <20140123130235.61e2eca44d92b37936955ff1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140123130235.61e2eca44d92b37936955ff1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Emelyanov <xemul@parallels.com>, Mel Gorman <mgorman@suse.de>, gnome@rvzt.net, grawoc@darkrefraction.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Thu, Jan 23, 2014 at 01:02:35PM -0800, Andrew Morton wrote:
> On Thu, 23 Jan 2014 19:14:45 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> 
> > VM_SOFTDIRTY bit affects vma merge routine: if two VMAs has all
> > bits in vm_flags matched except dirty bit the kernel can't longer
> > merge them and this forces the kernel to generate new VMAs instead.
> 
> Do you intend to alter the brk() and binprm code to set VM_SOFTDIRTY?

brk() will be "dirtified" now with this merge fix.
brk
  do_brk
    out:
	...
	vma->vm_flags |= VM_SOFTDIRTY;

this will work even if vma get merged, the problem was that earlier
we tried to merge without VM_SOFTDIRTY flag. And matcher failed.

do_brk
  flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
	vma = vma_merge(mm, prev, addr, addr + len, flags,
					NULL, NULL, pgoff, NULL);
	if (vma)
		goto out;
...
out:
	...
	vma->vm_flags |= VM_SOFTDIRTY;

That said I'm not really sure now if I should alert @flags in code above.
Should I add VM_SOFTDIRTY into @flags for clarity?

Same for binprm -- the vma allocated for bprm->vma is dirtified
__bprm_mm_init
  vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;

then setup_arg_pages calls mprotect_fixup with @vm_flags having dirty bit
set thus it'll be propagated to vma

mprotect_fixup
  ...
  vma->vm_flags = newflags;

the @newflags will have dirty bit set from caller code.

Or you mean something else which I'm missing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
