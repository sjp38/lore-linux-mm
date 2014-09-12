Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id B4E8F6B0038
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 09:11:19 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id ex7so588976wid.9
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 06:11:14 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id n9si2897259wic.14.2014.09.12.06.11.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 06:11:09 -0700 (PDT)
Date: Fri, 12 Sep 2014 15:10:56 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 07/10] x86, mpx: decode MPX instruction to get bound
 violation information
In-Reply-To: <54127A16.4030701@zytor.com>
Message-ID: <alpine.DEB.2.10.1409121238290.4178@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-8-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120015030.4178@nanos> <5412230A.6090805@intel.com> <541223B1.5040705@zytor.com> <alpine.DEB.2.10.1409120133330.4178@nanos>
 <54127A16.4030701@zytor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Qiaowei Ren <qiaowei.ren@intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 11 Sep 2014, H. Peter Anvin wrote:

> On 09/11/2014 04:37 PM, Thomas Gleixner wrote:
> > > 
> > > Specifically because marshaling the data in and out of the generic
> > > decoder was more complex than a special-purpose decoder.
> > 
> > I did not look at that detail and I trust your judgement here, but
> > that is in no way explained in the changelog.
> > 
> > This whole patchset is a pain to review due to half baken changelogs
> > and complete lack of a proper design description.
> > 
> 
> I'm not wedded to that concept, by the way, but using the generic parser had a
> whole bunch of its own problems, including the fact that you're getting bytes
> from user space.

Errm. The instruction decoder does not even know about user space.

      u8 buf[MAX_INSN_SIZE];

      memset(buf, 0, MAX_INSN_SIZE);
      if (copy_from_user(buf, addr, MAX_INSN_SIZE))
      	    return 0;

      insn_init(insn, buf, is_64bit(current));

      /* Process the entire instruction */
      insn_get_length(insn);

      /* Decode the faulting address */
      return mpx_get_addr(insn, regs);

I really can't see why that should not work. insn_get_length()
retrieves exactly the information which is required to call
mpx_get_addr().

Sure it might be a bit slower because the generic decoder does a bit
more than the mpx private sauce, but this happens in the context of a
bounds violation and it really does not matter at all whether SIGSEGV
is delivered 5 microseconds later or not.

The only difference is the insn->limit handling in the MPX
decoder. The existing decoder has a limit check of:

#define MAX_INSN_SIZE       16

and MPX private one makes that

#define MAX_MPX_INSN_SIZE   15

and limits it runtime further to:

    MAX_MPX_INSN_SIZE - bytes_not_copied_from_user_space;

This is beyond silly, really. If we cannot copy 16 bytes from user
space, why bother in dealing with a partial copy at all.

Aside of that the existing decoder handles the 32bit app on a 64bit
kernel already correctly while the extra magic MPX decoder does
not. It just adds some magically optimized and different copy of the
existing decoder for exactly ZERO value.

> It might be worthwhile to compare the older patchset which did use the generic
> parser to make sure that it actually made sense.

I can't find such a thing. The first version I found contains an even
more convoluted private parser. Intelnal mail perhaps?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
