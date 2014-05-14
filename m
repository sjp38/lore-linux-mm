Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f181.google.com (mail-ve0-f181.google.com [209.85.128.181])
	by kanga.kvack.org (Postfix) with ESMTP id 72D166B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 18:52:20 -0400 (EDT)
Received: by mail-ve0-f181.google.com with SMTP id pa12so299631veb.40
        for <linux-mm@kvack.org>; Wed, 14 May 2014 15:52:20 -0700 (PDT)
Received: from mail-ve0-f175.google.com (mail-ve0-f175.google.com [209.85.128.175])
        by mx.google.com with ESMTPS id gu9si570300vdc.160.2014.05.14.15.52.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 15:52:19 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id jw12so310863veb.6
        for <linux-mm@kvack.org>; Wed, 14 May 2014 15:52:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
References: <53739201.6080604@oracle.com> <20140514132312.573e5d3cf99276c3f0b82980@linux-foundation.org>
 <5373D509.7090207@oracle.com> <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
 <5373DBE4.6030907@oracle.com> <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 14 May 2014 15:51:59 -0700
Message-ID: <CALCETrW2=xk+YMjH9AGMn7H1tQZb6XL5hrgNcttKS=ruyt44fA@mail.gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 14, 2014 at 2:31 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 14 May 2014 17:11:00 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
>
>> > In my linux-next all that code got deleted by Andy's "x86, vdso:
>> > Reimplement vdso.so preparation in build-time C" anyway.  What kernel
>> > were you looking at?
>>
>> Deleted? It appears in today's -next. arch/x86/vdso/vma.c:124 .
>>
>> I don't see Andy's patch removing that code either.
>
> ah, OK, it got moved from arch/x86/vdso/vdso32-setup.c into
> arch/x86/vdso/vma.c.
>
> Maybe you managed to take a fault against the symbol area between the
> _install_special_mapping() and the remap_pfn_range() call, but mmap_sem
> should prevent that.
>
> Or the remap_pfn_range() call never happened.  Should map_vdso() be
> running _install_special_mapping() at all if
> image->sym_vvar_page==NULL?

You're almost right, but that was enough to point me in the right direction :)

The mapping is still needed, since there are two pages.  qemu -no-hpet
will trigger this, but the nohpet kernel option will not.  The latter
is arguably a bug in the nohpet option.

Fix coming.

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
