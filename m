Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92261C0650E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:55:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C17D2089E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:55:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C17D2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2CC36B000A; Tue, 11 Jun 2019 13:55:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDC716B000D; Tue, 11 Jun 2019 13:55:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA4D76B0010; Tue, 11 Jun 2019 13:55:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 751A26B000A
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:55:40 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z10so9576629pgf.15
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:55:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=s8XiuS/Ar9B5408ANwA1TcpILkK7Dk8O5JFpFAfdw8U=;
        b=AqzTI9HCGIa2Ypxh+tJTasS8MTT2ITQeAYvC+MVZoeNNFMP8U4h/r4bjf6yFM68N73
         HfnoGT7pU18ftdwhT0HB4JTGGnoPKXvxOf7XtOciprg55cGEGo8OISlcJdnu3fJ9xiWA
         +mgFhZWTk1+RpG5Y8hQhX/fDgF4EL1npGK9+rGE1UnVneXZjZ3xIorkmNMJJ4lxxC6nj
         +a1i4gaHX+hleRHiXkE5w+eYN8CMos/P3fjcLWPN4zm81J6Ea+16Uf0jxTkaZR2uWXRX
         viagPkYyPqZR8pmI12OnlgX7FxcMOBDw3GrFaKGmMK5UtBJvzosFlDBqIdMURZUm4Luh
         mHDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUga42QIPJ/pGXRXggpj/84ZTu0iSWQMtBia35ttSMisBT0Qpzl
	a7qvpWo0bBH/4qUMlmyAk550swBBWlOWtTIJXJY8IKG7fUmQ/Jpo/HSPYUUVcZh/ktXgY1SvmgQ
	Etl7dBDBbMWBvOaZ8wxWFGmRwmSom0/ke6LFfYC0LQgZ5vhB1bXRBQwC1Ipj2NzF+Ig==
X-Received: by 2002:a17:902:8204:: with SMTP id x4mr75607052pln.226.1560275740172;
        Tue, 11 Jun 2019 10:55:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRnPKAMy1DoTsVSuP5gOGBPxdtHNhXsmYqHFFYZd+uIhDqSALOYbQ/oACqyFHtKbY893Qz
X-Received: by 2002:a17:902:8204:: with SMTP id x4mr75606996pln.226.1560275739416;
        Tue, 11 Jun 2019 10:55:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560275739; cv=none;
        d=google.com; s=arc-20160816;
        b=fBl1igi6RWObT77d0H8cs23If7AUGS0ZLNElI0fz8IIm9HnzHrUXE3khqzjvUUZiLo
         BVfOuUl3Mry6agYsGsf2dJucxsY7fsPxgsWGfYfLMnBTCKEKyWSWL3u8Etx09N7MOzb0
         iEFvFy6jDPuF0xFToM+GwGGuaiCfipitB1YO7SKrffwIrQ21Pc0NoXQ+Iu0nVhY0xqBN
         SzsnMPRl8kMGPJyIQXVdFK/iuW4QrCAUnZN3qd03f1Se249pfY4KirjhMakmc896aqLV
         sQbvflxL2pb6ndPdE1bxfUyveRFcqBK4IMp1srWkCr1TMhoeidwfoGXoBRviTlhjQLoj
         Modw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=s8XiuS/Ar9B5408ANwA1TcpILkK7Dk8O5JFpFAfdw8U=;
        b=zntN8wbOqXxteaz+n49H1kAX/Foya8tEQ0/U9G1vFOYMuNMf/NWm+s/BPROl8S0CMv
         dO0nTEn8Ysqjb6VhTc7NigZjOGQeyEMtQtJp77amT8QCEW+prVsjXwBUw6K+r4sJYgNK
         zfc3We7cYqqgiS++WtFlfC/xLxmsqpL0DQpENrJ0jzqBWlQp4Hg2+qlktPuWNQNvZsnC
         YTahhu/lDGdp7Jw1NVDjL/s+ItTKd4k89EmrvxlsF4U48DIKrJV4cdnPYc96kAbLNxAv
         WxIgXPtgSFQrKY1ZvNs1LxGI0ZOaNNzWqrgxtIf5WFFuJed2hwzikBwcrz93sRyrC8o3
         I8bg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id az12si12836110plb.165.2019.06.11.10.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 10:55:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jun 2019 10:55:38 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.198.151]) ([10.7.198.151])
  by orsmga004.jf.intel.com with ESMTP; 11 Jun 2019 10:55:38 -0700
Subject: Re: [PATCH v7 25/27] mm/mmap: Add Shadow stack pages to memory
 accounting
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
 "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>,
 Borislav Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>,
 "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
 Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
 Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>,
 Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>,
 Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
 <20190606200646.3951-26-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <1cfc7396-ca90-1933-34ad-b3d43ae52e08@intel.com>
Date: Tue, 11 Jun 2019 10:55:38 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606200646.3951-26-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/6/19 1:06 PM, Yu-cheng Yu wrote:
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1703,6 +1703,9 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
>  	if (file && is_file_hugepages(file))
>  		return 0;
>  
> +	if (arch_copy_pte_mapping(vm_flags))
> +		return 1;
> +
>  	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
>  }
>  
> @@ -3319,6 +3322,8 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
>  		mm->stack_vm += npages;
>  	else if (is_data_mapping(flags))
>  		mm->data_vm += npages;
> +	else if (arch_copy_pte_mapping(flags))
> +		mm->data_vm += npages;
>  }

This classifies shadow stack as data instead of stack.  That seems a wee
bit counterintuitive.  Why did you make this choice?

