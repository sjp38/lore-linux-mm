Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 105496B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 12:28:20 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x85so2346963oix.3
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 09:28:20 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e85sor441265oib.322.2017.09.28.09.28.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Sep 2017 09:28:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <x49tvzmaiyy.fsf@segfault.boston.devel.redhat.com>
References: <150655617774.700.5326522538400299973.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150655618343.700.16350109614227108839.stgit@dwillia2-desk3.amr.corp.intel.com>
 <x49tvzmaiyy.fsf@segfault.boston.devel.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 28 Sep 2017 09:28:18 -0700
Message-ID: <CAPcyv4hE-VnScR39cgsM4TROJdcMYqQkJVSHPMN6tvveGt-Pgg@mail.gmail.com>
Subject: Re: [PATCH 1/3] dax: disable filesystem dax on devices that do not
 map pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Thu, Sep 28, 2017 at 9:25 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
> Dan Williams <dan.j.williams@intel.com> writes:
>
>> If a dax buffer from a device that does not map pages is passed to
>> read(2) or write(2) as a target for direct-I/O it triggers SIGBUS. If
>> gdb attempts to examine the contents of a dax buffer from a device that
>> does not map pages it triggers SIGBUS. If fork(2) is called on a process
>> with a dax mapping from a device that does not map pages it triggers
>> SIGBUS. 'struct page' is required otherwise several kernel code paths
>> break in surprising ways. Disable filesystem-dax on devices that do not
>> map pages.
>>
> [...]
>> @@ -123,6 +124,12 @@ int __bdev_dax_supported(struct super_block *sb, int blocksize)
>>               return len < 0 ? len : -EIO;
>>       }
>>
>> +     if (!pfn_t_has_page(pfn)) {
>> +             pr_err("VFS (%s): error: dax support not enabled\n",
>> +                             sb->s_id);
>
> Is the pr_err really necessary?  At least one caller already prints a
> warning.  It seems cleaner to me to let the caller determine whether
> it's worth printing anything.

Agreed, I'll drop it in v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
