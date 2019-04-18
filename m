Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A38EC10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:42:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2154A2183F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:42:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="R/AYdV4I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2154A2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B47A16B0005; Thu, 18 Apr 2019 01:41:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACFBB6B0006; Thu, 18 Apr 2019 01:41:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 997C06B0007; Thu, 18 Apr 2019 01:41:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4006B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:41:59 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id g12so429982vkf.20
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:41:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zQ9PhXUre7lv39dhKUe3RnNugaLVkc5Fpp+aduMWHKc=;
        b=e1DCfJGSLVSc9DWsW2d1i9bhYC8V8OX1dvracLVViAWJCcKjJamUJz/UKKOGmkakTW
         lAtaI61WG0ey5sYLvgbjbNuIkbJa24zR88LAWnPju0l9XsliQEPET4eAaJQWvUDhvrI6
         Y/kAZiwvL3yRqkSMjKVHZX7SJsX2qwKCH9VyYy2a5UdBcJAZ/9Pxj2ESX9cbyG1E1q79
         y4zTY3KNZCUXICPqU2uMzWgygFKrpeotWi0UH/Hv/fEpo9V8mxM4zaxvGt5txD/kiE3G
         K7fuonaxnGc3iQdIBnM1tO9FurohvFAO+boO3KRGbYOlVqbWsra18P30cIGhqaMacbHK
         w/sg==
X-Gm-Message-State: APjAAAXu72UtLnWVR4QwfDftW781MREjsFjS4DnYV/l1kyTUKNq3LW9a
	997jxGlQZvs+Wz2cdHHkVNw9n7YXW0RYyi7Ivf9jHQylcnDi3j2u2ukTfWV0r1qpfilntwMFh14
	OPNH6sQhgLY8F3rOevxPjcQqCWz2D0QC9lOyPQ1fR4V0Mmd7nUMSe1tZK1Q6y/D5rQg==
X-Received: by 2002:ab0:274a:: with SMTP id c10mr24804714uap.107.1555566119212;
        Wed, 17 Apr 2019 22:41:59 -0700 (PDT)
