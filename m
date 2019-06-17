Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE045C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 21:36:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D2A920657
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 21:36:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D2A920657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6EEE6B0003; Mon, 17 Jun 2019 17:36:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E20AB8E0002; Mon, 17 Jun 2019 17:36:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE6D98E0001; Mon, 17 Jun 2019 17:36:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9446A6B0003
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:36:57 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id l4so7808494pff.5
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 14:36:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ppqVdxzcxAahABA2z+AKKdl+43Sl02TIR5zwRqkLHuo=;
        b=pAztH8lEXWL/ifSAY0mLRuIAYxtrQBwEhLzgf2KQ/ownK+/d6A3L5XzO+J3RyacCa6
         JBfsRfjItFHLp7UzBursOE1fvIwuivjkNgXB82FkJ3HptHJMqDC2Q6h1OQn/VGtFOc33
         EDceXhPoIsW1uTnmCzKTbWe6mephHiinKZNuvWMFYj+JQOgrAkTgchKmj8c3wfpnRrX4
         nAUuOsoHBchBDRVtlTtzRkA5DiWUP76iJ6n3vBC/Gs4yUQ5TqmmwfPFCXlJZj3B5FKJS
         mCagYrSnSv6gGYMRIdJehfwm2+ptyWwAxnirWy+vOo+c/0hNjNRaAFx1DAWFph/5y25W
         jHpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWH6G15TNPqRr4ZBIc+3LGvwGTrMjh6S4bb1Y7gRHc7otddb8JU
	Gu21x8WLP5w6eJcrQWSeWzBilxCP8GzPvZPhuaMVVz3SrZqFca5UkGXTjPHiNKVRv9CHrOtA0Mi
	jFC10He3GAIDbF4hgrkdXpn/b1NdFToAKoS1Rde1vxu8QBtpCUeOKZsZT6g5UMT6ZHw==
X-Received: by 2002:a62:2784:: with SMTP id n126mr49706836pfn.61.1560807417236;
        Mon, 17 Jun 2019 14:36:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxv0HsfB1IoUOTZ70/WfEBroMRSFXoov1aPbT22Ek/rsxKRg6u0I4CRrwVTS9Hi3DJBG2c/
X-Received: by 2002:a62:2784:: with SMTP id n126mr49706762pfn.61.1560807416280;
        Mon, 17 Jun 2019 14:36:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560807416; cv=none;
        d=google.com; s=arc-20160816;
        b=JRoRlt6RoHBiD/F7rKV8r73XNtoL63VhDOtp1sfRVReWKMB1QtjccbnHUdRYXvT4zj
         0ZgYa1rxBx9jHiX63I5mPfi2eyeTPyZCSy25KNO+pQhi1MAiTgd6JH3YPnDqLXT1a+0V
         T/EZ6eNrVBZbVVajK5HERG7j/gAoIZMa7eh61WQuMK5ZmunJAd1YLGIuW4uQCePZoeu/
         VZ2UT9PVqia1Ve8c1GaqigngYMnU82NCsA+/nGTgyPQh4WYhMf5gWyW5X8OZBqH/UZ81
         tDy1a0uYLG9ZACYUShAMJswSZ6JrTYhc1izKNZaxQaBFpEr3QlJIhtNPM5Ej7NkRVOc3
         MIlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=ppqVdxzcxAahABA2z+AKKdl+43Sl02TIR5zwRqkLHuo=;
        b=DKo3iOR1paTLDX7QbNdCHUuDyJB+TAOSm7wd5w2sGzcHiuP4v+WnhF5X+M96pbeIzC
         eEe6P27OziyhbfX0feqh1pEalY4Qc942zkfsgiJaNeA2l6mZbRRM/KKR7BHd0bfzupk/
         x7qRfcqGV8Eaa5JkcE8kWTNQpFBGkr0qoBLZk5Y+rfvjjhc/+QMzbK7FyEZrviVN5FVg
         4rkxqJ3iB6vWiu9Cq68VzhzAfABXD7FyCWYnaJ2AX4B4eXyge6nI4a4u8M9cn+e0ffXZ
         rI3HM8E+r4enkb6gY/PQD0JokCaF8abmr84kjYJXohcVXW0gkyN9gVTgTmNKHsvGUlHf
         zuyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a6si390530pjo.91.2019.06.17.14.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 14:36:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 14:36:55 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga005.jf.intel.com with ESMTP; 17 Jun 2019 14:36:54 -0700
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for
 MKTME
To: Andy Lutomirski <luto@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 Peter Zijlstra <peterz@infradead.org>, David Howells <dhowells@redhat.com>,
 Kees Cook <keescook@chromium.org>, Kai Huang <kai.huang@linux.intel.com>,
 Jacob Pan <jacob.jun.pan@linux.intel.com>,
 Alison Schofield <alison.schofield@intel.com>, Linux-MM
 <linux-mm@kvack.org>, kvm list <kvm@vger.kernel.org>,
 keyrings@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
 Tom Lendacky <thomas.lendacky@amd.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
 <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
 <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <d599b1d7-9455-3012-0115-96ddbad31833@intel.com>
