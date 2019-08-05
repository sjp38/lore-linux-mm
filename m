Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AC47C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 20:30:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36F54216F4
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 20:30:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36F54216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC62F6B0005; Mon,  5 Aug 2019 16:30:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B76286B0006; Mon,  5 Aug 2019 16:30:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A651D6B0007; Mon,  5 Aug 2019 16:30:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 702CA6B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 16:30:18 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g21so54246831pfb.13
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 13:30:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rPyXaFAVZ7AVV36zYzo2icT2RiHdu+UYjxl8ZZTBuMo=;
        b=WgkLDwqVIewkZRZRZJul9K81Www+k2aofjReRdgIA9D/pMnN927DTeQjeRikO+XvF/
         o2IQuorXAQiBk32em6hWSulJ/wFD7ZGpqbn6jRMB+tL7UJcTsddCD6Q4cUao0W2Ne5NC
         aU2BExKOs/SmXmJEvh4wp6cD/Qbj4OWi6zxIZCrt1rmKWIHWer/dlsasAE0tHgsUY3ik
         mStWyP81Sf7q5Gc9qNLneWEJR8NMXVbYPTxavaT4ygT2TRIcNWinsU9a6l3MXgCkipNm
         DvGs7IWucU427xW09tdqRQnSe5zRdszvH/mjRfdj75v9WmjAUapuw0jeaqUkbVaTgCaD
         YcBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUI7NWXtEk+8kOmnLN0AE0qxRAPS87nYuPyroBZjsTIdzCbrqas
	bn9pz+UNKU5cKxRCroCPJuCBzhiiMP+JaUQC2mor/hfps0D7+UV2NJxDv+O/NfotGoEkNX6Zkdh
	tGcAvM2+WJDYAROqGyrMWlVY2gFGzi8AcWaOsgSsYkn4lc3vIPFTOj4xp7tzJcwf9fA==
X-Received: by 2002:a17:902:e281:: with SMTP id cf1mr141463448plb.271.1565037018135;
        Mon, 05 Aug 2019 13:30:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4rCqUm0dryRUTmQwZ84VJgQVbwcMzrVK7dZQOsjahrGY1pMgU9Vn7Fa0DZichvFnfgloH
X-Received: by 2002:a17:902:e281:: with SMTP id cf1mr141463394plb.271.1565037017253;
        Mon, 05 Aug 2019 13:30:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565037017; cv=none;
        d=google.com; s=arc-20160816;
        b=YXLefWJKFaFuB6pFpYFHAz5MNxNIDVDXqus2iUyilzvJfWmEVS9kxi3omd9nzYtK3Q
         DGMRaxzpQ0rfaTUAs8CGPOqgIXNKeIbY6oGhuIflXr9UI57vlumNcZmiVrTwdvDJj6hI
         MnXL6AbPaqRTjNPbsfna7zvGkDbitDsG2Fsl5Le1pTuI8MfgjSsFg10c+wkve6SzZMYw
         /hr7wryEJqZyqZYCp4tlXMIx2W85B3ULeE7C7A3KKPHEDGpylsaSIJhoSJgnDOmQPW6T
         oBbU+tNuNXYvAbDpXoxKDNYdys9t/8NleDEgT1ia0c2/OhAWfFoJd0jgA7ZaUQfN25HN
         ZWJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rPyXaFAVZ7AVV36zYzo2icT2RiHdu+UYjxl8ZZTBuMo=;
        b=aM9O4fQpooDjK3Auv6T6SrsJ3lUB+JHDwEMVumG3nY28Jgy2XcJNiL3FOA1QiI2yms
         BSnuQCRe2akNbgivz5X1biBPDPDW3jTq/cmJoHHSrqbr8mfxWwlrkbW5gGrcvhM5uAif
         RnZ4PPUS106XBMy1CFGJ4YDpheN5I6KFyPyrGlyEdxHGizWC+aB5cxB1efZ4NfwXBJ9S
         De/cLn86eyhdmKB70btJwimjddg19TRl01sghfSrqh3hJVSIz756oNEXJXyBBCCBWLT7
         FFA3H+f55OOcXapIrUTWFsgiyYkYgbFXKPh69oHSRGlT2eJ0yCDPnovgwEft1CSbt9oA
         ydtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z7si43266251plk.350.2019.08.05.13.30.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 13:30:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Aug 2019 13:30:16 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,350,1559545200"; 
   d="scan'208";a="198086880"
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by fmsmga004.fm.intel.com with ESMTP; 05 Aug 2019 13:30:15 -0700
Date: Mon, 5 Aug 2019 13:31:02 -0700
From: Alison Schofield <alison.schofield@intel.com>
To: Ben Boeckel <mathstuf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 25/59] keys/mktme: Preparse the MKTME key payload
Message-ID: <20190805203102.GA7592@alison-desk.jf.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
 <20190731150813.26289-26-kirill.shutemov@linux.intel.com>
 <20190805115819.GA31656@rotor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805115819.GA31656@rotor>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 07:58:19AM -0400, Ben Boeckel wrote:
> On Wed, Jul 31, 2019 at 18:07:39 +0300, Kirill A. Shutemov wrote:
> > From: Alison Schofield <alison.schofield@intel.com>
> > +/* Make sure arguments are correct for the TYPE of key requested */
> > +static int mktme_check_options(u32 *payload, unsigned long token_mask,
> > +			       enum mktme_type type, enum mktme_alg alg)
> > +{
> > +	if (!token_mask)
> > +		return -EINVAL;
> > +
> > +	switch (type) {
> > +	case MKTME_TYPE_CPU:
> > +		if (test_bit(OPT_ALGORITHM, &token_mask))
> > +			*payload |= (1 << alg) << 8;
> > +		else
> > +			return -EINVAL;
> > +
> > +		*payload |= MKTME_KEYID_SET_KEY_RANDOM;
> > +		break;
> > +
> > +	case MKTME_TYPE_NO_ENCRYPT:
		if (test_bit(OPT_ALGORITHM, &token_mask))
			return -EINVAL;
> > +		*payload |= MKTME_KEYID_NO_ENCRYPT;
> > +		break;
> 
> The documentation states that for `type=no-encrypt`, algorithm must not
> be specified at all. Where is that checked?
> 
> --Ben
It's not currently checked, but should be. 
I'll add it as shown above.
Thanks for the review,
Alison

