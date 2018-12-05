Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61E2A6B7535
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 11:21:17 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 74so17107083pfk.12
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:21:17 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t6si19639150pgn.258.2018.12.05.08.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 08:21:16 -0800 (PST)
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7A36D2133F
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 16:21:15 +0000 (UTC)
Received: by mail-wm1-f42.google.com with SMTP id r11-v6so13833091wmb.2
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 08:21:15 -0800 (PST)
MIME-Version: 1.0
References: <6f9c65fb-ea7e-8217-a4cc-f93e766ed9bb@intel.com>
 <87k1ln8o7u.fsf@oldenburg.str.redhat.com> <20181108201231.GE5481@ram.oc3035372033.ibm.com>
 <87bm6z71yw.fsf@oldenburg.str.redhat.com> <20181109180947.GF5481@ram.oc3035372033.ibm.com>
 <87efbqqze4.fsf@oldenburg.str.redhat.com> <20181127102350.GA5795@ram.oc3035372033.ibm.com>
 <87zhtuhgx0.fsf@oldenburg.str.redhat.com> <58e263a6-9a93-46d6-c5f9-59973064d55e@intel.com>
 <87va4g5d3o.fsf@oldenburg.str.redhat.com> <20181203040249.GA11930@ram.oc3035372033.ibm.com>
In-Reply-To: <20181203040249.GA11930@ram.oc3035372033.ibm.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 5 Dec 2018 08:21:02 -0800
Message-ID: <CALCETrXeSQ8T9nvK7WpgPpkraLfg70FoDWvPZeLS3KiDaqXwtw@mail.gmail.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxram@us.ibm.com
Cc: Florian Weimer <fweimer@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

> On Dec 2, 2018, at 8:02 PM, Ram Pai <linuxram@us.ibm.com> wrote:
>
>> On Thu, Nov 29, 2018 at 12:37:15PM +0100, Florian Weimer wrote:
>> * Dave Hansen:
>>
>>>> On 11/27/18 3:57 AM, Florian Weimer wrote:
>>>> I would have expected something that translates PKEY_DISABLE_WRITE |
>>>> PKEY_DISABLE_READ into PKEY_DISABLE_ACCESS, and also accepts
>>>> PKEY_DISABLE_ACCESS | PKEY_DISABLE_READ, for consistency with POWER.
>>>>
>>>> (My understanding is that PKEY_DISABLE_ACCESS does not disable all
>>>> access, but produces execute-only memory.)
>>>
>>> Correct, it disables all data access, but not execution.
>>
>> So I would expect something like this (completely untested, I did not
>> even compile this):
>
>
> Ok. I re-read through the entire email thread to understand the problem a=
nd
> the proposed solution. Let me summarize it below. Lets see if we are on t=
he same
> plate.
>
> So the problem is as follows:
>
> Currently the kernel supports  'disable-write'  and 'disable-access'.
>
> On x86, cpu supports 'disable-write' and 'disable-access'. This
> matches with what the kernel supports. All good.
>
> However on power, cpu supports 'disable-read' too. Since userspace can
> program the cpu directly, userspace has the ability to set
> 'disable-read' too.  This can lead to inconsistency between the kernel
> and the userspace.
>
> We want the kernel to match userspace on all architectures.
>
> Proposed Solution:
>
> Enhance the kernel to understand 'disable-read', and facilitate architect=
ures
> that understand 'disable-read' to allow it.
>
> Also explicitly define the semantics of disable-access  as
> 'disable-read and disable-write'
>
> Did I get this right?  Assuming I did, the implementation has to do
> the following --
>
>    On power, sys_pkey_alloc() should succeed if the init_val
>    is PKEY_DISABLE_READ, PKEY_DISABLE_WRITE, PKEY_DISABLE_ACCESS
>    or any combination of the three.
>
>    On x86, sys_pkey_alloc() should succeed if the init_val is
>    PKEY_DISABLE_WRITE or PKEY_DISABLE_ACCESS or PKEY_DISABLE_READ
>    or any combination of the three, except  PKEY_DISABLE_READ
>          specified all by itself.
>
>    On all other arches, none of the flags are supported.

I don=E2=80=99t really love having a situation where you can use different
flag combinations to refer to the same mode.

Also, we should document the effect these flags have on execute permission.
