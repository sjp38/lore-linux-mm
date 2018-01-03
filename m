Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3126B031B
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 04:26:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c82so369277wme.8
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 01:26:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 4sor453627edx.50.2018.01.03.01.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 01:26:07 -0800 (PST)
Date: Wed, 3 Jan 2018 12:26:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG at ./include/linux/mm.h:LINE! (3)
Message-ID: <20180103092604.5y4bvh3i644ts3zm@node.shutemov.name>
References: <20171228160346.6406d52df0d9afe8cf7a0862@linux-foundation.org>
 <20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
 <20180103010238.1e510ac2@lembas.zaitcev.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180103010238.1e510ac2@lembas.zaitcev.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pete Zaitcev <zaitcev@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-usb@vger.kernel.org

On Wed, Jan 03, 2018 at 01:02:38AM -0600, Pete Zaitcev wrote:
> On Fri, 29 Dec 2017 16:24:20 +0300
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > Looks like MON_IOCT_RING_SIZE reallocates ring buffer without any
> > serialization wrt mon_bin_vma_fault(). By the time of get_page() the page
> > may be freed.
> 
> Okay. Who knew that you could fork while holding an open descriptor. :-)

It's threads. But yeah.

> > The patch below seems help the crash to go away, but I *think* more work
> > is required. For instance, after ring buffer reallocation the old pages
> > will stay mapped. Nothing pulls them.
> 
> You know, this bothered me all these years too, but I was assured
> back in the day (as much as I can remember), that doing get_page()
> in the .fault() is just the right thing. In my defense, you can
> see other drivers doing it, such as:
> 
> ./drivers/char/agp/alpha-agp.c
> ./drivers/hsi/clients/cmt_speech.c
> 
> I'd appreciate insight from someone who knows how VM subsystem works.

get_page() is not a problem. It's right thing to do in ->fault.

After more thought, I think it's not a problem at all. As long as
userspace is aware that old mapping is no good after changing size of the
buffer everything would work fine. Even if userspace would use old mapping
nothing bad would happen from kernel POV.  Just userspace may see
old/inconsistent data. But there's no crashes or such.

> Now, about the code:
> 
> > diff --git a/drivers/usb/mon/mon_bin.c b/drivers/usb/mon/mon_bin.c
> > index f6ae753ab99b..ac168fecf04f 100644
> > --- a/drivers/usb/mon/mon_bin.c
> > +++ b/drivers/usb/mon/mon_bin.c
> > @@ -1228,15 +1228,24 @@ static void mon_bin_vma_close(struct vm_area_struct *vma)
> >  static int mon_bin_vma_fault(struct vm_fault *vmf)
> >  {
> >  	struct mon_reader_bin *rp = vmf->vma->vm_private_data;
> > -	unsigned long offset, chunk_idx;
> > +	unsigned long offset, chunk_idx, flags;
> >  	struct page *pageptr;
> >  
> > +	mutex_lock(&rp->fetch_lock);
> > +	spin_lock_irqsave(&rp->b_lock, flags);
> >  	offset = vmf->pgoff << PAGE_SHIFT;
> > -	if (offset >= rp->b_size)
> > +	if (offset >= rp->b_size) {
> > +		spin_unlock_irqrestore(&rp->b_lock, flags);
> > +		mutex_unlock(&rp->fetch_lock);
> >  		return VM_FAULT_SIGBUS;
> > +	}
> >  	chunk_idx = offset / CHUNK_SIZE;
> > +
> >  	pageptr = rp->b_vec[chunk_idx].pg;
> >  	get_page(pageptr);
> > +	spin_unlock_irqrestore(&rp->b_lock, flags);
> > +	mutex_unlock(&rp->fetch_lock);
> > +
> >  	vmf->page = pageptr;
> >  	return 0;
> >  }
> 
> I think that grabbing the spinlock is not really necessary in
> this case. The ->b_lock is designed for things that are accessed
> from interrupts that Host Controller Driver serves -- mostly
> various pointers. By defintion it's not covering things that
> are related to re-allocation. Now, the re-allocation itself
> grabs it, because it resets indexes into the new buffer, but
> does not appear to apply here, does it now?

Please, double check everything. I remember that the mutex wasn't enough
to stop bug from triggering. But I didn't spend much time understanding
the code.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
