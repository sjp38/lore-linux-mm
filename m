Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95233C3A5A0
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 01:02:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 633FA22CE8
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 01:02:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 633FA22CE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F16486B0007; Mon, 19 Aug 2019 21:02:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC6566B0008; Mon, 19 Aug 2019 21:02:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDB1D6B000A; Mon, 19 Aug 2019 21:02:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id B828E6B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:02:04 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5EEC4181AC9BF
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:02:04 +0000 (UTC)
X-FDA: 75841004568.03.dolls72_8645a4bd51916
X-HE-Tag: dolls72_8645a4bd51916
X-Filterd-Recvd-Size: 4057
Received: from mga04.intel.com (mga04.intel.com [192.55.52.120])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:02:02 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Aug 2019 18:02:00 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,407,1559545200"; 
   d="scan'208";a="180537314"
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.41])
  by orsmga003.jf.intel.com with ESMTP; 19 Aug 2019 18:02:00 -0700
Date: Mon, 19 Aug 2019 18:02:00 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v8 18/27] mm: Introduce do_mmap_locked()
Message-ID: <20190820010200.GI1916@linux.intel.com>
References: <20190813205225.12032-1-yu-cheng.yu@intel.com>
 <20190813205225.12032-19-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813205225.12032-19-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 01:52:16PM -0700, Yu-cheng Yu wrote:
> There are a few places that need do_mmap() with mm->mmap_sem held.
> Create an in-line function for that.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  include/linux/mm.h | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index bc58585014c9..275c385f53c6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2394,6 +2394,24 @@ static inline void mm_populate(unsigned long addr, unsigned long len)
>  static inline void mm_populate(unsigned long addr, unsigned long len) {}
>  #endif
>  
> +static inline unsigned long do_mmap_locked(struct file *file,
> +	unsigned long addr, unsigned long len, unsigned long prot,
> +	unsigned long flags, vm_flags_t vm_flags, struct list_head *uf)
> +{
> +	struct mm_struct *mm = current->mm;
> +	unsigned long populate;
> +
> +	down_write(&mm->mmap_sem);
> +	addr = do_mmap(file, addr, len, prot, flags, vm_flags, 0,
> +		       &populate, uf);
> +	up_write(&mm->mmap_sem);
> +
> +	if (populate)
> +		mm_populate(addr, populate);
> +
> +	return addr;
> +}

Any reason not to put this in cet.c, as suggested by PeterZ?  All of the
calls from CET have identical params except for @len, e.g. you can add
'static unsigned long cet_mmap(unsigned long len)' and bury most of the
copy-paste code in there.

https://lkml.kernel.org/r/20190607074707.GD3463@hirez.programming.kicks-ass.net

> +
>  /* These take the mm semaphore themselves */
>  extern int __must_check vm_brk(unsigned long, unsigned long);
>  extern int __must_check vm_brk_flags(unsigned long, unsigned long, unsigned long);
> -- 
> 2.17.1
> 

