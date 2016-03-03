Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 377D66B0255
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 12:29:22 -0500 (EST)
Received: by mail-qg0-f52.google.com with SMTP id t4so22700300qge.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 09:29:22 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id c68si12146256qge.29.2016.03.03.09.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 09:29:17 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
 <CAGRGNgXCcEmKU9f2XRpRv6By4QPZU7rxxTQPzSp+kahjmRTO5Q@mail.gmail.com>
 <56D78471.1020707@oracle.com>
 <CAGRGNgVyPUUUTV9_GAyE9S4FVPce4PBU-G+QXv3eNkosGj3eyg@mail.gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <56D8744D.9020300@oracle.com>
Date: Thu, 3 Mar 2016 10:28:45 -0700
MIME-Version: 1.0
In-Reply-To: <CAGRGNgVyPUUUTV9_GAyE9S4FVPce4PBU-G+QXv3eNkosGj3eyg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Calaby <julian.calaby@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, corbet@lwn.net, Andrew Morton <akpm@linux-foundation.org>, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, Arnd Bergmann <arnd@arndb.de>, sparclinux <sparclinux@vger.kernel.org>, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, Andy Lutomirski <luto@kernel.org>, ebiederm@xmission.com, bsegall@google.com, Geert Uytterhoeven <geert@linux-m68k.org>, dave@stgolabs.net, Alexey Dobriyan <adobriyan@gmail.com>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/02/2016 05:48 PM, Julian Calaby wrote:
> Hi Khalid,
>
> On Thu, Mar 3, 2016 at 11:25 AM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>> Thanks, Julian! I really appreciate your feedback.
>
> No problem!
>
>> My comments below.
>>
>> On 03/02/2016 04:08 PM, Julian Calaby wrote:
>>>
>>> Hi Khalid,
>>>
>>> On Thu, Mar 3, 2016 at 7:39 AM, Khalid Aziz <khalid.aziz@oracle.com>
>>> wrote:
>>>>
>>>>
>>>> Enable Application Data Integrity (ADI) support in the sparc
>>>> kernel for applications to use ADI in userspace. ADI is a new
>>>> feature supported on sparc M7 and newer processors. ADI is supported
>>>> for data fetches only and not instruction fetches. This patch adds
>>>> prctl commands to enable and disable ADI (TSTATE.mcde), return ADI
>>>> parameters to userspace, enable/disable MCD (Memory Corruption
>>>> Detection) on selected memory ranges and enable TTE.mcd in PTEs. It
>>>> also adds handlers for all traps related to MCD. ADI is not enabled
>>>> by default for any task and a task must explicitly enable ADI
>>>> (TSTATE.mcde), turn MCD on on a memory range and set version tag
>>>> for ADI to be effective for the task. This patch adds support for
>>>> ADI for hugepages only. Addresses passed into system calls must be
>>>> non-ADI tagged addresses.
>>>
>>>
>>> I can't comment on the actual functionality here, but I do see a few
>>> minor style issues in your patch.
>>>
>>> My big concern is that you're defining a lot of new code that is ADI
>>> specific but isn't inside a CONFIG_SPARC_ADI ifdef. (That said,
>>> handling ADI specific traps if ADI isn't enabled looks like a good
>>> idea to me, however most of the other stuff is just dead code if
>>> CONFIG_SPARC_ADI isn't enabled.)
>>
>>
>> Some of the code will be executed when CONFIG_SPARC_ADI is not enabled, for
>> instance init_adi() which will parse machine description to determine if
>> platform supports ADI. On the other hand, it might still make sense to
>> enclose this code in #ifdef. More on that below.
>>
>>
>>>
>>>> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
>>>> ---
>>>> NOTES: ADI is a new feature added to M7 processor to allow hardware
>>>>           to catch rogue accesses to memory. An app can enable ADI on
>>>>           its data pages, set version tags on them and use versioned
>>>>           addresses (bits 63-60 of the address contain a version tag)
>>>>           to access the data pages. If a rogue app attempts to access
>>>>           ADI enabled data pages, its access is blocked and processor
>>>>           generates an exception. Enabling this functionality for all
>>>>           data pages of an app requires adding infrastructure to save
>>>>           version tags for any data pages that get swapped out and
>>>>           restoring those tags when pages are swapped back in. In this
>>>>           first implementation I am enabling ADI for hugepages only
>>>>           since these pages are locked in memory and hence avoid the
>>>>           issue of saving and restoring tags. Once this core functionality
>>>>           is stable, ADI for other memory pages can be enabled more
>>>>           easily.
>>>>
>>>> v2:
>>>>           - Fixed a build error
>>>>
>>>>    Documentation/prctl/sparc_adi.txt     |  62 ++++++++++
>>>>    Documentation/sparc/adi.txt           | 206
>>>> +++++++++++++++++++++++++++++++
>>>>    arch/sparc/Kconfig                    |  12 ++
>>>>    arch/sparc/include/asm/hugetlb.h      |  14 +++
>>>>    arch/sparc/include/asm/hypervisor.h   |   2 +
>>>>    arch/sparc/include/asm/mmu_64.h       |   1 +
>>>>    arch/sparc/include/asm/pgtable_64.h   |  15 +++
>>>>    arch/sparc/include/asm/processor_64.h |  19 +++
>>>>    arch/sparc/include/asm/ttable.h       |  10 ++
>>>>    arch/sparc/include/uapi/asm/asi.h     |   3 +
>>>>    arch/sparc/include/uapi/asm/pstate.h  |  10 ++
>>>>    arch/sparc/kernel/entry.h             |   3 +
>>>>    arch/sparc/kernel/head_64.S           |   1 +
>>>>    arch/sparc/kernel/mdesc.c             |  81 +++++++++++++
>>>>    arch/sparc/kernel/process_64.c        | 222
>>>> ++++++++++++++++++++++++++++++++++
>>>>    arch/sparc/kernel/sun4v_mcd.S         |  16 +++
>>>>    arch/sparc/kernel/traps_64.c          |  96 ++++++++++++++-
>>>>    arch/sparc/kernel/ttable_64.S         |   6 +-
>>>>    include/linux/mm.h                    |   2 +
>>>>    include/uapi/asm-generic/siginfo.h    |   5 +-
>>>>    include/uapi/linux/prctl.h            |  16 +++
>>>>    kernel/sys.c                          |  30 +++++
>>>>    22 files changed, 826 insertions(+), 6 deletions(-)
>>>>    create mode 100644 Documentation/prctl/sparc_adi.txt
>>>>    create mode 100644 Documentation/sparc/adi.txt
>>>>    create mode 100644 arch/sparc/kernel/sun4v_mcd.S
>>>
>>>
>>> I must admit that I'm slightly impressed that the documentation is
>>> over a quarter of the lines added. =)
>>>
>>>> diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
>>>> index 56442d2..0aac0ae 100644
>>>> --- a/arch/sparc/Kconfig
>>>> +++ b/arch/sparc/Kconfig
>>>> @@ -80,6 +80,7 @@ config SPARC64
>>>>           select NO_BOOTMEM
>>>>           select HAVE_ARCH_AUDITSYSCALL
>>>>           select ARCH_SUPPORTS_ATOMIC_RMW
>>>> +       select SPARC_ADI
>>>
>>>
>>> This doesn't look right.
>>>
>>>>    config ARCH_DEFCONFIG
>>>>           string
>>>> @@ -314,6 +315,17 @@ if SPARC64
>>>>    source "kernel/power/Kconfig"
>>>>    endif
>>>>
>>>> +config SPARC_ADI
>>>> +       bool "Application Data Integrity support"
>>>> +       def_bool y if SPARC64
>>>
>>>
>>> def_bool is for config options without names (i.e. "this is a boolean
>>> value and it's default is...")
>>>
>>> So if you want people to be able to disable this option, then you
>>> should remove the select above and just have:
>>>
>>> bool "Application Data Integrity support"
>>> default y if SPARC64
>>>
>>> If you don't want people disabling it, then there's no point in having
>>> a separate Kconfig symbol.
>>>
>>
>> Ah, I see. I do not want people disabling it. I will make changes.
>
> Why don't you want people disabling it? I must acknowledge that it's
> not a lot of code, but I can see people wanting to build "minimal"
> kernels for processors without ADI or to run some specific thing that
> doesn't use ADI. Providing the kernel responds appropriately if
> there's an unexpected ADI fault I don't see why the code would be
> needed if it'll never be used.
>

Hi Julian,

My goal in making CONFIG_SPARC_ADI auto-selected was to not add yet 
another config option that end user has to understand and figure out 
what to do with, and make the kernel self-configuring where ADI simply 
becomes available if platform supports it. Kernel auto-detecting 
platform features is especially useful for distro kernels. I do see your 
point in being able to build a minimal kernel when building a custom 
kernel. Both options of making CONFIG_SPARC_ADI auto-selected or not, 
have pros and cons. I don't have a strong feeling about it one way or 
the other and can go either way.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
