Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 706186B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 09:47:49 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 44so125873001qtf.3
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 06:47:49 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id h68si20004341itb.42.2016.09.01.06.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 06:47:48 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id v143so22805822wmv.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 06:47:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160901124522.GK23045@uranus.lan>
References: <20160831135936.2281-1-dsafonov@virtuozzo.com> <20160831135936.2281-7-dsafonov@virtuozzo.com>
 <CAJwJo6YZEN75XB8YaMS26rbFAR0x77B-gfLKv37ib_eB_OLMBg@mail.gmail.com>
 <20160901122744.GA7438@redhat.com> <20160901124522.GK23045@uranus.lan>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Thu, 1 Sep 2016 16:47:23 +0300
Message-ID: <CAJwJo6aL5vG1k=WTtBJQZeD5esUU=6StiTPtYxLAt5Q40xDMOg@mail.gmail.com>
Subject: Re: [PATCHv4 6/6] x86/signal: add SA_{X32,IA32}_ABI sa_flags
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, X86 ML <x86@kernel.org>, Pavel Emelyanov <xemul@virtuozzo.com>

Thanks for your replies Oleg, Cyrill,

2016-09-01 15:45 GMT+03:00 Cyrill Gorcunov <gorcunov@gmail.com>:
> On Thu, Sep 01, 2016 at 02:27:44PM +0200, Oleg Nesterov wrote:
>> > Hi Oleg,
>> > can I have your acks or reviewed-by tags for 4-5-6 patches in the seri=
es,
>> > or there is something left to fix?
>>
>> Well yes... Although let me repeat, I am not sure I personally like
>> the very idea of 3/6 and 6/6. But as I already said I do not feel I
>> understand the problem space enough, so I won't argue.
>>
>> However, let me ask again. Did you consider another option? Why criu
>> can't exec a dummy 32-bit binary before anything else?
>
> I'm not really sure how this would look then. If I understand you
> correctly you propose to exec dummy 32bit during "forking" stage
> where we're recreating a process tree, before anything else. If
> true this implies that we will need two criu engines: one compiled
> with 64 bit and (same) second but compiled with 32 bits, no?

Yep, we would need then full CRIU, but compiled in 32 bits.
And it can be then even more complicated, as 64-bit parent
can have 32-bit child, which can have 64-bit child... et cetera.

And the biggest problem in this approach would be not the size of
code changes to CRIU (which are already quite large with this
patches set), but AFAICS, it will have big performance penalty:
we would need to bounce process tree, processes properties
from parent-CRIU to child-CRIU after exec() call and down on
the processes hierarchy, recreating processes while synchronizing
process's data from images.

As for now, we already have time-critical problems in =D0=A1RIU and
we try to reduce the number of system calls, while it's still slow
at some places. But that approach will lead to:
o exec different CRIU
o initialize it (i.e, parse /proc/self/maps to know it's vmas)
o transphere process tree, for each process it's properties with IPC
   after exec()
It will all go for a large number of syscalls in total.

So, for the current patches set the performance penalty is one call
to arch_prctl() to map 32-bit vdso blob. It's even smaller, as one
specifies the address on which to map the blob and doesn't need
additional mremap()'s to move the blob on needed location.
And this arch_prctl() API is visible under CHECKPOINT_RESTORE
config option, so will not bother anyone.

--=20
             Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
