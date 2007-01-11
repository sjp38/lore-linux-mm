Date: Thu, 11 Jan 2007 13:37:59 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH/RFC 2.6.20-rc4 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
Message-Id: <20070111133759.d17730a4.akpm@osdl.org>
In-Reply-To: <20070111142427.GA1668@localhost>
References: <20070111142427.GA1668@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jan 2007 15:24:27 +0100
Jaya Kumar <jayakumar.lkml@gmail.com> wrote:

> +/* this is to find and return the vmalloc-ed fb pages */
> +static struct page* hecubafb_vm_nopage(struct vm_area_struct *vma, 
> +					unsigned long vaddr, int *type)
> +{
> +	unsigned long offset;
> +	struct page *page;
> +	struct fb_info *info = vma->vm_private_data;
> +
> +	offset = (vaddr - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
> +	if (offset >= (DPY_W*DPY_H)/8)
> +		return NOPAGE_SIGBUS;
> +
> +	page = vmalloc_to_page(info->screen_base + offset);
> +	if (!page)
> +		return NOPAGE_OOM;
> +
> +	get_page(page);
> +	if (type)
> +		*type = VM_FAULT_MINOR;
> +	return page;
> +}
> +
> +static void hecubafb_work(struct work_struct *work)
> +{
> +	struct hecubafb_par *par = container_of(work, struct hecubafb_par,
> +					deferred_work.work);
> +	struct list_head *node, *next;
> +	struct page_list *cur;
> +
> +	/* here we unmap the pages, then do all deferred IO */
> +	spin_lock(&par->lock);
> +	list_for_each_safe(node, next, &par->pagelist) {
> +		cur = list_entry(node, struct page_list, list);
> +		list_del(node);
> +		lock_page_nosync(cur->page);
> +		page_mkclean(cur->page);
> +		unlock_page(cur->page);
> +		kfree(cur);
> +	}
> +	spin_unlock(&par->lock);
> +	hecubafb_dpy_update(par);
> +}
> +
> +static int hecubafb_page_mkwrite(struct vm_area_struct *vma, 
> +					struct page *page)
> +{
> +	struct fb_info *info = vma->vm_private_data;
> +	struct hecubafb_par *par = info->par;
> +	struct page_list *new;
> +
> +	/* this is a callback we get when userspace first tries to 
> +	write to the page. we schedule a workqueue. that workqueue 
> +	will eventually unmap the touched pages and execute the 
> +	deferred framebuffer IO. then if userspace touches a page 
> +	again, we repeat the same scheme */
> +
> +	new = kzalloc(sizeof(struct page_list), GFP_KERNEL);
> +	if (!new)
> +		return -ENOMEM;
> +	new->page = page;
> +
> +	/* protect against the workqueue changing the page list */
> +	spin_lock(&par->lock);
> +	list_add(&new->list, &par->pagelist);
> +	spin_unlock(&par->lock);
> +
> +	/* come back in 1s to process the deferred IO */
> +	schedule_delayed_work(&par->deferred_work, HZ);
> +	return 0;
> +}

That's all very interesting.

Please don't dump a bunch of new implementation concepts like this on us
with no description of what it does, why it does it and why it does it in
this particular manner.

What is the "theory of operation" here?

Presumably this is a performance optimisation to permit batching of the
copying from user memory into the frambuffer card?  If so, how much
performance does it gain?

I expect the benefit will be large, and could be increased if you were to
add a small delay between first-touch and writeback to the display.  Let's
talk about that a bit.

Is the optimisation applicable to other drivers?  If so, should it be
generalised into library code somewhere?

I guess the export of page_mkclean() makes sense for this application.

The use of lock_page_nosync() is wrong.  It can still sleep, and here it's
inside spinlock.  And we don't want to export __lock_page_nosync() to
modules.  I suggest you convert the list locking here to a mutex and use
lock_page().



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
