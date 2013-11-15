Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3B72A6B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 14:16:46 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lf10so4033753pab.22
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 11:16:45 -0800 (PST)
Received: from psmtp.com ([74.125.245.104])
        by mx.google.com with SMTP id hk1si2788212pbb.221.2013.11.15.11.16.43
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 11:16:44 -0800 (PST)
Message-ID: <52867309.4040406@zytor.com>
Date: Fri, 15 Nov 2013 11:16:25 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Early use of boot service memory
References: <CAOJsxLFkHQ6_f+=CMwfNLykh59TZH5VrWeVEDPCWPF1wiw7tjQ@mail.gmail.com> <20131114180455.GA32212@anatevka.fc.hp.com> <CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com> <20131115005049.GJ5116@anatevka.fc.hp.com> <20131115062417.GB9237@gmail.com> <CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com> <5285C639.5040203@zytor.com> <20131115140738.GB6637@redhat.com> <CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com> <52865CA1.5020309@zytor.com> <20131115183002.GE6637@redhat.com> <52866C0D.3050006@zytor.com>
In-Reply-To: <52866C0D.3050006@zytor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@kernel.org>, jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 11/15/2013 10:46 AM, H. Peter Anvin wrote:
> On 11/15/2013 10:30 AM, Vivek Goyal wrote:
>>
>> I agree taking assistance of hypervisor should be useful.
>>
>> One reason we use kdump for VM too because it makes life simple. There
>> is no difference in how we configure, start and manage crash dumps
>> in baremetal or inside VM. And in practice have not heard of lot of
>> failures of kdump in VM environment.
>>
>> So while reliability remains a theoritical concern, in practice it
>> has not been a real concern and that's one reason I think we have
>> not seen a major push for alternative method in VM environment.
>>
> 
> Another reason, again, is that it doesn't sit on all that memory.
> 

This led me to a potentially interesting idea.  If we can tell the
hypervisor about which memory blocks belong to kdump, we can still use
kdump in its current form with only a few hypervisor calls thrown in.

One set of calls would mark memory ranges as belonging to kdump.  This
would (a) make them protected, and (b) tell the hypervisor that these
memory ranges will not be accessed and don't need to occupy physical RAM.

On a crash, we would them execute another hypercall to reanimate the
kdump areas.  Since this is a once-in-a-lifetime (literally) event, this
can be arbitrarily slow.

This would only require a small number of hypercalls inserted into
already existing code paths, and provide most of the benefit of
hypervisor-assisted crash dumping.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
