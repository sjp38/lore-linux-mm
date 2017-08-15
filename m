Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F2E466B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 08:42:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m80so1444830wmd.4
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:42:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j97si7411917wrj.127.2017.08.15.05.42.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 05:42:52 -0700 (PDT)
Date: Tue, 15 Aug 2017 14:42:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 3/3] fs, xfs: introduce MAP_DIRECT for creating
 block-map-sealed file ranges
Message-ID: <20170815124250.GG27505@quack2.suse.cz>
References: <150277752553.23945.13932394738552748440.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150277754211.23945.458876600578531019.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150277754211.23945.458876600578531019.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: darrick.wong@oracle.com, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Mon 14-08-17 23:12:22, Dan Williams wrote:
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index ff151814a02d..73fdc0ada9ee 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -306,6 +306,7 @@ struct vm_area_struct {
>  	struct mm_struct *vm_mm;	/* The address space we belong to. */
>  	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
>  	unsigned long vm_flags;		/* Flags, see mm.h. */
> +	unsigned long fs_flags;		/* fs flags, see MAP_DIRECT etc */
>  
>  	/*
>  	 * For areas with an address space and backing store,

Ah, OK, here are VMA flags I was missing in the previous patch :) But why
did you create separate fs_flags field for this? on 64-bit archs there's
still space in vm_flags and frankly I don't see why we should separate
MAP_DIRECT or MAP_SYNC from other flags? After all a difference in these
flags must also prevent VMA merging (which you forgot to handle I think)
and they need to be copied on split (which happens by chance even now).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
