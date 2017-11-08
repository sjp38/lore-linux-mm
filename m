Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C47C6B02B6
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 19:13:42 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id a132so275431oih.22
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 16:13:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q184sor894421oib.140.2017.11.07.16.13.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 16:13:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171107183950.46f238fd@vento.lan>
References: <151001623063.16354.14661493921524115663.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151001624873.16354.2551756846133945335.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171107063345.22626a5d@vento.lan> <CAPcyv4hNSV=c4KY8omKEdRth2w4YEr8EQJQfOoxXS8XELGFVcA@mail.gmail.com>
 <20171107183950.46f238fd@vento.lan>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 Nov 2017 16:13:40 -0800
Message-ID: <CAPcyv4gvE8ovWA8DQoHJYoGqaOk1HxQLBJdwPPu3OXAb=MbfKw@mail.gmail.com>
Subject: Re: [PATCH 3/3] [media] v4l2: disable filesystem-dax mapping support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mauro Carvalho Chehab <mchehab@s-opensource.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, "Linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Tue, Nov 7, 2017 at 12:39 PM, Mauro Carvalho Chehab
<mchehab@s-opensource.com> wrote:
> Em Tue, 7 Nov 2017 09:43:41 -0800
> Dan Williams <dan.j.williams@intel.com> escreveu:
>
>> On Tue, Nov 7, 2017 at 12:33 AM, Mauro Carvalho Chehab
>> <mchehab@s-opensource.com> wrote:
>> > Em Mon, 06 Nov 2017 16:57:28 -0800
>> > Dan Williams <dan.j.williams@intel.com> escreveu:
>> >
>> >> V4L2 memory registrations are incompatible with filesystem-dax that
>> >> needs the ability to revoke dma access to a mapping at will, or
>> >> otherwise allow the kernel to wait for completion of DMA. The
>> >> filesystem-dax implementation breaks the traditional solution of
>> >> truncate of active file backed mappings since there is no page-cache
>> >> page we can orphan to sustain ongoing DMA.
>> >>
>> >> If v4l2 wants to support long lived DMA mappings it needs to arrange to
>> >> hold a file lease or use some other mechanism so that the kernel can
>> >> coordinate revoking DMA access when the filesystem needs to truncate
>> >> mappings.
>> >
>> >
>> > Not sure if I understand this your comment here... what happens
>> > if FS_DAX is enabled? The new err = get_user_pages_longterm()
>> > would cause DMA allocation to fail?
>>
>> Correct, any attempt to specify a filesystem-dax mapping range to
>> get_user_pages_longterm will fail with EOPNOTSUPP. In the future we
>> want to add something like a 'struct file_lock *' argument to
>> get_user_pages_longterm so that the kernel has a handle to revoke
>> access to the returned pages. Once we have a safe way for the kernel
>> to undo elevated page counts we can stop failing the longterm vs
>> filesystem-dax case.
>
> Argh! Perhaps we should make it depend on BROKEN while not fixed :-/

Small consolation, but we do warn that filesystem-dax is still
considered experimental when mounting a filesystem with "-o dax"

>> Here is more background on why _longterm gup is a problem for filesystem-dax:
>>
>>     https://lwn.net/Articles/737273/
>>
>> > If so, that doesn't sound
>> > right. Instead, mm should somehow mark this mapping to be out
>> > of FS_DAX control range.
>>
>> DAX is currently global setting for the entire backing device of the
>> filesystem, so any mapping of any file when the "-o dax" mount option
>> is set is in the "FS_DAX control range". In other words there's
>> currently no way to prevent FS_DAX mappings from being exposed to V4L2
>> outside of CONFIG_FS_DAX=n.
>
> Grrr...
>
>> > Also, it is not only videobuf-dma-sg.c that does long lived
>> > DMA mappings. VB2 also does that (and videobuf-vmalloc).
>>
>> Without finding the code videobuf-vmalloc sounds like it should be ok
>> if the kernel is allocating memory separate from a file-backed DAX
>> mapping.
>
> videobuf-vmalloc do DMA mapping for pages allocated via vmalloc(),
> via vmalloc_user()/remap_vmalloc_range().

Ok, that's completely safe since filesystem-dax mappings are not
involved in a vmalloc backed virtual address range.

> There aren't much drivers using VB1 anymore, but a change at VB2
> will likely break support for almost all webcams if fs DAX is
> in usage.

Yes, unless / until we can switch userspace to using a new memory
registration api that includes a way for the kernel to revoke access
to a dax mapping. Another mitigation is following through on support
for moving dax support from a global mount flag to a per-inode flag to
at least prevent dax from leaking to use cases that need explicit
coordination.

>> Where is the VB2 get_user_pages call?
>
> Before changeset 3336c24f25ec, the logic for get_user_pages() were
> at drivers/media/v4l2-core/videobuf2-dma-sg.c. Now, the logic
> it uses is inside mm/frame_vector.c.

Ok, I'll take a look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
