Received: by an-out-0708.google.com with SMTP id b38so319556ana
        for <linux-mm@kvack.org>; Mon, 11 Dec 2006 15:54:05 -0800 (PST)
Message-ID: <45a44e480612111554j1450f35ub4d9932e5cd32d4@mail.gmail.com>
Date: Mon, 11 Dec 2006 18:54:05 -0500
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: [RFC 2.6.19 1/1] fbdev,mm: hecuba/E-Ink fbdev driver v2
In-Reply-To: <457D895D.4010500@innova-card.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200612111046.kBBAkV8Y029087@localhost.localdomain>
	 <457D895D.4010500@innova-card.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Franck <vagabon.xyz@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/11/06, Franck Bui-Huu <vagabon.xyz@gmail.com> wrote:
> jayakumar.lkml@gmail.com wrote:
> > +     atomic_t ref_count;
> > +     atomic_t vma_count;
>
> what purpose do these counters deserve ?

You are right. I can remove them.

> > +
> > +void hcb_wait_for_ack(struct hecubafb_par *par)
> > +{
> > +
> > +     int timeout;
> > +     unsigned char ctl;
> > +
> > +     timeout=500;
> > +     do {
> > +             ctl = hcb_get_ctl(par);
> > +             if ((ctl & HCB_ACK_BIT))
> > +                     return;
> > +             udelay(1);
> > +     } while (timeout--);
> > +     printk(KERN_ERR "timed out waiting for ack\n");
> > +}
>
> When timeout occur this function does not return any error values.
> the callers needn't to be warn in this case ?

You are right. I need to figure out what exactly to do. Currently, if
a timeout is observed it normally means the display controller is
hung. However, in some cases  the controller does seem to recover
after some period of time. I guess I should probably return an error
and terminate pending activity.

> > +
> > +/* this is to find and return the vmalloc-ed fb pages */
> > +static struct page* hecubafb_vm_nopage(struct vm_area_struct *vma,
> > +                                     unsigned long vaddr, int *type)
> > +{
> > +     unsigned long offset;
> > +     struct page *page;
> > +     struct fb_info *info = vma->vm_private_data;
> > +
> > +     offset = (vaddr - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
> > +     if (offset >= (DPY_W*DPY_H)/8)
> > +             return NOPAGE_SIGBUS;
> > +
> > +     page = vmalloc_to_page(info->screen_base + offset);
> > +     if (!page)
> > +             return NOPAGE_OOM;
> > +
> > +     get_page(page);
> > +     if (type)
> > +             *type = VM_FAULT_MINOR;
> > +     return page;
> > +}
> > +
>
> so page can be accessed by using vma->start virtual address....

The userspace app would be doing:

ioctl(fd, FBIOGET_FSCREENINFO, &finfo);
ioctl(fd, FBIOGET_VSCREENINFO, &vinfo);
screensize = ( vinfo.xres * vinfo.yres * vinfo.bits_per_pixel) / 8;
maddr = mmap(finfo.mmio_start, screensize, PROT_WRITE, MAP_SHARED, fd, 0);

>
> > +static int hecubafb_page_mkwrite(struct vm_area_struct *vma,
>
> [snip]
>
> > +
> > +     if (!(videomemory = vmalloc(videomemorysize)))
> > +             return retval;
>
> and here the kernel access to the same page by using address returned
> by vmalloc which are different from the previous one. So 2 different
> addresses map the same physical page. In this case are there any cache
> aliasing issues specially for x86 arch ?

I think that PTEs set up by vmalloc are marked cacheable and via the
above nopage end up as cacheable. I'm not doing DMA. So the accesses
are through the cache so I don't think cache aliasing is an issue for
this case. Please let me know if I misunderstood.

Thanks,
jayakumar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
