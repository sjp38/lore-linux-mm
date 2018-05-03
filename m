Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1E0F6B000A
	for <linux-mm@kvack.org>; Thu,  3 May 2018 11:24:33 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m18-v6so5833251lfb.9
        for <linux-mm@kvack.org>; Thu, 03 May 2018 08:24:33 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 127-v6sor3073592ljf.16.2018.05.03.08.24.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 08:24:31 -0700 (PDT)
Date: Thu, 3 May 2018 18:24:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/6] mm, arm64: untag user addresses in mm/gup.c
Message-ID: <20180503152432.q742zvdbv6xtvo34@kshutemo-mobl1>
References: <cover.1524077494.git.andreyknvl@google.com>
 <0db34d04fa16be162336106e3b4a94f3dacc0af4.1524077494.git.andreyknvl@google.com>
 <20180426174714.4jtb72q56w3xonsa@armageddon.cambridge.arm.com>
 <CAAeHK+zY8p9E4FZa7mbdgR=wR0u-RDS552dn=h9fKRC-ArYLdw@mail.gmail.com>
 <20180502153645.fui4ju3scsze3zkq@black.fi.intel.com>
 <CAAeHK+yTbmZfkeNbqbo+J90zsjsM99rwnYBGfQBxphHMMfgD7A@mail.gmail.com>
 <CAAeHK+zh0LSpq2VFJeHrV7AETnL1b9R+yex3iPMg5SetbEyxwg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+zh0LSpq2VFJeHrV7AETnL1b9R+yex3iPMg5SetbEyxwg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jonathan Corbet <corbet@lwn.net>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, James Morse <james.morse@arm.com>, Kees Cook <keescook@chromium.org>, Bart Van Assche <bart.vanassche@wdc.com>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Thu, May 03, 2018 at 04:09:56PM +0200, Andrey Konovalov wrote:
> On Wed, May 2, 2018 at 7:25 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > On Wed, May 2, 2018 at 5:36 PM, Kirill A. Shutemov
> > <kirill.shutemov@linux.intel.com> wrote:
> >> On Wed, May 02, 2018 at 02:38:42PM +0000, Andrey Konovalov wrote:
> >>> > Does having a tagged address here makes any difference? I couldn't hit a
> >>> > failure with my simple tests (LD_PRELOAD a library that randomly adds
> >>> > tags to pointers returned by malloc).
> >>>
> >>> I think you're right, follow_page_mask is only called from
> >>> __get_user_pages, which already untagged the address. I'll remove
> >>> untagging here.
> >>
> >> It also called from follow_page(). Have you covered all its callers?
> >
> > Oh, missed that, will take a look.
> 
> I wasn't able to find anything that calls follow_page with pointers
> passed from userspace except for the memory subsystem syscalls, and we
> deliberately don't add untagging in those.

I guess I missed this part, but could you elaborate on this? Why?
Not yet or not ever?

Also I wounder if we can find (with sparse?) all places where we cast out
__user. This would give a nice list of places where to pay attention.

-- 
 Kirill A. Shutemov
