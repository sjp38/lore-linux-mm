Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D15696B0044
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 16:43:51 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so5942894pde.34
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 13:43:51 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ko1si41866447pbd.115.2014.07.07.13.43.49
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 13:43:50 -0700 (PDT)
Message-ID: <53BB0673.8020604@intel.com>
Date: Mon, 07 Jul 2014 13:43:31 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/3] mm: introduce fincore()
References: <1404756006-23794-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1404756006-23794-2-git-send-email-n-horiguchi@ah.jp.nec.com> <53BAEE95.50807@intel.com> <20140707202108.GA5031@nhori.bos.redhat.com>
In-Reply-To: <20140707202108.GA5031@nhori.bos.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Kees Cook <kees@outflux.net>

On 07/07/2014 01:21 PM, Naoya Horiguchi wrote:
> On Mon, Jul 07, 2014 at 12:01:41PM -0700, Dave Hansen wrote:
>> But, is this trying to do too many things at once?  Do we have solid use
>> cases spelled out for each of these modes?  Have we thought out how they
>> will be used in practice?
> 
> tools/vm/page-types.c will be an in-kernel user after this base code is
> accepted. The idea of doing fincore() thing comes up during the discussion
> with Konstantin over file cache mode of this tool.
> pfn and page flag are needed there, so I think it's one clear usecase.

I'm going to take that as a no. :)

The whole FINCORE_PGOFF vs. FINCORE_BMAP issue is something that will
come up in practice.  We just don't have the interfaces for an end user
to pick which one they want to use.
>> Is it really right to say this is going to be 8 bytes?  Would we want it
>> to share types with something else, like be an loff_t?
> 
> Could you elaborate it more?

We specify file offsets in other system calls, like the lseek family.  I
was just thinking that this type should match up with those calls since
they are expressing the same data type with the same ranges and limitations.

>>> + * - FINCORE_PFN:
>>> + *     stores pfn, using 8 bytes.
>>
>> These are all an unprivileged operations from what I can tell.  I know
>> we're going to a lot of trouble to hide kernel addresses from being seen
>> in userspace.  This seems like it would be undesirable for the folks
>> that care about not leaking kernel addresses, especially for
>> unprivileged users.
>>
>> This would essentially tell userspace where in the kernel's address
>> space some user-controlled data will be.
> 
> OK, so this and FINCORE_PAGEFLAGS will be limited for privileged users.

Then I'd just question their usefulness outside of a debugging
environment, especially when you can get at them in other (more
roundabout) ways in a debugging environment.

This is really looking to me like two system calls.  The bitmap-based
one, and another more extensible one.  I don't think there's any harm in
having two system calls, especially when they're trying to glue together
two disparate interfaces.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
