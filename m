Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4116B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 19:09:36 -0400 (EDT)
Received: by ietj16 with SMTP id j16so13290043iet.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 16:09:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t33si6536646ioi.1.2015.07.09.16.09.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 16:09:35 -0700 (PDT)
Date: Thu, 9 Jul 2015 16:09:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: cleaning per architecture MM hook header files
Message-Id: <20150709160934.888dad2b24ce45957e65b139@linux-foundation.org>
In-Reply-To: <1435745853-27535-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <55924508.9080101@synopsys.com>
	<1435745853-27535-1-git-send-email-ldufour@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Vineet Gupta <Vineet.Gupta1@synopsys.com>, Geert Uytterhoeven <geert@linux-m68k.org>, uclinux-h8-devel@lists.sourceforge.jp, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

On Wed,  1 Jul 2015 12:17:33 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> The commit 2ae416b142b6 ("mm: new mm hook framework") introduced an empty
> header file (mm-arch-hooks.h) for every architecture, even those which
> doesn't need to define mm hooks.
> 
> As suggested by Geert Uytterhoeven, this could be cleaned through the use
> of a generic header file included via each per architecture
> asm/include/Kbuild file.
> 
> The PowerPC architecture is not impacted here since this architecture has
> to defined the arch_remap MM hook.

So the way this works is that if an arch wants to override a hook, it
will remove the "generic-y += mm-arch-hooks.h" and add
arch/XXX/include/asm/mm-arch-hooks.h, yes?

And the new arch/XXX/include/asm/mm-arch-hooks.h only needs to define
the hook(s) which the arch wants to override?

So nothing will ever be added to include/asm-generic/mm-arch-hooks.h?

Seems fair enough.

Oleg is angling to remove arch_remap(), so there won't be anything left
in these files!  But there are plenty of ad-hoc things which *should*
be moved over.

> Changes in V2:
> --------------
>  - Vineet Gupta reported that the Kbuild files should be kept sorted.

Yes, we do this to avoid patch collisions.  Everyone always adds stuff
to the end of the list (Makefiles, #includes, etc etc), thus carefully
maximizing the number of patch collisions :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
