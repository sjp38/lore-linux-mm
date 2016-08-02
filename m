Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8006E6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 07:00:46 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w207so356376937oiw.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 04:00:46 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0093.outbound.protection.outlook.com. [104.47.2.93])
        by mx.google.com with ESMTPS id p22si1006937otd.125.2016.08.02.04.00.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 04:00:45 -0700 (PDT)
Subject: Re: [PATCHv2 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
 <20160629105736.15017-4-dsafonov@virtuozzo.com>
 <CALCETrW+xWp-xVDjOyPkB5P3-zAubt4U65R4tVNsY34+406tTg@mail.gmail.com>
 <b451bdf2-3ce9-dc86-6f9c-fe3bd665d1d8@virtuozzo.com>
 <CALCETrUEP-q-Be1i=L7hxX-nf4OpBv7edq2Mg0gi5TRX73FTsA@mail.gmail.com>
 <20160711182654.GA19160@redhat.com>
 <CALCETrVaO_E923KY2bKGfG1tH75JBtEns4nKc+GWsYAx9NT0hQ@mail.gmail.com>
 <20160712141446.GB28837@redhat.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <e9e3b298-d655-2ee8-3d19-e581501aee1d@virtuozzo.com>
Date: Tue, 2 Aug 2016 13:59:40 +0300
MIME-Version: 1.0
In-Reply-To: <20160712141446.GB28837@redhat.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On 07/12/2016 05:14 PM, Oleg Nesterov wrote:
> On 07/11, Andy Lutomirski wrote:
>> I'm starting to wonder if we should finally suck it up and give
>> special mappings a non-NULL vm_file so we can track them properly.
>> Oleg, weren't you thinking of doing that for some other reason?
>
> Yes, uprobes. Currently we can't probe vdso page(s).

So, to make sure, that I've understood correctly, I need to:
o add vm_file to vdso/vvar vmas, __install_special_mapping will init
   them;
o place array pages[] inside f_mapping;
o create f_inode for each file -- for this we need some mount point, so
   I'll create something like vdsofs, register this filesystem and mount
   it in initcall (or like do_basic_setup - as it's done by shmem, i.e).

Is this the idea, or I got it wrong?

And maybe the idea is to create fake vm_file for just reference
counting, but do not treat/init it like file with inode, etc?
So with fake file I can also check if vdso is mapped already, but
I'm sure the fake file will not help Oleg with uprobes.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
