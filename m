Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 401E66B026B
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 16:15:17 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id g14so278997ual.8
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:15:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 74sor2899834ual.276.2018.01.10.13.15.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 13:15:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1801100921000.7926@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
 <1515531365-37423-3-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1801100921000.7926@nuc-kabylake>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 10 Jan 2018 13:15:14 -0800
Message-ID: <CAGXu5jLdtLQhkcujTjMwKCwbV6kVb7-2mqz4ki-B9NtPTrDQ9A@mail.gmail.com>
Subject: Re: [PATCH 02/36] usercopy: Include offset in overflow report
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com

On Wed, Jan 10, 2018 at 7:25 AM, Christopher Lameter <cl@linux.com> wrote:
> On Tue, 9 Jan 2018, Kees Cook wrote:
>
>> -static void report_usercopy(unsigned long len, bool to_user, const char *type)
>> +int report_usercopy(const char *name, const char *detail, bool to_user,
>> +                 unsigned long offset, unsigned long len)
>>  {
>> -     pr_emerg("kernel memory %s attempt detected %s '%s' (%lu bytes)\n",
>> +     pr_emerg("kernel memory %s attempt detected %s %s%s%s%s (offset %lu, size %lu)\n",
>>               to_user ? "exposure" : "overwrite",
>> -             to_user ? "from" : "to", type ? : "unknown", len);
>> +             to_user ? "from" : "to",
>> +             name ? : "unknown?!",
>> +             detail ? " '" : "", detail ? : "", detail ? "'" : "",
>> +             offset, len);
>>       /*
>>        * For greater effect, it would be nice to do do_group_exit(),
>>        * but BUG() actually hooks all the lock-breaking and per-arch
>>        * Oops code, so that is used here instead.
>>        */
>>       BUG();
>
> Should this be a WARN() or so? Or some configuration that changes
> BUG() behavior? Otherwise

This BUG() is the existing behavior, with the new behavior taking the
WARN() route in a following patch.

>> +
>> +     return -1;
>
> This return code will never be returned.
>
> Why a return code at all? Maybe I will see that in the following patches?

I was trying to simplify the callers, but I agree, the result is
rather ugly. I'll see if I can fix this up.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
