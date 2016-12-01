Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5175A6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 18:27:06 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y68so373141572pfb.6
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 15:27:06 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s125si2088673pgs.40.2016.12.01.15.27.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 15:27:05 -0800 (PST)
Date: Thu, 1 Dec 2016 16:27:04 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 5/6] dax: Call ->iomap_begin without entry lock during
 dax fault
Message-ID: <20161201232704.GC13739@linux.intel.com>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
 <1479980796-26161-6-git-send-email-jack@suse.cz>
 <20161201222447.GB13739@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201222447.GB13739@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Dec 01, 2016 at 03:24:47PM -0700, Ross Zwisler wrote:
> On Thu, Nov 24, 2016 at 10:46:35AM +0100, Jan Kara wrote:
> > Currently ->iomap_begin() handler is called with entry lock held. If the
> > filesystem held any locks between ->iomap_begin() and ->iomap_end()
> > (such as ext4 which will want to hold transaction open), this would cause
> > lock inversion with the iomap_apply() from standard IO path which first
> > calls ->iomap_begin() and only then calls ->actor() callback which grabs
> > entry locks for DAX.
> 
> I don't see the dax_iomap_actor() grabbing any entry locks for DAX?  Is this
> an issue currently, or are you just trying to make the code consistent so we
> don't run into issues in the future?

Ah, I see that you use this new ordering in patch 6/6 so that you can change
your interaction with the ext4 journal.  I'm still curious if we have a lock
ordering inversion within DAX, but if this ordering helps you with ext4, good
enough.

One quick comment:

> @@ -1337,19 +1353,10 @@ int dax_iomap_pmd_fault(struct vm_area_struct *vma, unsigned long address,
>        */                                                                     
>       entry = grab_mapping_entry(mapping, pgoff, RADIX_DAX_PMD);              
>       if (IS_ERR(entry))                                                      
> -             goto fallback;                                                  
> +             goto finish_iomap;                                              
>                                                                               
> -     /*                                                                      
> -      * Note that we don't use iomap_apply here.  We aren't doing I/O, only  
> -      * setting up a mapping, so really we're using iomap_begin() as a way   
> -      * to look up our filesystem block.                                     
> -      */                                                                     
> -     pos = (loff_t)pgoff << PAGE_SHIFT;                                      
> -     error = ops->iomap_begin(inode, pos, PMD_SIZE, iomap_flags, &iomap);    
> -     if (error)                                                              
> -             goto unlock_entry;                                              
>       if (iomap.offset + iomap.length < pos + PMD_SIZE)                       
> -             goto finish_iomap;                                              
> +             goto unlock_entry;       

I think this offset+length bounds check could be moved along with the
iomap_begin() call up above the grab_mapping_entry().  You would then goto
'finish_iomap' if you hit this error condition, allowing you to avoid grabbing
and releasing of the mapping entry.

Other than that one small nit, this looks fine to me:
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
