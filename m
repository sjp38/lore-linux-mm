Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B48D5C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 20:44:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 647C12086D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 20:44:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 647C12086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCE466B0005; Mon,  5 Aug 2019 16:44:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7DFD6B0006; Mon,  5 Aug 2019 16:44:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6D2E6B0007; Mon,  5 Aug 2019 16:44:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 803516B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 16:44:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r142so54196424pfc.2
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 13:44:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wsUDVBChK+M8fcBKPuwuj27qHFq9S3uCU5NzsNKzh4M=;
        b=k1a3b1oVcTQ62cY6GmgpnLZyebR210gClxI3XIeAasj2JwBF1cRYHwgPjKRYhUkFkA
         IRUEeWQRTtzUpxSiWTR/2clvtAAuH08nntTHQYvCZfwM1dn+BNC9JkfwwVkzhwHWu3l/
         mwgpKvSygoZy7Ry4f4V2Ygrt4mA54Wx1Itf1ar56raRJ5liuObFQdDzllC0avg+2/6dj
         B4SnPKkmM+TPJLEZLarMeTWEr0DwWx8UfqBFmEuO6CQ/WyVkkGSwy15GSNaGw90w0NQX
         zkGIpNAzZ4vE3T9xsObY7WvvWmdW1ICjokP1qJX2GzbMmjJZkRoDnyhsr86BPEZnKShB
         QeAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUYgWFD9JD5RJWXPJLVSWJONj7zMlyLNuixc8ybZW+WAcfju35G
	88hsbxw/8raOfhWDnq8uscUBf9ADPDbTvQ2GyrgISTdRHeBL/KQ0M6hkZmVT6sZ2iHzHEP46C37
	gKJBvSd5iq02nxCPXJhnvIry6UthH5Y/klXq/Fg7Uybo142uSEs0cPJIMLBRuln7GZw==
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr141657733plp.95.1565037849210;
        Mon, 05 Aug 2019 13:44:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXfp7nVMmJhnjsNiEknCkCBstQYcksfH20+wrlXQ7cO2IVQ+ojIbxpvWmaHrOl1nXyejR0
X-Received: by 2002:a17:902:9a04:: with SMTP id v4mr141657682plp.95.1565037848491;
        Mon, 05 Aug 2019 13:44:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565037848; cv=none;
        d=google.com; s=arc-20160816;
        b=ZDnlg1RknLbk9/cSlrw4kvyxxL+05CBeakUBGOeRkcQZRdh47ocVsOsk2by6mGNTAl
         qie6Lle/L7H7u8/A1wGYQPzSBBTjTil1lPdzOB7iQgxNyGlgTaSoZTedjOM2FXNR9I3P
         GntTjnliLNSa2S57+13vZ4Nqo30K7Y3GJbnbyuEsadL+67xKmAHNARQuM16Ada48CG7v
         OaYoPRu3A7njj3u9pzrH3k6ofFe5TMgFEpoU/BVwwDbYLQRd8SXNHBTrNpXRX5rM752l
         Wz1hXnd9yXh3x63kIrExgmifjC26pRJ8d5rdTx4Gprq1jyt1CvSZ06+KgNlg8jjRFT5v
         KfMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wsUDVBChK+M8fcBKPuwuj27qHFq9S3uCU5NzsNKzh4M=;
        b=09nBAxD2cebt+x+HWvioDiH+tJcPTkQzGJdtJPPmO1/ygSRdDERoZ68uCk4p4uszkL
         1hg+31CbDQGgUqFm/TZOrltgSlFb+oAqi/kwa1TjPKBJryBcy+Ibh90Jh8dznBAOLaBk
         jSIQ33gS6R78jnJPi+56PNlvmYKgMgRQRrdP6PjDb+nF/ADu9tBB/aA7GKuaDbZWbJRi
         n4Kau0kSps3PBqOntespC9/ISB3U5g1cbci+CVFCwH8pXyJ7LHberZuayig8gUwgcmge
         2pZhtKdMYdT03QAszBxDGt55mxnDNSSkXQIjIoIkTf7Y8DVhRWOHZA7RIURNm0E7sPRD
         lBGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id r8si47810343pgr.243.2019.08.05.13.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 13:44:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Aug 2019 13:44:07 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,350,1559545200"; 
   d="scan'208";a="373200445"
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by fmsmga005.fm.intel.com with ESMTP; 05 Aug 2019 13:44:06 -0700
Date: Mon, 5 Aug 2019 13:44:53 -0700
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
Subject: Re: [PATCHv2 57/59] x86/mktme: Document the MKTME Key Service API
Message-ID: <20190805204453.GB7592@alison-desk.jf.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
 <20190731150813.26289-58-kirill.shutemov@linux.intel.com>
 <20190805115837.GB31656@rotor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190805115837.GB31656@rotor>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 07:58:37AM -0400, Ben Boeckel wrote:
> On Wed, Jul 31, 2019 at 18:08:11 +0300, Kirill A. Shutemov wrote:
> > +	key = add_key("mktme", "name", "no-encrypt", strlen(options_CPU),
> > +		      KEY_SPEC_THREAD_KEYRING);
> 
> Should this be `type=no-encrypt` here? Also, seems like copy/paste from
> the `type=cpu` case for the `strlen` call.
> 
> --Ben

Yes. Fixed up as follows:

	Add a "no-encrypt' type key::

        char \*options_NOENCRYPT = "type=no-encrypt";

        key = add_key("mktme", "name", options_NOENCRYPT,
                      strlen(options_NOENCRYPT), KEY_SPEC_THREAD_KEYRING);

Thanks for the review,
Alison

