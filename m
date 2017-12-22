Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1E176B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 11:26:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h18so20471502pfi.2
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:26:57 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 3si15253650plv.147.2017.12.22.08.26.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 08:26:56 -0800 (PST)
Subject: Re: [RFC PATCH v4 08/18] kvm: add the VM introspection subsystem
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-9-alazar@bitdefender.com>
 <3b9dd83a-5e13-97b5-3d87-14de288e88d8@oracle.com>
 <1513951900.E02F46f7.12019@host>
 <6c329fc6-4be8-8119-1516-2e41a106662e@oracle.com>
 <1513957884.c78eA1f5a.26462@host>
From: Patrick Colp <patrick.colp@oracle.com>
Message-ID: <e9bcccc6-6543-9ae1-2406-5333c87a89b0@oracle.com>
Date: Fri, 22 Dec 2017 11:26:49 -0500
MIME-Version: 1.0
In-Reply-To: <1513957884.c78eA1f5a.26462@host>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: alazar@bitdefender.com, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>, =?UTF-8?B?TmljdciZb3IgQ8OuyJt1?= <ncitu@bitdefender.com>, =?UTF-8?Q?Mircea_C=c3=aerjaliu?= <mcirjaliu@bitdefender.com>, Marian Rotariu <mrotariu@bitdefender.com>

On 2017-12-22 10:51 AM, alazar@bitdefender.com wrote:
> On Fri, 22 Dec 2017 10:12:35 -0500, Patrick Colp <patrick.colp@oracle.com> wrote:
>> On 2017-12-22 09:11 AM, Adalbert Lazi? 1/2 i? 1/2 i? 1/2 i? 1/2 r wrote:
>>> We've made changes in all the places pointed by you, but read below.
>>> Thanks again,
>>> Adalbert
>>>
>>> On Fri, 22 Dec 2017 02:34:45 -0500, Patrick Colp <patrick.colp@oracle.com> wrote:
>>>> On 2017-12-18 02:06 PM, Adalber LazA?r wrote:
>>>>> From: Adalbert Lazar <alazar@bitdefender.com>
>>>>>
>>>>> This subsystem is split into three source files:
>>>>>     - kvmi_msg.c - ABI and socket related functions
>>>>>     - kvmi_mem.c - handle map/unmap requests from the introspector
>>>>>     - kvmi.c - all the other
>>>>>
>>>>> The new data used by this subsystem is attached to the 'kvm' and
>>>>> 'kvm_vcpu' structures as opaque pointers (to 'kvmi' and 'kvmi_vcpu'
>>>>> structures).
>>>>>
>>>>> Besides the KVMI system, this patch exports the
>>>>> kvm_vcpu_ioctl_x86_get_xsave() and the mm_find_pmd() functions,
>>>>> adds a new vCPU request (KVM_REQ_INTROSPECTION) and a new VM ioctl
>>>>> (KVM_INTROSPECTION) used to pass the connection file handle from QEMU.
>>>>>
>>>>> Signed-off-by: Mihai DonE?u <mdontu@bitdefender.com>
>>>>> Signed-off-by: Adalbert LazA?r <alazar@bitdefender.com>
>>>>> Signed-off-by: NicuE?or CA(R)E?u <ncitu@bitdefender.com>
>>>>> Signed-off-by: Mircea CA(R)rjaliu <mcirjaliu@bitdefender.com>
>>>>> Signed-off-by: Marian Rotariu <mrotariu@bitdefender.com>
>>>>> ---
>>>>>     arch/x86/include/asm/kvm_host.h |    1 +
>>>>>     arch/x86/kvm/Makefile           |    1 +
>>>>>     arch/x86/kvm/x86.c              |    4 +-
>>>>>     include/linux/kvm_host.h        |    4 +
>>>>>     include/linux/kvmi.h            |   32 +
>>>>>     include/linux/mm.h              |    3 +
>>>>>     include/trace/events/kvmi.h     |  174 +++++
>>>>>     include/uapi/linux/kvm.h        |    8 +
>>>>>     mm/internal.h                   |    5 -
>>>>>     virt/kvm/kvmi.c                 | 1410 +++++++++++++++++++++++++++++++++++++++
>>>>>     virt/kvm/kvmi_int.h             |  121 ++++
>>>>>     virt/kvm/kvmi_mem.c             |  730 ++++++++++++++++++++
>>>>>     virt/kvm/kvmi_msg.c             | 1134 +++++++++++++++++++++++++++++++
>>>>>     13 files changed, 3620 insertions(+), 7 deletions(-)
>>>>>     create mode 100644 include/linux/kvmi.h
>>>>>     create mode 100644 include/trace/events/kvmi.h
>>>>>     create mode 100644 virt/kvm/kvmi.c
>>>>>     create mode 100644 virt/kvm/kvmi_int.h
>>>>>     create mode 100644 virt/kvm/kvmi_mem.c
>>>>>     create mode 100644 virt/kvm/kvmi_msg.c
>>>>>
>>>>> +bool kvmi_hook(struct kvm *kvm, struct kvm_introspection *qemu)
>>>>> +{
>>>>> +	kvm_info("Hooking vm with fd: %d\n", qemu->fd);
>>>>> +
>>>>> +	kvm_page_track_register_notifier(kvm, &kptn_node);
>>>>> +
>>>>> +	return (alloc_kvmi(kvm) && setup_socket(kvm, qemu));
>>>>
>>>> Is this safe? It could return false if the alloc fails (in which case
>>>> the caller has to do nothing) or if setting up the socket fails (in
>>>> which case the caller needs to free the allocated kvmi).
>>>>
>>>
>>> If the socket fails for any reason (eg. the introspection tool is
>>> stopped == socket closed) 'the plan' is to signal QEMU to reconnect
>>> (and call kvmi_hook() again) or else let the introspected VM continue (and
>>> try to reconnect asynchronously).
>>>
>>> I see that kvm_page_track_register_notifier() should not be called more
>>> than once.
>>>
>>> Maybe we should rename this to kvmi_rehook() or kvmi_reconnect().
>>
>> I assume that a kvmi_rehook() function would then not call
>> kvm_page_track_register_notifier() or at least have some check to make
>> sure it only calls it once?
>>
>> One approach would be to have separate kvmi_hook() and kvmi_rehook()
>> functions. Another possibility is to have kvmi_hook() take an extra
>> argument that's a boolean to specify if it's the first attempt at
>> hooking or not.
>>
> 
> alloc_kvmi() didn't worked with a second kvmi_hook() call.
> 
> For the moment I've changed the code to:
> 
> kvmi_hook
> 	return (alloc_kvmi && setup_socket)
> 
> alloc_kvmi
> 	return (IKVM(kvm) || __alloc_kvmi)
> 
> __alloc_kvmi
> 	kzalloc
> 	kvm_page_track_register_notifier
> 
> At least it works as 'advertised' :)

Yes, that seems a lot more clear :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
