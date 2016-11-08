Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E01C16B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 07:32:11 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so68955318pfb.6
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 04:32:11 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50134.outbound.protection.outlook.com. [40.107.5.134])
        by mx.google.com with ESMTPS id s7si22972162pgn.194.2016.11.08.04.32.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 04:32:10 -0800 (PST)
Subject: Re: [PATCHv3 1/8] powerpc/vdso: unify return paths in
 setup_additional_pages
References: <20161027170948.8279-1-dsafonov@virtuozzo.com>
 <20161027170948.8279-2-dsafonov@virtuozzo.com>
 <87mvhaltl5.fsf@concordia.ellerman.id.au>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <4fac19b7-aeec-f2b7-02fe-85c219151c3b@virtuozzo.com>
Date: Tue, 8 Nov 2016 15:29:14 +0300
MIME-Version: 1.0
In-Reply-To: <87mvhaltl5.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On 11/08/2016 03:10 AM, Michael Ellerman wrote:
> Hi Dmitry,
>
> Thanks for the patches.
>
> Dmitry Safonov <dsafonov@virtuozzo.com> writes:
>> Impact: cleanup
>
> I'm not a fan of these "Impact" lines, especially when they're not
> correct, ie. this is not a cleanup, a cleanup doesn't change logic.
>
>> Rename `rc' variable which doesn't seems to mean anything into
>> kernel-known `ret'.
>
> 'rc' means "Return Code", it's fairly common. I see at least ~8500
> "int rc" declarations in the kernel.
>
> Please don't rename variables and change logic in one patch.

Ok, right - just didn't saw `rc' that freq as `ret'.
Will leave the name.

>> Combine two function returns into one as it's
>> also easier to read.
>>
>> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Cc: Paul Mackerras <paulus@samba.org>
>> Cc: Michael Ellerman <mpe@ellerman.id.au>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Oleg Nesterov <oleg@redhat.com>
>> Cc: linuxppc-dev@lists.ozlabs.org
>> Cc: linux-mm@kvack.org
>> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
>> ---
>>  arch/powerpc/kernel/vdso.c | 19 +++++++------------
>>  1 file changed, 7 insertions(+), 12 deletions(-)
>>
>> diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
>> index 4111d30badfa..4ffb82a2d9e9 100644
>> --- a/arch/powerpc/kernel/vdso.c
>> +++ b/arch/powerpc/kernel/vdso.c
>> @@ -154,7 +154,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
>>  	struct page **vdso_pagelist;
>>  	unsigned long vdso_pages;
>>  	unsigned long vdso_base;
>> -	int rc;
>> +	int ret = 0;
>
> Please don't initialise return codes in the declaration, it prevents the
> compiler from warning you if you forget to initialise it in a
> particular path.
>
> AFAICS you never even use the default value either.

Oh, right - I split this patch from converting install_special_mapping()
to special vma version _install_special_mapping(), 6/8 patch in series.
Will move initialization to that patch.

>>  	if (!vdso_ready)
>>  		return 0;
>> @@ -203,8 +203,8 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
>>  				      ((VDSO_ALIGNMENT - 1) & PAGE_MASK),
>>  				      0, 0);
>>  	if (IS_ERR_VALUE(vdso_base)) {
>> -		rc = vdso_base;
>> -		goto fail_mmapsem;
>> +		ret = vdso_base;
>> +		goto out_up_mmap_sem;
>>  	}
>>
>>  	/* Add required alignment. */
>> @@ -227,21 +227,16 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
>>  	 * It's fine to use that for setting breakpoints in the vDSO code
>>  	 * pages though.
>>  	 */
>> -	rc = install_special_mapping(mm, vdso_base, vdso_pages << PAGE_SHIFT,
>> +	ret = install_special_mapping(mm, vdso_base, vdso_pages << PAGE_SHIFT,
>>  				     VM_READ|VM_EXEC|
>>  				     VM_MAYREAD|VM_MAYWRITE|VM_MAYEXEC,
>>  				     vdso_pagelist);
>> -	if (rc) {
>> +	if (ret)
>>  		current->mm->context.vdso_base = 0;
>> -		goto fail_mmapsem;
>> -	}
>> -
>> -	up_write(&mm->mmap_sem);
>> -	return 0;
>>
>> - fail_mmapsem:
>> +out_up_mmap_sem:
>>  	up_write(&mm->mmap_sem);
>> -	return rc;
>> +	return ret;
>>  }
>
>
> If you strip out the variable renames then I think that change would be
> OK.
>
> cheers
>


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
