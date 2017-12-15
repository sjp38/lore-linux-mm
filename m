Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF0C6B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 00:04:59 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id w22so5998939pge.10
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 21:04:59 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z15si3993033pgr.595.2017.12.14.21.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 21:04:58 -0800 (PST)
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
References: <20171214112726.742649793@infradead.org>
 <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com>
 <20171214205450.GI3326@worktop>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com>
Date: Thu, 14 Dec 2017 21:04:56 -0800
MIME-Version: 1.0
In-Reply-To: <20171214205450.GI3326@worktop>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On 12/14/2017 12:54 PM, Peter Zijlstra wrote:
>> That short-circuits the page fault pretty quickly.  So, basically, the
>> rule is: if the hardware says you tripped over pkey permissions, you
>> die.  We don't try to do anything to the underlying page *before* saying
>> that you die.
> That only works when you trip the fault from hardware. Not if you do a
> software fault using gup().
> 
> AFAIK __get_user_pages(FOLL_FORCE|FOLL_WRITE|FOLL_GET) will loop
> indefinitely on the case I described.

So, the underlying bug here is that we now a get_user_pages_remote() and
then go ahead and do the p*_access_permitted() checks against the
current PKRU.  This was introduced recently with the addition of the new
p??_access_permitted() calls.

We have checks in the VMA path for the "remote" gups and we avoid
consulting PKRU for them.  This got missed in the pkeys selftests
because I did a ptrace read, but not a *write*.  I also didn't
explicitly test it against something where a COW needed to be done.

I've got some additions to the selftests and a fix where we pass FOLL_*
flags around a bit more instead of just 'write'.  I'll get those out as
soon as I do a bit more testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
