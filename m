Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9826C6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 18:26:19 -0500 (EST)
Received: by mail-oi0-f46.google.com with SMTP id y66so264958964oig.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 15:26:19 -0800 (PST)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id ry4si7972174obb.106.2016.01.04.15.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 15:26:18 -0800 (PST)
Received: by mail-ob0-x22a.google.com with SMTP id wp13so126334402obc.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 15:26:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160104230246.GU22941@pd.tnic>
References: <cover.1451869360.git.tony.luck@intel.com> <968b4c079271431292fddfa49ceacff576be6849.1451869360.git.tony.luck@intel.com>
 <20160104120751.GG22941@pd.tnic> <CA+8MBbKZ6VfN9t5-dYNHhZVU0k2HEr+E7Un0y2gtsxE0sDgoHQ@mail.gmail.com>
 <CALCETrU9AN6HmButY0tV1F4syNHZVKyQyVvit2JHcHAuXK9XNA@mail.gmail.com>
 <20160104210228.GR22941@pd.tnic> <CALCETrVOF9P3YFKMeShp0FYX15cqppkWhhiOBi6pxfu6k+XDmA@mail.gmail.com>
 <20160104230246.GU22941@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 4 Jan 2016 15:25:58 -0800
Message-ID: <CALCETrUcuZSp_D-bsZi3i7m2-DKHBOe4KpmJnbR+1bVvbyp5Mw@mail.gmail.com>
Subject: Re: [PATCH v6 1/4] x86: Clean up extable entry format (and free up a bit)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@gmail.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86-ML <x86@kernel.org>

On Mon, Jan 4, 2016 at 3:02 PM, Borislav Petkov <bp@alien8.de> wrote:
> On Mon, Jan 04, 2016 at 02:29:09PM -0800, Andy Lutomirski wrote:
>> Josh will argue with you if he sees that :)
>
> Except Josh doesn't need allyesconfigs. tinyconfig's __ex_table is 2K.

If we do the make-it-bigger approach, we get a really nice
simplification.  Screw the whole 'class' idea -- just store an offset
to a handler.

bool extable_handler_default(struct pt_regs *regs, unsigned int fault,
unsigned long error_code, unsigned long info)
{
    if (fault == X86_TRAP_MC)
        return false;

    ...
}

bool extable_handler_mc_copy(struct pt_regs *regs, unsigned int fault,
unsigned long error_code, unsigned long info);
bool extable_handler_getput_ex(struct pt_regs *regs, unsigned int
fault, unsigned long error_code, unsigned long info);

and then shove ".long extable_handler_whatever - ." into the extable entry.

Major bonus points to whoever can figure out how to make
extable_handler_iret work -- the current implementation of that is a
real turd.  (Hint: it's not clear to me that it's even possible
without preserving at least part of the asm special case.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
