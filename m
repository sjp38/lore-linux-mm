Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 140AE8E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 15:58:58 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id w23-v6so10535480ywg.11
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:58:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a7-v6sor16101ywc.431.2018.09.24.12.58.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 12:58:57 -0700 (PDT)
Received: from mail-yw1-f53.google.com (mail-yw1-f53.google.com. [209.85.161.53])
        by smtp.gmail.com with ESMTPSA id g2-v6sm79243ywb.84.2018.09.24.12.58.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 12:58:54 -0700 (PDT)
Received: by mail-yw1-f53.google.com with SMTP id d126-v6so1714907ywa.5
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 12:58:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1537815484.19013.48.camel@intel.com>
References: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com>
 <1536874298-23492-3-git-send-email-rick.p.edgecombe@intel.com>
 <CAGXu5jJ9nZYbVn5xdi7nsMJRD6ScLeWP2DWjrD8yEfwi-XXcRw@mail.gmail.com> <1537815484.19013.48.camel@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 24 Sep 2018 12:58:51 -0700
Message-ID: <CAGXu5jKho6Ui0sP6-4FN=i6zZ1+gXcd9Zyctqhvg+4r1cz-Mqw@mail.gmail.com>
Subject: Re: [PATCH v6 2/4] x86/modules: Increase randomization for modules
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jannh@google.com" <jannh@google.com>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

On Mon, Sep 24, 2018 at 11:57 AM, Edgecombe, Rick P
<rick.p.edgecombe@intel.com> wrote:
> On Fri, 2018-09-21 at 12:05 -0700, Kees Cook wrote:
>> On Thu, Sep 13, 2018 at 2:31 PM, Rick Edgecombe
>> <rick.p.edgecombe@intel.com> wrote:
>> I would find this much more readable as:
>> static unsigned long get_module_vmalloc_start(void)
>> {
>>        unsigned long addr = MODULES_VADDR;
>>
>>        if (kaslr_randomize_base())
>>               addr += get_module_load_offset();
>>
>>        if (kaslr_randomize_each_module())
>>                addr += get_modules_rand_len();
>>
>>        return addr;
>> }
> Thanks, that looks better.
>
>>
>> >  void *module_alloc(unsigned long size)
>> >  {
>> > @@ -84,16 +201,18 @@ void *module_alloc(unsigned long size)
>> >         if (PAGE_ALIGN(size) > MODULES_LEN)
>> >                 return NULL;
>> >
>> > -       p = __vmalloc_node_range(size, MODULE_ALIGN,
>> > -                                   MODULES_VADDR +
>> > get_module_load_offset(),
>> > -                                   MODULES_END, GFP_KERNEL,
>> > -                                   PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
>> > -                                   __builtin_return_address(0));
>> > +       p = try_module_randomize_each(size);
>> > +
>> > +       if (!p)
>> > +               p = __vmalloc_node_range(size, MODULE_ALIGN,
>> > +                               get_module_vmalloc_start(), MODULES_END,
>> > +                               GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
>> > +                               NUMA_NO_NODE, __builtin_return_address(0));
>> Instead of having two open-coded __vmalloc_node_range() calls left in
>> this after the change, can this be done in terms of a call to
>> try_module_alloc() instead? I see they're slightly different, but it
>> might be nice for making the two paths share more code.
> Not sure what you mean. Across the whole change, there is one call
> to __vmalloc_node_range, and one to __vmalloc_node_try_addr.

I guess I meant the vmalloc calls -- one for node_range and one for
node_try_addr. I was wondering if the logic could be combined in some
way so that the __vmalloc_node_range() could be made in terms of the
the helper that try_module_randomize_each() uses. But this could just
be me hoping for nice-to-read changes. ;)

-Kees

-- 
Kees Cook
Pixel Security
