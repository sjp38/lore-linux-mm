Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2FBE96B004F
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 15:46:07 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B3EA082CD28
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 16:00:54 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Qt3nFvySRDhU for <linux-mm@kvack.org>;
	Wed,  3 Jun 2009 16:00:54 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 83A6682CD31
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 16:00:47 -0400 (EDT)
Date: Wed, 3 Jun 2009 15:45:57 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <20090603202117.39b070d5@lxorguk.ukuu.org.uk>
Message-ID: <alpine.DEB.1.10.0906031542180.20254@gentwo.org>
References: <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain> <20090531022158.GA9033@oblivion.subreption.com> <alpine.DEB.1.10.0906021130410.23962@gentwo.org> <20090602203405.GC6701@oblivion.subreption.com>
 <alpine.DEB.1.10.0906031047390.15621@gentwo.org> <20090603182949.5328d411@lxorguk.ukuu.org.uk> <alpine.LFD.2.01.0906031032390.4880@localhost.localdomain> <20090603180037.GB18561@oblivion.subreption.com> <alpine.LFD.2.01.0906031109150.4880@localhost.localdomain>
 <20090603183939.GC18561@oblivion.subreption.com> <alpine.LFD.2.01.0906031142390.4880@localhost.localdomain> <alpine.LFD.2.01.0906031145460.4880@localhost.localdomain> <alpine.DEB.1.10.0906031458250.9269@gentwo.org>
 <20090603202117.39b070d5@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Larry H." <research@subreption.com>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, 3 Jun 2009, Alan Cox wrote:

> This appears to break the security models as they can no longer replace
> the CAP_SYS_RAWIO check with something based on the security model.

Right it would be fixed like CAP_SYS_NICE.

>
> > @@ -1043,6 +1046,9 @@ unsigned long do_mmap_pgoff(struct file
> >  		}
> >  	}
> >
> > +	if ((addr < mmap_min_addr) && !capable(CAP_SYS_RAWIO))
> > +		return -EACCES;
> > +
>
> You can't move this bit here

The same code is executed in security_file_mmap right now which is the
next function called at this spot.

> >  	error = security_file_mmap(file, reqprot, prot, flags, addr, 0);
>
> You need it in the default (no security) version of security_file_mmap()
> in security.h not hard coded into do_mmap_pgoff, and leave the one in
> cap_* alone.

But that would still leave it up to the security "models" to check
for basic security issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
