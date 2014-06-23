Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id CC80C6B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 17:04:44 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id w7so5355199lbi.35
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 14:04:44 -0700 (PDT)
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
        by mx.google.com with ESMTPS id bm6si27840472lbb.30.2014.06.23.14.04.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 14:04:43 -0700 (PDT)
Received: by mail-lb0-f179.google.com with SMTP id z11so5291756lbi.38
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 14:04:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53A88DE4.8050107@intel.com>
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com>
 <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com> <53A884B2.5070702@mit.edu>
 <53A88806.1060908@intel.com> <CALCETrXYZZiZsDiUvvZd0636+qHP9a0sHTN6wt_ZKjvLaeeBzw@mail.gmail.com>
 <53A88DE4.8050107@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 23 Jun 2014 14:04:22 -0700
Message-ID: <CALCETrWBbkFzQR3tz1TphqxiGYycvzrFrKc=ghzMynbem=d7rg@mail.gmail.com>
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Mon, Jun 23, 2014 at 1:28 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 06/23/2014 01:06 PM, Andy Lutomirski wrote:
>> Can the new vm_operation "name" be use for this?  The magic "always
>> written to core dumps" feature might need to be reconsidered.
>
> One thing I'd like to avoid is an MPX vma getting merged with a non-MPX
> vma.  I don't see any code to prevent two VMAs with different
> vm_ops->names from getting merged.  That seems like a bit of a design
> oversight for ->name.  Right?

AFAIK there are no ->name users that don't also set ->close, for
exactly that reason.  I'd be okay with adding a check for ->name, too.

Hmm.  If MPX vmas had a real struct file attached, this would all come
for free.  Maybe vmas with non-default vm_ops and file != NULL should
never be mergeable?

>
> Thinking out loud a bit... There are also some more complicated but more
> performant cleanup mechanisms that I'd like to go after in the future.
> Given a page, we might want to figure out if it is an MPX page or not.
> I wonder if we'll ever collide with some other user of vm_ops->name.  It
> looks fairly narrowly used at the moment, but would this keep us from
> putting these pages on, say, a tmpfs mount?  Doesn't look that way at
> the moment.

You could always check the vm_ops pointer to see if it's MPX.

One feature I've wanted: a way to have special per-process vmas that
can be easily found.  For example, I want to be able to efficiently
find out where the vdso and vvar vmas are.  I don't think this is
currently supported.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
