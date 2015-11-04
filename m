Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 887C982F66
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 13:22:13 -0500 (EST)
Received: by padhx2 with SMTP id hx2so51840457pad.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 10:22:13 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id wf4si3780135pac.32.2015.11.04.10.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 10:22:09 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so35583673pac.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 10:22:09 -0800 (PST)
Subject: Re: [PATCH v2 2/2] arm: mm: support ARCH_MMAP_RND_BITS.
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
 <1446574204-15567-2-git-send-email-dcashman@android.com>
 <CAGXu5jKGzDD9WVQnMTT2EfupZtjpdcASUpx-3npLAB-FctLodA@mail.gmail.com>
 <20151103223904.GG8644@n2100.arm.linux.org.uk>
 <CAGXu5jJWdZ57uMACwRBcOoU8MqPu9-pN+cp9WzyguY+G3C5qWg@mail.gmail.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <563A4CCD.60803@android.com>
Date: Wed, 4 Nov 2015 10:22:05 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJWdZ57uMACwRBcOoU8MqPu9-pN+cp9WzyguY+G3C5qWg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, dcashman <dcashman@google.com>

On 11/3/15 3:18 PM, Kees Cook wrote:
> On Tue, Nov 3, 2015 at 2:39 PM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
>> On Tue, Nov 03, 2015 at 11:19:44AM -0800, Kees Cook wrote:
>>> On Tue, Nov 3, 2015 at 10:10 AM, Daniel Cashman <dcashman@android.com> wrote:
>>>> From: dcashman <dcashman@google.com>
>>>>
>>>> arm: arch_mmap_rnd() uses a hard-code value of 8 to generate the
>>>> random offset for the mmap base address.  This value represents a
>>>> compromise between increased ASLR effectiveness and avoiding
>>>> address-space fragmentation. Replace it with a Kconfig option, which
>>>> is sensibly bounded, so that platform developers may choose where to
>>>> place this compromise. Keep 8 as the minimum acceptable value.
>>>>
>>>> Signed-off-by: Daniel Cashman <dcashman@google.com>
>>>
>>> Acked-by: Kees Cook <keescook@chromium.org>
>>>
>>> Russell, if you don't see any problems here, it might make sense not
>>> to put this through the ARM patch tracker since it depends on the 1/2,
>>> and I think x86 and arm64 (and possibly other arch) changes are coming
>>> too.
>>
>> Yes, it looks sane, though I do wonder whether there should also be
>> a Kconfig option to allow archtectures to specify the default, instead
>> of the default always being the minimum randomisation.  I can see scope
>> to safely pushing our mmap randomness default to 12, especially on 3GB
>> setups, as we already have 11 bits of randomness on the sigpage and if
>> enabled, 13 bits on the heap.
> 
> My thinking is that the there shouldn't be a reason to ever have a
> minimum that was below the default. I have no objection with it, but
> it seems needless. Frankly minimum is "0", really, so I don't think it
> makes much sense to have default != arch minimum. I actually view
> "arch minimum" as "known good", so if we are happy with raising the
> "known good" value, that should be the new minimum.

While I generally agree, the ability to specify a non-minimum arch
default could be useful if there is a small fraction which relies on
having a small value.  8 as the current minimum for arm made sense to me
since it has already been established as minimum in the current code.
It may be the case, as Russel has suggested for example, that we could
up the default to 12 for the vast majority of systems, but that 8 could
still be required for a select few.  In this case, our current solution
would have to leave the minimum at 8, and thus leave the default at 8
for all systems when 12 would be preferable. This patch allows those
systems to change that, of course, so the question becomes one of opt-in
vs opt-out for an increased amount of randomness if this situation occurred.

Both approaches seem reasonable to me.  Russel, if you'd still like the
ability to specify a non-minimum default, would establishing an
additional Kconfig variable, say ARCH_HAS_DEF_MMAP_RND_BITS, or simply
dropping the default line from the global config be preferable?

Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
