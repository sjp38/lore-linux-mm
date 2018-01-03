Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BAD3A6B0387
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 16:04:22 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id u128so1163679oib.8
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 13:04:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t129si437837oib.446.2018.01.03.13.04.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 13:04:21 -0800 (PST)
Date: Wed, 3 Jan 2018 15:04:19 -0600
From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: kernel BUG at ./include/linux/mm.h:LINE! (3)
Message-ID: <20180103150419.2fefd759@lembas.zaitcev.lan>
In-Reply-To: <20180103092604.5y4bvh3i644ts3zm@node.shutemov.name>
References: <20171228160346.6406d52df0d9afe8cf7a0862@linux-foundation.org>
	<20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
	<20180103010238.1e510ac2@lembas.zaitcev.lan>
	<20180103092604.5y4bvh3i644ts3zm@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-usb@vger.kernel.org, Pete Zaitcev <zaitcev@redhat.com>

On Wed, 3 Jan 2018 12:26:04 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> > > +++ b/drivers/usb/mon/mon_bin.c
> > > @@ -1228,15 +1228,24 @@ static void mon_bin_vma_close(struct vm_area_struct *vma)
> > >  static int mon_bin_vma_fault(struct vm_fault *vmf)
> > >  {
> > >  	struct mon_reader_bin *rp = vmf->vma->vm_private_data;
> > > -	unsigned long offset, chunk_idx;
> > > +	unsigned long offset, chunk_idx, flags;
> > >  	struct page *pageptr;
> > >  
> > > +	mutex_lock(&rp->fetch_lock);
> > > +	spin_lock_irqsave(&rp->b_lock, flags);
> > >  	offset = vmf->pgoff << PAGE_SHIFT;
> > > -	if (offset >= rp->b_size)
> > > +	if (offset >= rp->b_size) {
> > > +		spin_unlock_irqrestore(&rp->b_lock, flags);
> > > +		mutex_unlock(&rp->fetch_lock);
> > >  		return VM_FAULT_SIGBUS;
> > > +	}
> > >  	chunk_idx = offset / CHUNK_SIZE;
> > > +
> > >  	pageptr = rp->b_vec[chunk_idx].pg;
> > >  	get_page(pageptr);
> > > +	spin_unlock_irqrestore(&rp->b_lock, flags);
> > > +	mutex_unlock(&rp->fetch_lock);
> > > +
> > >  	vmf->page = pageptr;
> > >  	return 0;
> > >  }  
> > 
> > I think that grabbing the spinlock is not really necessary in
> > this case. [...]
> 
> Please, double check everything. I remember that the mutex wasn't enough
> to stop bug from triggering. But I didn't spend much time understanding
> the code.

I just don't understand why. The only two fields that are used
in the fault routine are rp->b_vec and rp->b_size. They are
protected by the mutex rp->fetch_lock. I don't see anything else
can spill into these fields by dirtying adjacent words in memory,
either.... except this:

	case MON_IOCQ_RING_SIZE:
		ret = rp->b_size;
		break;

In the old days, this was safe, but who knows what CPUs do today.
It needs the same mutex taken around the read-only reference too.
How about this:

diff --git a/drivers/usb/mon/mon_bin.c b/drivers/usb/mon/mon_bin.c
index f6ae753ab99b..cb3612f28804 100644
--- a/drivers/usb/mon/mon_bin.c
+++ b/drivers/usb/mon/mon_bin.c
@@ -1004,7 +1004,9 @@ static long mon_bin_ioctl(struct file *file, unsigned int cmd, unsigned long arg
 		break;
 
 	case MON_IOCQ_RING_SIZE:
+		mutex_lock(&rp->fetch_lock);
 		ret = rp->b_size;
+		mutex_unlock(&rp->fetch_lock);
 		break;
 
 	case MON_IOCT_RING_SIZE:
@@ -1231,12 +1233,15 @@ static int mon_bin_vma_fault(struct vm_fault *vmf)
 	unsigned long offset, chunk_idx;
 	struct page *pageptr;
 
+	mutex_lock(&rp->fetch_lock);
 	offset = vmf->pgoff << PAGE_SHIFT;
 	if (offset >= rp->b_size)
+		mutex_unlock(&rp->fetch_lock);
 		return VM_FAULT_SIGBUS;
 	chunk_idx = offset / CHUNK_SIZE;
 	pageptr = rp->b_vec[chunk_idx].pg;
 	get_page(pageptr);
+	mutex_unlock(&rp->fetch_lock);
 	vmf->page = pageptr;
 	return 0;
 }

-- Pete

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
