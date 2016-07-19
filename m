Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBD1F6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 05:21:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x83so9657480wma.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 02:21:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w6si1785735wmw.38.2016.07.19.02.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 02:21:42 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6J9JZ86130977
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 05:21:41 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2496ebj0y9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 05:21:40 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 19 Jul 2016 10:21:39 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id D91561B0805F
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 10:23:00 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6J9Lb3Z9109926
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 09:21:37 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6J9LG6i011617
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 03:21:36 -0600
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Tue, 19 Jul 2016 11:21:13 +0200
MIME-Version: 1.0
In-Reply-To: <1468619065-3222-3-git-send-email-keescook@chromium.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <578DF109.5030704@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org
Cc: Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On 07/15/2016 11:44 PM, Kees Cook wrote:
> +config HAVE_ARCH_LINEAR_KERNEL_MAPPING
> +	bool
> +	help
> +	  An architecture should select this if it has a secondary linear
> +	  mapping of the kernel text. This is used to verify that kernel
> +	  text exposures are not visible under CONFIG_HARDENED_USERCOPY.

I have trouble parsing this. (What does secondary linear mapping mean?)
So let me give an example below

> +
[...]
> +/* Is this address range in the kernel text area? */
> +static inline const char *check_kernel_text_object(const void *ptr,
> +						   unsigned long n)
> +{
> +	unsigned long textlow = (unsigned long)_stext;
> +	unsigned long texthigh = (unsigned long)_etext;
> +
> +	if (overlaps(ptr, n, textlow, texthigh))
> +		return "<kernel text>";
> +
> +#ifdef HAVE_ARCH_LINEAR_KERNEL_MAPPING
> +	/* Check against linear mapping as well. */
> +	if (overlaps(ptr, n, (unsigned long)__va(__pa(textlow)),
> +		     (unsigned long)__va(__pa(texthigh))))
> +		return "<linear kernel text>";
> +#endif
> +
> +	return NULL;
> +}

s390 has an address space for user (primary address space from 0..4TB/8PB) and a separate 
address space (home space from 0..4TB/8PB) for the kernel. In this home space the kernel
mapping is virtual containing the physical memory as well as vmalloc memory (creating aliases
into the physical one). The kernel text is mapped from _stext to _etext in this mapping.
So I assume this would qualify for HAVE_ARCH_LINEAR_KERNEL_MAPPING ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
