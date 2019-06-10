Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA3E8C28EBD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 02:23:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB99E20820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 02:23:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB99E20820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B8276B0008; Sun,  9 Jun 2019 22:23:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36FDC6B0010; Sun,  9 Jun 2019 22:23:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27C716B0266; Sun,  9 Jun 2019 22:23:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CF34F6B0008
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 22:23:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d13so13054076edo.5
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 19:23:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Cw3jMaawpERIzFx9V/izJtDBjK0NX3WzIA7lubamf2M=;
        b=aq5zc7zfCeXH9CP9z3R8Iw8pjYlQ0dot+ThrNxu1X0SHUCz6UQ17HgOXah8fTSmSpH
         vHh53dk3G8Qr7XJxVr6C6PwNxrPL5SJlinJ20cLu2xsdcwFk1sE8ss+EoAooPoIZHhWC
         HMn1DPeksaQnBFfznPsSOaF1eZMLbO0pTVaQIqASZjhHdV8GtqBl14iP6MhJ4HZ70dLm
         4XqSe6IlB9eoGMJuksulKIigOvnPJ8XsKNGqGGMMdH9JnDVJTCzfOpE5T8ldPWPK/obi
         QA0Tk0u5PdGNQrlsriaQAfTGH0TUwJPQS6v4wNMY4hMd3yCQKQeqX1QNmAC7+K4rBFNq
         sYMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAV09vQaIz2QvfssVE1rZLd7CIe04E+mRZpOA+X1M4AKHViWt5n4
	sFzBWfxSKsc3kNdkXSIUA7mejZpX1JZqRXVXaIVNcETtX2yezA38MtRK8S1UoJJnMuJJ9aWtaww
	C1Hldn8y7LZdiWAWqBOyI76JUJCGjrF12Va3twhJJHsorAJp0luQpc9dy+f9JqNoeug==
X-Received: by 2002:a17:906:eb93:: with SMTP id mh19mr34295463ejb.42.1560133388348;
        Sun, 09 Jun 2019 19:23:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7v8VLm+L3JsflGNqshsVFM7/4hcCn+b1LWLit7nAxF1YCqLaq0E68Ld91wB7Umlxl1l9J
X-Received: by 2002:a17:906:eb93:: with SMTP id mh19mr34295427ejb.42.1560133387580;
        Sun, 09 Jun 2019 19:23:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560133387; cv=none;
        d=google.com; s=arc-20160816;
        b=JjF1eepiK4J7/fi4YC3OmE9IEsVsk9I7r4z2sYmrCEJoUSrpMKS1+cyIbQ5x1VDl2i
         p8KrOYQtAmA5ePFcS+5+zA57Ry/Qk+cpAgYtZeNbQtXyidd4/F3Fmrmx5OuTh0rdGyeU
         cfBcXv+JiLUIkOm6w+MRLVvkwoZcXCiKKoXMn5GhPZOe1pZoFODoea0CfULUS5Z10cW3
         YS0MUyjg9j+g+cex1E4TqCbuu1eWnxEeiUL4jnh0o1e8yhoLz9ks2lNqefcxfbIlozxG
         SFwcLH9YhS6GS+/f8lOmLaMn27x9USfpR/TlZ/mtVhkLzzB0PkAa8C5Inq1H/m8UTlvQ
         Ro9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Cw3jMaawpERIzFx9V/izJtDBjK0NX3WzIA7lubamf2M=;
        b=GyuwNM1k8w/XawkB6tzJq1xofaHNQ4l2lD+UPItB1Fse//vPUllt13Zdbde5XbfmxM
         DGUp+uxWpGBrhvNSMg5xA080wXsZcZRhgJaH+8P12E2RUSJiML9MWdlCm7ID+yFosVMM
         EfHETBho08OLzWQywdNogHG1LgaOjkEo/boBeCkY16Zp/Hgizpj4kaCKbcB8WHv5ipPO
         NnMxEQOYuhnn4sW2EFWmjETd6ucfNFhtTMC95SbVesDnBKxqQuf2GbRpmWA2VbZbfn70
         RdoMEzq03Xvt6UAwpfVcTZvb88qYAjKuLt8mCNLqRuGcQXJ64YAt/cNcijQeVC8EFrkn
         VK9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id bp17si2729657ejb.14.2019.06.09.19.23.06
        for <linux-mm@kvack.org>;
        Sun, 09 Jun 2019 19:23:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7520A337;
	Sun,  9 Jun 2019 19:23:05 -0700 (PDT)
Received: from [10.162.42.131] (p8cg001049571a15.blr.arm.com [10.162.42.131])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 19D773F557;
	Sun,  9 Jun 2019 19:22:56 -0700 (PDT)
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Matthew Wilcox <willy@infradead.org>, Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Andrey Konovalov <andreyknvl@google.com>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 Dave Hansen <dave.hansen@linux.intel.com>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <20190607220326.1e21fc9c@canb.auug.org.au>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <632eae55-92f5-1bfc-bfe4-24673558e1d8@arm.com>
Date: Mon, 10 Jun 2019 07:53:15 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190607220326.1e21fc9c@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/07/2019 05:33 PM, Stephen Rothwell wrote:
> Hi Anshuman,
> 
> On Fri,  7 Jun 2019 16:04:15 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
>>
>> +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
>> +					      unsigned int trap)
>> +{
>> +	int ret = 0;
>> +
>> +	/*
>> +	 * To be potentially processing a kprobe fault and to be allowed
>> +	 * to call kprobe_running(), we have to be non-preemptible.
>> +	 */
>> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
>> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
>> +			ret = 1;
>> +	}
>> +	return ret;
>> +}
> 
> Since this is now declared as "bool" (thanks for that), you should make
> "ret" be bool and use true and false;

Sure, done.

