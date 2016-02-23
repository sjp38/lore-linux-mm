Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 956826B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 12:46:09 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id z8so13410138ige.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 09:46:09 -0800 (PST)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id vs5si40285832igb.33.2016.02.23.09.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 09:46:08 -0800 (PST)
Received: by mail-io0-x22a.google.com with SMTP id l127so220432718iof.3
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 09:46:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160223103221.GA1418@node.shutemov.name>
References: <20160211192223.4b517057@thinkpad>
	<20160211190942.GA10244@node.shutemov.name>
	<20160211205702.24f0d17a@thinkpad>
	<20160212154116.GA15142@node.shutemov.name>
	<56BE00E7.1010303@de.ibm.com>
	<20160212181640.4eabb85f@thinkpad>
	<20160223103221.GA1418@node.shutemov.name>
Date: Tue, 23 Feb 2016 09:46:08 -0800
Message-ID: <CA+55aFxh5P57Qg2xPYbTekAXzpWWON2qw76ZtC93ZQKqaqBA6A@mail.gmail.com>
Subject: Re: [BUG] random kernel crashes after THP rework on s390 (maybe also
 on PowerPC and ARM)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Tue, Feb 23, 2016 at 2:32 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> I still worry about pmd_present(). It looks wrong to me. I wounder if
> patch below makes a difference.

Let's hope that's it, but in the meantime I do want to start the
discussion about what to do if it isn't. We're at rc5, and 4.5 is just
a few weeks away, and so far this issue hasn't gone anywhere.

So the *good* scenario is that your pmd_present() patch fixes it, and
we can all take a relieved breath.

But if not, what then? It looks like we have two options:

 (a) do a (hopefully minimal) revert.

     I say "hopefully minimal", but I suspect the revert is going to
have to undo pretty much all of the core THP changes. I'd hate to see
that, because I really liked the cleanups.

 (b) mark THP as "depends on !S390" in the 4.5 release

The (b) option is obviously much simpler, but it's a regression. I
really don't like it, even if it generally shouldn't be the kind of
regression that is actually user-noticeable (apart from performance).
I also hate the fact that while the problem only seems to happen on
s390, we don't even understand it, so maybe it's a more generic issue
that for some reason just ends up being *much* more noticeable on one
odd architecture that happens to be a bit different.

I'm inclined to think of (b) as just a "give us more time to figure it
out" thing, but I'm also worried that it will then make people not
pursue this issue.

How big is a revert patch that makes THP work on s390 again? Can we do
a revert that keeps the infrastructure intact and makes it easy to
revisit the THP cleanups later? Or is the revert inevitably going to
be all the core patches in that series?

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
