Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 284AA6B0256
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 13:08:45 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id c203so85061648oia.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 10:08:45 -0800 (PST)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id f6si12847280oez.5.2016.03.07.10.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 10:08:44 -0800 (PST)
Received: by mail-oi0-x233.google.com with SMTP id r187so85041493oih.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 10:08:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56DDC2B6.6020009@oracle.com>
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
 <20160305.230702.1325379875282120281.davem@davemloft.net> <56DD9949.1000106@oracle.com>
 <20160307.115626.807716799249471744.davem@davemloft.net> <56DDC2B6.6020009@oracle.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 7 Mar 2016 10:08:24 -0800
Message-ID: <CALCETrXN43nT4zq2MpO90VrgK3k+DKHjOHWf7iOhS7TSBmdCPQ@mail.gmail.com>
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity (ADI)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: David Miller <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Arnd Bergmann <arnd@arndb.de>, sparclinux@vger.kernel.org, Rob Gardner <rob.gardner@oracle.com>, Michal Hocko <mhocko@suse.cz>, chris.hyser@oracle.com, Richard Weinberger <richard@nod.at>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, Andrew Lutomirski <luto@kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Benjamin Segall <bsegall@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Davidlohr Bueso <dave@stgolabs.net>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Mar 7, 2016 at 10:04 AM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
> On 03/07/2016 09:56 AM, David Miller wrote:
>>
>> From: Khalid Aziz <khalid.aziz@oracle.com>
>> Date: Mon, 7 Mar 2016 08:07:53 -0700
>>
>>> PR_GET_SPARC_ADICAPS
>>
>>
>> Put this into a new ELF auxiliary vector entry via ARCH_DLINFO.
>>
>> So now all that's left is supposedly the TAG stuff, please explain
>> that to me so I can direct you to the correct existing interface to
>> provide that as well.
>>
>> Really, try to avoid prtctl, it's poorly typed and almost worse than
>> ioctl().
>>
>
> The two remaining operations I am looking at are:
>
> 1. Is PSTATE.mcde bit set for the process? PR_SET_SPARC_ADI provides this in
> its return value in the patch I sent.
>
> 2. Is TTE.mcd set for a given virtual address? PR_GET_SPARC_ADI_STATUS
> provides this function in the patch I sent.
>
> Setting and clearing version tags can be done entirely from userspace:
>
>         while (addr < end) {
>                 asm volatile(
>                         "stxa %1, [%0]ASI_MCD_PRIMARY\n\t"
>                         :
>                         : "r" (addr), "r" (version));
>                 addr += adicap.blksz;
>         }
> so I do not have to add any kernel code for tags.

Is the effect of that to change the tag associated with a page to
which the caller has write access?

I sense DoS issues in your future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