X-Received: by 2002:ab0:274a:: with SMTP id c10mr24804696uap.107.1555566118440;
        Wed, 17 Apr 2019 22:41:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555566118; cv=none;
        d=google.com; s=arc-20160816;
        b=Kl058gLnsi2Azv53dPDrVnMplzCz3IbQM3gjAUrWkve4U6zpmeq+nrwTvrlke3kgG4
         rzMOka0Q2J18PNXN0fAb0c6BkQSPIi4vydM4qZi2HMI2hIPCvncu47H8Tqw1OL2eWoFE
         006PfVO4MYnKVugSX21HCLCY4LGSObxp6V8IkGE/q2BxZjwkdGK5wkG+ZzwL5FqHee3b
         3RER54AgBHPdg7VmMpK+WRJbh69pjA/aaO0QYOwiyEPfJSR5gnp8oKjpMBI4JCHMXUBg
         yLX6Aj4PiSAEq+8vfqYKa8mbPu5QWVZjf4C4YkvZoewNbozqI48wz8T7zZcLSwI5omox
         ZVxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zQ9PhXUre7lv39dhKUe3RnNugaLVkc5Fpp+aduMWHKc=;
        b=R0QRpIiFedI+QUN4c14Sc8WUCOOM5+Nw+b1iSxjxWJP5DN8SI326xnKsLHlZZIBb+U
         f0d7R+wr6MaivYMZ0hakUVV3+3vFu5X1+wk+WKmzm8GoMk7Gx0Ycrq9HBu7M0/tOqZHe
         QqlLbKsKq/H/w7KaaReOSpvJEAW1i6KP0qMSwJKWONVM5skR5ecCv0I9ohcnAyrSdV1R
         +YIM2XtDu68Ih5VC/nQFsL9Kk666HzNOENLUuS/oW7KCUX3Q7wNFQCIkE6lLRS5ZlaqH
         txxw/t12k4nsBznQ2My5qED8X7UKDTHgqZ2x3aQref/+/Xr/oUEKfBM8qn4Kq7dtnvm9
         W2Ow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="R/AYdV4I";
       spf=pass (google.com: domain of keescook@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s85sor314503vkb.4.2019.04.17.22.41.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 22:41:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="R/AYdV4I";
       spf=pass (google.com: domain of keescook@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zQ9PhXUre7lv39dhKUe3RnNugaLVkc5Fpp+aduMWHKc=;
        b=R/AYdV4IFItQnfjUNNubyf9+5USGcILzz8B1DmWPKSECRCluWxSP8rnztSiAw/nHbx
         OgWc7upQI8/4NLGzsj8XCYD8CtK21EXPUD3kqVz8L9yqhXJs06gDEQL5f14t98XkKrDi
         zZLGfesRzIi7SEtmDIBJc/zWHSSeITVGpq4qWo6pCUtYoX+1nKYsEkGc/aMtjhfeYPaR
         zpe5obPY5UDXKnX5Ux3km1WyEqJmPrsvxZPBHysfpd+ZMjsl8a01eFzYpNC5mgWQOQvs
         wfgj8VJjyeSiWxP7AB+2Th18IJzOpvgz45GRbENtjjUmOZDRpabHmRe+wBMg/KPgX8r9
         SNsQ==
X-Google-Smtp-Source: APXvYqzZLwtZBmPJJ/5v5RygK+/cFMwA6/cdqWVv/GY3jUCoHNshsVXhYcdmHi4zwosCo3mHVhlDcSu086Z/Mts0mIg=
X-Received: by 2002:a1f:a4d:: with SMTP id 74mr51091145vkk.13.1555566117779;
 Wed, 17 Apr 2019 22:41:57 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1554248001.git.khalid.aziz@oracle.com> <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com> <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com> <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com>
 <20190417172632.GA95485@gmail.com> <063753CC-5D83-4789-B594-019048DE22D9@gmail.com>
 <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de>
 <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com>
 <alpine.DEB.2.21.1904180129000.3174@nanos.tec.linutronix.de>
 <CAHk-=whUwOjFW6RjHVM8kNOv1QVLJuHj2Dda0=mpLPdJ1UyatQ@mail.gmail.com> <CALCETrXm9PuUTEEmzA8bQJmg=PHC_2XSywECittVhXbMJS1rSA@mail.gmail.com>
In-Reply-To: <CALCETrXm9PuUTEEmzA8bQJmg=PHC_2XSywECittVhXbMJS1rSA@mail.gmail.com>
From: Kees Cook <keescook@google.com>
Date: Thu, 18 Apr 2019 00:41:45 -0500
Message-ID: <CAGXu5jL-qJtW7eH8S2yhqciE+J+FWz8HHzTrGJTgVUbd55n6dQ@mail.gmail.com>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Nadav Amit <nadav.amit@gmail.com>, Ingo Molnar <mingo@kernel.org>, 
	Khalid Aziz <khalid.aziz@oracle.com>, Juerg Haefliger <juergh@gmail.com>, 
	Tycho Andersen <tycho@tycho.ws>, Julian Stecklina <jsteckli@amazon.de>, Kees Cook <keescook@google.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, 
	deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>, 
	Tyler Hicks <tyhicks@canonical.com>, David Woodhouse <dwmw@amazon.co.uk>, 
	Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, 
	Boris Ostrovsky <boris.ostrovsky@oracle.com>, iommu <iommu@lists.linux-foundation.org>, 
	X86 ML <x86@kernel.org>, 
	"linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	LSM List <linux-security-module@vger.kernel.org>, Khalid Aziz <khalid@gonehiking.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, 
	Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Arjan van de Ven <arjan@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 11:41 PM Andy Lutomirski <luto@kernel.org> wrote:
> I don't think this type of NX goof was ever the argument for XPFO.
> The main argument I've heard is that a malicious user program writes a
> ROP payload into user memory (regular anonymous user memory) and then
> gets the kernel to erroneously set RSP (*not* RIP) to point there.

Well, more than just ROP. Any of the various attack primitives. The NX
stuff is about moving RIP: SMEP-bypassing. But there is still basic
SMAP-bypassing for putting a malicious structure in userspace and
having the kernel access it via the linear mapping, etc.

> I find this argument fairly weak for a couple reasons.  First, if
> we're worried about this, let's do in-kernel CFI, not XPFO, to

CFI is getting much closer. Getting the kernel happy under Clang, LTO,
and CFI is under active development. (It's functional for arm64
already, and pieces have been getting upstreamed.)

> mitigate it.  Second, I don't see why the exact same attack can't be
> done using, say, page cache, and unless I'm missing something, XPFO
> doesn't protect page cache.  Or network buffers, or pipe buffers, etc.

My understanding is that it's much easier to feel out the linear
mapping address than for the others. But yes, all of those same attack
primitives are possible in other memory areas (though most are NX),
and plenty of exploits have done such things.

-- 
Kees Cook

