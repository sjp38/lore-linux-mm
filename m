Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4378E6B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 20:48:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x66so13199047pfe.21
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:48:35 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id i188si12082953pgd.378.2017.11.21.17.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 17:48:33 -0800 (PST)
Subject: Re: [RFC PATCH 0/2] mm: introduce MAP_FIXED_SAFE
References: <20171116101900.13621-1-mhocko@kernel.org>
 <20171116121438.6vegs4wiahod3byl@dhcp22.suse.cz>
 <b1848e34-7fcd-8ad8-6a6a-3be3dce3fda7@nvidia.com>
 <20171120090509.moagbwu7ug3y42gj@dhcp22.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <9a02b37c-978a-48ef-0b22-b1e4cbb9a704@nvidia.com>
Date: Tue, 21 Nov 2017 17:48:31 -0800
MIME-Version: 1.0
In-Reply-To: <20171120090509.moagbwu7ug3y42gj@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>

On 11/20/2017 01:05 AM, Michal Hocko wrote:
> On Fri 17-11-17 00:45:49, John Hubbard wrote:
>> On 11/16/2017 04:14 AM, Michal Hocko wrote:
>>> [Ups, managed to screw the subject - fix it]
>>>
>>> On Thu 16-11-17 11:18:58, Michal Hocko wrote:
>>>> Hi,
>>>> this has started as a follow up discussion [1][2] resulting in the
>>>> runtime failure caused by hardening patch [3] which removes MAP_FIXED
>>>> from the elf loader because MAP_FIXED is inherently dangerous as it
>>>> might silently clobber and existing underlying mapping (e.g. stack). The
>>>> reason for the failure is that some architectures enforce an alignment
>>>> for the given address hint without MAP_FIXED used (e.g. for shared or
>>>> file backed mappings).
>>>>
>>>> One way around this would be excluding those archs which do alignment
>>>> tricks from the hardening [4]. The patch is really trivial but it has
>>>> been objected, rightfully so, that this screams for a more generic
>>>> solution. We basically want a non-destructive MAP_FIXED.
>>>>
>>>> The first patch introduced MAP_FIXED_SAFE which enforces the given
>>>> address but unlike MAP_FIXED it fails with ENOMEM if the given range
>>>> conflicts with an existing one. The flag is introduced as a completely
>>>> new flag rather than a MAP_FIXED extension because of the backward
>>>> compatibility. We really want a never-clobber semantic even on older
>>>> kernels which do not recognize the flag. Unfortunately mmap sucks wrt.
>>>> flags evaluation because we do not EINVAL on unknown flags. On those
>>>> kernels we would simply use the traditional hint based semantic so the
>>>> caller can still get a different address (which sucks) but at least not
>>>> silently corrupt an existing mapping. I do not see a good way around
>>>> that. Except we won't export expose the new semantic to the userspace at
>>>> all. It seems there are users who would like to have something like that
>>>> [5], though. Atomic address range probing in the multithreaded programs
>>>> sounds like an interesting thing to me as well, although I do not have
>>>> any specific usecase in mind.
>>
>> Hi Michal,
>>
>> From looking at the patchset, it seems to me that the new MAP_FIXED_SAFE
>> (or whatever it ends up being named) *would* be passed through from
>> user space. When you say that "we won't export expose the new semantic 
>> to the userspace at all", do you mean that glibc won't add it? Or
>> is there something I'm missing, that prevents that flag from getting
>> from the syscall, to do_mmap()?
> 
> I meant that I could make it an internal flag outside of the map_type
> space. So the userspace will not be able to use it.
>  
>> On the usage: there are cases in user space that could probably make
>> good use of a no-clobber hint to MAP_FIXED. The user space code
>> that surrounds HMM (speaking loosely there--it's really any user space
>> code that manages a unified memory address space, across devices)
>> often ends up using MAP_FIXED, but MAP_FIXED crams several features
>> into one flag: an exact address, an "atomic" switch to the new mapping,
>> and unmapping the old mappings. That's pretty overloaded, so being
>> able to split it up a bit, by removing one of those features, seems
>> useful.
> 
> Yes, atomic address range probing sounds useful. I cannot comment on HMM
> usage but if you have any more specific I would welcome any links to add
> them to the changelog.
> 

Hi Michal,

Yes, it really is useful for user space. I'll use CUDA as an example, but I 
think anything that enforces a uniform virtual addressing scheme across CPUs
and devices, probably has to do something eerily similar. CUDA does this:

a) Searches /proc/<pid>/maps for a "suitable" region of available VA space. 
"Suitable" generally means it has to have a base address within a certain
limited range (a particular device model might have odd limitations, for 
example), it has to be large enough, and alignment has to be large enough
(again, various devices may have constraints that lead us to do this).

This is of course subject to races with other threads in the process.

Let's say it finds a region starting at va.

b) Next it does: 
    p = mmap(va, ...) 

*without* setting MAP_FIXED, of course (so va is just a hint), to attempt to
safely reserve that region. If p != va, then in most cases, this is a failure
(almost certainly due to another thread getting a mapping from that region
before we did), and so this layer now has to call munmap(), before returning
a "failure: retry" to upper layers.

    IMPROVEMENT: --> if instead, we could call this:

            p = mmap(va, ... MAP_FIXED_NO_CLOBBER ...)

        , then we could skip the munmap() call upon failure. This is a small thing, 
        but it is useful here. (Thanks to Piotr Jaroszynski and Mark Hairgrove
        for helping me get that detail exactly right, btw.)

c) After that, CUDA suballocates from p, via: 
 
     q = mmap(sub_region_start, ... MAP_FIXED ...)

Interestingly enough, "freeing" is also done via MAP_FIXED, and setting PROT_NONE
to the subregion. Anyway, I just included (c) for general interest.

I expect that as we continue working on the open source compute software stack,
this new capability will be useful there, too.

Oh, and on the naming, when I described how your implementation worked (without
naming it) to Piotr, he said, "oh, something like map-fixed-no-clobber?". So I
think my miniature sociology naming data point here can bolster the case ever so
slightly for calling it MAP_FIXED_NO_CLOBBER. haha. :)

thanks,
John Hubbard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
