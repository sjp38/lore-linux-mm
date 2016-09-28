Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA1A428024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 22:56:20 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 82so80018609ioh.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 19:56:20 -0700 (PDT)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id n21si7213687ioe.68.2016.09.27.19.56.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 19:56:20 -0700 (PDT)
Date: Tue, 27 Sep 2016 20:55:44 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v5] powerpc: Do not make the entire heap executable
Message-ID: <20160928025544.GA24199@obsidianresearch.com>
References: <20160822185105.29600-1-dvlasenk@redhat.com>
 <87d1jo7qbw.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d1jo7qbw.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linuxppc-dev@lists.ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Oleg Nesterov <oleg@redhat.com>, Florian Weimer <fweimer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 28, 2016 at 11:42:11AM +1000, Michael Ellerman wrote:

> But this is not really a powerpc patch, and I'm not an ELF expert. So
> I'm not comfortable merging it via the powerpc tree. It doesn't look
> like we really have a maintainer for binfmt_elf.c, so I'm not sure who
> should be acking that part.

Thanks a bunch for looking at this Michael.

> I've added Al Viro to Cc, he maintains fs/ and might be interested.

> I've also added Andrew Morton who might be happy to put this in his
> tree, and see if anyone complains?

For those added to the CC, I would re-state my original commit message
more clearly.

My research showed that the ELF loader bug fixed in this patch is the
root cause bug fix required to implement this hunk:

> > -#define VM_DATA_DEFAULT_FLAGS32	(VM_READ | VM_WRITE | VM_EXEC | \
> > +#define VM_DATA_DEFAULT_FLAGS32 \
> > +	(((current->personality & READ_IMPLIES_EXEC) ? VM_EXEC : 0) | \
> > +				 VM_READ | VM_WRITE | \
> >  				 VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)

Eg that 32 bit powerpc currently unconditionally injects writable,
executable pages into a user space process.

This critically undermines all the W^X security work that has been
done in the tool chain and user space by the PPC community.

I would encourage people to view this as an important security patch
for 32 bit powerpc environments.

Regards,
Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
