Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6EE6B02C3
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 21:40:10 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n74so7275080ioe.3
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 18:40:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v127sor228350itc.27.2017.08.31.18.40.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Aug 2017 18:40:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwsfUj1f41w8hqt9LN3-ajmJ=2AB1Nb6ZzwHgE1OKxGOw@mail.gmail.com>
References: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150413450616.5923.7069852068237042023.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170831100359.GD21443@lst.de> <CAPcyv4jvTB4Aiei1-fGybyJNopXQy9zADpnFcuRNdZCS4Mf1QQ@mail.gmail.com>
 <CA+55aFwsfUj1f41w8hqt9LN3-ajmJ=2AB1Nb6ZzwHgE1OKxGOw@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 31 Aug 2017 18:40:08 -0700
Message-ID: <CAA9_cmdn3BVjkMTLhcdPqaNcnuPHLjmrG9k4vmpb7bSM8SxpJw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: introduce MAP_VALIDATE, a mechanism for for
 safely defining new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 31, 2017 at 6:27 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, Aug 31, 2017 at 6:01 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>>
>> Ugh, nommu defeats the MAP_SHARED_VALIDATE proposal from Linus.
>>
>>         if ((flags & MAP_TYPE) != MAP_PRIVATE &&
>>             (flags & MAP_TYPE) != MAP_SHARED)
>>                 return -EINVAL;
>>
>> ...parisc strikes again.
>
> Why? That's no different from the case statement for the mmu case,
> just written differently.
>
> You *want* existing kernels to fail, since they don't test the bits
> you want to test.
>
> So you just want to rewrite these all as
>
>     switch (flags & MAP_TYPE) {
>     case MAP_SHARED_VALIDATE:
>         .. validate the other bits...
>         /* fallhtough */
>     case MAP_SHARED:
>         .. do the shared case ..
>     case MAP_PRIVATE:
>         .. do the private case ..
>     default:
>         return -EINVAL;
>     }
>
> and you're all good.
>
> I'm not seeing the problem.

Right, I went cross-eyed for a second. There is no problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
