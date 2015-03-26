Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 48B096B006C
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:17:41 -0400 (EDT)
Received: by wgs2 with SMTP id 2so66084321wgs.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:17:40 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id gz6si10115750wjc.142.2015.03.26.07.17.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 07:17:39 -0700 (PDT)
Received: by wibg7 with SMTP id g7so150310998wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:17:39 -0700 (PDT)
Date: Thu, 26 Mar 2015 15:17:31 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 2/2] powerpc/mm: Tracking vDSO remap
Message-ID: <20150326141730.GA23060@gmail.com>
References: <20150325121118.GA2542@gmail.com>
 <cover.1427289960.git.ldufour@linux.vnet.ibm.com>
 <b6ce07f8e1e0d654371aee70bd8eac310456d0df.1427289960.git.ldufour@linux.vnet.ibm.com>
 <20150325183316.GA9090@gmail.com>
 <20150325183647.GA9331@gmail.com>
 <1427317867.6468.87.camel@kernel.crashing.org>
 <20150326094330.GA15407@gmail.com>
 <5513E16D.1030101@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5513E16D.1030101@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org


* Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> > I argue we should use the right condition to clear vdso_base: if 
> > the vDSO gets at least partially unmapped. Otherwise there's 
> > little point in the whole patch: either correctly track whether 
> > the vDSO is OK, or don't ...
> 
> That's a good option, but it may be hard to achieve in the case the 
> vDSO area has been splitted in multiple pieces.
>
> Not sure there is a right way to handle that, here this is a best 
> effort, allowing a process to unmap its vDSO and having the 
> sigreturn call done through the stack area (it has to make it 
> executable).
> 
> Anyway I'll dig into that, assuming that the vdso_base pointer 
> should be clear if a part of the vDSO is moved or unmapped. The 
> patch will be larger since I'll have to get the vDSO size which is 
> private to the vdso.c file.

At least for munmap() I don't think that's a worry: once unmapped 
(even if just partially), vdso_base becomes zero and won't ever be set 
again.

So no need to track the zillion pieces, should there be any: Humpty 
Dumpty won't be whole again, right?

> > There's also the question of mprotect(): can users mprotect() the 
> > vDSO on PowerPC?
> 
> Yes, mprotect() the vDSO is allowed on PowerPC, as it is on x86, and 
> certainly all the other architectures. Furthermore, if it is done on 
> a partial part of the vDSO it is splitting the vma...

btw., CRIU's main purpose here is to reconstruct a vDSO that was 
originally randomized, but whose address must now be reproduced as-is, 
right?

In that sense detecting the 'good' mremap() as your patch does should 
do the trick and is certainly not objectionable IMHO - I was just 
wondering whether we could make a perfect job very simply.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
