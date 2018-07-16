Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC8DD6B000D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:30:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g5-v6so928785edp.1
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:30:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x42-v6si639276edm.81.2018.07.16.04.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 04:30:21 -0700 (PDT)
Subject: Re: [PATCH v7] add param that allows bootline control of hardened
 usercopy
References: <1530646988-25546-1-git-send-email-crecklin@redhat.com>
 <b1bfe507-3dda-fccb-5355-26f6cce9fa6a@suse.cz>
 <CAGXu5jJa=jEZmRQa6TYuOFORHs_nYvQAO3Q3Hv5vz4tsHd00nQ@mail.gmail.com>
 <0bf9be39-82bb-ad3a-a3c3-e41bebedba7e@suse.cz>
 <CAGXu5jLcx7iFNJGL9=LStCGCq6gx2D7onJAmHsKK3Vxe2pJvdg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5e08d6ab-00dd-1d1c-3a2f-32761bc51d28@suse.cz>
Date: Mon, 16 Jul 2018 13:30:20 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLcx7iFNJGL9=LStCGCq6gx2D7onJAmHsKK3Vxe2pJvdg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Chris von Recklinghausen <crecklin@redhat.com>, Laura Abbott <labbott@redhat.com>, Paolo Abeni <pabeni@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On 07/15/2018 04:04 AM, Kees Cook wrote:
> On Wed, Jul 4, 2018 at 10:47 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> On 07/04/2018 06:52 PM, Kees Cook wrote:
>>> This produces less efficient code in the general case, and I'd like to
>>> keep the general case (hardening enabled) as fast as possible.
>>
>> How specifically is the code less efficient? It should be always a
>> static key check (no-op thanks to the code patching involved) and a
>> function call in the "hardening enabled" case, just in different order.
>> And in either case compiled out if it's a constant.
> 
> My understanding from reading the jump label comments[1] is that on
> order produces:
> 
> NOP
> do normal thing
> label1:
> do rest of function
> RET
> label2:
> do exceptional thing
> jump label1
> 
> where "NOP" is changed to "JMP label2" when toggled, and the other is:
> 
> JMP label1
> do exceptional thing
> JMP label2
> label1:
> do normal thing
> label2:
> do rest of function
> RET
> 
> where "JMP label1" is changed to NOP when toggled. (i.e. does the
> default do NOP, thing, function, or does the default to JMP, thing,
> JMP, function)

My mistake, sorry. I didn't mean to change likely() to unlikely(). Also
I didn't negate the condition. The correct code is:

        if (!__builtin_constant_p(n) &&
                        !static_branch_unlikely(&bypass_usercopy_checks))
                __check_object_size(ptr, n, to_user);

I've test-compiled it, did objdump -d and checked few call sites and they
seem to be preceded just y NOP, so it's the first case you mentioned above,
as expected - calling __check_object_size() is treated as the "normal thing".
