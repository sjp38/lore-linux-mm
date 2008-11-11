Date: Tue, 11 Nov 2008 15:03:45 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver
Message-ID: <20081111150345.7fff8ff2@bike.lwn.net>
In-Reply-To: <1226409701-14831-4-git-send-email-ieidus@redhat.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
	<1226409701-14831-2-git-send-email-ieidus@redhat.com>
	<1226409701-14831-3-git-send-email-ieidus@redhat.com>
	<1226409701-14831-4-git-send-email-ieidus@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

I don't claim to begin to really understand the deep VM side of this
patch, but I can certainly pick nits as I work through it...sorry for
the lack of anything more substantive.

> +static struct list_head slots;

Some of these file-static variable names seem a little..terse...

> +#define PAGECMP_OFFSET 128
> +#define PAGEHASH_SIZE (PAGECMP_OFFSET ? PAGECMP_OFFSET : PAGE_SIZE)
> +/* hash the page */
> +static void page_hash(struct page *page, unsigned char *digest)

So is this really saying that you only hash the first 128 bytes, relying on
full compares for the rest?  I assume there's a perfectly good reason for
doing it that way, but it's not clear to me from reading the code.  Do you
gain performance which is not subsequently lost in the (presumably) higher
number of hash collisions?

> +static int ksm_scan_start(struct ksm_scan *ksm_scan, int scan_npages,
> +			  int max_npages)
> +{
> +	struct ksm_mem_slot *slot;
> +	struct page *page[1];
> +	int val;
> +	int ret = 0;
> +
> +	down_read(&slots_lock);
> +
> +	scan_update_old_index(ksm_scan);
> +
> +	while (scan_npages > 0 && max_npages > 0) {

Should this loop maybe check kthread_run too?  It seems like you could loop
for a long time after kthread_run has been set to zero.

> +static int ksm_dev_open(struct inode *inode, struct file *filp)
> +{
> +	try_module_get(THIS_MODULE);
> +	return 0;
> +}
> +
> +static int ksm_dev_release(struct inode *inode, struct file *filp)
> +{
> +	module_put(THIS_MODULE);
> +	return 0;
> +}
> +
> +static struct file_operations ksm_chardev_ops = {
> +	.open           = ksm_dev_open,
> +	.release        = ksm_dev_release,
> +	.unlocked_ioctl = ksm_dev_ioctl,
> +	.compat_ioctl   = ksm_dev_ioctl,
> +};

Why do you roll your own module reference counting?  Is there a reason you
don't just set .owner and let the VFS handle it?

Given that the KSM_REGISTER_MEMORY_REGION ioctl() creates unswappable
memory, should there be some sort of capability check done there?  A check
for starting/stopping the thread might also make sense.  Or is that
expected to be handled via permissions on /dev/ksm?

Actually, it occurs to me that there's no sanity checks on any of the
values passed in by ioctl().  What happens if the user tells KSM to scan a
bogus range of memory?

Any benchmarks on the runtime cost of having KSM running?

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
