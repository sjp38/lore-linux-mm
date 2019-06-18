Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAD80C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:15:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1377213F2
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:15:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="sp219faf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1377213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49A148E0002; Tue, 18 Jun 2019 12:15:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44A878E0001; Tue, 18 Jun 2019 12:15:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 339118E0002; Tue, 18 Jun 2019 12:15:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D917C8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:15:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d13so21935816edo.5
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:15:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TV0b7JjOzi3iVkcg5Sm68/8xpqk1N7OtdOwvdmMSM/4=;
        b=WDRgBmmlX7BRFTBDLtf+FmoH4ZnIRI29OpQeFTcwpB0S/J52Ywn9WVTgalm8kFP1a5
         PVE9IPbVXEVT43f4iUcxzE36w7JjNdkQh4uWWbXfpKx9MkUEDsWKGlDqz3SJq9Nb21du
         KcTImDNAPiHMk7SoVXPAvXZelSwWHsNkxwQgRq/ZKfWTT6NCPavhHGCskqMEs5uCtfk1
         UhNiguxrxlWSS5NEV1ZIxTjuVgXQjW45MfYqXSsEXsWcqlARL/b6wuMhe8W/T6FgNlHz
         4pxm5t9GTSW/LtgOaSo4tkc55+TLnaeic9Fi31eceEj407AmaVgZgpmzwA6j2ILAvcEd
         1nEA==
X-Gm-Message-State: APjAAAWDQUrBK1ktvjf2KYod2J+UwX2LnvHzleZCSMZK4uxvFP621og2
	p68mqoCiqFzJ2QY562P6qdSX8WtoVSKyf/0Re0Kc8Y9rjno+8PKOBKrteUpi7cdeig2LY/irapq
	8QSoeWazXz0CdbJ4GfAfLtvcpphVDXDULwhYGSZcXFRVJhWFh+kIk0BXxFLCahrTSzg==
X-Received: by 2002:a17:906:4882:: with SMTP id v2mr26689140ejq.100.1560874505397;
        Tue, 18 Jun 2019 09:15:05 -0700 (PDT)
X-Received: by 2002:a17:906:4882:: with SMTP id v2mr26689051ejq.100.1560874504548;
        Tue, 18 Jun 2019 09:15:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560874504; cv=none;
        d=google.com; s=arc-20160816;
        b=Nzb6ECkYOrrSSf9rwFXpY/3pDULdG8ugMmzYwEpuwa6by9VwWerNpEyyxxCJer4hLo
         j+M/43hK6mdr+r8jPXfwktk35leOA9cfjOheshsZOXaXPB8vugoE3oP+aQacg8U8ydpZ
         UZPARnqg9IaIjrKUbWmHpFJWHJPzYsmUqxCu7u1gEjsueU0pYB7Y1o1Hv/HMm18NqBz5
         u21BsQ3DBKvJLa7fYzD5VPL41MY/HSwZb9F6i811T5TNfDahR0bmVzy18A8Nny45dJCL
         ZTYQGPYKvCqLSvilCmaHIl1wQVYXFdeIGpQ7N3QEkfWosSi1waUPtq/sKHYtnbwnAdgg
         436A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TV0b7JjOzi3iVkcg5Sm68/8xpqk1N7OtdOwvdmMSM/4=;
        b=alfRD+UoBzWNP3ceG/r1Vx8mAYH+HBDUhVyVwM++ylSZyeB0WRqnN4YvtghA6ofu1P
         HAbfL80GteF//vbfZaKHfFr4eRkA5feRB8iFaNM8+pSv2lZXmxq7nQDd0DU1ZmrrHAxx
         0m3RanneKYMxz20xJsbj+4XtglsCfN72kJ7M1DxOtkwDNbOSTHiMe3RM9zouv2K7Sz45
         Hzn9OKrFIscf9YSc2nRaryNS9ZG5DQqlXBZ1mkIU3pooJT4Lgt5AuwZwL0Z4w3ZOrPQW
         mWS0xpUBhC4cEmXqmPQ5fR4f9OYYoGg8vWV97BPQbye72sWgs+m7epDjsXxdeDwL8IDv
         ZrLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=sp219faf;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor4753254ejl.47.2019.06.18.09.15.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 09:15:04 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=sp219faf;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TV0b7JjOzi3iVkcg5Sm68/8xpqk1N7OtdOwvdmMSM/4=;
        b=sp219fafTDU9AF/f/dDdjrZCyZ0ajovfZ5IsEGibzM7oT+JPXHoqtpUp9y+/FKsAwK
         cLIQ+SaiFpOVgcfnmqkW9kh5ZPD933ncGaqvOqcRXz/pzYG3CBjS75hfB8b9mHWeavRe
         9YN1tKGr4uMlODuJh8c/skxvKjR4ZWdBSfgEzgsswaLzfDNG+8bqhpgeVcbY2wroQOgm
         m8yqhLkLzqsfAkLZhQk83MDmYYETbswPrTbUk+blwkZ74EGdHU7kVpaDKfhD/bL/qi0Z
         PjZ6O9mRV5k2iiT8GT6xBwuzKmNmxmOfoNm4dcg+n+TIGqaR7jY0hQPi6Dux1UfSzHJt
         f5iA==
