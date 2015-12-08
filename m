Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id BB04A6B0278
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 19:48:09 -0500 (EST)
Received: by qgeb1 with SMTP id b1so4020196qge.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 16:48:09 -0800 (PST)
Received: from mail-qk0-x233.google.com (mail-qk0-x233.google.com. [2607:f8b0:400d:c09::233])
        by mx.google.com with ESMTPS id y70si801227qgd.62.2015.12.07.16.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 16:48:08 -0800 (PST)
Received: by qkdp187 with SMTP id p187so7186423qkd.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 16:48:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56661DBA.5000302@deltatee.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
	<562AA15E.3010403@deltatee.com>
	<CAPcyv4gQ-8-tL-rhAPzPxKzBLmWKnFcqSFVy4KVOM56_9gn6RA@mail.gmail.com>
	<565F6A7A.4040302@deltatee.com>
	<CAPcyv4jjyzKgPMzdwms8xH-_RoKEGxRp1r4qxEcPYmPv7qStqw@mail.gmail.com>
	<566244CC.5080107@deltatee.com>
	<56661DBA.5000302@deltatee.com>
Date: Mon, 7 Dec 2015 16:48:08 -0800
Message-ID: <CAPcyv4iaWD0oxYfDWZr1Vsp0NYcYtBD3373vsY9YyQYYqis+mQ@mail.gmail.com>
Subject: Re: [PATCH v2 00/20] get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Stephen Bates <Stephen.Bates@pmcs.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Mon, Dec 7, 2015 at 4:00 PM, Logan Gunthorpe <logang@deltatee.com> wrote:
> Hi Dan,
>
> I've done a bit of digging and here's some more information:
>
> * The crash occurs in ext4_end_io_unwritten when it tries to dereference
> bh->b_assoc_map which is not necessarily NULL.
>
> * That function is called by __dax_pmd_fault, as the argument
> complete_unwritten.
>
> * Looking in __dax_pmd_fault, the bug occurs if we hit either of the first
> two 'goto fallback' lines. (In my case, it's hitting the first one.)
>
> * After the fallback code, it goes back to 'out', then checks '&bh'
> for the unwritten flag. But bh hasn't been initialized yet and, on my setup,
> the unwritten flag happens to be set. So, it then calls complete_unwritten
> with a garbage bh and crashes.
>
> If I move the memset(&bh) up in the code, before the goto fallbacks can
> occur, I can fix the crash.  I don't know if this is really the best way to
> fix the problem though.

I believe you are hitting the same issue that Matthew hit here:

https://patchwork.kernel.org/patch/7763851/

I have it fixed up in the latest that I pushed out last night to
libnvdimm-pending.  Note the libnvdimm-pending branch is now based on
linux-next as I needed to resolve collisions with transparent huge
page work pending in the -mm tree.

> However, unfortunately, fixing the above just uncovered another issue. Now
> the MR de-registration seems to have completed but the task hangs when it's
> trying to munmap the memory. (Stack trace at the end of this email.)
>
> It looks like the i_mmap_lock_write is hanging in unlink_file_vma. I'm not
> really sure how to go about debugging this lock issue. If you have any steps
> I can try to get you more information let me know. I'm also happy to re-test
> if you have any other changes you'd like me to try.

I worked through a crop of hangs and crashes triggered by Toshi's mmap
test.  Give the latest a try if you get a chance and I'll fix it up if
it still occurs.  I'll be pushing an updated branch again tonight with
fixes for issues uncovered while running the nvml test suite.

Thanks Logan!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
