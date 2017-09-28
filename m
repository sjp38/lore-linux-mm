Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A244C6B0038
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 20:09:37 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b184so20603597oii.1
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 17:09:37 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f50sor44832otj.183.2017.09.27.17.09.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 17:09:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <150655619012.700.15161500295945223238.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150655617774.700.5326522538400299973.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150655619012.700.15161500295945223238.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 27 Sep 2017 17:09:36 -0700
Message-ID: <CAPcyv4gy=_QA9Ko-wz=GwvmXa2Q8t_5QZv6WM3siCoROM92hXQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] dax: stop using VM_MIXEDMAP for dax
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Wed, Sep 27, 2017 at 4:49 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> Now that we always have pages for DAX we can stop setting VM_MIXEDMAP.
> This does require some small fixups for the pte insert routines that dax
> utilizes.
>

This changelog can be improved with this from the cover letter:

VM_MIXEDMAP is used by dax to direct mm paths like vm_normal_page() that
the memory page it is dealing with is not typical memory from the linear
map. The get_user_pages_fast() path, since it does not resolve the vma,
is already using {pte,pmd}_devmap() as a stand-in for VM_MIXEDMAP, so we
use that as a VM_MIXEDMAP replacement in some locations. In the cases
where there is no pte to consult we fallback to using vma_is_dax() to
detect the VM_MIXEDMAP special case.

...I'll fold this in for v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
