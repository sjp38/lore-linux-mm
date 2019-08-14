Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C5AFC32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 17:10:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B0C6208C2
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 17:10:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B0C6208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E84906B0003; Wed, 14 Aug 2019 13:10:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E35AE6B0005; Wed, 14 Aug 2019 13:10:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4C9C6B0006; Wed, 14 Aug 2019 13:10:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0135.hostedemail.com [216.40.44.135])
	by kanga.kvack.org (Postfix) with ESMTP id B39406B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 13:10:08 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6DCFE180AD7C1
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:10:08 +0000 (UTC)
X-FDA: 75821671296.14.sheep15_5874cf48fb71d
X-HE-Tag: sheep15_5874cf48fb71d
X-Filterd-Recvd-Size: 4029
Received: from mga17.intel.com (mga17.intel.com [192.55.52.151])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 17:10:07 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Aug 2019 10:10:06 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,386,1559545200"; 
   d="scan'208";a="376806157"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by fmsmga006.fm.intel.com with ESMTP; 14 Aug 2019 10:10:05 -0700
Message-ID: <a47dd0338ff37ebaa7888f291d05a5fccf1cb44b.camel@intel.com>
Subject: Re: [PATCH v8 15/27] mm: Handle shadow stack page fault
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML
 <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION"
 <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch
 <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd
 Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Borislav
 Petkov <bp@alien8.de>,  Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann
 Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit
 <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek
 <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,  Dave Martin
 <Dave.Martin@arm.com>
Date: Wed, 14 Aug 2019 10:00:27 -0700
In-Reply-To: <bf8a6390-97a6-1ab6-90ef-6399437ed38c@intel.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
	 <20190813205225.12032-16-yu-cheng.yu@intel.com>
	 <CALCETrVKbqzivPfUOiGi5efHUpEsfPkNzP0CrmAZzcwUgf7quA@mail.gmail.com>
	 <eabd0c16bd2028ad9fef8d10ddf570b3a10d5680.camel@intel.com>
	 <bf8a6390-97a6-1ab6-90ef-6399437ed38c@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-08-14 at 09:48 -0700, Dave Hansen wrote:
> On 8/14/19 9:27 AM, Yu-cheng Yu wrote:
> > On Tue, 2019-08-13 at 15:55 -0700, Andy Lutomirski wrote:
> > > On Tue, Aug 13, 2019 at 2:02 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > > > When a task does fork(), its shadow stack (SHSTK) must be duplicated
> > > > for the child.  This patch implements a flow similar to copy-on-write
> > > > of an anonymous page, but for SHSTK.
> > > > 
> > > > A SHSTK PTE must be RO and dirty.  This dirty bit requirement is used
> > > > to effect the copying.  In copy_one_pte(), clear the dirty bit from a
> > > > SHSTK PTE to cause a page fault upon the next SHSTK access.  At that
> > > > time, fix the PTE and copy/re-use the page.
> > > 
> > > Is using VM_SHSTK and special-casing all of this really better than
> > > using a special mapping or other pseudo-file-backed VMA and putting
> > > all the magic in the vm_operations?
> > 
> > A special mapping is cleaner.  However, we also need to exclude normal [RO +
> > dirty] pages from shadow stack.
> 
> I don't understand what you are saying.
> 
> Are you saying that we need this VM_SHSTK flag in order to exclude
> RO+HW-Dirty pages from being created in non-shadow-stack VMAs?

We use VM_SHSTK for page fault handling (the special-casing).  If we have a
special mapping, all these become cleaner (but more code).  However, we still
need most of the PTE macros (e.g. ptep_set_wrprotect, PAGE_DIRTY_SW, etc.).

Yu-cheng

