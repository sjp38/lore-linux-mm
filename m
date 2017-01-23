Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 327A76B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 16:36:25 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 14so213530266pgg.4
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 13:36:25 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y96si16802245plh.249.2017.01.23.13.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 13:36:24 -0800 (PST)
Date: Mon, 23 Jan 2017 14:36:14 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] mm, fs: reduce fault, page_mkwrite, and pfn_mkwrite to
 take only vmf
Message-ID: <20170123213614.GA27007@linux.intel.com>
References: <148495502151.58418.7078842737664999534.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148495502151.58418.7078842737664999534.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, tytso@mit.edu, darrick.wong@oracle.com, mawilcox@microsoft.com, dave.hansen@intel.com, hch@lst.de, linux-mm@kvack.org, jack@suse.com, linux-fsdevel@vger.kernel.org, ross.zwisler@linux.intel.com, dan.j.williams@intel.com, linux-nvdimm@lists.01.org

On Fri, Jan 20, 2017 at 04:33:08PM -0700, Dave Jiang wrote:
> ->fault(), ->page_mkwrite(), and ->pfn_mkwrite() calls do not need to take
> a vma and vmf parameter when the vma already resides in vmf. Remove the vma
> parameter to simplify things.
> 
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
> ---
> 
> This patch has received a build success notification from the 0day-kbuild
> robot across 124 configs. 
> 
> ---
<>
> diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
> index 10820f6..b6661fd 100644
> --- a/arch/x86/entry/vdso/vma.c
> +++ b/arch/x86/entry/vdso/vma.c
> @@ -38,7 +38,7 @@ void __init init_vdso_image(const struct vdso_image *image)
>  struct linux_binprm;
>  
>  static int vdso_fault(const struct vm_special_mapping *sm,
> -		      struct vm_area_struct *vma, struct vm_fault *vmf)
> +		struct vm_area_struct *vma, struct vm_fault *vmf)

Unneeded spacing change.

Other than that, this looks good to me.  I agree with Jan's observation that
it creates a lot of thrash, but I personally like the change because it
eliminates the question of what to do when the 'vma' you're passed in doesn't
match 'vmf->vma'.  Having one source of truth seems good, and it reduces the
amount of args we are passing around.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
