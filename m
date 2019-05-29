Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EC46C28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:08:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0DA224029
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:08:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0DA224029
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 777156B0266; Wed, 29 May 2019 14:08:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 727E76B026A; Wed, 29 May 2019 14:08:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C8936B026B; Wed, 29 May 2019 14:08:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 259866B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:08:23 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d2so2062461pla.18
        for <linux-mm@kvack.org>; Wed, 29 May 2019 11:08:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CONB8rVSRnWRj9gZKbHMvgz8FVNQk4hmsA8tU4Qc8fA=;
        b=JYXbgWgAT8nCnJYy45NZuI4rTOKfq0+Q5DeKlWEm1+4FBBT7L3swZAK5cu3Sj9oOR4
         DC9Xr1LzfEgFea2BUjLKELrl2stwthUR27xk9qZ7FJoAxmDFIWpdOHkqqlWmURkFCKxI
         COYIymkX70otWnSx4kc48GCE95S96eNXoVQkFJ7Vnax62IhEhvQitaP1SP1x2L33kwLE
         uBwpJLemIo21AbVDMntUqjaESQ6o84us8KwSsWeciDo2Y5dSbRC+udke5nmVqC0dW6Q8
         T0poj9b5Lg1TdWpQH2nF5HmeG9SMmsX2FG8PL6yl5uLqNFPbNz861r9QlTpaEj712aTL
         ABRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX7L0J18aTpBQCM0vllReUUA+aaLf02Kdv5TdYs6yPP7A9XYGls
	yyunPhU+7q967egqv5BpRu+NEqq+ORMUZHNP66BRzHcNI1y/JzG3z7oyhXm2JWxnSQ+vOHZKijy
	JdM/Xdyd4SHiBLXQJcL5RBbLwLT8Zl09pbj91WgNErqt65F7BuZi86gx1qm9BhGz9Gw==
X-Received: by 2002:a65:624f:: with SMTP id q15mr3523283pgv.436.1559153302805;
        Wed, 29 May 2019 11:08:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQN7HMiSvpQlDN+i1S+V0sTrBxrOR4jfn7FpXVSUnumKRd/k9myYiQMZZaUdBHnmvx1iTD
X-Received: by 2002:a65:624f:: with SMTP id q15mr3523210pgv.436.1559153302082;
        Wed, 29 May 2019 11:08:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559153302; cv=none;
        d=google.com; s=arc-20160816;
        b=Bo0pfMRH6a58aeGMvwvceYwJ+uABM3XpVQtse8gc8XD2G+NLM6aBKns6FQ7TtX5Og1
         NDJO6sE8/O5RoKHjRnoVJLfA1OH7MASjJ39alNjhbDpGet5KmhrC9gNI1JJs7U82oTWu
         SuTUZ7GBVh+FJC2OluF+NYPmWA5AdxO/sFAbl5x3sQaV5pmTuJu1SR4SHOtAAYr0ad9C
         e/jHoE6FyP2JPz6ni+tj4y3Vwww6vYNKJZ/MtzgNCNEmCCwEnFsxHA4KczpY19VdinYG
         z6/Qx/8vFlXcrfohJ0fGZef26LEzVVTMCrPuh3LVdcJdV+Ay4QaaDQN4hUhvtO8tqUCI
         sAmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CONB8rVSRnWRj9gZKbHMvgz8FVNQk4hmsA8tU4Qc8fA=;
        b=0pnqkuIUPW0YCGrdjtm52J/tEiI9GFWXM4Krpwzy0IX8fZX17rCPGEfLoxdLsgimVZ
         CNTDTuNKTUhnCzE4RNdxRnpdyhWj5ceE6SVtmqBLJ3kbxwuxFgskKnxnwItCJ2JwKvFD
         Domu87JQcbBOlSTG5VxxwVaWniTx3qjR7pWpoxCZNfR2RX5qO4At0RW0DZFcSfuFjlD6
         bLzGdAtz04LgJ01MppXINI8Dg/E1DKw7RTTtwvi0a9OD67mfLvZNXre6oyn3Qpr5KfUw
         BZkPRvAj6qjHIVRvAwggw33DcdG8c/SiY9b9RQJ7boVSRqMQfpqg7KWcsDDbp/gJ3hbt
         rLgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id f9si416680pgs.115.2019.05.29.11.08.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 11:08:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alison.schofield@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alison.schofield@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 May 2019 11:08:21 -0700
X-ExtLoop1: 1
Received: from alison-desk.jf.intel.com ([10.54.74.53])
  by fmsmga004.fm.intel.com with ESMTP; 29 May 2019 11:08:20 -0700
Date: Wed, 29 May 2019 11:12:11 -0700
From: Alison Schofield <alison.schofield@intel.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
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
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 43/62] syscall/x86: Wire up a system call for MKTME
 encryption keys
Message-ID: <20190529181211.GA32533@alison-desk.jf.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-44-kirill.shutemov@linux.intel.com>
 <20190529072136.GD3656@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529072136.GD3656@rapoport-lnx>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 10:21:37AM +0300, Mike Rapoport wrote:
> On Wed, May 08, 2019 at 05:44:03PM +0300, Kirill A. Shutemov wrote:
> > From: Alison Schofield <alison.schofield@intel.com>
> > 
> > encrypt_mprotect() is a new system call to support memory encryption.
> > 
> > It takes the same parameters as legacy mprotect, plus an additional
> > key serial number that is mapped to an encryption keyid.
> 
> Shouldn't this patch be after the encrypt_mprotect() is added?

COND_SYSCALL(encrypt_mprotect) defined in kernel/sys_ni.c, allowed
it to build in this order, but the order is not logical. Thanks for
pointing it out. I will reorder the two patches.

Alison

