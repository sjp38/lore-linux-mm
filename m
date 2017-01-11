Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B2F436B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 13:49:57 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so65895581pfb.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 10:49:57 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z26si6589824pgc.94.2017.01.11.10.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 10:49:56 -0800 (PST)
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com>
 <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com>
 <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com>
 <CALCETrUQ2+P424d9MW-Dy2yQ0+EnMfBuY80wd8NkNmc8is0AUw@mail.gmail.com>
 <978d5f1a-ec4d-f747-93fd-27ecfe10cb88@intel.com>
 <20170111142904.GD4895@node.shutemov.name>
 <CALCETrUn=KNdOnoRYd8GcnXPNDHAhGkaMaHRTAri4o92FSC1qg@mail.gmail.com>
 <20170111183750.GE4895@node.shutemov.name>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0a6f1ee4-e260-ae7b-3d39-c53f6bed8102@intel.com>
Date: Wed, 11 Jan 2017 10:49:55 -0800
MIME-Version: 1.0
In-Reply-To: <20170111183750.GE4895@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 01/11/2017 10:37 AM, Kirill A. Shutemov wrote:
>> How about preventing the max addr from being changed to too high a
>> value while MPX is on instead of overriding the set value?  This would
>> have the added benefit that it would prevent silent failures where you
>> think you've enabled large addresses but MPX is also on and mmap
>> refuses to return large addresses.
> Setting rlimit high doesn't mean that you necessary will get access to
> full address space, even without MPX in picture. TASK_SIZE limits the
> available address space too.

OK, sure...  If you want to take another mechanism into account with
respect to MPX, we can do that.  We'd just need to change every
mechanism we want to support to ensure that it can't transition in ways
that break MPX.

What are you arguing here, though?  Since we *might* be limited by
something else that we should not care about controlling the rlimit?

> I think it's consistent with other resources in rlimit: setting RLIMIT_RSS
> to unlimited doesn't really means you are not subject to other resource
> management.

The farther we get into this, the more and more I think using an rlimit
is a horrible idea.  Its semantics aren't a great match, and you seem to
be resistant to making *this* rlimit differ from the others when there's
an entirely need to do so.  We're already being bitten by "legacy"
rlimit.  IOW, being consistent with *other* rlimit behavior buys us
nothing, only complexity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
