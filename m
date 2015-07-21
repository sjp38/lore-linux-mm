Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id E57AB9003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 19:34:35 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so130428824pdj.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:34:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bk6si15680589pad.202.2015.07.21.16.34.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 16:34:35 -0700 (PDT)
Date: Tue, 21 Jul 2015 16:34:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v9 4/8] proc: add kpagecgroup file
Message-Id: <20150721163433.618855e1f61536a09dfac30b@linux-foundation.org>
In-Reply-To: <679498f8d3f87c1ee57b7c3b58382193c9046b6a.1437303956.git.vdavydov@parallels.com>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<679498f8d3f87c1ee57b7c3b58382193c9046b6a.1437303956.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 19 Jul 2015 15:31:13 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:

> /proc/kpagecgroup contains a 64-bit inode number of the memory cgroup
> each page is charged to, indexed by PFN. Having this information is
> useful for estimating a cgroup working set size.
> 
> The file is present if CONFIG_PROC_PAGE_MONITOR && CONFIG_MEMCG.
>
> ...
>
> @@ -225,10 +226,62 @@ static const struct file_operations proc_kpageflags_operations = {
>  	.read = kpageflags_read,
>  };
>  
> +#ifdef CONFIG_MEMCG
> +static ssize_t kpagecgroup_read(struct file *file, char __user *buf,
> +				size_t count, loff_t *ppos)
> +{
> +	u64 __user *out = (u64 __user *)buf;
> +	struct page *ppage;
> +	unsigned long src = *ppos;
> +	unsigned long pfn;
> +	ssize_t ret = 0;
> +	u64 ino;
> +
> +	pfn = src / KPMSIZE;
> +	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
> +	if (src & KPMMASK || count & KPMMASK)
> +		return -EINVAL;

The user-facing documentation should explain that reads must be
performed in multiple-of-8 sizes.

> +	while (count > 0) {
> +		if (pfn_valid(pfn))
> +			ppage = pfn_to_page(pfn);
> +		else
> +			ppage = NULL;
> +
> +		if (ppage)
> +			ino = page_cgroup_ino(ppage);
> +		else
> +			ino = 0;
> +
> +		if (put_user(ino, out)) {
> +			ret = -EFAULT;

Here we do the usual procfs violation of read() behaviour.  read()
normally only returns an error if it read nothing.  This code will
transfer a megabyte then return -EFAULT so userspace doesn't know that
it got that megabyte.

That's easy to fix, but procfs files do this all over the place anyway :(

> +			break;
> +		}
> +
> +		pfn++;
> +		out++;
> +		count -= KPMSIZE;
> +	}
> +
> +	*ppos += (char __user *)out - buf;
> +	if (!ret)
> +		ret = (char __user *)out - buf;
> +	return ret;
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
