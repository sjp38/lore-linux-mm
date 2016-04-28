Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3ADD36B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 14:53:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so180820753pfe.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:53:26 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id w127si11544495pfb.38.2016.04.28.11.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 11:53:25 -0700 (PDT)
Subject: Re: VDSO unmap and remap support for additional architectures
References: <20151202121918.GA4523@arm.com>
 <1461856737-17071-1-git-send-email-cov@codeaurora.org>
From: Andy Lutomirski <luto@kernel.org>
Message-ID: <2ce7203f-305c-6edf-0ef9-448c141cb103@kernel.org>
Date: Thu, 28 Apr 2016 11:53:22 -0700
MIME-Version: 1.0
In-Reply-To: <1461856737-17071-1-git-send-email-cov@codeaurora.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Covington <cov@codeaurora.org>, Catalin Marinas <catalin.marinas@arm.com>, criu@openvz.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Will Deacon <Will.Deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, dsafonov@virtuozzo.com

On 04/28/2016 08:18 AM, Christopher Covington wrote:
> Please take a look at the following prototype of sharing the PowerPC
> VDSO unmap and remap code with other architectures. I've only hooked
> up arm64 to begin with. If folks think this is a reasonable approach I
> can work on 32 bit ARM as well. Not hearing back from an earlier
> request for guidance [1], I simply dove in and started hacking.
> Laurent's test case [2][3] is a compelling illustration of whether VDSO
> remap works or not on a given architecture.

I think there's a much nicer way:

https://lkml.kernel.org/r/1461584223-9418-1-git-send-email-dsafonov@virtuozzo.com

Could arm64 and ppc use this approach?  These arch_xyz hooks are gross.

Also, at some point, possibly quite soon, x86 will want a way for user code to ask the kernel to map a specific vdso variant at a specific address.  Could we perhaps add a new pair of syscalls:

struct vdso_info {
    unsigned long space_needed_before;
    unsigned long space_needed_after;
    unsigned long alignment;
};

long vdso_get_info(unsigned int vdso_type, struct vdso_info *info);

long vdso_remap(unsigned int vdso_type, unsigned long addr, unsigned int flags);

#define VDSO_X86_I386 0
#define VDSO_X86_64 1
#define VDSO_X86_X32 2
// etc.

vdso_remap will map the vdso of the chosen type such at AT_SYSINFO_EHDR lines up with addr.  It will use up to space_needed_before bytes before that address and space_needed_after after than address.  It will also unmap the old vdso (or maybe only do that if some flag is set).

On x86, mremap is *not* sufficient for everything that's needed, because some programs will need to change the vdso type.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
