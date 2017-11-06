Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2C9E6B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 01:48:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 191so11753934pgd.0
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 22:48:08 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y1sor3575809pfl.26.2017.11.05.22.48.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 05 Nov 2017 22:48:07 -0800 (PST)
Date: Mon, 6 Nov 2017 17:47:52 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
Message-ID: <20171106174707.19f6c495@roar.ozlabs.ibm.com>
In-Reply-To: <871slcszfl.fsf@linux.vnet.ibm.com>
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
	<20171105231850.5e313e46@roar.ozlabs.ibm.com>
	<871slcszfl.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Florian Weimer <fweimer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

On Mon, 06 Nov 2017 11:48:06 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Nicholas Piggin <npiggin@gmail.com> writes:
> 
> > On Fri, 3 Nov 2017 18:05:20 +0100
> > Florian Weimer <fweimer@redhat.com> wrote:
> >  
> >> We are seeing an issue on ppc64le and ppc64 (and perhaps on some arm 
> >> variant, but I have not seen it on our own builders) where running 
> >> localedef as part of the glibc build crashes with a segmentation fault.
> >> 
> >> Kernel version is 4.13.9 (Fedora 26 variant).
> >> 
> >> I have only seen this with an explicit loader invocation, like this:
> >> 
> >> while I18NPATH=. /lib64/ld64.so.1 /usr/bin/localedef 
> >> --alias-file=../intl/locale.alias --no-archive -i locales/nl_AW -c -f 
> >> charmaps/UTF-8 
> >> --prefix=/builddir/build/BUILDROOT/glibc-2.26-16.fc27.ppc64 nl_AW ; do : 
> >> ; done
> >> 
> >> To be run in the localedata subdirectory of a glibc *source* tree, after 
> >> a build.  You may have to create the 
> >> /builddir/build/BUILDROOT/glibc-2.26-16.fc27.ppc64/usr/lib/locale 
> >> directory.  I have only reproduced this inside a Fedora 27 chroot on a 
> >> Fedora 26 host, but there it does not matter if you run the old (chroot) 
> >> or newly built binary.
> >> 
> >> I filed this as a glibc bug for tracking:
> >> 
> >>    https://sourceware.org/bugzilla/show_bug.cgi?id=22390
> >> 
> >> There's an strace log and a coredump from the crash.
> >> 
> >> I think the data shows that the address in question should be writable.
> >> 
> >> The crossed 0x0000800000000000 binary is very suggestive.  I think that 
> >> based on the operation of glibc's malloc, this write would be the first 
> >> time this happens during the lifetime of the process.
> >> 
> >> Does that ring any bells?  Is there anything I can do to provide more 
> >> data?  The host is an LPAR with a stock Fedora 26 kernel, so I can use 
> >> any diagnostics tool which is provided by Fedora.  
> >
> > There was a recent change to move to 128TB address space by default,
> > and option for 512TB addresses if explicitly requested.
> >
> > Your brk request asked for > 128TB which the kernel gave it, but the
> > address limit in the paca that the SLB miss tests against was not
> > updated to reflect the switch to 512TB address space.  
> 
> We should not return that address, unless we requested with a hint value
> of > 128TB. IIRC we discussed this early during the mmap interface
> change and said, we will return an address > 128T only if the hint
> address is above 128TB (not hint addr + length).

Yeah, I'm thinking we should change that. Make explicit addr + length
hint return > 128TB. Well, it already seems to for this case, which
is why powerpc breaks.

This restriction was added for reasonably well written apps that just
happened to assume they don't get > 128TB va returned by mmap. An app
which asked for addr < 128TB && addr + len > 128TB and were relying on
that to fail is very different. I don't think we should add a big
unintuitive wart to the interface for such an obscure and broken type
of app.

"You get < 128TB unless explicitly requested."

Simple, reasonable, obvious rule. Avoids breaking apps that store
some bits in the top of pointers (provided that memory allocator
userspace libraries also do the right thing).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
