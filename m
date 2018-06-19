Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1E4C6B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 02:41:02 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b195-v6so16508285qkc.8
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 23:41:02 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o125-v6si647430qkd.38.2018.06.18.23.41.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 23:41:01 -0700 (PDT)
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com>
 <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com>
 <alpine.DEB.2.21.1806121155450.2157@nanos.tec.linutronix.de>
 <CAMe9rOoCiXQ4iVD3j_AHGrvEXtoaVVZVs7H7fCuqNEuuR5j+2Q@mail.gmail.com>
 <CALCETrXO8R+RQPhJFk4oiA4PF77OgSS2Yro_POXQj1zvdLo61A@mail.gmail.com>
 <CAMe9rOpLxPussn7gKvn0GgbOB4f5W+DKOGipe_8NMam+Afd+RA@mail.gmail.com>
 <CALCETrWmGRkQvsUgRaj+j0CP4beKys+TT5aDR5+18nuphwr+Cw@mail.gmail.com>
 <CAMe9rOpzcCdje=bUVs+C1WrY6GuwA-8AUFVLOG325LGz7KHJxw@mail.gmail.com>
 <alpine.DEB.2.21.1806122046520.1592@nanos.tec.linutronix.de>
 <CAMe9rOrGjJf0aMnUjAP38MqvOiW3=iXGQjcUT3O=f9pE85hXaw@mail.gmail.com>
 <CALCETrVsh5t-V1Sm88LsZE_+DS0GE_bMWbcoX3SjD6GnrB08Pw@mail.gmail.com>
 <CAGXu5jK0gospOXRpN6zYiQPXOZeE=YpVAz2qu4Zc3-32v85+EQ@mail.gmail.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <e152e1a7-e3b1-c3c4-ce1a-874e97300b37@redhat.com>
Date: Tue, 19 Jun 2018 08:40:53 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5jK0gospOXRpN6zYiQPXOZeE=YpVAz2qu4Zc3-32v85+EQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>
Cc: "H. J. Lu" <hjl.tools@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On 06/19/2018 02:52 AM, Kees Cook wrote:
> Adding Florian to CC, but if something gets CET enabled, it really
> shouldn't have a way to turn it off. If there's a way to turn it off,
> all the ROP research will suddenly turn to exactly one gadget before
> doing the rest of the ROP: turning off CET. Right now ROP is: use
> stack-pivot gadget, do everything else. Allowed CET to turn off will
> just add one step: use CET-off gadget, use stack-pivot gadget, do
> everything else. :P
> 
> Following Linus's request for "slow introduction" of new security
> features, likely the best approach is to default to "relaxed" (with a
> warning about down-grades), and allow distros/end-users to pick
> "forced" if they know their libraries are all CET-enabled.

The dynamic linker can tell beforehand (before executing any user code) 
whether a process image supports CET.  So there doesn't have to be 
anything gradual about it per se to preserve backwards compatibility.

The idea to turn off CET probably comes from the desire to support 
dlopen.  I'm not sure if this is really necessary because the complexity 
is rather nasty.  (We currently do something similar for executable 
stacks.)  I'd rather have a switch to turn off the feature upon process 
start.  Things like NSS and PAM modules need to be recompiled early.  (I 
hope that everything that goes directly to the network via custom 
protocols or hardware such as smartcards is proxied via daemons these days.)

Thanks,
Florian
