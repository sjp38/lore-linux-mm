Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA0FB6B0005
	for <linux-mm@kvack.org>; Thu,  3 May 2018 12:51:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u137-v6so16592itc.4
        for <linux-mm@kvack.org>; Thu, 03 May 2018 09:51:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e84-v6sor5242937itb.143.2018.05.03.09.51.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 09:51:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180503152432.q742zvdbv6xtvo34@kshutemo-mobl1>
References: <cover.1524077494.git.andreyknvl@google.com> <0db34d04fa16be162336106e3b4a94f3dacc0af4.1524077494.git.andreyknvl@google.com>
 <20180426174714.4jtb72q56w3xonsa@armageddon.cambridge.arm.com>
 <CAAeHK+zY8p9E4FZa7mbdgR=wR0u-RDS552dn=h9fKRC-ArYLdw@mail.gmail.com>
 <20180502153645.fui4ju3scsze3zkq@black.fi.intel.com> <CAAeHK+yTbmZfkeNbqbo+J90zsjsM99rwnYBGfQBxphHMMfgD7A@mail.gmail.com>
 <CAAeHK+zh0LSpq2VFJeHrV7AETnL1b9R+yex3iPMg5SetbEyxwg@mail.gmail.com> <20180503152432.q742zvdbv6xtvo34@kshutemo-mobl1>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 3 May 2018 18:51:14 +0200
Message-ID: <CAAeHK+xzcjVm+E+nHLNcZ1jDOMM3ha2fH+Y0G26RU7aO81BSdw@mail.gmail.com>
Subject: Re: [PATCH 4/6] mm, arm64: untag user addresses in mm/gup.c
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jonathan Corbet <corbet@lwn.net>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, James Morse <james.morse@arm.com>, Kees Cook <keescook@chromium.org>, Bart Van Assche <bart.vanassche@wdc.com>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Thu, May 3, 2018 at 5:24 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> On Thu, May 03, 2018 at 04:09:56PM +0200, Andrey Konovalov wrote:
>> On Wed, May 2, 2018 at 7:25 PM, Andrey Konovalov <andreyknvl@google.com> wrote:

>> I wasn't able to find anything that calls follow_page with pointers
>> passed from userspace except for the memory subsystem syscalls, and we
>> deliberately don't add untagging in those.
>
> I guess I missed this part, but could you elaborate on this? Why?
> Not yet or not ever?

Check out the discussion here:
https://www.spinics.net/lists/arm-kernel/msg640936.html

>
> Also I wounder if we can find (with sparse?) all places where we cast out
> __user. This would give a nice list of places where to pay attention.

The way I tested this is I added BUG_ON(top byte tag is set) to
find_vma and find_extend_vma and ran a modified version of syzkaller
that embeds tags into pointers overnight. The only crashes that I saw
were coming from memory subsystem syscalls. I then temporarily added
untagging to suppress those crashes
(https://gist.github.com/xairy/3aa1f57798fa62522c8ac53fad9b74ca), and
didn't see any crashes after that.
