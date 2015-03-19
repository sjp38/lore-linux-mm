Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id D9CE16B006E
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 11:36:56 -0400 (EDT)
Received: by lamx15 with SMTP id x15so65444244lam.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 08:36:56 -0700 (PDT)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com. [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id x16si1262610lbg.47.2015.03.19.08.36.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 08:36:55 -0700 (PDT)
Received: by ladw1 with SMTP id w1so65286285lad.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 08:36:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150319151214.GA2175@udknight>
References: <20150228064647.GA9550@udknight.ahead-top.com>
	<CALYGNiMLwhqQSmj58mT4MWk2RAuU-3TykoSd=XjuXVfqkL3NoA@mail.gmail.com>
	<20150319151214.GA2175@udknight>
Date: Thu, 19 Mar 2015 18:36:54 +0300
Message-ID: <CALYGNiPjEFLC2uiTGZMqP4TwDBit6+3VaiEpvGELYg8jDsVXBw@mail.gmail.com>
Subject: Re: [RFC] Strange do_munmap in mmap_region
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang YanQing <udknight@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, yinghai@kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Mar 19, 2015 at 6:12 PM, Wang YanQing <udknight@gmail.com> wrote:
> On Thu, Mar 19, 2015 at 11:33:41AM +0300, Konstantin Khlebnikov wrote:
>> On Sat, Feb 28, 2015 at 9:46 AM, Wang YanQing <udknight@gmail.com> wrote:
>> > Hi Mel Gorman and all.
>> >
>> > I have read do_mmap_pgoff and mmap_region more than one hour,
>> > but still can't catch sense about below code in mmap_region:
>> >
>> > "
>> >         /* Clear old maps */
>> >         error = -ENOMEM;
>> > munmap_back:
>> >         if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
>> >                 if (do_munmap(mm, addr, len))
>> >                         return -ENOMEM;
>> >                 goto munmap_back;
>> >         }
>> > "
>> >
>> > How can we just do_munmap overlapping vma without check its vm_flags
>> > and new vma's vm_flags? I must miss some important things, but I can't
>> > figure out.
>> >
>> > You give below comment about the code in "understand the linux memory manager":)
>> >
>> > "
>> > If a VMA was found and it is part of the new mmapping, this removes the
>> >  old mmapping because the new one will cover both
>> > "
>> >
>> > But if new mmapping has different vm_flags or others' property, how
>> > can we just say the new one will cover both?
>> >
>> > I appreicate any clue and explanation about this headache question.
>> >
>> > Thanks.
>> >
>>
>> Mmap() creates new mapping in given range
>> (new vma might be merged to one or both of sides if possible)
>> so everything what was here before is unmapped in process. Not?
>
> Thanks for reply.
>
> Assme process has vma in region 4096-8192, one page size, mapped to
> a file's first 4096 bytes, then a new map want to create vma in range
> 0-8192 to map 4096-1288 in file, please tell me what's your meaning:
> "so everything what was here before is unmapped in process"?
>
> Why we can just delete old vma for first 4096 size in file which reside
> in range 4096-8192 without notify user process? And create the new vma
> to occupy range 0-8192, do you think "everything" is really the same?

Old and new vmas are intersects? Then that means userpace asked to
create new mapping at fixed address, so it tells kernel to unmap
everything in that range. Without MAP_FIXED kernel always choose free area.

>
> Process lost old map for file's first 4096 bytes, and we use a new
> map for 4096-1288 in file to lie it, and say "the same".
>
> Indeed, I have another question, I guess the answer could save me the
> same as this question.
>
> I have read get_unmapped_area, it seems it will return a unused enough
> region for new vma, and we hold mm->mmap_sem before vm_mmap_pgoff,
> why unused enough region return by get_unmapped_area has overlapping vma
> in mmap_region cause the first question?
>
> I have tested it, running system always call do_munmap in mmap_region, so
> I must miss something important, it is strange.
>
> Thanks again.
>>
>> >
>> >
>> > --
>> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> > the body to majordomo@kvack.org.  For more info on Linux MM,
>> > see: http://www.linux-mm.org/ .
>> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
