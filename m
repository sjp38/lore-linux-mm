Received: by nf-out-0910.google.com with SMTP id b2so1071119nfe
        for <linux-mm@kvack.org>; Sat, 24 Feb 2007 00:14:21 -0800 (PST)
Message-ID: <45a44e480702240014p52c98667tf06626b52716b3e7@mail.gmail.com>
Date: Sat, 24 Feb 2007 03:14:21 -0500
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: [Linux-fbdev-devel] [RFC 2.6.20 1/1] fbdev, mm: Deferred IO and hecubafb driver
In-Reply-To: <1172299914.4109.47.camel@daplas>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070223063228.GA9906@localhost> <1172299914.4109.47.camel@daplas>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Antonino A. Daplas" <adaplas@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/24/07, Antonino A. Daplas <adaplas@gmail.com> wrote:
> On Fri, 2007-02-23 at 07:32 +0100, Jaya Kumar wrote:
> Can you create 2 separate patches, one for the deferred_io and another
> for the driver that uses it?

Will do.

> > +static struct vm_operations_struct hecubafb_vm_ops = {
> > +     .nopage         = hecubafb_vm_nopage,
> > +     .page_mkwrite   = fb_deferred_io_mkwrite,
> > +};
> > +
>
> It would seem to me that the above can be made generic, so we have this
> instead:

We could. But I think fb_deferred_io_vm_nopage would then have to
handle the different types or possible combinations of framebuffer
allocations, if they kmalloced or vmalloced or maybe combinations. Ok.
I'll try to implement that. Maybe we'll need a flag where the driver
informs us of the type of allocation.

>
> > +static struct fb_deferred_io hecubafb_defio = {
> > +     .delay          = HZ,
> > +     .deferred_io    = hecubafb_dpy_deferred_io,
> > +};
>
> Leaving the drivers to just fill up the above. This would result in a
> decrease of code duplication and it will be easier for driver writers.

I agree it'll be much cleaner that way but was worried if having
fb_defio do that would prevent driver writers from having their own
nopage and controlling other vm related functionality. Looking at
drivers/video/* shows no one touching vm_ops, so I guess we'll be
fine. If fb_defio takes ownership of the driver's nopage, vm_ops, etc,
then it could be just the above struct and the
fb_deferred_io_init/cleanup functions that are exposed to the driver.
ie: if an fbdev driver calls fb_deferred_io_init, we setup their mmap,
vm_ops and the necessary bits. I'll give that a shot.

>
> I would prefer to have the init and cleanup functions called by the
> driver themselves, instead of piggy-backing them to the
> framebuffer_register/unregister.
>

Understood. I had done it that way originally but changed just before
posting. I'll revert back. :)

> This basically dumps the entire framebuffer to the hardware, doesn't it?
> This framebuffer has only 2 pages at the most, so it doesn't matter. But
> for hardware with MB's of RAM, I don't think this is feasible.

Yup, hecuba doesn't have clean partial update functionality. But the
callback exposed to drivers is:

+       void (*deferred_io)(struct fb_info *info, struct list_head *pagelist);

which gives the drivers the list of dirty pages in pagelist. So other
drivers for hardware with the right capabilities can implement
selective or partial updates. As you mentioned, I imagine that the
drivers internally could have a bit array to enable them to mark and
find sequential partial updates. I would leave the page bitmap for
drivers to do since it would be specific to their hardware.

Thanks,
jaya

>
> Is there a way to selectively update only the touched pages, ie from the
> fbdevio->pagelist? struct page has a field (pgoff_t index), is this
> usable? If not, can we just create a bit array, just to tell the driver
> which are the dirty pages?
>
> Tony
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
