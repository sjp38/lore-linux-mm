Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 991BD6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 22:55:01 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so209849pad.35
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 19:55:01 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ae8si4936541pad.193.2014.09.11.19.54.59
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 19:55:00 -0700 (PDT)
From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Subject: RE: [PATCH v8 06/10] mips: sync struct siginfo with general version
Date: Fri, 12 Sep 2014 02:54:55 +0000
Message-ID: <9E0BE1322F2F2246BD820DA9FC397ADE017A3FF0@shsmsx102.ccr.corp.intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
 <1410425210-24789-7-git-send-email-qiaowei.ren@intel.com>
 <alpine.DEB.2.10.1409120007550.4178@nanos>
In-Reply-To: <alpine.DEB.2.10.1409120007550.4178@nanos>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>



On 2014-09-12, Thomas Gleixner wrote:
> On Thu, 11 Sep 2014, Qiaowei Ren wrote:
>=20
>> Due to new fields about bound violation added into struct siginfo,
>> this patch syncs it with general version to avoid build issue.
>=20
> You completely fail to explain which build issue is addressed by this
> patch. The code you added to kernel/signal.c which accesses _addr_bnd
> is guarded by
>=20
> +#ifdef SEGV_BNDERR
>=20
> which is not defined my MIPS. Also why is this only affecting MIPS and
> not any other architecture which provides its own struct siginfo ?
>=20
> That patch makes no sense at all, at least not without a proper explanati=
on.
>

For arch=3Dmips, siginfo.h (arch/mips/include/uapi/asm/siginfo.h) will incl=
ude general siginfo.h, and only replace general stuct siginfo with mips spe=
cific struct siginfo. So SEGV_BNDERR will be defined for all archs, and we =
will get error like "no _lower in struct siginfo" when arch=3Dmips.

In addition, only MIPS arch define its own struct siginfo, so this is only =
affecting MIPS.=20

Thanks,
Qiaowei

>=20
>> Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
>> ---
>>  arch/mips/include/uapi/asm/siginfo.h |    4 ++++
>>  1 files changed, 4 insertions(+), 0 deletions(-)
>> diff --git a/arch/mips/include/uapi/asm/siginfo.h
>> b/arch/mips/include/uapi/asm/siginfo.h
>> index e811744..d08f83f 100644
>> --- a/arch/mips/include/uapi/asm/siginfo.h
>> +++ b/arch/mips/include/uapi/asm/siginfo.h
>> @@ -92,6 +92,10 @@ typedef struct siginfo {
>>  			int _trapno;	/* TRAP # which caused the signal */
>>  #endif
>>  			short _addr_lsb;
>> +			struct {
>> +				void __user *_lower;
>> +				void __user *_upper;
>> +			} _addr_bnd;
>>  		} _sigfault;
>> =20
>>  		/* SIGPOLL, SIGXFSZ (To do ...)	 */
>> --
>> 1.7.1
>>=20
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
