Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 44E95831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 14:19:30 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id p85so26377221vkd.10
        for <linux-mm@kvack.org>; Mon, 22 May 2017 11:19:30 -0700 (PDT)
Received: from mail-ua0-x22b.google.com (mail-ua0-x22b.google.com. [2607:f8b0:400c:c08::22b])
        by mx.google.com with ESMTPS id l30si8216596uaa.68.2017.05.22.11.19.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 11:19:29 -0700 (PDT)
Received: by mail-ua0-x22b.google.com with SMTP id y4so58116867uay.2
        for <linux-mm@kvack.org>; Mon, 22 May 2017 11:19:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1495474514-24425-1-git-send-email-catalin.marinas@arm.com>
References: <1495474514-24425-1-git-send-email-catalin.marinas@arm.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 22 May 2017 11:19:08 -0700
Message-ID: <CALCETrVaFPjQrVAiOad6GhFvK=AQphF0Kx5zDsCcAt4bPfQbnw@mail.gmail.com>
Subject: Re: [PATCH] mm: kmemleak: Treat vm_struct as alternative reference to
 vmalloc'ed objects
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>

On Mon, May 22, 2017 at 10:35 AM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> Kmemleak requires that vmalloc'ed objects have a minimum reference count
> of 2: one in the corresponding vm_struct object and the other owned by
> the vmalloc() caller. There are cases, however, where the original
> vmalloc() returned pointer is lost and, instead, a pointer to vm_struct
> is stored (see free_thread_stack()). Kmemleak currently reports such
> objects as leaks.
>
> This patch adds support for treating any surplus references to an object
> as additional references to a specified object. It introduces the
> kmemleak_vmalloc() API function which takes a vm_struct pointer and sets
> its surplus reference passing to the actual vmalloc() returned pointer.
> The __vmalloc_node_range() calling site has been modified accordingly.
>
> An unrelated minor change is included in this patch to change the type
> of kmemleak_object.flags to unsigned int (previously unsigned long).
>
> Reported-by: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>
> Hi,
>
> As per [1], I added support to use pointers to vm_struct as an
> alternative way to avoid false positives when the original vmalloc()
> pointer has been lost. This is slightly harder to reason about but it
> seems to work for this use-case. I'm not aware of other cases (than
> free_thread_stack()) where the original vmalloc() pointer is removed in
> favour of a vm_struct one.
>
> An alternative implementation (simpler to understand), if preferred, is
> to annotate alloc_thread_stack_node() and free_thread_stack() with
> kmemleak_unignore()/kmemleak_ignore() calls and proper comments.
>

I personally prefer the option in this patch.  It keeps the special
case in kmemleak and the allocation code rather than putting it in the
consumer code.

Also, I want to add an API at some point that vmallocs some memory and
returns the vm_struct directly.  That won't work with explicit
annotations in the caller because kmemleak might think it's leaked
before the caller can execute the annotations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
