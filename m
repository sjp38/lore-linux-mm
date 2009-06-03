Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF1B66B00D2
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 15:20:23 -0400 (EDT)
Date: Wed, 3 Jun 2009 20:21:17 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
Message-ID: <20090603202117.39b070d5@lxorguk.ukuu.org.uk>
In-Reply-To: <alpine.DEB.1.10.0906031458250.9269@gentwo.org>
References: <20090530230022.GO6535@oblivion.subreption.com>
	<alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>
	<20090531022158.GA9033@oblivion.subreption.com>
	<alpine.DEB.1.10.0906021130410.23962@gentwo.org>
	<20090602203405.GC6701@oblivion.subreption.com>
	<alpine.DEB.1.10.0906031047390.15621@gentwo.org>
	<20090603182949.5328d411@lxorguk.ukuu.org.uk>
	<alpine.LFD.2.01.0906031032390.4880@localhost.localdomain>
	<20090603180037.GB18561@oblivion.subreption.com>
	<alpine.LFD.2.01.0906031109150.4880@localhost.localdomain>
	<20090603183939.GC18561@oblivion.subreption.com>
	<alpine.LFD.2.01.0906031142390.4880@localhost.localdomain>
	<alpine.LFD.2.01.0906031145460.4880@localhost.localdomain>
	<alpine.DEB.1.10.0906031458250.9269@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Larry H." <research@subreption.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009 14:59:51 -0400 (EDT)
Christoph Lameter <cl@linux-foundation.org> wrote:

> We could just move the check for mmap_min_addr out from
> CONFIG_SECURITY?
> 
> 
> Use mmap_min_addr indepedently of security models
> 
> This patch removes the dependency of mmap_min_addr on CONFIG_SECURITY.
> It also sets a default mmap_min_addr of 4096.
> 
> mmapping of addresses below 4096 will only be possible for processes
> with CAP_SYS_RAWIO.

This appears to break the security models as they can no longer replace
the CAP_SYS_RAWIO check with something based on the security model.

> @@ -1043,6 +1046,9 @@ unsigned long do_mmap_pgoff(struct file
>  		}
>  	}
> 
> +	if ((addr < mmap_min_addr) && !capable(CAP_SYS_RAWIO))
> +		return -EACCES;
> +

You can't move this bit here

>  	error = security_file_mmap(file, reqprot, prot, flags, addr, 0);

You need it in the default (no security) version of security_file_mmap()
in security.h not hard coded into do_mmap_pgoff, and leave the one in
cap_* alone.

So NAK - not to the idea but to the fact the patch is buggy.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
