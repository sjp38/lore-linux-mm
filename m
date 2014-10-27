Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 46FAC900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 14:48:15 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so6196251pdj.10
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 11:48:14 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qp3si11128153pac.147.2014.10.27.11.48.13
        for <linux-mm@kvack.org>;
        Mon, 27 Oct 2014 11:48:14 -0700 (PDT)
Date: Mon, 27 Oct 2014 14:48:09 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: Progress on system crash traces with LTTng using DAX and pmem
Message-ID: <20141027184809.GW11522@wil.cx>
References: <1254279794.1957.1414240389301.JavaMail.zimbra@efficios.com>
 <465653369.1985.1414241485934.JavaMail.zimbra@efficios.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <465653369.1985.1414241485934.JavaMail.zimbra@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, lttng-dev <lttng-dev@lists.lttng.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Oct 25, 2014 at 12:51:25PM +0000, Mathieu Desnoyers wrote:
> A quick follow up on my progress on using DAX and pmem with
> LTTng. I've been able to successfully gather a user-space
> trace into buffers mmap'd into an ext4 filesystem within
> a pmem block device mounted with -o dax to bypass the page
> cache. After a soft reboot, I'm able to mount the partition
> again, and gather the very last data collected in the buffers
> by the applications. I created a "lttng-crash" program that
> extracts data from those buffers and converts the content
> into a readable Common Trace Format trace. So I guess
> you have a use-case for your patchsets on commodity hardware
> right there. :)

Sweet!

> I've been asked by my customers if DAX would work well with
> mtd-ram, which they are using. To you foresee any roadblock
> with this approach ?

Looks like we'd need to add support to mtd-blkdevs.c for DAX.  I assume
they're already using one of the block-based ways to expose MTD to
filesystems, rather than jffs2/logfs/ubifs?

I'm thinking we might want to add a flag somewhere in the block_dev / bdi
that indicates whether DAX is supported.  Currently we rely on whether
->direct_access is present in the block_device_operations to indicate
that, so we'd have to have two block_dev_operations in mtd-blkdevs,
depending on whether direct access is supported by the underlying
MTD device.  Not a show-stopper.

> Please keep me in CC on your next patch versions. I'm willing
> to spend some more time reviewing them if needed. By the way,
> do you guys have a target time-frame/kernel version you aim
> at for getting this work upstream ?

We're trying to get it upstream ASAP.  We've been working on it
publically since December last year, and it's getting frustrating that
it's not upstream already.  I sent a v12 a few minutes before you sent
this message ...  I thought git would add you to the cc's since your
Reviewed-by is on some of the patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
