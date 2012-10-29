Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 0B2B06B0075
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:44:03 -0400 (EDT)
Date: Mon, 29 Oct 2012 11:44:03 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v3 4/6] net/core: apply pm_runtime_set_memalloc_noio on
 network devices
In-Reply-To: <1351513440-9286-5-git-send-email-ming.lei@canonical.com>
Message-ID: <Pine.LNX.4.44L0.1210291142000.22882-100000@netrider.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@canonical.com>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, David Decotigny <david.decotigny@google.com>, Tom Herbert <therbert@google.com>, Ingo Molnar <mingo@elte.hu>

On Mon, 29 Oct 2012, Ming Lei wrote:

> Deadlock might be caused by allocating memory with GFP_KERNEL in
> runtime_resume callback of network devices in iSCSI situation, so
> mark network devices and its ancestor as 'memalloc_noio_resume'
> with the introduced pm_runtime_set_memalloc_noio().

> @@ -1411,6 +1414,8 @@ int netdev_register_kobject(struct net_device *net)
>  	*groups++ = &netstat_group;
>  #endif /* CONFIG_SYSFS */
>  
> +	pm_runtime_set_memalloc_noio(dev, true);
> +
>  	error = device_add(dev);
>  	if (error)
>  		return error;

This is an example of what I described earlier.  The 
pm_runtime_set_memalloc_noio() call should come after device_add(), not 
before.

(Not to mention that this version of the code doesn't correctly handle
the case where device_add() fails.)

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
