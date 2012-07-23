Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id D913A6B005A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 06:58:39 -0400 (EDT)
Date: Mon, 23 Jul 2012 13:58:19 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 2/2 v5][resend] tmpfs: interleave the starting node of
 /dev/shmem
Message-ID: <20120723105819.GA4455@mwanda>
References: <1341845199-25677-1-git-send-email-nzimmer@sgi.com>
 <1341845199-25677-2-git-send-email-nzimmer@sgi.com>
 <1341845199-25677-3-git-send-email-nzimmer@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1341845199-25677-3-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Hugh Dickins <hughd@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Mon, Jul 09, 2012 at 09:46:39AM -0500, Nathan Zimmer wrote:
> +static unsigned long shmem_interleave(struct vm_area_struct *vma,
> +					unsigned long addr)
> +{
> +	unsigned long offset;
> +
> +	/* Use the vm_files prefered node as the initial offset. */
> +	offset = (unsigned long *) vma->vm_private_data;

Should this be?:
	offset = (unsigned long)vma->vm_private_data;

offset is an unsigned long, not a pointer.  ->vm_private_data is a
void pointer.

It causes a GCC warning:
mm/shmem.c: In function a??shmem_interleavea??:
mm/shmem.c:1341:9: warning: assignment makes integer from pointer without a cast [enabled by default]

> +
> +	offset += ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> +
> +	return offset;
> +}
>  #endif

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
