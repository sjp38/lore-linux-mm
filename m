Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 351276B0038
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 20:49:06 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so220407pdb.14
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 17:49:05 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id e4si37188590pdj.133.2014.09.17.17.49.04
        for <linux-mm@kvack.org>;
        Wed, 17 Sep 2014 17:49:05 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
Date: Thu, 18 Sep 2014 00:40:29 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE017B32C6@shsmsx102.ccr.corp.intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
 <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com>
 <20140916075007.GA22076@chicago.guarana.org>
In-Reply-To: <20140916075007.GA22076@chicago.guarana.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Easton <kevin@guarana.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 2014-09-16, Kevin Easton wrote:
> On Thu, Sep 11, 2014 at 04:46:48PM +0800, Qiaowei Ren wrote:
>> +
>> +int mpx_register(struct task_struct *tsk) {
>> +	struct mm_struct *mm =3D tsk->mm;
>> +
>> +	if (!cpu_has_mpx)
>> +		return -EINVAL;
>> +
>> +	/*
>> +	 * runtime in the userspace will be responsible for allocation of
>> +	 * the bounds directory. Then, it will save the base of the bounds
>> +	 * directory into XSAVE/XRSTOR Save Area and enable MPX through
>> +	 * XRSTOR instruction.
>> +	 *
>> +	 * fpu_xsave() is expected to be very expensive. In order to do
>> +	 * performance optimization, here we get the base of the bounds
>> +	 * directory and then save it into mm_struct to be used in future.
>> +	 */
>> +	mm->bd_addr =3D task_get_bounds_dir(tsk);
>> +	if (!mm->bd_addr)
>> +		return -EINVAL;
>> +
>> +	return 0;
>> +}
>> +
>> +int mpx_unregister(struct task_struct *tsk) {
>> +	struct mm_struct *mm =3D current->mm;
>> +
>> +	if (!cpu_has_mpx)
>> +		return -EINVAL;
>> +
>> +	mm->bd_addr =3D NULL;
>> +	return 0;
>> +}
>=20
> If that's changed, then mpx_register() and mpx_unregister() don't need
> a task_struct, just an mm_struct.
>=20
Yes. An mm_struct is enough.

> Probably these functions should be locking mmap_sem.
>=20
> Would it be prudent to use an error code other than EINVAL for the
> "hardware doesn't support it" case?
>
Seems like no specific error code for this case.

>> @@ -2011,6 +2017,12 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned
> long, arg2, unsigned long, arg3,
>>  			me->mm->def_flags &=3D ~VM_NOHUGEPAGE;
>>  		up_write(&me->mm->mmap_sem);
>>  		break;
>> +	case PR_MPX_REGISTER:
>> +		error =3D MPX_REGISTER(me);
>> +		break;
>> +	case PR_MPX_UNREGISTER:
>> +		error =3D MPX_UNREGISTER(me);
>> +		break;
>=20
> If you pass me->mm from prctl, that makes it clear that it's
> per-process not per-thread, just like PR_SET_DUMPABLE / PR_GET_DUMPABLE.
>=20
> This code should also enforce nulls in arg2 / arg3 / arg4,/ arg5 if
> it's not using them, otherwise you'll be sunk if you ever want to use the=
m later.
>=20
> It seems like it only makes sense for all threads using the mm to have
> the same bounds directory set.  If the interface was changed to
> directly pass the address, then could the kernel take care of setting
> it for *all* of the threads in the process? This seems like something
> that would be easier for the kernel to do than userspace.
>=20
If the interface was changed to this, it will be possible for insane applic=
ation to pass error bounds directory address to kernel. We still have to ca=
ll fpu_xsave() to check this.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
