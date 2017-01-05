Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A490A6B025E
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 18:17:24 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g1so1480184905pgn.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 15:17:24 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t17si70937973pgi.290.2017.01.05.15.17.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 15:17:23 -0800 (PST)
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com>
 <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com>
 <161ece66-fbf4-cb89-3da6-91b4851af69f@intel.com>
 <CALCETrUQ2+P424d9MW-Dy2yQ0+EnMfBuY80wd8NkNmc8is0AUw@mail.gmail.com>
 <978d5f1a-ec4d-f747-93fd-27ecfe10cb88@intel.com>
 <CALCETrW7yxmgrR15yvxkXOF1pHy5vicwDv6Oj019ecEyBCrWBQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <215875b1-2035-df2a-99b2-1b1b036e2a3c@intel.com>
Date: Thu, 5 Jan 2017 15:17:22 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrW7yxmgrR15yvxkXOF1pHy5vicwDv6Oj019ecEyBCrWBQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 01/05/2017 01:27 PM, Andy Lutomirski wrote:
> On Thu, Jan 5, 2017 at 12:49 PM, Dave Hansen <dave.hansen@intel.com> wrote:
...
>> Remember, we already have (legacy MPX) binaries in the wild that have no
>> knowledge of this stuff.  So, we can implicitly have the kernel bump
>> this rlimit around, but we can't expect userspace to do it, ever.
> 
> If you s/rlimit/prctl, then I think this all makes sense with one
> exception.  It would be a bit sad if the personality-setting tool
> didn't work if compiled with MPX.

Ahh, because if you have MPX enabled you *can't* sanely switch between
the two modes because you suddenly go from having small bounds tables to
having big ones?

It's not the simplest thing in the world to do, but there's nothing
keeping the personality-setting tool from doing all the work.  It can do:

	new_bd = malloc(1TB);
	prctl(MPX_DISABLE_MANAGEMENT);
	memcpy(new_bd, old_bd, LEGACY_MPX_BD_SIZE);
	set_bounds_config(new_bd | ENABLE_BIT);
	prctl(WIDER_VADDR_WIDTH);
	prctl(MPX_ENABLE_MANAGEMENT);
	

> So what if we had a second prctl field that is the value that kicks in
> after execve()?

Yeah, that's a pretty sane way to do it too.  execve() is a nice chokepoint.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
