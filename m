Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7891FC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:48:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E1B020B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 16:48:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E1B020B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C20FE6B0005; Tue, 18 Jun 2019 12:48:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD1F08E0002; Tue, 18 Jun 2019 12:48:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A99C28E0001; Tue, 18 Jun 2019 12:48:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 737086B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 12:48:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y75so1744310pfg.1
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 09:48:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=Id8FC4UKbpkhWM3vYR07qgjvZRPME8zimSEH9eZmCEg=;
        b=BkqlFmRLrLaU1orh3lSpPaLXbu2/1PBgf83pdVqyTTsbzPvhUYun0QwGHu7V9RNsVs
         8c5zqLwVHkmc0MmScJG/PctgchNYjbLXLqjP/vmMNuvrTUs0qfGT39NJbr3i0PMVKTHs
         4DxHZ/L+YK9MMQ1Nz7cEWy5SUfHx6jp/3G3eRB0Az5pKzTwuQDXUMt96QBxCI6LCVOxI
         KCyMy2/sGCP97NuMb6BFls5+l0jQmS+WHrVOtfeBQTgkkHraS7qgVIF5S1Ec55Q0Egjl
         GyfRUF0pMLcDmnNOtu9p7pMP8JEIIv0VMiRXQS7RD/pMBCNs4dLnrGucDBcqOXBX6G/r
         ys6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV8D27mwhhvBI0/ZFMwvUuthfchU1gRg1eAmbFpb9oKMHnWVMwR
	1fXaZUiHPOcOU6K1nmKbKmJ4Pp1oKZgRQl2/J2okFTrk55DRX6I/QQDlwA+QRKk06FNkwTaSn6B
	artzFqfDnXaBp95RV/wSAhw3Ng8Zu3SfaDFQjkmurilgsMUUto0RWPmhJCy82t9PTmA==
X-Received: by 2002:a17:902:f216:: with SMTP id gn22mr96221038plb.118.1560876528135;
        Tue, 18 Jun 2019 09:48:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxidyQkLhZkksw76rJs0KeDnr7H7DxnSP+IjFB9d9UBWxktmn/RYfawGyvqoxMeq/ENoQrL
X-Received: by 2002:a17:902:f216:: with SMTP id gn22mr96220989plb.118.1560876527431;
        Tue, 18 Jun 2019 09:48:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560876527; cv=none;
        d=google.com; s=arc-20160816;
        b=VrN0KbXuxbubhX1sHWBrVyqYRwDbYA5614t6ZC7mX6mLg6qUwCidVDpCnQqqyAVl86
         D27hOIIVSaWLGHbpuJlj1PrLh438CImxBYZutBPwB/ST0jdZ0wZx4rlzcUhqGD/i4Tvz
         EAwb8qvY2K7g9ntIlM1IhW0wegiVvUjwjWKXg2eY9LLK0XtJNdHXnoNYj0InLDBGDGY9
         nSqABuUGXloa8rloVwjmmb3T03Z9uuKHUap7fi/5vuPA38Pk1ntXs0AHKNDIMVt1LId9
         s4OysvSm4IMZIdDmtGrFLN+NV2EuHYYjHRWTtWlSGeY6PAjTPbBUkj5HzrKzysTPvJ73
         pH6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=Id8FC4UKbpkhWM3vYR07qgjvZRPME8zimSEH9eZmCEg=;
        b=bnmH+Z+SCCv3BsDC/glcQH5Pv5GHQ7z9LC+a6AXPWU1uC0sd3VxZQolpkbpJ+dEVAe
         eS+zZ8zU7BFr8lLMx8DRvg62+KsUE8JAosxmackxCY0cI4fuQk/4gSBpbmpx/jxeFNbG
         qMknN9IzgqsrerXEqpK6nR0iynbvl6HnXA/MGy1CkXQmvDtNxfy9pO1aGPjPq9VNwlpF
         uWmJ+mh3Xd4XRqEhXHNJfdlh03kkt0u9LRdDATphLvZrKdQ5IO5L+3to7DahcVQKNDcD
         7UGksLdVldXD8ykJdLIY8mHsJkzYJ9sInUqG2lpo5mYV6jnKc/1hrgj3UmujNi3/ngjp
         DMuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id e13si13764865pfn.24.2019.06.18.09.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 09:48:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 09:48:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,389,1557212400"; 
   d="scan'208";a="243045278"
Received: from oamaslek-mobl.amr.corp.intel.com (HELO [10.251.9.224]) ([10.251.9.224])
  by orsmga001.jf.intel.com with ESMTP; 18 Jun 2019 09:48:46 -0700
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for
 MKTME
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
 Peter Zijlstra <peterz@infradead.org>, Kai Huang
 <kai.huang@linux.intel.com>, Andy Lutomirski <luto@kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 David Howells <dhowells@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jacob Pan <jacob.jun.pan@linux.intel.com>,
 Alison Schofield <alison.schofield@intel.com>, Linux-MM
 <linux-mm@kvack.org>, kvm list <kvm@vger.kernel.org>,
 keyrings@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
 Tom Lendacky <thomas.lendacky@amd.com>
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
 <20190618161502.jiuqhvs3wvnac5ow@box.shutemov.name>
 <f701f859-0990-9f02-baa2-451dd6c8b3c4@intel.com>
 <8FDB1E33-21BC-400D-9051-7BE61400ACD2@amacapital.net>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <7e001776-a8f8-9109-a536-90398de81d53@intel.com>
Date: Tue, 18 Jun 2019 09:48:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <8FDB1E33-21BC-400D-9051-7BE61400ACD2@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/18/19 9:36 AM, Andy Lutomirski wrote:
> Should MKTME+DAX encrypt the entire volume or should it encrypt individual files?  Or both?

Our current thought is that there should be two modes: One for entire
DAX namespaces and one for filesystem DAX that would allow it to be at
the file level.  More likely, we would mirror fscrypt and do it at the
directory level.

> If it encrypts individual files, should the fs be involved at all?
> Should there be metadata that can check whether a given key is the
> correct key?
FWIW, this is a question for the fs guys.  Their guidance so far has
been "do what fscrypt does", and fscrypt does not protect against
incorrect keys being specified.  See:

	https://www.kernel.org/doc/html/v5.1/filesystems/fscrypt.html

Which says:

> Currently, fscrypt does not prevent a user from maliciously providing
> an incorrect key for another user’s existing encrypted files. A
> protection against this is planned.

> If it encrypts individual files, is it even conceptually possible to
> avoid corruption if the fs is not involved?  After all, many
> filesystems think that they can move data blocks, compute checksums,
> journal data, etc.

Yes, exactly.  Thankfully, fscrypt has thought about this already and
has infrastructure for this.  For instance:

> Online defragmentation of encrypted files is not supported. The
> EXT4_IOC_MOVE_EXT and F2FS_IOC_MOVE_RANGE ioctls will fail with
> EOPNOTSUPP.

