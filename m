Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0EE8B5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 01:24:12 -0400 (EDT)
Received: by ti-out-0910.google.com with SMTP id a21so1195540tia.8
        for <linux-mm@kvack.org>; Sun, 19 Apr 2009 22:24:33 -0700 (PDT)
Date: Mon, 20 Apr 2009 14:24:22 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
Message-Id: <20090420142422.ff1a2a66.minchan.kim@barrios-desktop>
In-Reply-To: <49EC029D.1060807@gmail.com>
References: <49E8292D.7050904@gmail.com>
	<20090420084533.7f701e16.minchan.kim@barrios-desktop>
	<49EBDADB.4040307@gmail.com>
	<20090420114236.dda3de34.minchan.kim@barrios-desktop>
	<49EBEBC0.8090102@gmail.com>
	<20090420135323.08015e32.minchan.kim@barrios-desktop>
	<49EC029D.1060807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Apr 2009 13:05:33 +0800
Huang Shijie <shijie8@gmail.com> wrote:

> Minchan Kim a??e??:
> > On Mon, 20 Apr 2009 11:28:00 +0800
> > Huang Shijie <shijie8@gmail.com> wrote:
> >
> > I will summarize your method. 
> > Is right ?
> >
> >
> > kernel(driver)					application 
> >
> > 						posix_memalign(buffer)
> > 						ioctl(buffer)
> >
> > ioctl handler
> > get_user_pages(pages);
> > /* This pages are mapped at user's vma' 
> > address space */
> > vaddr = vmap(pages);
> > /* This pages are mapped at vmalloc space */
> > .
> > .
> > <after sometime, 
> > It may change to other process context>
> > .
> > .
> > interrupt handler in your driver 
> > memcpy(vaddr, src, len); 
> > notify_user();
> >
> > 						processing(buffer);
> >
> > It's rather awkward use case of get_user_pages. 
> >
> > If you want to share one big buffer between kernel and user, 
> > You can vmalloc and remap_pfn_range.
> >   
> The v4l2 method IO_METHOD_MMAP does use the vmaloc() method you told above ,
> our driver also support this method,we user vmalloc /remap_vmalloc_range().
> 
> But the v4l2 method IO_METHOD_USERPTR must use the method I told above.

I can't understand IO_METHOD_USERPTR's benefit compared with IO_METHOD_MMAP. 
I think both solution can support that application programmer can handle buffer as like pointer and kernel can reduce copy overhead from kernel to user. 

Why do you have to support IO_METHOD_USERPTR?
If you can justify your goal, we can add locked GUP. 

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
