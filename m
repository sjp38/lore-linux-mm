Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 001766B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 07:02:24 -0400 (EDT)
Received: by wgra20 with SMTP id a20so94889529wgr.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 04:02:24 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id lf5si2666108wjb.111.2015.03.27.04.02.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 04:02:23 -0700 (PDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 27 Mar 2015 11:02:21 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 18615219005C
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 11:02:06 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2RB2HLC59310332
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 11:02:17 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2RB2Gj0007685
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 05:02:17 -0600
Message-ID: <551538B5.2030507@linux.vnet.ibm.com>
Date: Fri, 27 Mar 2015 12:02:13 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/2] powerpc/mm: Tracking vDSO remap
References: <20150326141730.GA23060@gmail.com> <cover.1427390952.git.ldufour@linux.vnet.ibm.com> <7fdae652993cf88bdd633d65e5a8f81c7ad8a1e3.1427390952.git.ldufour@linux.vnet.ibm.com> <20150326185550.GA25547@gmail.com>
In-Reply-To: <20150326185550.GA25547@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org

On 26/03/2015 19:55, Ingo Molnar wrote:
> 
> * Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:
> 
>> +{
>> +	unsigned long vdso_end, vdso_start;
>> +
>> +	if (!mm->context.vdso_base)
>> +		return;
>> +	vdso_start = mm->context.vdso_base;
>> +
>> +#ifdef CONFIG_PPC64
>> +	/* Calling is_32bit_task() implies that we are dealing with the
>> +	 * current process memory. If there is a call path where mm is not
>> +	 * owned by the current task, then we'll have need to store the
>> +	 * vDSO size in the mm->context.
>> +	 */
>> +	BUG_ON(current->mm != mm);
>> +	if (is_32bit_task())
>> +		vdso_end = vdso_start + (vdso32_pages << PAGE_SHIFT);
>> +	else
>> +		vdso_end = vdso_start + (vdso64_pages << PAGE_SHIFT);
>> +#else
>> +	vdso_end = vdso_start + (vdso32_pages << PAGE_SHIFT);
>> +#endif
>> +	vdso_end += (1<<PAGE_SHIFT); /* data page */
>> +
>> +	/* Check if the vDSO is in the range of the remapped area */
>> +	if ((vdso_start <= old_start && old_start < vdso_end) ||
>> +	    (vdso_start < old_end && old_end <= vdso_end)  ||
>> +	    (old_start <= vdso_start && vdso_start < old_end)) {
>> +		/* Update vdso_base if the vDSO is entirely moved. */
>> +		if (old_start == vdso_start && old_end == vdso_end &&
>> +		    (old_end - old_start) == (new_end - new_start))
>> +			mm->context.vdso_base = new_start;
>> +		else
>> +			mm->context.vdso_base = 0;
>> +	}
>> +}
> 
> Oh my, that really looks awfully complex, as you predicted, and right 
> in every mremap() call.

I do agree, that's awfully complex ;)

> I'm fine with your original, imperfect, KISS approach. Sorry about 
> this detour ...
>
> Reviewed-by: Ingo Molnar <mingo@kernel.org>

No problem, so let's stay on the v3 version of the patch.
Thanks for Reviewed-by statement which, I guess, applied to the v3 too.
Should I resend the v3 ?

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
