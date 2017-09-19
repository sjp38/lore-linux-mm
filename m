Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 29DB96B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 19:45:40 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r20so317205oie.0
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 16:45:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h186sor263547oif.148.2017.09.19.16.45.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 16:45:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <11e8c954-7d54-ae4f-f4fe-459da79c2990@oracle.com>
References: <11e8c954-7d54-ae4f-f4fe-459da79c2990@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Sep 2017 16:45:38 -0700
Message-ID: <CAPcyv4ieKRPP43-FQQS5OfXigSZYoa5mEqiRN9ujj=fe37+e4g@mail.gmail.com>
Subject: Re: DAX error inject/page poison
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal L Verma <vishal.l.verma@intel.com>

On Tue, Sep 19, 2017 at 4:15 PM, Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
> We were trying to simulate pmem errors in an environment where a DAX
> filesystem is used (ext4 although I suspect it does not matter).  The
> sequence attempted on a DAX filesystem is:
> - Populate a file in the DAX filesystem
> - mmap the file
> - madvise(MADV_HWPOISON)
>
> The madvise operation fails with EFAULT.  This appears to come from
> get_user_pages() as there are no struct pages for such mappings?
>
> The idea is to make sure an application can recover from such errors
> by hole punching and repopulating with another page.
>
> A couple questions:
> It seems like madvise(MADV_HWPOISON) is not going to work (ever?) in
> such situations.  If so, should we perhaps add a IS_DAX like check and
> return something like EINVAL?  Or, at least document expected behavior?

The MADV_HWPOISON machinery assumes normal memory pages, not DAX and
certainly not the special ZONE_DEVICE pages we allocate for the
purpose of DMA. Returning EINVAL seems like the right thing to do
since there is no facility in the kernel to soft offline a DAX page.
In other words MADV_HWPOISON is for emulating errors in volatile
memory that might be transient until the next reboot, DAX errors cause
permanent data loss in filesytem files, so the error injection and
handling models need to be different.

> If madvise(MADV_HWPOISON) will not work, how can one inject errors to
> test error handling code?

Similar to "hdparm --make-bad-sector" we need a platform specific
facility to inject a hard memory error at a given physical persistent
memory address. In the case of an ACPI 6.2 based platform that
mechanism is: "Section 9.20.7.9 Function Index 7 - ARS Error Inject".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
