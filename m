Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4246B02A1
	for <linux-mm@kvack.org>; Tue,  8 May 2018 11:11:47 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id a18-v6so14927297oiy.14
        for <linux-mm@kvack.org>; Tue, 08 May 2018 08:11:47 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a20-v6si6237297oih.294.2018.05.08.08.11.46
        for <linux-mm@kvack.org>;
        Tue, 08 May 2018 08:11:46 -0700 (PDT)
Date: Tue, 8 May 2018 16:11:38 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 4/6] mm, arm64: untag user addresses in mm/gup.c
Message-ID: <20180508151137.zguepljs3pa7xv5g@armageddon.cambridge.arm.com>
References: <cover.1524077494.git.andreyknvl@google.com>
 <0db34d04fa16be162336106e3b4a94f3dacc0af4.1524077494.git.andreyknvl@google.com>
 <20180426174714.4jtb72q56w3xonsa@armageddon.cambridge.arm.com>
 <CAAeHK+zY8p9E4FZa7mbdgR=wR0u-RDS552dn=h9fKRC-ArYLdw@mail.gmail.com>
 <20180502153645.fui4ju3scsze3zkq@black.fi.intel.com>
 <CAAeHK+yTbmZfkeNbqbo+J90zsjsM99rwnYBGfQBxphHMMfgD7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+yTbmZfkeNbqbo+J90zsjsM99rwnYBGfQBxphHMMfgD7A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jonathan Corbet <corbet@lwn.net>, Dmitry Vyukov <dvyukov@google.com>, Bart Van Assche <bart.vanassche@wdc.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Dan Williams <dan.j.williams@intel.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, James Morse <james.morse@arm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Zi Yan <zi.yan@cs.rutgers.edu>

On Wed, May 02, 2018 at 07:25:17PM +0200, Andrey Konovalov wrote:
> On Wed, May 2, 2018 at 5:36 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > On Wed, May 02, 2018 at 02:38:42PM +0000, Andrey Konovalov wrote:
> >> > Does having a tagged address here makes any difference? I couldn't hit a
> >> > failure with my simple tests (LD_PRELOAD a library that randomly adds
> >> > tags to pointers returned by malloc).
> >>
> >> I think you're right, follow_page_mask is only called from
> >> __get_user_pages, which already untagged the address. I'll remove
> >> untagging here.
> >
> > It also called from follow_page(). Have you covered all its callers?
> 
> Oh, missed that, will take a look.
> 
> Thinking about that, would it make sense to add untagging to find_vma
> (and others) instead of trying to cover all find_vma callers?

I don't think adding the untagging to find_vma() is sufficient. In many
cases the caller does a subsequent check like 'start < vma->vm_start'
(see sys_msync() as an example, there are a few others as well). What I
did in my tests was a WARN_ON_ONCE() in find_vma() if the address is
tagged.

-- 
Catalin
