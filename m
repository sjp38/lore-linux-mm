Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C8A8A6B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 13:37:07 -0500 (EST)
Date: Tue, 13 Nov 2012 11:38:53 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [RFC 1/3] mm: Add VM pressure notifications
Message-ID: <20121113113853.56d71f27@lwn.net>
In-Reply-To: <20121107110128.GA30462@lizard>
References: <20121107105348.GA25549@lizard>
	<20121107110128.GA30462@lizard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, 7 Nov 2012 03:01:28 -0800
Anton Vorontsov <anton.vorontsov@linaro.org> wrote:

> This patch introduces vmpressure_fd() system call. The system call creates
> a new file descriptor that can be used to monitor Linux' virtual memory
> management pressure.

I noticed a couple of quick things as I was looking this over...

> +static ssize_t vmpressure_read(struct file *file, char __user *buf,
> +			       size_t count, loff_t *ppos)
> +{
> +	struct vmpressure_watch *watch = file->private_data;
> +	struct vmpressure_event event;
> +	int ret;
> +
> +	if (count < sizeof(event))
> +		return -EINVAL;
> +
> +	ret = wait_event_interruptible(watch->waitq,
> +				       atomic_read(&watch->pending));

Would it make sense to support non-blocking reads?  Perhaps a process would
like to simply know that current pressure level?

> +SYSCALL_DEFINE1(vmpressure_fd, struct vmpressure_config __user *, config)
> +{
> +	struct vmpressure_watch *watch;
> +	struct file *file;
> +	int ret;
> +	int fd;
> +
> +	watch = kzalloc(sizeof(*watch), GFP_KERNEL);
> +	if (!watch)
> +		return -ENOMEM;
> +
> +	ret = copy_from_user(&watch->config, config, sizeof(*config));
> +	if (ret)
> +		goto err_free;

This is wrong - you'll return the number of uncopied bytes to user space.
You'll need a "ret = -EFAULT;" in there somewhere.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
