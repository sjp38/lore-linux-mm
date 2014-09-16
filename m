Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE3C6B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 23:20:39 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id fa1so7868831pad.30
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 20:20:38 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id dr2si26432772pbc.248.2014.09.15.20.20.37
        for <linux-mm@kvack.org>;
        Mon, 15 Sep 2014 20:20:37 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
Date: Tue, 16 Sep 2014 03:20:27 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE017AE183@shsmsx102.ccr.corp.intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
	<1410425210-24789-9-git-send-email-qiaowei.ren@intel.com>
 <20140915010025.5940c946@alan.etchedpixels.co.uk>
In-Reply-To: <20140915010025.5940c946@alan.etchedpixels.co.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 2014-09-15, One Thousand Gnomes wrote:
>> The base of the bounds directory is set into mm_struct during
>> PR_MPX_REGISTER command execution. This member can be used to check
>> whether one application is mpx enabled.
>=20
> Not really because by the time you ask the question another thread
> might have decided to unregister it.
>=20
>=20
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
>=20
> What stops two threads calling this in parallel ?
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
>=20
> or indeed calling this in parallel
>=20
> What are the semantics across execve() ?
>=20
This will not impact on the semantics of execve(). One runtime library for =
MPX will be provided (or merged into Glibc), and when the application start=
s, this runtime will be called to initialize MPX runtime environment, inclu=
ding calling prctl() to notify the kernel to start managing the bounds dire=
ctories. You can see the discussion about exec(): https://lkml.org/lkml/201=
4/1/26/199=20

It would be extremely unusual for an application to have some MPX and some =
non-MPX threads, since they would share the same address space and the non-=
MPX threads would mess up the bounds. That is to say, it looks like be unus=
ual for one of these threads to call prctl() to enable or disable MPX. I gu=
ess we need to add some rules into documentation.

Thanks,
Qiaowei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
