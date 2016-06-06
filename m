Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF65A6B0253
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 11:50:42 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h68so67853010lfh.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 08:50:42 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id lb8si27462677wjc.158.2016.06.06.08.50.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 08:50:39 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id k204so32982384wmk.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 08:50:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160606133801.GA6136@davidb.org>
References: <20160531013029.4c5db8b570d86527b0b53fe4@gmail.com>
 <20160531013145.612696c12f2ef744af739803@gmail.com> <20160601124227.e922af8299168c09308d5e1b@linux-foundation.org>
 <20160603194252.91064b8e682ad988283fc569@gmail.com> <20160606133801.GA6136@davidb.org>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 6 Jun 2016 08:50:38 -0700
Message-ID: <CAGXu5jKDdPsRU+oa8hKpFCyf2Q-BvnNJ0ZrPM_b6frw-h0Cg_w@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCH v2 1/3] Add the latent_entropy gcc plugin
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Brown <david.brown@linaro.org>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andrew Morton <akpm@linux-foundation.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Mon, Jun 6, 2016 at 6:38 AM, David Brown <david.brown@linaro.org> wrote:
> On Fri, Jun 03, 2016 at 07:42:52PM +0200, Emese Revfy wrote:
>>
>> On Wed, 1 Jun 2016 12:42:27 -0700
>> Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>>> On Tue, 31 May 2016 01:31:45 +0200 Emese Revfy <re.emese@gmail.com>
>>> wrote:
>>>
>>> > This plugin mitigates the problem of the kernel having too little
>>> > entropy during
>>> > and after boot for generating crypto keys.
>>> >
>>> > It creates a local variable in every marked function. The value of this
>>> > variable is
>>> > modified by randomly chosen operations (add, xor and rol) and
>>> > random values (gcc generates them at compile time and the stack pointer
>>> > at runtime).
>>> > It depends on the control flow (e.g., loops, conditions).
>>> >
>>> > Before the function returns the plugin writes this local variable
>>> > into the latent_entropy global variable. The value of this global
>>> > variable is
>>> > added to the kernel entropy pool in do_one_initcall() and _do_fork().
>>>
>>> I don't think I'm really understanding.  Won't this produce the same
>>> value on each and every boot?
>>
>>
>> No, because of interrupts and intentional data races.
>
>
> Wouldn't that result in the value having one of a small number of
> values, then?  Even if it was just one of thousands or millions of
> values, it would make the search space quite small.

My understanding is that it's not cryptographically secure, but it
provides a way for different machines and different boots to end up
with different seeds here, which is a big improvement over some of the
embedded devices that all boot with the same entropy every time.

I would, however, like to see the documentation improved to describe
the "How" and "Why". The "What" is pretty well covered. Adding
comments to the plugin for kernel developers (not compiler developers)
would help a lot: assume the reader knows nothing about gcc plugins.
:)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
