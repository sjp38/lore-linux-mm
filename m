Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 25D5A6B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 14:28:12 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id b13so920932wgh.19
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:28:11 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id cf2si13706244wjc.124.2014.05.20.11.28.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 May 2014 11:28:06 -0700 (PDT)
Message-ID: <537B9EA6.3030103@zytor.com>
Date: Tue, 20 May 2014 11:27:50 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] x86,mm: Improve _install_special_mapping and fix
 x86 vdso naming
References: <cover.1400538962.git.luto@amacapital.net> <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net> <20140520172134.GJ2185@moon> <CALCETrWSgjc+iymPrvC9xiz1z4PqQS9e9F5mRLNnuabWTjQGQQ@mail.gmail.com> <20140520174759.GK2185@moon> <CALCETrUARCP0eNj5e3Kh81KDXg5AFLnoNoDHeoZcBXi9z-5F3w@mail.gmail.com> <20140520180104.GL2185@moon> <537B9C6D.7010705@zytor.com> <CALCETrWmKvox1poGK5fBw2OBip7zMpjb-bpYrzd4EGHPDvZEHg@mail.gmail.com>
In-Reply-To: <CALCETrWmKvox1poGK5fBw2OBip7zMpjb-bpYrzd4EGHPDvZEHg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On 05/20/2014 11:24 AM, Andy Lutomirski wrote:
> On Tue, May 20, 2014 at 11:18 AM, H. Peter Anvin <hpa@zytor.com> wrote:
>> On 05/20/2014 11:01 AM, Cyrill Gorcunov wrote:
>>>>
>>>> This patch should fix this issue, at least.  If there's still a way to
>>>> get a native vdso that doesn't say "[vdso]", please let me know/
>>>
>>> Yes, having a native procfs way to detect vdso is much preferred!
>>>
>>
>> Is there any path by which we can end up with [vdso] without a leading
>> slash in /proc/self/maps?  Otherwise, why is that not "native"?
> 
> Dunno.  But before this patch the reverse was possible: we can end up
> with a vdso that doesn't say [vdso].
> 

That's a bug, which is being fixed.  We can't go back in time and create
new interfaces on old kernels.

>>
>>>>>   The situation get worse when task was dumped on one kernel and
>>>>> then restored on another kernel where vdso content is different
>>>>> from one save in image -- is such case as I mentioned we need
>>>>> that named vdso proxy which redirect calls to vdso of the system
>>>>> where task is restoring. And when such "restored" task get checkpointed
>>>>> second time we don't dump new living vdso but save only old vdso
>>>>> proxy on disk (detecting it is a different story, in short we
>>>>> inject a unique mark into elf header).
>>>>
>>>> Yuck.  But I don't know whether the kernel can help much here.
>>>
>>> Some prctl which would tell kernel to put vdso at specifed address.
>>> We can live without it for now so not a big deal (yet ;)
>>
>> mremap() will do this for you.
> 
> Except that it's buggy: it doesn't change mm->context.vdso.  For
> 64-bit tasks, the only consumer outside exec was arch_vma_name, and
> this patch removes even that.  For 32-bit tasks, though, it's needed
> for signal delivery.
> 

Again, a bug, let's fix it rather than saying we need a new interface.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
