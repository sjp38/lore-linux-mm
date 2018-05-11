Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D86876B0663
	for <linux-mm@kvack.org>; Fri, 11 May 2018 08:36:24 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n83-v6so1350683itg.2
        for <linux-mm@kvack.org>; Fri, 11 May 2018 05:36:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 78-v6sor1544257ioi.237.2018.05.11.05.36.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 May 2018 05:36:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180508151137.zguepljs3pa7xv5g@armageddon.cambridge.arm.com>
References: <cover.1524077494.git.andreyknvl@google.com> <0db34d04fa16be162336106e3b4a94f3dacc0af4.1524077494.git.andreyknvl@google.com>
 <20180426174714.4jtb72q56w3xonsa@armageddon.cambridge.arm.com>
 <CAAeHK+zY8p9E4FZa7mbdgR=wR0u-RDS552dn=h9fKRC-ArYLdw@mail.gmail.com>
 <20180502153645.fui4ju3scsze3zkq@black.fi.intel.com> <CAAeHK+yTbmZfkeNbqbo+J90zsjsM99rwnYBGfQBxphHMMfgD7A@mail.gmail.com>
 <20180508151137.zguepljs3pa7xv5g@armageddon.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 11 May 2018 14:36:22 +0200
Message-ID: <CAAeHK+yR9=SYEBg-Pvi+x3qSqQSG1u+79pk5vQvOcsp+o=zkxw@mail.gmail.com>
Subject: Re: [PATCH 4/6] mm, arm64: untag user addresses in mm/gup.c
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jonathan Corbet <corbet@lwn.net>, Dmitry Vyukov <dvyukov@google.com>, Bart Van Assche <bart.vanassche@wdc.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Dan Williams <dan.j.williams@intel.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, James Morse <james.morse@arm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>

On Tue, May 8, 2018 at 5:11 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Wed, May 02, 2018 at 07:25:17PM +0200, Andrey Konovalov wrote:
>> On Wed, May 2, 2018 at 5:36 PM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> > On Wed, May 02, 2018 at 02:38:42PM +0000, Andrey Konovalov wrote:
>> >> > Does having a tagged address here makes any difference? I couldn't hit a
>> >> > failure with my simple tests (LD_PRELOAD a library that randomly adds
>> >> > tags to pointers returned by malloc).
>> >>
>> >> I think you're right, follow_page_mask is only called from
>> >> __get_user_pages, which already untagged the address. I'll remove
>> >> untagging here.
>> >
>> > It also called from follow_page(). Have you covered all its callers?
>>
>> Oh, missed that, will take a look.
>>
>> Thinking about that, would it make sense to add untagging to find_vma
>> (and others) instead of trying to cover all find_vma callers?
>
> I don't think adding the untagging to find_vma() is sufficient. In many
> cases the caller does a subsequent check like 'start < vma->vm_start'
> (see sys_msync() as an example, there are a few others as well).

OK.

> What I
> did in my tests was a WARN_ON_ONCE() in find_vma() if the address is
> tagged.

So this is similar to what I did.

Do you think trying to find "all places where we cast out __user" with
static analysis as Kirill suggested is something I should pursue? Or
is this patchset is good as is as the first approximation, since we
can fix more things where untagging is needed as we discover them one
by one?
