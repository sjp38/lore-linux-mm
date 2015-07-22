Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5217C9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 06:33:38 -0400 (EDT)
Received: by lblf12 with SMTP id f12so133645131lbl.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 03:33:37 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id f9si842289laa.60.2015.07.22.03.33.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 03:33:36 -0700 (PDT)
Date: Wed, 22 Jul 2015 13:33:06 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 4/8] proc: add kpagecgroup file
Message-ID: <20150722103306.GJ23374@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <679498f8d3f87c1ee57b7c3b58382193c9046b6a.1437303956.git.vdavydov@parallels.com>
 <20150721163433.618855e1f61536a09dfac30b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150721163433.618855e1f61536a09dfac30b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg
 Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David
 Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 21, 2015 at 04:34:33PM -0700, Andrew Morton wrote:
> On Sun, 19 Jul 2015 15:31:13 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:
> 
> > /proc/kpagecgroup contains a 64-bit inode number of the memory cgroup
> > each page is charged to, indexed by PFN. Having this information is
> > useful for estimating a cgroup working set size.
> > 
> > The file is present if CONFIG_PROC_PAGE_MONITOR && CONFIG_MEMCG.
> >
> > ...
> >
> > @@ -225,10 +226,62 @@ static const struct file_operations proc_kpageflags_operations = {
> >  	.read = kpageflags_read,
> >  };
> >  
> > +#ifdef CONFIG_MEMCG
> > +static ssize_t kpagecgroup_read(struct file *file, char __user *buf,
> > +				size_t count, loff_t *ppos)
> > +{
> > +	u64 __user *out = (u64 __user *)buf;
> > +	struct page *ppage;
> > +	unsigned long src = *ppos;
> > +	unsigned long pfn;
> > +	ssize_t ret = 0;
> > +	u64 ino;
> > +
> > +	pfn = src / KPMSIZE;
> > +	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
> > +	if (src & KPMMASK || count & KPMMASK)
> > +		return -EINVAL;
> 
> The user-facing documentation should explain that reads must be
> performed in multiple-of-8 sizes.

It does. It's in the end of Documentation/vm/pagemap.c:

: Other notes:
: 
: Reading from any of the files will return -EINVAL if you are not starting
: the read on an 8-byte boundary (e.g., if you sought an odd number of bytes
: into the file), or if the size of the read is not a multiple of 8 bytes.

> 
> > +	while (count > 0) {
> > +		if (pfn_valid(pfn))
> > +			ppage = pfn_to_page(pfn);
> > +		else
> > +			ppage = NULL;
> > +
> > +		if (ppage)
> > +			ino = page_cgroup_ino(ppage);
> > +		else
> > +			ino = 0;
> > +
> > +		if (put_user(ino, out)) {
> > +			ret = -EFAULT;
> 
> Here we do the usual procfs violation of read() behaviour.  read()
> normally only returns an error if it read nothing.  This code will
> transfer a megabyte then return -EFAULT so userspace doesn't know that
> it got that megabyte.

Yeah, that's how it works. I did it preliminary for /proc/kpagecgroup to
work exactly like /proc/kpageflags and /proc/kpagecount.

FWIW, the man page I have on my system already warns about this
peculiarity of read(2):

: On error, -1 is returned, and errno is set appropriately. In this
: case, it is left unspecified whether the file position (if any)
: changes.

> 
> That's easy to fix, but procfs files do this all over the place anyway :(
> 
> > +			break;
> > +		}
> > +
> > +		pfn++;
> > +		out++;
> > +		count -= KPMSIZE;
> > +	}
> > +
> > +	*ppos += (char __user *)out - buf;
> > +	if (!ret)
> > +		ret = (char __user *)out - buf;
> > +	return ret;
> > +}
> > +
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
