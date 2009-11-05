Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 091BF6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:19:02 -0500 (EST)
Received: by pxi2 with SMTP id 2so45051pxi.11
        for <linux-mm@kvack.org>; Thu, 05 Nov 2009 07:19:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091105132109.GA12676@gamma.logic.tuwien.ac.at>
References: <20091030063216.GA30712@gamma.logic.tuwien.ac.at>
	 <20091102005218.8352.A69D9226@jp.fujitsu.com>
	 <20091102135640.93de7c2a.minchan.kim@barrios-desktop>
	 <28c262360911012300h4535118ewd65238c746b91a52@mail.gmail.com>
	 <20091102155543.E60E.A69D9226@jp.fujitsu.com>
	 <20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091102141917.GJ2116@gamma.logic.tuwien.ac.at>
	 <28c262360911020640k3f9dfcdct2cac6cc1d193144d@mail.gmail.com>
	 <20091105132109.GA12676@gamma.logic.tuwien.ac.at>
Date: Fri, 6 Nov 2009 00:19:01 +0900
Message-ID: <28c262360911050719u4de4223eub08c0f7ea8797137@mail.gmail.com>
Subject: Re: OOM killer, page fault
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Norbert Preining <preining@logic.at>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Thu, Nov 5, 2009 at 10:21 PM, Norbert Preining <preining@logic.at> wrote=
:
> Hi Kim, hi all,
>
> (still please Cc)
>
> sorry for the late reply. I have two news, one good and one bad: The good
> being that I can reproduce the bug by running VirtualBox with some W7

W7 means "Windows 7"?

> within. Anyway, I don't have a trace or better debug due to the bad news:
> Both 2.6.32-rc5 and 2.6.32-rc6 do *not* boot with the patch below.
> Don't ask me why, please, and I don't have a serial/net console so that
> I can tell you more, but the booting hangs badly at:
> [ =A0 =A06.657492] usb 4-1: Product: Globetrotter HSDPA Modem
> [ =A0 =A06.657494] usb 4-1: Manufacturer: Option N.V.
> [ =A0 =A06.657496] usb 4-1: SerialNumber: Serial Number
> [ =A0 =A06.657558] usb 4-1: configuration #1 chosen from 1 choice
> [ =A0 =A06.837364] input: PS/2 Mouse as /devices/platform/i8042/serio2/in=
put/input6
> [ =A0 =A06.853693] input: AlpsPS/2 ALPS GlidePoint as /devices/platform/i=
8042/serio2/input/input7
>
> Normally it continues like that, but with the patch below it hangs here
> and does not continue. I need to Sysrq-s/u/b out of it.
>
> [ =A0 =A06.904119] usb 8-2: new full speed USB device using uhci_hcd and =
address 2
> [ =A0 =A07.075524] usb 8-2: New USB device found, idVendor=3D044e, idProd=
uct=3D3017
>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 7e91b5f..47e4b15 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2713,7 +2713,11 @@ static int __do_fault(struct mm_struct *mm,
>> struct vm_area_struct *vma,
>> =A0 =A0 =A0 =A0vmf.page =3D NULL;
>>
>> =A0 =A0 =A0 =A0ret =3D vma->vm_ops->fault(vma, &vmf);
>> - =A0 =A0 =A0 if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
>> + =A0 =A0 =A0 if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG "vma->vm_ops->fault : 0x=
%lx\n",
>> vma->vm_ops->fault);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON(1);
>> +
>> + =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
>>
>> =A0 =A0 =A0 =A0if (unlikely(PageHWPoison(vmf.page))) {
>
> I know it sounds completely crazy, the patch only does harmless things
> afais. But I tried it. Several times. rc6+patch never did boot, while
> rc5 without path did boot. Then I patched it into -rc5, recompiled, and
> boom, no boot. booting into .31.5, recompiling rc6 and rc5 without
> that patch and suddenly rc6 boots (and I am sure rc5, too).

Hmm. It's out of my knowledge.
Probably, It's because WARN_ON?
Could you try it with omitting WARN_ON, again?

>
> Sorry that I cannot give more infos, please let me know what else I can
> do.

Thanks for your time :)

> Ah yes, I can reproduce the original strange bug with oom killer!

Sounds good to me.
Could you tell me your test scenario, your system info(CPU, RAM) and
config?
I want to reproduce it in my mahchine to not bother you. :)


>
> Best wishes
>
> Norbert
>
> -------------------------------------------------------------------------=
------
> Dr. Norbert Preining =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0Associate Professor
> JAIST Japan Advanced Institute of Science and Technology =A0 preining@jai=
st.ac.jp
> Vienna University of Technology =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 preining@logic.at
> Debian Developer (Debian TeX Task Force) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0preining@debian.org
> gpg DSA: 0x09C5B094 =A0 =A0 =A0fp: 14DF 2E6C 0307 BE6D AD76 =A0A9C0 D2BF =
4AA3 09C5 B094
> -------------------------------------------------------------------------=
------
> MELTON CONSTABLE (n.)
> A patent anti-wrinkle cream which policemen wear to keep themselves
> looking young.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0--- Douglas Adams, The Mea=
ning of Liff
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
