Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE96C6B0069
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 13:18:34 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id p189so25529531itg.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 10:18:34 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id w76si2845071ita.65.2017.01.06.10.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 10:18:34 -0800 (PST)
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <f33f2c3c-4ec5-423c-5d13-a4b9ab8f7a95@linux.intel.com>
 <cae91a3b-27f2-4008-539e-153d66fc03ae@oracle.com>
 <b761e7a9-6f64-e8cb-334a-a49528e95cdf@linux.intel.com>
 <20170106.120204.927644401352332269.davem@davemloft.net>
 <dd42d787-0d3c-bd91-7376-3ce35bdd4c4c@oracle.com>
 <9b2562b4-754c-aab2-8fd7-3f9bd89b0314@oracle.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <7f78da33-a591-e913-d96e-fec022f2ba9e@oracle.com>
Date: Fri, 6 Jan 2017 11:18:01 -0700
MIME-Version: 1.0
In-Reply-To: <9b2562b4-754c-aab2-8fd7-3f9bd89b0314@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Gardner <rob.gardner@oracle.com>, David Miller <davem@davemloft.net>, dave.hansen@linux.intel.com
Cc: mhocko@kernel.org, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org, hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

On 01/06/2017 10:54 AM, Rob Gardner wrote:
> On 01/06/2017 09:10 AM, Khalid Aziz wrote:
>> On 01/06/2017 10:02 AM, David Miller wrote:
>>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>> Date: Fri, 6 Jan 2017 08:55:03 -0800
>>>
>>>> Actually, that reminds me...  How does your code interface with
>>>> ksm?  Or
>>>> is there no interaction needed since you're always working on virtual
>>>> addresses?
>>>
>>> This reminds me, I consider this feature potentially extremely useful
>>> for
>>> kernel debugging.  So I would like to make sure we don't implement
>>> anything
>>> in a way which would preclude that in the long term.
>>
>> I agree and please do point out if I have made any implementation
>> decisions that could preclude that.
>>
>> Thanks,
>> Khalid
>
>
> Khalid, I have already pointed out an implementation decision that
> interferes with the potential for kernel debugging with ADI: lazy
> clearing of version tags.

This does not preclude kernel debugging. If kernel debugging ends up 
requiring tags be cleared whenever a page is freed, we can add that code 
as part of kernel debugging support code and enable it conditionally 
only when kernel is being debugged. Forcing every task to incur the 
large cost of clearing tags on every "free" all the time is just not an 
acceptable cost only to support kernel debugging. It should be a dynamic 
switch to be toggled on only when debugging kernel. PSTATE.mcde being 
set is not enough to trigger a trap. It is easy enough to clear TTE.mcd 
before block initialization of a page and avoid a trap due to tag 
mismatch, or just use physical address with block initialization.

We can evaluate all of these options when we get to implementing kernel 
debugging using ADI.

Thanks,
Khalid


>
> Details: when memory is "freed" the version tags are left alone, as it
> is an expensive operation to go through the memory and clear the tag for
> each cache line. So this is done lazily whenever memory is "allocated".
> More specifically, the first time a user process touches freshly
> allocated memory, a fault occurs and the kernel then clears the page. In
> the NG4 and M7 variants of clear_user_page, the block init store ASI is
> used to optimize, and it has the side effect of clearing the ADI tag for
> the cache line. BUT only if pstate.mcde is clear. If pstate.mcde is set,
> then instead of the ADI tag being cleared, the tag is *checked*, and if
> there is a mismatch between the version in the virtual address and the
> version in memory, then you'll get a trap and panic. Therefore, with
> this design, you cannot have pstate.mcde enabled while in the kernel (in
> general). To solve this you have to check the state of pstate.mcde (or
> just turn it off) before doing any block init store in clear_user_page,
> memset, memcpy, etc.
>
> Rob
>
> --
> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
