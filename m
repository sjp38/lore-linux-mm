Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6FF6B0006
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 20:18:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v25so2369709pgn.20
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 17:18:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x4-v6si4550273plw.354.2018.03.28.17.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 17:17:58 -0700 (PDT)
Subject: Re: [PATCH 00/11] Use global pages with PTI
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com>
 <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
 <alpine.DEB.2.21.1803271526260.1964@nanos.tec.linutronix.de>
 <c0e7ca0b-dcb5-66e2-9df6-f53e4eb22781@linux.intel.com>
 <alpine.DEB.2.21.1803271949250.1618@nanos.tec.linutronix.de>
 <20180327200719.lvdomez6hszpmo4s@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <0d6ea030-ec3b-d649-bad7-89ff54094e25@linux.intel.com>
Date: Wed, 28 Mar 2018 17:17:56 -0700
MIME-Version: 1.0
In-Reply-To: <20180327200719.lvdomez6hszpmo4s@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On 03/27/2018 01:07 PM, Ingo Molnar wrote:
> * Thomas Gleixner <tglx@linutronix.de> wrote:
>>> systems.  Atoms are going to be the easiest thing to get my hands on,
>>> but I tend to shy away from them for performance work.
>> What I have in mind is that I wonder whether the whole circus is worth it
>> when there is no performance advantage on PCID systems.

I was waiting on trying to find a relatively recent Atom system (they
actually come in reasonably sized servers [1]), but I'm hitting a snag
there, so I figured I'd just share a kernel compile using Ingo's
perf-based methodology on a Skylake desktop system with PCIDs.  Here's
the kernel compile:

No Global pages (baseline): 186.951 seconds time elapsed  ( +-  0.35% )
28 Global pages (this set): 185.756 seconds time elapsed  ( +-  0.09% )
                             -1.195 seconds (-0.64%)

Lower is better here, obviously.

I also re-checked everything using will-it-scale's llseek1 test[2] which
is basically a microbenchmark of a halfway reasonable syscall.  Higher
here is better.

No Global pages (baseline): 15783951 lseeks/sec
28 Global pages (this set): 16054688 lseeks/sec
			     +270737 lseeks/sec (+1.71%)

So, both the kernel compile and the microbenchmark got measurably faster.

1.
https://ark.intel.com/products/97933/Intel-Atom-Processor-C3955-16M-Cache-up-to-2_40-GHz
2.
https://github.com/antonblanchard/will-it-scale/blob/master/tests/lseek1.c
