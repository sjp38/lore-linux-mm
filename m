Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5626B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 06:37:44 -0400 (EDT)
Received: by wgra20 with SMTP id a20so58960408wgr.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 03:37:44 -0700 (PDT)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id je4si27473136wic.42.2015.03.26.03.37.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 03:37:43 -0700 (PDT)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 26 Mar 2015 10:37:42 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4493317D805A
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:38:07 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2QAbcR47995806
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:37:38 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2QAbZE5027874
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:37:38 -0600
Message-ID: <5513E16D.1030101@linux.vnet.ibm.com>
Date: Thu, 26 Mar 2015 11:37:33 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] powerpc/mm: Tracking vDSO remap
References: <20150325121118.GA2542@gmail.com> <cover.1427289960.git.ldufour@linux.vnet.ibm.com> <b6ce07f8e1e0d654371aee70bd8eac310456d0df.1427289960.git.ldufour@linux.vnet.ibm.com> <20150325183316.GA9090@gmail.com> <20150325183647.GA9331@gmail.com> <1427317867.6468.87.camel@kernel.crashing.org> <20150326094330.GA15407@gmail.com>
In-Reply-To: <20150326094330.GA15407@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org

On 26/03/2015 10:43, Ingo Molnar wrote:
> 
> * Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
>> On Wed, 2015-03-25 at 19:36 +0100, Ingo Molnar wrote:
>>> * Ingo Molnar <mingo@kernel.org> wrote:
>>>
>>>>> +#define __HAVE_ARCH_REMAP
>>>>> +static inline void arch_remap(struct mm_struct *mm,
>>>>> +			      unsigned long old_start, unsigned long old_end,
>>>>> +			      unsigned long new_start, unsigned long new_end)
>>>>> +{
>>>>> +	/*
>>>>> +	 * mremap() doesn't allow moving multiple vmas so we can limit the
>>>>> +	 * check to old_start == vdso_base.
>>>>> +	 */
>>>>> +	if (old_start == mm->context.vdso_base)
>>>>> +		mm->context.vdso_base = new_start;
>>>>> +}
>>>>
>>>> mremap() doesn't allow moving multiple vmas, but it allows the 
>>>> movement of multi-page vmas and it also allows partial mremap()s, 
>>>> where it will split up a vma.
>>>
>>> I.e. mremap() supports the shrinking (and growing) of vmas. In that 
>>> case mremap() will unmap the end of the vma and will shrink the 
>>> remaining vDSO vma.
>>>
>>> Doesn't that result in a non-working vDSO that should zero out 
>>> vdso_base?
>>
>> Right. Now we can't completely prevent the user from shooting itself 
>> in the foot I suppose, though there is a legit usage scenario which 
>> is to move the vDSO around which it would be nice to support. I 
>> think it's reasonable to put the onus on the user here to do the 
>> right thing.
> 
> I argue we should use the right condition to clear vdso_base: if the 
> vDSO gets at least partially unmapped. Otherwise there's little point 
> in the whole patch: either correctly track whether the vDSO is OK, or 
> don't ...

That's a good option, but it may be hard to achieve in the case the vDSO
area has been splitted in multiple pieces.

Not sure there is a right way to handle that, here this is a best
effort, allowing a process to unmap its vDSO and having the sigreturn
call done through the stack area (it has to make it executable).

Anyway I'll dig into that, assuming that the vdso_base pointer should be
clear if a part of the vDSO is moved or unmapped. The patch will be
larger since I'll have to get the vDSO size which is private to the
vdso.c file.

> There's also the question of mprotect(): can users mprotect() the vDSO 
> on PowerPC?

Yes, mprotect() the vDSO is allowed on PowerPC, as it is on x86, and
certainly all the other architectures.
Furthermore, if it is done on a partial part of the vDSO it is splitting
the vma...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
