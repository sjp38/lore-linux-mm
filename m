Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92F156B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 09:36:33 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id j12so75444799ywb.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 06:36:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m20si14560575qke.275.2016.08.10.06.36.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 06:36:32 -0700 (PDT)
Date: Wed, 10 Aug 2016 15:36:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4] powerpc: Do not make the entire heap executable
Message-ID: <20160810133621.GA30167@redhat.com>
References: <20160810130030.5268-1-dvlasenk@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160810130030.5268-1-dvlasenk@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <dvlasenk@redhat.com>
Cc: linuxppc-dev@lists.ozlabs.org, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>, Florian Weimer <fweimer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/10, Denys Vlasenko wrote:
>
> Currently, to support 32-bit binaries with PLT in BSS kernel maps *entire
> brk area* with executable rights for all binaries, even --secure-plt ones.
>
> Stop doing that.

Can't really review this patch, but at least the change in mm/mmap.c looks
technically correct to me... One nit below, feel free to ignore.

> @@ -2668,7 +2668,7 @@ static int do_brk(unsigned long addr, unsigned long request)
>  	if (!len)
>  		return 0;
>
> -	flags = VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
> +	flags |= VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;

OK. But note that we have

	mlock_future_check(mm->def_flags);

a few lines below and after this change this _looks_ wrong because
VM_LOCKED can come from the new "flags" argument passed to do_brk().
Nobody does this right now, still this looks wrong/confusing.

I'd suggest to add another change

	-	mlock_future_check(mm->def_flags);
	+	mlock_future_check(flags);

or add a sanity check at the start to deny VM_LOCKED and perhaps
something else...

The same for vm_brk_flags() which after your change does

	do_brk_flags(flags);
	populate = (mm->def_flags & VM_LOCKED);

again, this is just a nit, I do not think it will be ever called
with VM_LOCKED in "flags".

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