Date: Mon, 17 Jun 2019 14:36:54 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>> Where if we have something like mprotect() (or madvise() or something
>> else taking pointer), we can just do:
>>
>>         fd = open("/dev/anything987");
>>         ptr = mmap(fd);
>>         sys_encrypt(ptr);
> 
> I'm having a hard time imagining that ever working -- wouldn't it blow
> up if someone did:
> 
> fd = open("/dev/anything987");
> ptr1 = mmap(fd);
> ptr2 = mmap(fd);
> sys_encrypt(ptr1);
> 
> So I think it really has to be:
> fd = open("/dev/anything987");
> ioctl(fd, ENCRYPT_ME);
> mmap(fd);

Yeah, shared mappings are annoying. :)

But, let's face it, nobody is going to do what you suggest in the
ptr1/ptr2 example.  It doesn't make any logical sense because it's
effectively asking to read the memory with two different keys.  I
_believe_ fscrypt has similar issues and just punts on them by saying
"don't do that".

We can also quite easily figure out what's going on.  It's a very simple
rule to kill a process that tries to fault a page in whose KeyID doesn't
match the VMA under which it is faulted in, and also require that no
pages are faulted in under VMAs which have their key changed.


>> Now, we might not *do* it that way for dax, for instance, but I'm just
>> saying that if we go the /dev/mktme route, we never get a choice.
>>
>>> I think that, in the long run, we're going to have to either expand
>>> the core mm's concept of what "memory" is or just have a whole
>>> parallel set of mechanisms for memory that doesn't work like memory.
>> ...
>>> I expect that some day normal memory will  be able to be repurposed as
>>> SGX pages on the fly, and that will also look a lot more like SEV or
>>> XPFO than like the this model of MKTME.
>>
>> I think you're drawing the line at pages where the kernel can manage
>> contents vs. not manage contents.  I'm not sure that's the right
>> distinction to make, though.  The thing that is important is whether the
>> kernel can manage the lifetime and location of the data in the page.
> 
> The kernel can manage the location of EPC pages, for example, but only
> under extreme constraints right now.  The draft SGX driver can and
> does swap them out and swap them back in, potentially at a different
> address.

The kernel can't put arbitrary data in EPC pages and can't use normal
memory for EPC.  To me, that puts them clearly on the side of being
unmanageable by the core mm code.

For instance, there's no way we could mix EPC pages in the same 'struct
zone' with non-EPC pages.  Not only are they not in the direct map, but
they never *can* be, even for a second.

>>> And, one of these days, someone will come up with a version of XPFO
>>> that could actually be upstreamed, and it seems entirely plausible
>>> that it will be totally incompatible with MKTME-as-anonymous-memory
>>> and that users of MKTME will actually get *worse* security.
>>
>> I'm not following here.  XPFO just means that we don't keep the direct
>> map around all the time for all memory.  If XPFO and
>> MKTME-as-anonymous-memory were both in play, I think we'd just be
>> creating/destroying the MKTME-enlightened direct map instead of a
>> vanilla one.
> 
> What I'm saying is that I can imagine XPFO also wanting to be
> something other than anonymous memory.  I don't think we'll ever want
> regular MAP_ANONYMOUS to enable XPFO by default because the
> performance will suck.

It will certainly suck for some things.  But, does it suck if the kernel
never uses the direct map for the XPFO memory?  If it were for KVM guest
memory for a guest using direct device assignment, we might not even
ever notice.

> I'm thinking that XPFO is a *lot* simpler under the hood if we just
> straight-up don't support GUP on it.  Maybe we should call this
> "strong XPFO".  Similarly, the kinds of things that want MKTME may
> also want the memory to be entirely absent from the direct map.  And
> the things that use SEV (as I understand it) *can't* usefully use the
> memory for normal IO via GUP or copy_to/from_user(), so these things
> all have a decent amount in common.

OK, so basically, you're thinking about new memory management
infrastructure that a memory-allocating-app can opt into where they get
a reduced kernel feature set, but also increased security guarantees?
 The main insight thought is that some hardware features *already*
impose (some of) this reduced feature set?

FWIW, I don't think many folks will go for the no-GUP rule.  It's one
thing to say no-GUPs for SGX pages which can't have I/O done on them in
the first place, but it's quite another to tell folks that sendfile() no
longer works without bounce buffers.

MKTME's security guarantees are very different than something like SEV.
 Since the kernel is in the trust boundary, it *can* do fun stuff like
RDMA which is a heck of a lot faster than bounce buffering.  Let's say a
franken-system existed with SEV and MKTME.  It isn't even clear to me
that *everyone* would pick SEV over MKTME.  IOW, I'm not sure the MKTME
model necessarily goes away given the presence of SEV.

> And another silly argument: if we had /dev/mktme, then we could
> possibly get away with avoiding all the keyring stuff entirely.
> Instead, you open /dev/mktme and you get your own key under the hook.
> If you want two keys, you open /dev/mktme twice.  If you want some
> other program to be able to see your memory, you pass it the fd.

We still like the keyring because it's one-stop-shopping as the place
that *owns* the hardware KeyID slots.  Those are global resources and
scream for a single global place to allocate and manage them.  The
hardware slots also need to be shared between any anonymous and
file-based users, no matter what the APIs for the anonymous side.

