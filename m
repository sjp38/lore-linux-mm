Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2DB16B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 12:25:29 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 6so859075qkr.11
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 09:25:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p29si1586790qkp.219.2017.09.28.09.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 09:25:29 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 1/3] dax: disable filesystem dax on devices that do not map pages
References: <150655617774.700.5326522538400299973.stgit@dwillia2-desk3.amr.corp.intel.com>
	<150655618343.700.16350109614227108839.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Thu, 28 Sep 2017 12:25:25 -0400
In-Reply-To: <150655618343.700.16350109614227108839.stgit@dwillia2-desk3.amr.corp.intel.com>
	(Dan Williams's message of "Wed, 27 Sep 2017 16:49:43 -0700")
Message-ID: <x49tvzmaiyy.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

Dan Williams <dan.j.williams@intel.com> writes:

> If a dax buffer from a device that does not map pages is passed to
> read(2) or write(2) as a target for direct-I/O it triggers SIGBUS. If
> gdb attempts to examine the contents of a dax buffer from a device that
> does not map pages it triggers SIGBUS. If fork(2) is called on a process
> with a dax mapping from a device that does not map pages it triggers
> SIGBUS. 'struct page' is required otherwise several kernel code paths
> break in surprising ways. Disable filesystem-dax on devices that do not
> map pages.
>
[...]
> @@ -123,6 +124,12 @@ int __bdev_dax_supported(struct super_block *sb, int blocksize)
>  		return len < 0 ? len : -EIO;
>  	}
>  
> +	if (!pfn_t_has_page(pfn)) {
> +		pr_err("VFS (%s): error: dax support not enabled\n",
> +				sb->s_id);

Is the pr_err really necessary?  At least one caller already prints a
warning.  It seems cleaner to me to let the caller determine whether
it's worth printing anything.

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
