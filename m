Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 15BE6828F3
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 20:40:07 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so221346872wmf.0
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 17:40:07 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id x11si10854382wmx.51.2016.01.09.17.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 17:40:05 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id f206so21213968wmf.2
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 17:40:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4iCbp0oR_V+XCTduLd1t2UxyFwaoJVk0_vwk8aO2Uh=bQ@mail.gmail.com>
References: <cover.1452297867.git.tony.luck@intel.com>
	<19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
	<CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
	<CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
	<CALCETrVQ_NxcnDr4N-VqROrMJ2hUzMKgmxjxAZu9TFbznqSDcg@mail.gmail.com>
	<CA+8MBbLUtVh3E4RqcHbZ165v+fURGYPm=ejOn2cOPq012BwLSg@mail.gmail.com>
	<CAPcyv4hAenpeqPsj7Rd0Un_SgDpm+CjqH3EK72ho-=zZFvG7wA@mail.gmail.com>
	<CALCETrVRgaWS86wq4B6oZbEY5_ODb3Nh5OeE9vvdGdds6j_pYg@mail.gmail.com>
	<CAPcyv4iCbp0oR_V+XCTduLd1t2UxyFwaoJVk0_vwk8aO2Uh=bQ@mail.gmail.com>
Date: Sat, 9 Jan 2016 17:40:05 -0800
Message-ID: <CA+8MBbLFb1gdhFWeG-3V4=gHd-fHK_n1oJEFCrYiNa8Af6XAng@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Borislav Petkov <bp@alien8.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, Ingo Molnar <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Sat, Jan 9, 2016 at 4:23 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Sat, Jan 9, 2016 at 2:33 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> Shouldn't that logic live in the mcsafe_copy routine itself rather
>> than being delegated to callers?
>>
>
> Yes, please.

Yes - we should have some of that fancy self-patching code that
redirects to the optimal routine for the cpu model we are running
on.

BUT ... it's all going to be very messy.  We don't have any CPUID
capability bits to say whether we support recovery, or which instructions
are good/bad choices for recovery. You might think that MCG_CAP{24}
which is described as "software error recovery" (or some such) would
be a good clue, but you'd be wrong. The bit got a little overloaded and
there are cpus that set it, but won't recover.

Only Intel(R) Xeon(R) branded cpus can recover, but not all. The story so far:

Nehalem, Westmere: E7 models support SRAO recovery (patrol scrub,
cache eviction). Not relevant for this e-mail thread.

Sandy Bridge: Some "advanced RAS" skus will recover from poison reads
(these have E5 model names, there was no E7 in this generation)

Ivy Bridge: Xeon E5-* models do not recover. E7-* models do recover.
Note E5 and E7 have the same CPUID model number.

Haswell: Same as Ivy Bridge

Broadwell/Sky Lake: Xeon not released yet ... can't talk about them.

Linux code recently got some recovery bits for AMD cpus ... I don't
know what the story is on which models support this,

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
