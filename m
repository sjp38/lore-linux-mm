Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C5C4D6B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 22:20:28 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so4489981pab.34
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 19:20:28 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id oe14si793953pdb.183.2014.10.26.19.20.27
        for <linux-mm@kvack.org>;
        Sun, 26 Oct 2014 19:20:27 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v9 10/12] x86, mpx: add prctl commands
 PR_MPX_ENABLE_MANAGEMENT, PR_MPX_DISABLE_MANAGEMENT
Date: Mon, 27 Oct 2014 02:17:58 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE0180ED65@shsmsx102.ccr.corp.intel.com>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
 <1413088915-13428-11-git-send-email-qiaowei.ren@intel.com>
 <alpine.DEB.2.11.1410241436560.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410241436560.5308@nanos>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>



On 2014-10-24, Thomas Gleixner wrote:
> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
>> +int mpx_enable_management(struct task_struct *tsk) {
>> +	struct mm_struct *mm =3D tsk->mm;
>> +	void __user *bd_base =3D MPX_INVALID_BOUNDS_DIR;
>=20
> What's the point of initializing bd_base here. I had to look twice to
> figure out that it gets overwritten by task_get_bounds_dir()
>=20

I just want to put task_get_bounds_dir() outside mm->mmap_sem holding.

>> @@ -285,6 +285,7 @@ dotraplinkage void do_bounds(struct pt_regs
>> *regs,
> long error_code)
>>  	struct xsave_struct *xsave_buf;
>>  	struct task_struct *tsk =3D current;
>>  	siginfo_t info;
>> +	int ret =3D 0;
>>=20
>>  	prev_state =3D exception_enter();
>>  	if (notify_die(DIE_TRAP, "bounds", regs, error_code, @@ -312,8
>> +313,35 @@ dotraplinkage void do_bounds(struct pt_regs *regs, long
> error_code)
>>  	 */
>>  	switch (status & MPX_BNDSTA_ERROR_CODE) {
>>  	case 2: /* Bound directory has invalid entry. */
>> -		if (do_mpx_bt_fault(xsave_buf))
>> +		down_write(&current->mm->mmap_sem);
>=20
> The handling of mm->mmap_sem here is horrible. The only reason why you
> want to hold mmap_sem write locked in the first place is that you want
> to cover the allocation and the mm->bd_addr check.
>=20
> I think it's wrong to tie this to mmap_sem in the first place. If MPX
> is enabled then you should have mm->bd_addr and an explicit mutex to prot=
ect it.
>=20
> So the logic would look like this:
>=20
>    mutex_lock(&mm->bd_mutex);
>    if (!kernel_managed(mm))
>       do_trap(); else if (do_mpx_bt_fault()) force_sig();
>    mutex_unlock(&mm->bd_mutex);
> No tricks with mmap_sem, no special return value handling. Straight
> forward code instead of a convoluted and error prone mess.
>=20
> Hmm?
>=20
I guess this is a good solution. If so, new field 'bd_sem' have to be added=
 into struct mm_struct.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
