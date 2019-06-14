Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A93AFC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:30:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7293F217F9
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:30:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7293F217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8B946B000C; Fri, 14 Jun 2019 13:30:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3C096B000D; Fri, 14 Jun 2019 13:30:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2A836B0266; Fri, 14 Jun 2019 13:30:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9306B000D
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:30:40 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s4so2381535pgr.3
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:30:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/eUQpgPNHwus1buYOY126L66tE3tz7TxIPOVE48KQZQ=;
        b=F1vBtfWAwAM7pNWhd7cOOn6FomeHR/ePaiqcf3nkFL9G5TkOZcID51e9AQPn9ylg53
         aUXsvdXjHXnsoM8RB6yYlqKeZhnslsIa6cHYwFNAnx6SvPUBK7vv1dfNLgF8ndbYsIN2
         15FJFEpj7vcd1rGLiJoqJPEsDfRuLLwKpyM15EvhJ4ZSjfOvvK1QY8B2cTdPMlXfKO/m
         uVZdtnrQQb0Qj3QrvOdA+ys6ECcYLmo8egW4BOGjbZRaiO27qg0bQqbEtuCi9g9OEiRX
         uDEFGVzYQoGUt/HXnTWZMVmOe3NM3gj7AKgvy3aUYY6vhrzBKQXW7AfBkLkb2jCkCIu3
         pI5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWdnPYKYh0EwO0UVFMkJr3QbYkWVe5j4FGFococT3wp1K10qbdE
	BNKOYu28Dqshyg5xFrbvCKzFtUqte8TTaPU8AA5pv2akPuvjUIo5f6+5vOZOhMO4yeByw0OQJrZ
	Si7ODUxdUlss8I2hVm1HikbS3fJe7Mxd8wC1ejMYJmmrp/YJ4ms8VGNtp5Wr/UJsJXA==
X-Received: by 2002:a63:f510:: with SMTP id w16mr34055374pgh.0.1560533440254;
        Fri, 14 Jun 2019 10:30:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzx4/EvjTW4x5do8cahcTi+LHA6g/NiDE8nJ6mgQ/AVG0OX/k4jWReNlLh6zQXlX8jxaQ4M
X-Received: by 2002:a63:f510:: with SMTP id w16mr34055315pgh.0.1560533439567;
        Fri, 14 Jun 2019 10:30:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560533439; cv=none;
        d=google.com; s=arc-20160816;
        b=beUJtOSyKYo6t3JG0MMWCDRJFxtvPZwiLKshchexQnpuo+QMzQhZv3pcHGzkhJRvP4
         Kr5sBThzmYGKAugIjTvnvP3mXrNhP24yYTzQLzmgApMSIRnMEZbqDfo4OL5PKCemS0Hx
         nrhgAvSO/bm2Gt18Q5PLZtndUbGJs8QNOPqwW+ncgDkUtkUj5XcQhDH2tXnsnlcfr2e6
         wHzcQ/UbeE299rmjqPnpZXRhjYi/I4HPKp54fHzMukCoiaINCzQjA2pqt7mBm5PpfOVR
         0DsvyMWuGGPP/XRMsFzm268OEcZqA0PLQmF4cziwoH2FPkVxCFl24g97FGEbaeejteP1
         OgxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/eUQpgPNHwus1buYOY126L66tE3tz7TxIPOVE48KQZQ=;
        b=TSaC8dkzlknYw0SFk/Uhkv/gkbQat6Ubt0s41NotelVtsUHQCpp+rZW1RHdP5fy7Ce
         DaZZp/BTdcEYXrXx37Rm9F/0agvOdTol1dUuTPMfnBHJY2BoM70LY5UiPonFIsjihoS7
         Fy7cXRAsZMfulbxusus9SrxsWA5/RzfrJkThoSDDa7zbHwUh/8RP/eX73Q5IC5FARXrw
         LtlqUNT1f55AncXFGKRY3fWbScy0A0mNLIcQrA/lVSIPhnzN7XmMyU/K8f5YhvunMRNV
         EnBK9MmMR6uT04AqwUOahB1r12STgM71OKWaQhqQXcTp1bLd8TnxEGTkqdV5Zi2CtU03
         cKPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id x24si2914645pfm.83.2019.06.14.10.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 10:30:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 10:30:39 -0700
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by orsmga005-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 10:30:38 -0700
Date: Fri, 14 Jun 2019 10:33:45 -0700
From: Alison Schofield <alison.schofield@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 44/62] x86/mm: Set KeyIDs in encrypted VMAs for MKTME
Message-ID: <20190614173345.GB5917@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-45-kirill.shutemov@linux.intel.com>
 <20190614114408.GD3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614114408.GD3436@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 01:44:08PM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:44:04PM +0300, Kirill A. Shutemov wrote:
> > From: Alison Schofield <alison.schofield@intel.com>
> > 
> > MKTME architecture requires the KeyID to be placed in PTE bits 51:46.
> > To create an encrypted VMA, place the KeyID in the upper bits of
> > vm_page_prot that matches the position of those PTE bits.
> > 
> > When the VMA is assigned a KeyID it is always considered a KeyID
> > change. The VMA is either going from not encrypted to encrypted,
> > or from encrypted with any KeyID to encrypted with any other KeyID.
> > To make the change safely, remove the user pages held by the VMA
> > and unlink the VMA's anonymous chain.
> 
> This does not look like a transformation that preserves content; is
> mprotect() still a suitable name?

Data is not preserved across KeyID changes, by design.

Background:
We chose to implement encrypt_mprotect() as an extension
to the legacy mprotect so that memory allocated in any
method could be encrypted. ie. we didn't want to be tied
to mmap. As an mprotect extension, encrypt_mprotect also
supports the changing of access flags.

The usage we suggest is:
1) alloc the memory w PROT_NONE to prevent any usage before
   encryption
2) use encrypt_mprotect() to add the key and change the
   access to  PROT_WRITE|PROT_READ.

Preserving the data across encryption key changes has not
been a requirement. I'm not clear if it was ever considered
and rejected. I believe that copying in order to preserve
the data was never considered.

Back to your naming question:
Since it is an mprotect extension, it seems we need to keep
the mprotect in the name. 

Thanks for bringing it up. It would be good to hear more
thoughts on this.

