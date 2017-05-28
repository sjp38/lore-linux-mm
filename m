Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DCD36B0292
	for <linux-mm@kvack.org>; Sun, 28 May 2017 17:32:26 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id d68so32604630ita.13
        for <linux-mm@kvack.org>; Sun, 28 May 2017 14:32:26 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b142sor1499145itc.48.2017.05.28.14.32.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 May 2017 14:32:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFUG7Cen=g4PbDHmkNOqDdTOWWDEx_UTS2gk75_ub=63DQqpJA@mail.gmail.com>
References: <20170519103811.2183-1-igor.stoppa@huawei.com> <20170519103811.2183-2-igor.stoppa@huawei.com>
 <CAGXu5j+3-CZpZ4Vj2fHH+0UPAa_jOdJQxHtrQ=F_FvvzWvE00Q@mail.gmail.com>
 <656b6465-16cd-ab0a-b439-ab5bea42006d@huawei.com> <CAGXu5jK25XvX4vSODg7rkdBPj_FzveUSODFUKu1=KatmKhFVzg@mail.gmail.com>
 <138740ab-ba0b-053c-d5b9-a71d6a5c7187@huawei.com> <CAGXu5jKEmEzAFssmBu2=kJvXikTZ12CF4f8gQy+7UBh8F24PAw@mail.gmail.com>
 <CAFUG7Cen=g4PbDHmkNOqDdTOWWDEx_UTS2gk75_ub=63DQqpJA@mail.gmail.com>
From: Kees Cook <keescook@google.com>
Date: Sun, 28 May 2017 14:32:24 -0700
Message-ID: <CAGXu5j++h=a57hNAR-23NMcjXeysqbtHmc1P=K94-D4VNgVSYg@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCH 1/1] Sealable memory support
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Lukashev <blukashev@sempervictus.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, Casey Schaufler <casey@schaufler-ca.com>, Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>, Daniel Micay <danielmicay@gmail.com>, Greg KH <gregkh@linuxfoundation.org>, James Morris <james.l.morris@oracle.com>, Stephen Smalley <sds@tycho.nsa.gov>

On Sun, May 28, 2017 at 11:56 AM, Boris Lukashev
<blukashev@sempervictus.com> wrote:
> So what about a middle ground where CoW semantics are used to enforce
> the state of these allocations as RO, but provide a strictly
> controlled pathway to read the RO data, copy and modify it, then write
> and seal into a new allocation. Successful return from this process
> should permit the page table to change the pointer to where the object
> now resides, and initiate freeing of the original memory so long as a
> refcount is kept for accesses. That way, sealable memory is sealed,
> and any consumers reading it will be using the original ptr to the
> original smalloc region. Attackers who do manage to change the

This could be another way to do it, yeah, and it helps that smalloc()
is built on vmalloc(). It'd require some careful design, but it could
be a way forward after this initial sealed-after-init version goes in.

> Lastly, my meager understanding is that PAX set the entire kernel as
> RO, and implemented writeable access via pax_open/close. How were they
> fighting against race conditions, and what is the benefit of specific
> regions being allocated this way as opposed to the RO-all-the-things
> approach which makes writes a specialized set of operations?

My understanding is that PaX's KERNEXEC with the constification plugin
moves a substantial portion of the kernel's .data section
(effectively) into the .rodata section. It's not the "entire" kernel.
(Well, depending on how you count. The .text section is already
read-only upstream.) PaX, as far as I know, provided no dynamic memory
allocation protections, like smalloc() would provide.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
