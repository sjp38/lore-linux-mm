Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC6A6B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 12:43:36 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id ho8so32231466pac.2
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:43:36 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sm4si13748298pac.245.2016.02.11.09.43.34
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 09:43:35 -0800 (PST)
Date: Thu, 11 Feb 2016 10:42:55 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/2] dax: rename dax_radix_entry to dax_radix_entry_insert
Message-ID: <20160211174255.GA11014@linux.intel.com>
References: <87bn7rwim2.fsf@openvz.org>
 <1454939598-16238-1-git-send-email-dmonakhov@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1454939598-16238-1-git-send-email-dmonakhov@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Monakhov <dmonakhov@openvz.org>
Cc: linux-mm@kvack.org, willy@linux.intel.com, ross.zwisler@linux.intel.com

On Mon, Feb 08, 2016 at 05:53:17PM +0400, Dmitry Monakhov wrote:
> - dax_radix_entry_insert is more appropriate name for that function

I think I may have actually had it named that at some point. :)  I changed it   
because it doesn't always insert an entry - in the read case for example we     
insert a clean entry, and then on the following dax_pfn_mkwrite() we call back  
in and mark it as dirty. 

> - Add lockless helper __dax_radix_entry_insert, it will be used by second patch
> 
> Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
> ---
>  fs/dax.c | 39 +++++++++++++++++++++++----------------
>  1 file changed, 23 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index fc2e314..89bb1f8 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
<>
> @@ -579,8 +586,8 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
>  	}
>  	dax_unmap_atomic(bdev, &dax);
>  
> -	error = dax_radix_entry(mapping, vmf->pgoff, dax.sector, false,
> -			vmf->flags & FAULT_FLAG_WRITE);
> +	error = dax_radix_entry_insert(mapping, vmf->pgoff, dax.sector, false,
> +				vmf->flags & FAULT_FLAG_WRITE, vmf->page);

fs/dax.c: In function a??dax_insert_mappinga??:
fs/dax.c:589:10: error: too many arguments to function a??dax_radix_entry_inserta??
  error = dax_radix_entry_insert(mapping, vmf->pgoff, dax.sector, false,
          ^
fs/dax.c:415:12: note: declared here
 static int dax_radix_entry_insert(struct address_space *mapping, pgoff_t index,
            ^
scripts/Makefile.build:258: recipe for target 'fs/dax.o' failed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
