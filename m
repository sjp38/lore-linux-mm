Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B1ADC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:07:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 259612183E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 17:07:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 259612183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7E616B000C; Fri, 14 Jun 2019 13:07:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2EB76B000D; Fri, 14 Jun 2019 13:07:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9133A6B0269; Fri, 14 Jun 2019 13:07:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58BF86B000C
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 13:07:20 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d19so1957911pls.1
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:07:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=KpqX5I4D4i4/2BGHt36UAxpem5y5cTRgTVQ/M67Smfk=;
        b=L51UxaspMKhIlC9zePnb7RhbVEjqvnR8j0gvfkENxX2Dvo4MlamweVqyLomt+PxzOn
         E43W3YIoLQ1cxicDFWfMiChjNOAiWgzTlSLo838T3c6r+Tc2Xxbt+VbMZqKzFuamGx8C
         9A55jnfCdHL+47mO0N5X2AVYCOvxmPPa8wdQ2/sKrf9PHqqpj0kZMhTwGSwCFdz6Ps8S
         gVzAVV2FgiN0hvRUBDOKBr8Y2TjcZIKvxgG4mRKieqEKs7Nd0ImLbiFMt8/RdMlmMvUD
         ZMKUhhsbrO5KWVLTeUskH2vNIpcOncadU2OkTGOhYZm9PSKmjZBlB8xrH/omAkob1I/+
         aTNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUB6WG2ZtyFTIj4Gw1P0G/wJgU1UfTGjn5ZsP8DdLPceMEpNvAJ
	uq3oAAm/n0WFvp1WDsSyWBNCfKCccAQ1YG1lemJ2YCE0WVyQ1sODXng00G1RNRCKW/mfdixL1Ob
	TYf8vfHCx9gRXi30oWMfIFCPWxXyhQ+3rVqJEzLigZmR4XA4HcxWuEq57VcxIXi4OBA==
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr28613971plb.139.1560532040032;
        Fri, 14 Jun 2019 10:07:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2i19+l2RX8RTbQlYF8P5b6DwqL6Se1Wh855Yl5G9/iz6fCQRXn3qrNNlkt9YuI+7JlkKJ
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr28613934plb.139.1560532039391;
        Fri, 14 Jun 2019 10:07:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560532039; cv=none;
        d=google.com; s=arc-20160816;
        b=aqHUnlmOy7uTAGizjSfPzpQvLjlPMZZ6a7fE7pK10zxfZ9bYUFvqXcTq9k4MFk+ssX
         2rObXj0JdY550WQhcgBak0KyB/AuiSsfbFHhFhfEehovkr5l5e8i+pnUcdFZGaB1tSZT
         mg+NiUqIUWFTxqXEdMik1TIRnMpHG8R7Ni9LUi83lYi5EsMYFDP/MMx0UisdR6aIE1FX
         VjPH2Iz2C2+AIlSxcDrhm7o/nT8VMjJ09tur4/SmoDzsNMIhdxxcqUyy5KKEws2P6fDn
         uTA7bw9qb6oiRDHDN7LtqA85B9lE3Gim2rNyiYGRFFQoBdBgVxKTFNDxIccgSDowK5d7
         xF6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=KpqX5I4D4i4/2BGHt36UAxpem5y5cTRgTVQ/M67Smfk=;
        b=fTJIo485iaNKDI9rIQh2fnm9o9Apb6bF4VVZWOuuW1i0xpR/3qyY6ulja0CttJvL2N
         mjS0DTswwopcicvL5xdPFuwFAxZ9FGm7zTWaJJEePh3Fl7ET5nQqWXVmTf//BOdgeWsH
         bcxoM0k6rYBiidwVli12QztCN8gPJeUPuZTgIxOezsr1AKjrO41Hxv1gsl0DuzIbcq6o
         tOe8ye9riHSVsZGYvt5pJ3KEAhbUS4hIZC4xzTW4EayaTgv3EDTlHfIPWgXB8B4VWttZ
         oMVSdPmAJfDkgwIZYg2R90wf7Tw2D197b5uMhARlFz9id82dXeVPX0V6n8Oxe0vZY7/6
         Hi4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id x3si2691418plv.26.2019.06.14.10.07.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 10:07:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 10:07:18 -0700
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Jun 2019 10:07:18 -0700
Date: Fri, 14 Jun 2019 10:10:25 -0700
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
Subject: Re: [PATCH, RFC 26/62] keys/mktme: Move the MKTME payload into a
 cache aligned structure
Message-ID: <20190614171025.GA5917@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-27-kirill.shutemov@linux.intel.com>
 <20190614113523.GC3436@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614113523.GC3436@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 01:35:23PM +0200, Peter Zijlstra wrote:
> On Wed, May 08, 2019 at 05:43:46PM +0300, Kirill A. Shutemov wrote:
> 
> > +/* Copy the payload to the HW programming structure and program this KeyID */
> > +static int mktme_program_keyid(int keyid, struct mktme_payload *payload)
> > +{
> > +	struct mktme_key_program *kprog = NULL;
> > +	int ret;
> > +
> > +	kprog = kmem_cache_zalloc(mktme_prog_cache, GFP_ATOMIC);
> 
> Why GFP_ATOMIC, afaict neither of the usage is with a spinlock held.

Got it. GFP_ATOMIC not needed.
That said, this is an artifact of reworking the locking, and that 
locking may need to change again. If it does, will try to pre-allocate
rather than depend on GFP_ATOMIC here.

> 
> > +	if (!kprog)
> > +		return -ENOMEM;
> > +
> > +	/* Hardware programming requires cached aligned struct */
> > +	kprog->keyid = keyid;
> > +	kprog->keyid_ctrl = payload->keyid_ctrl;
> > +	memcpy(kprog->key_field_1, payload->data_key, MKTME_AES_XTS_SIZE);
> > +	memcpy(kprog->key_field_2, payload->tweak_key, MKTME_AES_XTS_SIZE);
> > +
> > +	ret = MKTME_PROG_SUCCESS;	/* Future programming call */
> > +	kmem_cache_free(mktme_prog_cache, kprog);
> > +	return ret;
> > +}