X-Google-Smtp-Source: APXvYqxkJFdEknnrEDQYFG7Dsrv3QgF4P1fh93uo1KXJbSzbgkocrY1GYGzkIA2M5LkSkPJAL6JZ8Q==
X-Received: by 2002:a17:906:2890:: with SMTP id o16mr76685704ejd.80.1560874504188;
        Tue, 18 Jun 2019 09:15:04 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id a6sm4612918eds.19.2019.06.18.09.15.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 09:15:03 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id E6FF61036B4; Tue, 18 Jun 2019 19:15:02 +0300 (+03)
Date: Tue, 18 Jun 2019 19:15:02 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Kai Huang <kai.huang@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>, David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	Linux-MM <linux-mm@kvack.org>, kvm list <kvm@vger.kernel.org>,
	keyrings@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
Message-ID: <20190618161502.jiuqhvs3wvnac5ow@box.shutemov.name>
References: <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
 <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
 <1560816342.5187.63.camel@linux.intel.com>
 <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
 <1560821746.5187.82.camel@linux.intel.com>
 <CALCETrUrFTFGhRMuNLxD9G9=GsR6U-THWn4AtminR_HU-nBj+Q@mail.gmail.com>
 <1560824611.5187.100.camel@linux.intel.com>
 <20190618091246.GM3436@hirez.programming.kicks-ass.net>
 <2ec26c05-7c57-d0e0-a628-94d581b96b63@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ec26c05-7c57-d0e0-a628-94d581b96b63@intel.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 07:09:36AM -0700, Dave Hansen wrote:
> On 6/18/19 2:12 AM, Peter Zijlstra wrote:
> > On Tue, Jun 18, 2019 at 02:23:31PM +1200, Kai Huang wrote:
> >> Assuming I am understanding the context correctly, yes from this perspective it seems having
> >> sys_encrypt is annoying, and having ENCRYPT_ME should be better. But Dave said "nobody is going to
> >> do what you suggest in the ptr1/ptr2 example"? 
> > 
> > You have to phrase that as: 'nobody who knows what he's doing is going
> > to do that', which leaves lots of people and fuzzers.
> > 
> > Murphy states that if it is possible, someone _will_ do it. And this
> > being something that causes severe data corruption on persistent
> > storage,...
> 
> I actually think it's not a big deal at all to avoid the corruption that
> would occur if it were allowed.  But, if you're even asking to map the
> same data with two different keys, you're *asking* for data corruption.
>  What we're doing here is continuing to  preserve cache coherency and
> ensuring an early failure.
> 
> We'd need two rules:
> 1. A page must not be faulted into a VMA if the page's page_keyid()
>    is not consistent with the VMA's
> 2. Upon changing the VMA's KeyID, all underlying PTEs must either be
>    checked or zapped.
> 
> If the rules are broken, we SIGBUS.  Andy's suggestion has the same
> basic requirements.  But, with his scheme, the error can be to the
> ioctl() instead of in the form of a SIGBUS.  I guess that makes the
> fuzzers' lives a bit easier.

I see a problem with the scheme: if we don't have a way to decide if the
key is right for the file, user without access to the right key is able to
prevent legitimate user from accessing the file. Attacker just need read
access to the encrypted file to prevent any legitimate use to access it.

The problem applies to ioctl() too.

To make sense of it we must have a way to distinguish right key from
wrong. I don't see obvious solution with the current hardware design.

-- 
 Kirill A. Shutemov

