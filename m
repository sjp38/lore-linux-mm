Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BC4CC468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:25:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E90F8214AE
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 16:25:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E90F8214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99FEF6B026B; Fri,  7 Jun 2019 12:25:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 950A56B026E; Fri,  7 Jun 2019 12:25:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 841536B026F; Fri,  7 Jun 2019 12:25:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4FA6B026B
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 12:25:10 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so1808763pfv.18
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 09:25:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fqZYQrrzFI1K/T5Ovd1jNF/j9A9kDqy2YB6vahLoPIQ=;
        b=J57mMfDhjLLKTDcLvc+PJ4FJ4BZFElXfjNIqrnMBwcamgzAhyoHPcMYQG9YyCfpAqK
         b4HPVnjInwDlkoHr7JcBt0M6iYSo2FUKftnrEfb3bWgioisc2/TDscu2fXOPWc5CGlyg
         EsxIKLDeHxOtEWncBJuhZKsLIdTiCc3MMSnc3iJ10M/2ku1vu3Amy+PUP6Xt0WtjvbQn
         0vnngPdpx3GtgF/n7EQ4RRj5iOiFKHg84FNZqBztQMiF6LVvu4M2z3jRML3q+6xWUY9I
         u28lqNECNbx9NbpbN82+P4G77NicklNHOS9WxlFRIh2uQm2XZPgH5QcNwN9vKZqlKLCu
         Zong==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVI3NX/sPkqyyn3wZBQCE5gpPabedUEhXy30WsRwtsKmQgy1SH5
	Fag9DKSZIsZ8XyMsqP1QV8m5Fn4cqrHM5EtKnJ+7ULNzVacTzE9i6s7zlNqaxv6N7NKDMhDSIuw
	f870Zu/BknBunm2nYI1/aBVEY9tB9Z3A57MasiU8pu+x1c5PdVxPFdgDKRVzuLfIamg==
X-Received: by 2002:a17:902:6ac6:: with SMTP id i6mr42649883plt.233.1559924709995;
        Fri, 07 Jun 2019 09:25:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJb3H1f+bfm0JX58uYczdhMD0dbfd33wXukmgsaMP/1tcQCpYmullk5GIQLE4OpTKtuswa
X-Received: by 2002:a17:902:6ac6:: with SMTP id i6mr42649763plt.233.1559924708982;
        Fri, 07 Jun 2019 09:25:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559924708; cv=none;
        d=google.com; s=arc-20160816;
        b=X9tG/3YIg+Q7BZFPoet7om6qPU3PKOTdxN29mgdUObrep8/5ceMzn7Aj3Cy0n6GdtU
         DaACOhtIx3hfHS7Y9RnSX5B7GofnwgDzh4EqjRWCHLLSb/Evj1bZljp0NPhO4wL9nDcX
         5ms8VYafrj96jcfK4VNnjzN9r8mEtrmK92EXcL2Src9teJrTJkWPtyKpkQWd4TGfRkFP
         6VuPG+e8WitAQccirK7yrf8kia1efnLCN4U48NyjfR4UPllULpFdFjp2fAhVHUlWeXpp
         qWM4gxs6OnDjr8EOPRjDJTthAtIVoD60hFNXL54nUljWGPbxSbDfmzarMURC27PpwG2+
         GePw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=fqZYQrrzFI1K/T5Ovd1jNF/j9A9kDqy2YB6vahLoPIQ=;
        b=GCZbFhRMHhofd1cerp2JcnUQzO2iYC3IJzVOICwJ7ujBXOA8aZcZzvbdvC+4Vuxgx3
         zRF8227UpnkNQJQ+G673M+SdPLXek/SLuM+g/twxg7G5VjYuRMO03BZWZ7lBIxJ8qQhV
         sG9yTVbrjt3VHr3thRkzzEZwu05OSb3nLP2KwYQXlUXMWeDD+uqbY+NLjUsGxs1jyMrn
         uY4teIKHIdyCx5lWDYlBZCpibM5K1klasDZ6a6L/D1R1UK1dkjwebo/+lpEmuHzU6CEv
         ELruyso5zHynjP460oxXx20q1yG465sSFpB2iGvTxt/DUwNclXSpLVBl1fZ1+F3PZEMM
         6xqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f17si2190529pjq.18.2019.06.07.09.25.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 09:25:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 09:25:08 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,563,1557212400"; 
   d="scan'208";a="182720042"
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga002.fm.intel.com with ESMTP; 07 Jun 2019 09:25:08 -0700
Message-ID: <1b5778f8f1336ad7a63f4621f189b7f04a56a9ed.camel@intel.com>
Subject: Re: [PATCH v7 22/27] binfmt_elf: Extract .note.gnu.property from an
 ELF file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>,  Mike Kravetz <mike.kravetz@oracle.com>, Nadav
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,  Pavel Machek
 <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar"
 <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Dave Martin <Dave.Martin@arm.com>
Date: Fri, 07 Jun 2019 09:17:06 -0700
In-Reply-To: <20190607075822.GR3419@hirez.programming.kicks-ass.net>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
	 <20190606200646.3951-23-yu-cheng.yu@intel.com>
	 <20190607075822.GR3419@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-07 at 09:58 +0200, Peter Zijlstra wrote:
> On Thu, Jun 06, 2019 at 01:06:41PM -0700, Yu-cheng Yu wrote:
> > An ELF file's .note.gnu.property indicates features the executable file
> > can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> > indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> > GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> > 
> > With this patch, if an arch needs to setup features from ELF properties,
> > it needs CONFIG_ARCH_USE_GNU_PROPERTY to be set, and a specific
> > arch_setup_property().
> > 
> > For example, for X86_64:
> > 
> > int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
> > {
> > 	int r;
> > 	uint32_t property;
> > 
> > 	r = get_gnu_property(ehdr, phdr, f, GNU_PROPERTY_X86_FEATURE_1_AND,
> > 			     &property);
> > 	...
> > }
> > 
> > Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> 
> Did HJ write this patch as suggested by that SoB chain? If so, you lost
> a From: line on top, if not, the SoB thing is invalid.

I will fix that.

Yu-cheng

