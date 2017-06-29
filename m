Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id D0A306B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 15:39:21 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id g13so34675964uaj.7
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 12:39:21 -0700 (PDT)
Received: from mail-ua0-x242.google.com (mail-ua0-x242.google.com. [2607:f8b0:400c:c08::242])
        by mx.google.com with ESMTPS id o7si2801367uao.70.2017.06.29.12.39.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 12:39:21 -0700 (PDT)
Received: by mail-ua0-x242.google.com with SMTP id l38so7363866uaf.1
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 12:39:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJuQx2qOt_aDqDQDcqGOZ5kmr5rQ9Zjv=MRRCJ65ERfGw@mail.gmail.com>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
 <1497544976-7856-6-git-send-email-s.mesoraca16@gmail.com> <CAGXu5jJuQx2qOt_aDqDQDcqGOZ5kmr5rQ9Zjv=MRRCJ65ERfGw@mail.gmail.com>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Thu, 29 Jun 2017 21:39:20 +0200
Message-ID: <CAJHCu1Lr9KOdheHMO6tkaatizDpcgjAd3ouxiUxSeVyQPpkXOg@mail.gmail.com>
Subject: Re: [RFC v2 5/9] S.A.R.A. WX Protection
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-security-module <linux-security-module@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

2017-06-28 1:04 GMT+02:00 Kees Cook <keescook@chromium.org>:
> On Thu, Jun 15, 2017 at 9:42 AM, Salvatore Mesoraca
> <s.mesoraca16@gmail.com> wrote:
>> +static int sara_check_vmflags(vm_flags_t vm_flags)
>> +{
>> +       u16 sara_wxp_flags = get_current_sara_wxp_flags();
>> +
>> +       if (sara_enabled && wxprot_enabled) {
>> +               if (sara_wxp_flags & SARA_WXP_WXORX &&
>> +                   vm_flags & VM_WRITE &&
>> +                   vm_flags & VM_EXEC) {
>> +                       if ((sara_wxp_flags & SARA_WXP_VERBOSE))
>> +                               pr_wxp("W^X");
>> +                       if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))
>> +                               return -EPERM;
>> +               }
>> +               if (sara_wxp_flags & SARA_WXP_MMAP &&
>> +                   (vm_flags & VM_EXEC ||
>> +                    (!(vm_flags & VM_MAYWRITE) && (vm_flags & VM_MAYEXEC))) &&
>> +                   get_current_sara_mmap_blocked()) {
>> +                       if ((sara_wxp_flags & SARA_WXP_VERBOSE))
>> +                               pr_wxp("executable mmap");
>> +                       if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))
>> +                               return -EPERM;
>> +               }
>> +       }
>
> Given the subtle differences between these various if blocks (here and
> in the other hook), I think it would be nice to have some beefy
> comments here to describe specifically what's being checked (and why).
> It'll help others review this code, and help validate code against
> intent.
>
> I would also try to minimize the written code by creating a macro for
> a repeated pattern here:
>
>> +                               if ((sara_wxp_flags & SARA_WXP_VERBOSE))
>> +                                       pr_wxp("mprotect on file mmap");
>> +                               if (!(sara_wxp_flags & SARA_WXP_COMPLAIN))
>> +                                       return -EACCES;
>
> These four lines are repeated several times with only the const char *
> and return value changing. Perhaps something like:
>
> #define sara_return(err, msg) do { \
>                                if ((sara_wxp_flags & SARA_WXP_VERBOSE)) \
>                                        pr_wxp(err); \
>                                if (!(sara_wxp_flags & SARA_WXP_COMPLAIN)) \
>                                        return -err; \
> } while (0)
>
> Then each if block turns into something quite easier to parse:
>
>                if (sara_wxp_flags & SARA_WXP_WXORX &&
>                    vm_flags & VM_WRITE &&
>                    vm_flags & VM_EXEC)
>                        sara_return(EPERM, "W^X");

I absolutely agree with all of the above. These issues will be addressed in v3.
Thank you for your contribution.

Salvatore

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
