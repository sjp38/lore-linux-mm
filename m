Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 156AE6B0039
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 13:48:45 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id u57so1102135wes.1
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 10:48:41 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id pj8si8587913wjb.18.2014.09.12.10.48.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 10:48:39 -0700 (PDT)
Date: Fri, 12 Sep 2014 19:48:27 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 07/10] x86, mpx: decode MPX instruction to get bound
 violation information
In-Reply-To: <5412F7AB.5040901@zytor.com>
Message-ID: <alpine.DEB.2.10.1409121943430.4178@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-8-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120015030.4178@nanos> <5412230A.6090805@intel.com> <541223B1.5040705@zytor.com> <alpine.DEB.2.10.1409120133330.4178@nanos>
 <54127A16.4030701@zytor.com> <alpine.DEB.2.10.1409121238290.4178@nanos> <5412F7AB.5040901@zytor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Qiaowei Ren <qiaowei.ren@intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Sep 2014, H. Peter Anvin wrote:
> The correct limit is 15 bytes, not anything else, so this is a bug in
> the existing decoder.  A sequence of bytes longer than 15 bytes will

Fine. Lets fix it there.

> #UD, regardless of being "otherwise valid".

> Keep in mind the instruction may not be aligned, and you could fit an
> instruction plus a jump and still overrun a page in 15 bytes.

Fair enough. OTOH, I doubt that a text mapping will end exactly at
that jump after the MPX instruction.

So that's simple to fix.

Kill the hardcoded limit in lib/insn.c and let the callsites hand in a
lenght argument. So you can still use it for MPX and avoid 200 lines
of blindly copied and slightly different decoder code.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
