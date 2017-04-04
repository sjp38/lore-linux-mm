Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7426B0038
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 11:46:04 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id y22so68734887ioe.9
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 08:46:04 -0700 (PDT)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id a192si14793741itc.25.2017.04.04.08.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 08:46:03 -0700 (PDT)
Received: by mail-io0-x230.google.com with SMTP id l7so97994336ioe.3
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 08:46:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170404151600.GN15132@dhcp22.suse.cz>
References: <20170331164028.GA118828@beast> <20170404113022.GC15490@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org> <20170404151600.GN15132@dhcp22.suse.cz>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 4 Apr 2017 08:46:02 -0700
Message-ID: <CAGXu5jJ0CzoELUacbsQc9Uf4fDnQDoeTFmhULtG+8Ddt4XMarA@mail.gmail.com>
Subject: Re: [PATCH] mm: Add additional consistency check
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 4, 2017 at 8:16 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 04-04-17 10:07:23, Cristopher Lameter wrote:
>> On Tue, 4 Apr 2017, Michal Hocko wrote:
>>
>> > NAK without a proper changelog. Seriously, we do not blindly apply
>> > changes from other projects without a deep understanding of all
>> > consequences.
>>
>> Functionalitywise this is trivial. A page must be a slab page in order to
>> be able to determine the slab cache of an object. Its definitely not ok if
>> the page is not a slab page.
>
> Yes, but we do not have to blow the kernel, right? Why cannot we simply
> leak that memory?

I can put this behind CHECK_DATA_CORRUPTION() instead of BUG(), which
allows the system builder to choose between WARN and BUG. Some people
absolutely want the kernel to BUG on data corruption as it could be an
attack.

>> The main issue that may exist here is the adding of overhead to a critical
>> code path like kfree().
>
> Yes, nothing is for free. But if the attack space is real then we
> probably want to sacrifice few cycles (to simply return ASAP without
> further further processing). This all should be in the changelog ideally
> with some numbers. I suspect this would be hard to measure in most
> workloads.

Given the trivial nature of the check, yeah, it seemed impossible to
actually show performance changes.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
