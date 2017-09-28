Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC1EB6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 12:32:47 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o13so824195qtf.9
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 09:32:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t123si1822002qke.262.2017.09.28.09.32.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 09:32:47 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 2/3] dax: stop using VM_MIXEDMAP for dax
References: <150655617774.700.5326522538400299973.stgit@dwillia2-desk3.amr.corp.intel.com>
	<150655619012.700.15161500295945223238.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Thu, 28 Sep 2017 12:32:44 -0400
In-Reply-To: <150655619012.700.15161500295945223238.stgit@dwillia2-desk3.amr.corp.intel.com>
	(Dan Williams's message of "Wed, 27 Sep 2017 16:49:50 -0700")
Message-ID: <x49poaaaimr.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

Dan Williams <dan.j.williams@intel.com> writes:

> Now that we always have pages for DAX we can stop setting VM_MIXEDMAP.
> This does require some small fixups for the pte insert routines that dax
> utilizes.

It used to be that userspace would look to see if it had a 'mm' entry in
/proc/pid/smaps to determine whether or not it got a direct mapping.
Later, that same userspace (nvml) just uniformly declared dax not
available from any Linux file system, since msync was required.  And, I
guess DAX has always been marked experimental, so the interface can be
changed.

All this is to say I guess it's fine to change this.

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 680506faceae..d682f60670ff 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1111,7 +1111,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
>  	 * We later require that vma->vm_flags == vm_flags,
>  	 * so this tests vma->vm_flags & VM_SPECIAL, too.
>  	 */
> -	if (vm_flags & VM_SPECIAL)
> +	if ((vm_flags & VM_SPECIAL))
>  		return NULL;

That looks superfluous.

-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
