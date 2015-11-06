Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 31FF982F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 15:55:09 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so19316148igb.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 12:55:09 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id s68si2603637ioe.199.2015.11.06.12.55.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 12:55:08 -0800 (PST)
Received: by igpw7 with SMTP id w7so41628704igp.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 12:55:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFx1tay0EBD1bueh8cFrw7Fv67-ZOG+GwzwO8vVVavrVqw@mail.gmail.com>
References: <20151106192205.351595349@linuxfoundation.org>
	<20151106192205.899033919@linuxfoundation.org>
	<CA+55aFx1tay0EBD1bueh8cFrw7Fv67-ZOG+GwzwO8vVVavrVqw@mail.gmail.com>
Date: Fri, 6 Nov 2015 12:55:08 -0800
Message-ID: <CA+55aFyZn6TtEJyMbjUco-0wb-XPxjFY=HTbycZOkyzZBeg8MQ@mail.gmail.com>
Subject: Re: [PATCH 4.1 11/86] iommu/amd: Fix BUG when faulting a PROT_NONE VMA
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, Jay Cornwall <jay@jcornwall.me>, Joerg Roedel <jroedel@suse.de>, linux-mm <linux-mm@kvack.org>

On Fri, Nov 6, 2015 at 12:49 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> And some "handle_mm_fault would BUG_ON()" comment is just bogus. It's
> not handle_mm_fault()'s case that you called it without checking
> proper permissions.

Side note: as to why handle_mm_fault() doesn't just do things itself,
there's a historical situation where we used to let people do things
in ptrace() that they couldn't do directly, and punch through
protections (and turn shared read-only pages into a dirty private
page).

So the permissions checking was up to the caller, because some callers
could do things that other callers could not.

I *think* we have gotten rid of all those cases, and I guess we could
consider just making handle_mm_fault() itself stricter. But that's the
historical background on why callers need to check this.

Adding linux-mm to the cc, to see if anybody there has some comments
wrt just moving all the EFAULT handling into handle_mm_fault() and
relaxing the caller requirements.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
