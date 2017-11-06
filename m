Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABC9C6B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 01:18:18 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v105so5451072wrc.11
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 22:18:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f2si76662edc.211.2017.11.05.22.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Nov 2017 22:18:17 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA66ERDV127233
	for <linux-mm@kvack.org>; Mon, 6 Nov 2017 01:18:15 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2e26wadfvq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Nov 2017 01:18:13 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 6 Nov 2017 06:18:12 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
In-Reply-To: <20171105231850.5e313e46@roar.ozlabs.ibm.com>
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com> <20171105231850.5e313e46@roar.ozlabs.ibm.com>
Date: Mon, 06 Nov 2017 11:48:06 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <871slcszfl.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, Florian Weimer <fweimer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

Nicholas Piggin <npiggin@gmail.com> writes:

> On Fri, 3 Nov 2017 18:05:20 +0100
> Florian Weimer <fweimer@redhat.com> wrote:
>
>> We are seeing an issue on ppc64le and ppc64 (and perhaps on some arm 
>> variant, but I have not seen it on our own builders) where running 
>> localedef as part of the glibc build crashes with a segmentation fault.
>> 
>> Kernel version is 4.13.9 (Fedora 26 variant).
>> 
>> I have only seen this with an explicit loader invocation, like this:
>> 
>> while I18NPATH=. /lib64/ld64.so.1 /usr/bin/localedef 
>> --alias-file=../intl/locale.alias --no-archive -i locales/nl_AW -c -f 
>> charmaps/UTF-8 
>> --prefix=/builddir/build/BUILDROOT/glibc-2.26-16.fc27.ppc64 nl_AW ; do : 
>> ; done
>> 
>> To be run in the localedata subdirectory of a glibc *source* tree, after 
>> a build.  You may have to create the 
>> /builddir/build/BUILDROOT/glibc-2.26-16.fc27.ppc64/usr/lib/locale 
>> directory.  I have only reproduced this inside a Fedora 27 chroot on a 
>> Fedora 26 host, but there it does not matter if you run the old (chroot) 
>> or newly built binary.
>> 
>> I filed this as a glibc bug for tracking:
>> 
>>    https://sourceware.org/bugzilla/show_bug.cgi?id=22390
>> 
>> There's an strace log and a coredump from the crash.
>> 
>> I think the data shows that the address in question should be writable.
>> 
>> The crossed 0x0000800000000000 binary is very suggestive.  I think that 
>> based on the operation of glibc's malloc, this write would be the first 
>> time this happens during the lifetime of the process.
>> 
>> Does that ring any bells?  Is there anything I can do to provide more 
>> data?  The host is an LPAR with a stock Fedora 26 kernel, so I can use 
>> any diagnostics tool which is provided by Fedora.
>
> There was a recent change to move to 128TB address space by default,
> and option for 512TB addresses if explicitly requested.
>
> Your brk request asked for > 128TB which the kernel gave it, but the
> address limit in the paca that the SLB miss tests against was not
> updated to reflect the switch to 512TB address space.

We should not return that address, unless we requested with a hint value
of > 128TB. IIRC we discussed this early during the mmap interface
change and said, we will return an address > 128T only if the hint
address is above 128TB (not hint addr + length). I am not sure why
we are finding us returning and address > 128TB with paca limit set to
128TB?


>
> Why is your brk starting so high? Are you trying to test the > 128TB
> case, or maybe something is confused by the 64->128TB change? What's
> the strace look like if you run on a distro or <= 4.10 kernel?
>
> Something like the following patch may help if you could test.
>
> Thanks,
> Nick
>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
