Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 739126B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 14:39:13 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id la4so1137589vcb.41
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:39:13 -0700 (PDT)
Received: from mail-ve0-f177.google.com (mail-ve0-f177.google.com [209.85.128.177])
        by mx.google.com with ESMTPS id ip6si4344449vec.165.2014.05.20.11.39.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 11:39:12 -0700 (PDT)
Received: by mail-ve0-f177.google.com with SMTP id db11so1124572veb.8
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:39:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <537B9EA6.3030103@zytor.com>
References: <cover.1400538962.git.luto@amacapital.net> <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net>
 <20140520172134.GJ2185@moon> <CALCETrWSgjc+iymPrvC9xiz1z4PqQS9e9F5mRLNnuabWTjQGQQ@mail.gmail.com>
 <20140520174759.GK2185@moon> <CALCETrUARCP0eNj5e3Kh81KDXg5AFLnoNoDHeoZcBXi9z-5F3w@mail.gmail.com>
 <20140520180104.GL2185@moon> <537B9C6D.7010705@zytor.com> <CALCETrWmKvox1poGK5fBw2OBip7zMpjb-bpYrzd4EGHPDvZEHg@mail.gmail.com>
 <537B9EA6.3030103@zytor.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 20 May 2014 11:38:52 -0700
Message-ID: <CALCETrVbdWSxgSjNnmqjtDLYKpiah09VUGA56_abrPwUC6q=mA@mail.gmail.com>
Subject: Re: [PATCH 3/4] x86,mm: Improve _install_special_mapping and fix x86
 vdso naming
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, May 20, 2014 at 11:27 AM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 05/20/2014 11:24 AM, Andy Lutomirski wrote:
>> On Tue, May 20, 2014 at 11:18 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>>> On 05/20/2014 11:01 AM, Cyrill Gorcunov wrote:
>>>>>
>>>>> This patch should fix this issue, at least.  If there's still a way to
>>>>> get a native vdso that doesn't say "[vdso]", please let me know/
>>>>
>>>> Yes, having a native procfs way to detect vdso is much preferred!
>>>>
>>>
>>> Is there any path by which we can end up with [vdso] without a leading
>>> slash in /proc/self/maps?  Otherwise, why is that not "native"?
>>
>> Dunno.  But before this patch the reverse was possible: we can end up
>> with a vdso that doesn't say [vdso].
>>
>
> That's a bug, which is being fixed.  We can't go back in time and create
> new interfaces on old kernels.
>
>>>
>>>>>>   The situation get worse when task was dumped on one kernel and
>>>>>> then restored on another kernel where vdso content is different
>>>>>> from one save in image -- is such case as I mentioned we need
>>>>>> that named vdso proxy which redirect calls to vdso of the system
>>>>>> where task is restoring. And when such "restored" task get checkpointed
>>>>>> second time we don't dump new living vdso but save only old vdso
>>>>>> proxy on disk (detecting it is a different story, in short we
>>>>>> inject a unique mark into elf header).
>>>>>
>>>>> Yuck.  But I don't know whether the kernel can help much here.
>>>>
>>>> Some prctl which would tell kernel to put vdso at specifed address.
>>>> We can live without it for now so not a big deal (yet ;)
>>>
>>> mremap() will do this for you.
>>
>> Except that it's buggy: it doesn't change mm->context.vdso.  For
>> 64-bit tasks, the only consumer outside exec was arch_vma_name, and
>> this patch removes even that.  For 32-bit tasks, though, it's needed
>> for signal delivery.
>>
>
> Again, a bug, let's fix it rather than saying we need a new interface.

What happens if someone remaps just part of the vdso?

Presumably we'd just track the position of the first page of the vdso,
but this might be hard to implement: I don't think there's any
callback from the core mm code for ths.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
