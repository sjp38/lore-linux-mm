Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0A16B00F2
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 15:54:02 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so12924649pac.2
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 12:54:01 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id mj8si16200442pab.90.2014.11.03.12.53.59
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 12:54:00 -0800 (PST)
Message-ID: <5457EB67.70904@intel.com>
Date: Mon, 03 Nov 2014 12:53:59 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos> <544DB873.1010207@intel.com> <alpine.DEB.2.11.1410272138540.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410272138540.5308@nanos>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ren Qiaowei <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.orgLinux-MM <linux-mm@kvack.org>

On 10/27/2014 01:49 PM, Thomas Gleixner wrote:
> Errm. Before user space can use the bounds table for the new mapping
> it needs to add the entries, right? So:
> 
> CPU 0					CPU 1
> 
> down_write(mm->bd_sem);
> mpx_pre_unmap();
>    clear bounds directory entries	
> unmap();
> 					map()
> 					write_bounds_entry()
> 					trap()
> 					  down_read(mm->bd_sem);
> mpx_post_unmap(); 
> up_write(mm->bd_sem);
> 					  allocate_bounds_table();
> 
> That's the whole point of bd_sem.

This does, indeed, seem to work for the normal munmap() cases.  However,
take a look at shmdt().  We don't know the size of the segment being
unmapped until after we acquire mmap_sem for write, so we wouldn't be
able to do do a mpx_pre_unmap() for those.

mremap() is similar.  We don't know if the area got expanded (and we
don't need to modify bounds tables) or moved (and we need to free the
old location's tables) until well after we've taken mmap_sem for write.

I propose we keep mm->bd_sem.  But, I think we need to keep a list
during each of the unmapping operations of VMAs that got unmapped, and
then keep them on a list without freeing then.  At up_write() time, we
look at the list, if it is empty, we just do an up_write() and we are done.

If *not* empty, downgrade_write(mm->mmap_sem), and do the work you
spelled out in mpx_pre_unmap() above: clear the bounds directory entries
and gather the VMAs while still holding mm->bd_sem for write.

Here's the other wrinkle: This would invert the ->bd_sem vs. ->mmap_sem
ordering (bd_sem nests outside mmap_sem with the above scheme).  We
_could_ always acquire bd_sem for write whenever mmap_sem is acquired,
although that seems a bit heavyweight.  I can't think of anything better
at the moment, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
