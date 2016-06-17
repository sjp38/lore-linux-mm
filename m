Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 790176B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:26:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so150799448pfa.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 02:26:18 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0137.outbound.protection.outlook.com. [104.47.1.137])
        by mx.google.com with ESMTPS id f5si17556664pay.145.2016.06.17.02.26.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 02:26:17 -0700 (PDT)
Subject: Re: [PATCHv9 2/2] selftest/x86: add mremap vdso test
References: <1463487232-4377-1-git-send-email-dsafonov@virtuozzo.com>
 <1463487232-4377-3-git-send-email-dsafonov@virtuozzo.com>
 <20160617080346.GB30525@gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <02e163e0-acbb-0f3a-df66-3e55b453936a@virtuozzo.com>
Date: Fri, 17 Jun 2016 12:24:58 +0300
MIME-Version: 1.0
In-Reply-To: <20160617080346.GB30525@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, luto@amacapital.net, tglx@linutronix.de, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org

On 06/17/2016 11:03 AM, Ingo Molnar wrote:
>
> * Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>
>> Should print on success:
>> [root@localhost ~]# ./test_mremap_vdso_32
>> 	AT_SYSINFO_EHDR is 0xf773f000
>> [NOTE]	Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
>> [OK]
>> Or segfault if landing was bad (before patches):
>> [root@localhost ~]# ./test_mremap_vdso_32
>> 	AT_SYSINFO_EHDR is 0xf774f000
>> [NOTE]	Moving vDSO: [f774f000, f7750000] -> [a000000, a001000]
>> Segmentation fault (core dumped)
>
> Yeah, so I changed my mind again, I still don't like that the testcase faults on
> old kernels:
>
>  triton:~/tip/tools/testing/selftests/x86> ./test_mremap_vdso_32
>          AT_SYSINFO_EHDR is 0xf7786000
>  [NOTE]  Moving vDSO: [0xf7786000, 0xf7787000] -> [0xf7781000, 0xf7782000]
>  Segmentation fault
>
> How do I know that this testcase is special and that a segmentation fault in this
> case means that I'm running it on a too old kernel and that it's not some other
> unexpected failure in the test?
>
> At minimum please run it behind fork() and catch the -SIGSEGV child exit:
>
>   mremap(0xf7747000, 4096, 4096, MREMAP_MAYMOVE|MREMAP_FIXED, 0xf7742000) = 0xf7742000
>   --- SIGSEGV {si_signo=SIGSEGV, si_code=SEGV_MAPERR, si_addr=0xf7747be9} ---
>   +++ killed by SIGSEGV +++
>
> and print:
>
>   [FAIL] mremap() of the vDSO does not work on this kernel!
>
> or such.
>
> Ok?

Ok, will do.

Thanks,
Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
