Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3763E6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 06:50:28 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s207so91896653oie.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 03:50:28 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0100.outbound.protection.outlook.com. [104.47.2.100])
        by mx.google.com with ESMTPS id r38si3421512otr.229.2016.08.10.03.50.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 10 Aug 2016 03:50:27 -0700 (PDT)
Subject: Re: [PATCHv2 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
 <20160629105736.15017-4-dsafonov@virtuozzo.com>
 <CALCETrW+xWp-xVDjOyPkB5P3-zAubt4U65R4tVNsY34+406tTg@mail.gmail.com>
 <b451bdf2-3ce9-dc86-6f9c-fe3bd665d1d8@virtuozzo.com>
 <CALCETrUEP-q-Be1i=L7hxX-nf4OpBv7edq2Mg0gi5TRX73FTsA@mail.gmail.com>
 <20160711182654.GA19160@redhat.com>
 <CALCETrVaO_E923KY2bKGfG1tH75JBtEns4nKc+GWsYAx9NT0hQ@mail.gmail.com>
 <20160712141446.GB28837@redhat.com>
 <e9e3b298-d655-2ee8-3d19-e581501aee1d@virtuozzo.com>
 <CALCETrWDGBEO2k803f4BV0Z4qtNY+=9ow1=2NnkDuyFBv=X-TQ@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <85e83754-e25a-b9b3-cc51-44b61f2dcaa8@virtuozzo.com>
Date: Wed, 10 Aug 2016 13:49:18 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrWDGBEO2k803f4BV0Z4qtNY+=9ow1=2NnkDuyFBv=X-TQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On 08/10/2016 11:35 AM, Andy Lutomirski wrote:
> On Tue, Aug 2, 2016 at 3:59 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> On 07/12/2016 05:14 PM, Oleg Nesterov wrote:
>>>
>>> On 07/11, Andy Lutomirski wrote:
>>>>
>>>> I'm starting to wonder if we should finally suck it up and give
>>>> special mappings a non-NULL vm_file so we can track them properly.
>>>> Oleg, weren't you thinking of doing that for some other reason?
>>>
>>>
>>> Yes, uprobes. Currently we can't probe vdso page(s).
>>
>>
>> So, to make sure, that I've understood correctly, I need to:
>> o add vm_file to vdso/vvar vmas, __install_special_mapping will init
>>   them;
>> o place array pages[] inside f_mapping;
>> o create f_inode for each file -- for this we need some mount point, so
>>   I'll create something like vdsofs, register this filesystem and mount
>>   it in initcall (or like do_basic_setup - as it's done by shmem, i.e).
>>
>> Is this the idea, or I got it wrong?
>>
>> And maybe the idea is to create fake vm_file for just reference
>> counting, but do not treat/init it like file with inode, etc?
>> So with fake file I can also check if vdso is mapped already, but
>> I'm sure the fake file will not help Oleg with uprobes.
>
> This would work, but it might be complicated.  I'm not an expert at mm
> internals.

Ok, thanks on answer!
I'll try to prepare patches in near days -- they will help to track
vdso and for uprobes. If this will become too complex, I'll just
iterate over vmas.

>
> Another approach would be to just iterate over all vmas and look for
> old copies of the special mapping.

Thanks,
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
