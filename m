Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB9B16B0003
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 11:39:18 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 33-v6so11398320pld.19
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 08:39:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16-v6si31063696pfj.251.2018.11.01.08.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 08:39:17 -0700 (PDT)
Subject: Re: [PATCH] x86/build: Build VSMP support only if selected
References: <20181030230905.xHZmM%akpm@linux-foundation.org>
 <9e14d183-55a4-8299-7a18-0404e50bf004@infradead.org>
 <alpine.DEB.2.21.1811011032190.1642@nanos.tec.linutronix.de>
 <SN6PR15MB2366D7688B41535AF0A331F9C3CE0@SN6PR15MB2366.namprd15.prod.outlook.com>
 <a8f2ac8e-45dc-1c12-e888-6ad880b1306f@scalemp.com>
 <054cd800-5124-f897-0069-aba49f8eb654@suse.com>
 <3c75860d-e3d7-8c28-6120-f6056200f941@scalemp.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <0d472636-e39d-8cd3-4a47-2b9dc139b7fe@suse.com>
Date: Thu, 1 Nov 2018 16:39:13 +0100
MIME-Version: 1.0
In-Reply-To: <3c75860d-e3d7-8c28-6120-f6056200f941@scalemp.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eial Czerwacki <eial@scalemp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Randy Dunlap <rdunlap@infradead.org>, "Shai Fultheim (Shai@ScaleMP.com)" <Shai@ScaleMP.com>, Andrew Morton <akpm@linux-foundation.org>, "broonie@kernel.org" <broonie@kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, X86 ML <x86@kernel.org>, 'Oren Twaig' <oren@scalemp.com>

On 01/11/2018 16:09, Eial Czerwacki wrote:
> Greetings,
> 
> On 11/01/2018 03:45 PM, Juergen Gross wrote:
>> On 01/11/2018 14:10, Eial Czerwacki wrote:
>>> Greetings,
>>>
>>> On 11/01/2018 12:39 PM, Shai Fultheim (Shai@ScaleMP.com) wrote:
>>>> On 01/11/18 11:37, Thomas Gleixner wrote:
>>>>
>>>>> VSMP support is built even if CONFIG_X86_VSMP is not set. This leads to a build
>>>>> breakage when CONFIG_PCI is disabled as well.
>>>>>
>>>>> Build VSMP code only when selected.
>>>>
>>>> This patch disables detect_vsmp_box() on systems without CONFIG_X86_VSMP, due to
>>>> the recent 6da63eb241a05b0e676d68975e793c0521387141.  This is significant
>>>> regression that will affect significant number of deployments.
>>>>
>>>> We will reply shortly with an updated patch that fix the dependency on pv_irq_ops,
>>>> and revert to CONFIG_PARAVIRT, with proper protection for CONFIG_PCI.
>>>>
>>>
>>> here is the proper patch which fixes the issue on hand:
>>> From ebff534f8cfa55d7c3ab798c44abe879f3fbe2b8 Mon Sep 17 00:00:00 2001
>>> From: Eial Czerwacki <eial@scalemp.com>
>>> Date: Thu, 1 Nov 2018 15:08:32 +0200
>>> Subject: [PATCH] x86/build: Build VSMP support only if CONFIG_PCI is
>>> selected
>>>
>>> vsmp dependency of pv_irq_ops removed some years ago, so now let's clean
>>> it up from vsmp_64.c.
>>>
>>> In short, "cap & ctl & (1 << 4)" was always returning 0, as such we can
>>> remove all the PARAVIRT/PARAVIRT_XXL code handling that.
>>>
>>> However, the rest of the code depends on CONFIG_PCI, so fix it accordingly.
>>>
>>> Signed-off-by: Eial Czerwacki <eial@scalemp.com>
>>> Acked-by: Shai Fultheim <shai@scalemp.com>
>>> ---
>>>  arch/x86/Kconfig          |  1 -
>>>  arch/x86/kernel/vsmp_64.c | 80
>>> +++--------------------------------------------
>>>  2 files changed, 5 insertions(+), 76 deletions(-)
>>>
>>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>>> index c51c989..4b187ca 100644
>>> --- a/arch/x86/Kconfig
>>> +++ b/arch/x86/Kconfig
>>> @@ -524,7 +524,6 @@ config X86_VSMP
>>>         bool "ScaleMP vSMP"
>>>         select HYPERVISOR_GUEST
>>>         select PARAVIRT
>>
>> Do you really still need PARAVIRT and HYPERVISOR_GUEST?
>> Maybe you want IRQ_REMAP instead?
>>
> Better performance is achieved with PARAVIRTed kernel.   Hence we keep
> them both in.

Do you have an explanation for that? Normally PARAVIRT is expected
to have a small negative impact on performance.


Juergen
