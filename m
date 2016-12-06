Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A2AEF6B025E
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 20:02:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so406792270pgc.2
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 17:02:08 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id j68si16681056pfj.291.2016.12.05.17.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 17:02:07 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id c4so66621000pfb.1
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 17:02:07 -0800 (PST)
Date: Mon, 5 Dec 2016 17:01:58 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] device-dax: fail all private mapping attempts
In-Reply-To: <147931721349.37471.4835899844582504197.stgit@dwillia2-desk3.amr.corp.intel.com>
Message-ID: <alpine.LSU.2.11.1612051648270.1536@eggly.anvils>
References: <147931721349.37471.4835899844582504197.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Pawel Lebioda <pawel.lebioda@intel.com>

On Wed, 16 Nov 2016, Dan Williams wrote:

> The device-dax implementation originally tried to be tricky and allow
> private read-only mappings, but in the process allowed writable
> MAP_PRIVATE + MAP_NORESERVE mappings.  For simplicity and predictability
> just fail all private mapping attempts since device-dax memory is
> statically allocated and will never support overcommit.
> 
> Cc: <stable@vger.kernel.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Fixes: dee410792419 ("/dev/dax, core: file operations and dax-mmap")
> Reported-by: Pawel Lebioda <pawel.lebioda@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  drivers/dax/dax.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
> index 0e499bfca41c..3d94ff20fdca 100644
> --- a/drivers/dax/dax.c
> +++ b/drivers/dax/dax.c
> @@ -270,8 +270,8 @@ static int check_vma(struct dax_dev *dax_dev, struct vm_area_struct *vma,
>  	if (!dax_dev->alive)
>  		return -ENXIO;
>  
> -	/* prevent private / writable mappings from being established */
> -	if ((vma->vm_flags & (VM_NORESERVE|VM_SHARED|VM_WRITE)) == VM_WRITE) {
> +	/* prevent private mappings from being established */
> +	if ((vma->vm_flags & VM_SHARED) != VM_SHARED) {

I think that is more restrictive than you intended: haven't tried,
but I believe it rejects a PROT_READ, MAP_SHARED, O_RDONLY fd mmap,
leaving no way to mmap /dev/dax without write permission to it.

See line 1393 of mm/mmap.c: the test you want is probably
	if (!(vma->vm_flags & VM_MAYSHARE))

Hugh

>  		dev_info(dev, "%s: %s: fail, attempted private mapping\n",
>  				current->comm, func);
>  		return -EINVAL;
> 
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
