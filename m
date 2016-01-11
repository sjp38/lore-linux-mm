Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 020A4828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 05:44:31 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id f206so261319536wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 02:44:30 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id kq7si809889wjb.150.2016.01.11.02.44.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 02:44:29 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id l65so25631855wmf.3
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 02:44:29 -0800 (PST)
Date: Mon, 11 Jan 2016 11:44:25 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
Message-ID: <20160111104425.GA29448@gmail.com>
References: <19f6403f2b04d3448ed2ac958e656645d8b6e70c.1452297867.git.tony.luck@intel.com>
 <CALCETrVqn58pMkMc09vbtNdbU2VFtQ=W8APZ0EqtLCh3JGvxoA@mail.gmail.com>
 <CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
 <CALCETrVQ_NxcnDr4N-VqROrMJ2hUzMKgmxjxAZu9TFbznqSDcg@mail.gmail.com>
 <CA+8MBbLUtVh3E4RqcHbZ165v+fURGYPm=ejOn2cOPq012BwLSg@mail.gmail.com>
 <CAPcyv4hAenpeqPsj7Rd0Un_SgDpm+CjqH3EK72ho-=zZFvG7wA@mail.gmail.com>
 <CALCETrVRgaWS86wq4B6oZbEY5_ODb3Nh5OeE9vvdGdds6j_pYg@mail.gmail.com>
 <CAPcyv4iCbp0oR_V+XCTduLd1t2UxyFwaoJVk0_vwk8aO2Uh=bQ@mail.gmail.com>
 <CA+8MBbLFb1gdhFWeG-3V4=gHd-fHK_n1oJEFCrYiNa8Af6XAng@mail.gmail.com>
 <20160110112635.GC22896@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160110112635.GC22896@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tony Luck <tony.luck@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>


* Borislav Petkov <bp@alien8.de> wrote:

> On Sat, Jan 09, 2016 at 05:40:05PM -0800, Tony Luck wrote:
> > BUT ... it's all going to be very messy.  We don't have any CPUID
> > capability bits to say whether we support recovery, or which instructions
> > are good/bad choices for recovery.
> 
> We can always define synthetic ones and set them after having checked
> MCA capability bits, f/m/s, etc., maybe even based on the list you're
> supplying...

So such a synthetic CPUID bit would definitely be useful.

Also, knowing whether a memcpy function is recoverable or not, should not be 
delegated to callers: there should be the regular memcpy APIs, plus new APIs that 
do everything they can to provide recoverable memory copies. Whether it's achieved 
via flag checking, a function pointer or code patching is an implementation detail 
that's not visible to drivers making use of the new facility.

I'd go for the simplest, most robust solution initially, also perhaps with boot 
time messages to make sure users know which variant is used and now.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
