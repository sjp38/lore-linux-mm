Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0DA680F85
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 15:40:03 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id i196so524247pgd.2
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 12:40:03 -0800 (PST)
Received: from osg.samsung.com (osg.samsung.com. [64.30.133.232])
        by mx.google.com with ESMTP id f14si1939746pgn.367.2017.11.07.12.40.02
        for <linux-mm@kvack.org>;
        Tue, 07 Nov 2017 12:40:02 -0800 (PST)
Date: Tue, 7 Nov 2017 18:39:50 -0200
From: Mauro Carvalho Chehab <mchehab@s-opensource.com>
Subject: Re: [PATCH 3/3] [media] v4l2: disable filesystem-dax mapping
 support
Message-ID: <20171107183950.46f238fd@vento.lan>
In-Reply-To: <CAPcyv4hNSV=c4KY8omKEdRth2w4YEr8EQJQfOoxXS8XELGFVcA@mail.gmail.com>
References: <151001623063.16354.14661493921524115663.stgit@dwillia2-desk3.amr.corp.intel.com>
	<151001624873.16354.2551756846133945335.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20171107063345.22626a5d@vento.lan>
	<CAPcyv4hNSV=c4KY8omKEdRth2w4YEr8EQJQfOoxXS8XELGFVcA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, "Linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

Em Tue, 7 Nov 2017 09:43:41 -0800
Dan Williams <dan.j.williams@intel.com> escreveu:

> On Tue, Nov 7, 2017 at 12:33 AM, Mauro Carvalho Chehab
> <mchehab@s-opensource.com> wrote:
> > Em Mon, 06 Nov 2017 16:57:28 -0800
> > Dan Williams <dan.j.williams@intel.com> escreveu:
> >  
> >> V4L2 memory registrations are incompatible with filesystem-dax that
> >> needs the ability to revoke dma access to a mapping at will, or
> >> otherwise allow the kernel to wait for completion of DMA. The
> >> filesystem-dax implementation breaks the traditional solution of
> >> truncate of active file backed mappings since there is no page-cache
> >> page we can orphan to sustain ongoing DMA.
> >>
> >> If v4l2 wants to support long lived DMA mappings it needs to arrange to
> >> hold a file lease or use some other mechanism so that the kernel can
> >> coordinate revoking DMA access when the filesystem needs to truncate
> >> mappings.  
> >
> >
> > Not sure if I understand this your comment here... what happens
> > if FS_DAX is enabled? The new err = get_user_pages_longterm()
> > would cause DMA allocation to fail?  
> 
> Correct, any attempt to specify a filesystem-dax mapping range to
> get_user_pages_longterm will fail with EOPNOTSUPP. In the future we
> want to add something like a 'struct file_lock *' argument to
> get_user_pages_longterm so that the kernel has a handle to revoke
> access to the returned pages. Once we have a safe way for the kernel
> to undo elevated page counts we can stop failing the longterm vs
> filesystem-dax case.

Argh! Perhaps we should make it depend on BROKEN while not fixed :-/

> Here is more background on why _longterm gup is a problem for filesystem-dax:
> 
>     https://lwn.net/Articles/737273/
> 
> > If so, that doesn't sound
> > right. Instead, mm should somehow mark this mapping to be out
> > of FS_DAX control range.  
> 
> DAX is currently global setting for the entire backing device of the
> filesystem, so any mapping of any file when the "-o dax" mount option
> is set is in the "FS_DAX control range". In other words there's
> currently no way to prevent FS_DAX mappings from being exposed to V4L2
> outside of CONFIG_FS_DAX=n.

Grrr...

> > Also, it is not only videobuf-dma-sg.c that does long lived
> > DMA mappings. VB2 also does that (and videobuf-vmalloc).  
> 
> Without finding the code videobuf-vmalloc sounds like it should be ok
> if the kernel is allocating memory separate from a file-backed DAX
> mapping.

videobuf-vmalloc do DMA mapping for pages allocated via vmalloc(),
via vmalloc_user()/remap_vmalloc_range().

There aren't much drivers using VB1 anymore, but a change at VB2
will likely break support for almost all webcams if fs DAX is
in usage.

> Where is the VB2 get_user_pages call?

Before changeset 3336c24f25ec, the logic for get_user_pages() were
at drivers/media/v4l2-core/videobuf2-dma-sg.c. Now, the logic
it uses is inside mm/frame_vector.c.

Thanks,
Mauro

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
