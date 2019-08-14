Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46B3AC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:30:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1214220665
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:30:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1214220665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF98E6B0003; Wed, 14 Aug 2019 12:30:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA9B96B0005; Wed, 14 Aug 2019 12:30:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 997856B000A; Wed, 14 Aug 2019 12:30:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0167.hostedemail.com [216.40.44.167])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1826B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:30:04 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 265F0181AC9AE
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:30:04 +0000 (UTC)
X-FDA: 75821570328.04.show25_1d7c56ad86a44
X-HE-Tag: show25_1d7c56ad86a44
X-Filterd-Recvd-Size: 2638
Received: from mga12.intel.com (mga12.intel.com [192.55.52.136])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:30:01 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Aug 2019 09:30:00 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,385,1559545200"; 
   d="scan'208";a="178211198"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga007.fm.intel.com with ESMTP; 14 Aug 2019 09:30:00 -0700
Message-ID: <699fe0a2c2331af0d45a3516d9422d5ed5b59a99.camel@intel.com>
Subject: Re: [PATCH v8 09/27] mm/mmap: Prevent Shadow Stack VMA merges
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar
 <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org,  linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski
 <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>,  Borislav
 Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, 
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,  Nadav
 Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek
 <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,  Dave Martin
 <Dave.Martin@arm.com>
Date: Wed, 14 Aug 2019 09:20:21 -0700
In-Reply-To: <5ba3d1b3-5587-e7dd-b9de-9a954172d31f@intel.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
	 <20190813205225.12032-10-yu-cheng.yu@intel.com>
	 <5ba3d1b3-5587-e7dd-b9de-9a954172d31f@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-08-13 at 15:34 -0700, Dave Hansen wrote:
> On 8/13/19 1:52 PM, Yu-cheng Yu wrote:
> > To prevent function call/return spills into the next shadow stack
> > area, do not merge shadow stack areas.
> 
> How does this prevent call/return spills?

It does not.  I will fix the description.

Yu-cheng

