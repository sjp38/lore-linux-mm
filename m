Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 12D7A6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 06:14:03 -0400 (EDT)
Received: by wibg7 with SMTP id g7so142334529wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 03:14:02 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id gy8si9784215wib.118.2015.03.26.03.14.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 03:14:01 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 26 Mar 2015 10:14:00 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 84D8D1B08069
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:14:24 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2QADwfv64880858
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:13:58 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2QADtxE024090
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:13:57 -0600
Message-ID: <5513DBE1.4070404@linux.vnet.ibm.com>
Date: Thu, 26 Mar 2015 11:13:53 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] powerpc/mm: Tracking vDSO remap
References: <20150325121118.GA2542@gmail.com> <cover.1427289960.git.ldufour@linux.vnet.ibm.com> <b6ce07f8e1e0d654371aee70bd8eac310456d0df.1427289960.git.ldufour@linux.vnet.ibm.com> <20150325183316.GA9090@gmail.com> <1427317797.6468.86.camel@kernel.crashing.org> <20150326094844.GB15407@gmail.com>
In-Reply-To: <20150326094844.GB15407@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org

On 26/03/2015 10:48, Ingo Molnar wrote:
> 
> * Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
>>>> +#define __HAVE_ARCH_REMAP
>>>> +static inline void arch_remap(struct mm_struct *mm,
>>>> +			      unsigned long old_start, unsigned long old_end,
>>>> +			      unsigned long new_start, unsigned long new_end)
>>>> +{
>>>> +	/*
>>>> +	 * mremap() doesn't allow moving multiple vmas so we can limit the
>>>> +	 * check to old_start == vdso_base.
>>>> +	 */
>>>> +	if (old_start == mm->context.vdso_base)
>>>> +		mm->context.vdso_base = new_start;
>>>> +}
>>>
>>> mremap() doesn't allow moving multiple vmas, but it allows the 
>>> movement of multi-page vmas and it also allows partial mremap()s, 
>>> where it will split up a vma.
>>>
>>> In particular, what happens if an mremap() is done with 
>>> old_start == vdso_base, but a shorter end than the end of the vDSO? 
>>> (i.e. a partial mremap() with fewer pages than the vDSO size)
>>
>> Is there a way to forbid splitting ? Does x86 deal with that case at 
>> all or it doesn't have to for some other reason ?
> 
> So we use _install_special_mapping() - maybe PowerPC does that too? 
> That adds VM_DONTEXPAND which ought to prevent some - but not all - of 
> the VM API weirdnesses.

The same is done on PowerPC. So calling mremap() to extend the vDSO is
failing but splitting it or unmapping a part of it is allowed but lead
to an unusable vDSO.

> On x86 we'll just dump core if someone unmaps the vdso.

On PowerPC, you'll get the same result.

Should we prevent the user to break its vDSO ?

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
