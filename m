Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B38B6B7A7B
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 16:10:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 129-v6so8355156wma.8
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 13:10:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n18-v6sor4346888wrw.21.2018.09.06.13.10.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 13:10:07 -0700 (PDT)
Date: Thu, 6 Sep 2018 22:10:04 +0200
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
Message-ID: <20180906201003.54bqs7sacynt5uyq@ltop.local>
References: <cover.1535629099.git.andreyknvl@google.com>
 <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <20180831081123.6mo62xnk54pvlxmc@ltop.local>
 <20180831134244.GB19965@ZenIV.linux.org.uk>
 <CAAeHK+w86m6YztnTGhuZPKRczb-+znZ1hiJskPXeQok4SgcaOw@mail.gmail.com>
 <01cadefd-c929-cb45-500d-7043cf3943f6@arm.com>
 <20180903151026.n2jak3e4yqusnogt@ltop.local>
 <a31d3400-4523-2bda-a429-f2a221e69ee8@arm.com>
 <20180905190316.a34yycthgbamx2t3@ltop.local>
 <5074b9b6-2b8d-c410-f908-b4c17dacbb2c@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5074b9b6-2b8d-c410-f908-b4c17dacbb2c@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, linux-kselftest@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, Jacob Bramley <Jacob.Bramley@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Sep 06, 2018 at 03:13:16PM +0100, Vincenzo Frascino wrote:
> On 05/09/18 20:03, Luc Van Oostenryck wrote:
> > I think that at this point, it would be nice to have a clear description
> > of the problem and what sort of checks are wanted.
> >
> 
> 
> The problem we are trying to address here is to identify when the user pointers
> are cast to integer types and to sanitize (when required) the kernel, when this
> happens.
> 
> The way on which we are trying to address this problem based on what Andrey
> proposed in his patch-set is to use the Top Byte Ignore feature (which is a 64 bit
> specific feature).
> 
> Based on what I said I think that we require 2 'modifiers':
> - __compat (or __compat_ptr) used when the kernel is dealing with user compat 
> pointers (32 bit, they can not be tagged). It should behave like force
> (silence warnings), but having something separate IMO makes more clear the
> intention of what we are trying to do.
> - __tagged (or __tagged_ptr) used when the kernel is dealing with user normal
> pointers (which can be tagged). In this case sparse should still be able to trigger
> a warning (that can be disabled by default as I was proposing in my previous email).
> When we put a tagged identifier we declare that we analyzed the code impacted by
> the conversion and eventually sanitized it. Having the warning still there allows us
> or whoever is looking at the code to always go back to the identified issue.  

OK. Thanks for the explanation.

So, the way I see things from a type checking perspective, is that
'being (potentially) tagged' is a new property of values, othogonal
the the concept of address space. Leaving the other address spaces
(__iomem, __percpu & __rcu) aside, it should be possible to have
__user & __kernel tagged pointers as well as tagged ulongs:
	__user __tagged *
	__kernel __tagged *
	ulong __tagged
in addition of the usuals:
	__user *
	__kernel *
	ulong
But some of them are banished or meaningless:
	__user *            (all __user pointers are potentially tagged)
	__kernel __tagged * (tags are only for user space)
	ulong __tagged      (pointers need to be untagged during conversion)
So, only the followings remain:
	__user __tagged *
	__kernel *
	ulong
and the property '__tagged' becomes equivalent to '__user'.
Thus '__tagged' can be implicit and this would have the advantage
of not needing to change any annotations.

Since the conversion '__user *' to '__kernel *' is already covered
by the default sparse warnings, only the conversion '__user' to
'ulong' need to be covered (and this is already covered by the new
option -Wcast-from-as) but that is only fine for detection. After
detection and auditing, several solution are possible:
1) simply add '__force' in the cast (this is very bad)
2) moving this '__force' inside a macro '__untag_ptr(x)' would already
   more acceptable but is fundamentaly the same as 1)
3) a weaker form of '__force', '__force_as', will do the trick nicely
   as long as __user is equated to __tagged (and could be useful on
   its own but could also hide real AS conversion problems).
4) a more specific solution would be to effectively add a new attribute,
   '__tagged', to define '__user' like:
	#define __user attribute((noderef,address_space(1),tagged))
   and have something like '__untag', a weaker form of __force meaning:
   "I know what I'm doing regarding conversion from 'tagged'". 

Neither 3) nor 4) should be much work but while I firmly think that
4) is the most correct solution, I'm not sure it's worth the added
complexity, certainly if KHWASAN is not meant to be upstreamed.

For the compat pointers, I'm less sure to understand the situation:
even if they can't be tagged, treating them as the other __user
pointers will still be OK (but I understand that it could be
interesting to be able to track them, it's just that it's independent
from the __tagged property).


-- Luc
