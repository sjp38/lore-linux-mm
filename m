Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19AA1C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:17:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D86672332B
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:17:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D86672332B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A43E36B0271; Tue, 20 Aug 2019 12:17:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F5186B0272; Tue, 20 Aug 2019 12:17:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E3AC6B0273; Tue, 20 Aug 2019 12:17:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB476B0271
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 12:17:45 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1DCCB181AC9D3
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:17:45 +0000 (UTC)
X-FDA: 75843312090.26.key14_7da17f9c3c945
X-HE-Tag: key14_7da17f9c3c945
X-Filterd-Recvd-Size: 4106
Received: from mga07.intel.com (mga07.intel.com [134.134.136.100])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:17:43 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Aug 2019 09:17:40 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,408,1559545200"; 
   d="scan'208";a="169130943"
Received: from yyu32-desk1.sc.intel.com ([10.144.153.205])
  by orsmga007.jf.intel.com with ESMTP; 20 Aug 2019 09:17:39 -0700
Message-ID: <fb058c3d56bb070706aa5f8502b4d8f0da265b74.camel@intel.com>
Subject: Re: [PATCH v8 18/27] mm: Introduce do_mmap_locked()
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Sean Christopherson <sean.j.christopherson@intel.com>
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
 <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap
 <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin
 <Dave.Martin@arm.com>
Date: Tue, 20 Aug 2019 09:08:34 -0700
In-Reply-To: <20190820010200.GI1916@linux.intel.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
	 <20190813205225.12032-19-yu-cheng.yu@intel.com>
	 <20190820010200.GI1916@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-08-19 at 18:02 -0700, Sean Christopherson wrote:
> On Tue, Aug 13, 2019 at 01:52:16PM -0700, Yu-cheng Yu wrote:
> > There are a few places that need do_mmap() with mm->mmap_sem held.
> > Create an in-line function for that.
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> >  include/linux/mm.h | 18 ++++++++++++++++++
> >  1 file changed, 18 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index bc58585014c9..275c385f53c6 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -2394,6 +2394,24 @@ static inline void mm_populate(unsigned long addr,
> > unsigned long len)
> >  static inline void mm_populate(unsigned long addr, unsigned long len) {}
> >  #endif
> >  
> > +static inline unsigned long do_mmap_locked(struct file *file,
> > +	unsigned long addr, unsigned long len, unsigned long prot,
> > +	unsigned long flags, vm_flags_t vm_flags, struct list_head *uf)
> > +{
> > +	struct mm_struct *mm = current->mm;
> > +	unsigned long populate;
> > +
> > +	down_write(&mm->mmap_sem);
> > +	addr = do_mmap(file, addr, len, prot, flags, vm_flags, 0,
> > +		       &populate, uf);
> > +	up_write(&mm->mmap_sem);
> > +
> > +	if (populate)
> > +		mm_populate(addr, populate);
> > +
> > +	return addr;
> > +}
> 
> Any reason not to put this in cet.c, as suggested by PeterZ?  All of the
> calls from CET have identical params except for @len, e.g. you can add
> 'static unsigned long cet_mmap(unsigned long len)' and bury most of the
> copy-paste code in there.
> 
> https://lkml.kernel.org/r/20190607074707.GD3463@hirez.programming.kicks-ass.ne
> t

Yes, I will do that.  I thought this would be useful in other places, but
currently only in mpx.c.

Yu-cheng

