Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B75AAC468C1
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 05:06:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 885D02085A
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 05:06:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 885D02085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 204536B0005; Mon, 10 Jun 2019 01:06:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18D676B0266; Mon, 10 Jun 2019 01:06:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02D676B0269; Mon, 10 Jun 2019 01:06:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A69866B0005
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 01:06:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a21so13523175edt.23
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 22:06:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Wz2zQ+Nf23f/S37L/eyEoJVgucVH00h1gMyuDCGh3XU=;
        b=i+V7m+KERKHO6ce1ndzUtwtaUmRQyZLP4ujFqsxSEfi5CpnXv6ENcobB2al3gZ1O9W
         gzQsi2iKQfib6rhFeOJxstQ7oHbqzxU8GPAqO4ooSibl4Slvkwnq6rnV6YcIkhWQsMIr
         bElXOyAzKSAjDxL26R+Rq3ljXC4zzq8tE27j6NIIhEsuscEaMv7wFDcNbdT2ehtiaN/l
         lXqD2Ld5Ck3JkfE+D0tRn7Ru1ccqebz0YZfcpo0dm+YSzkjIejGDAnIYGM7ak55CQVgK
         Qhr0LZe1yHShxtR1H7XKzqgchZcG1aSZf0+DuthJfNkhdVprH+mZogmaCr9KPYZqVfsk
         0Stg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVjP9pJWpb+ojeocULTS1T666KEHDUXZFF2GEwd/X9ducFNQXXI
	I2xhPouoGvPEo0ef8mQcdqCZJcKOEbquFbbx8lHSdlthRE8345y4dkx6/XxN0cBYF4yb8Q+rN2F
	iZblog4pgRe1axKjkTtg1sXNTgEC06MtY7bfPU41iHhrhAEcAwfyv3oNKcGpSJCDbag==
X-Received: by 2002:a05:6402:1436:: with SMTP id c22mr40462352edx.70.1560143185270;
        Sun, 09 Jun 2019 22:06:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpHPIicU9SGRYEEeXwFA6ZfzD/XgukhQAiswhj3ZW6ifCjei4T74rerA6nCnpgzAD2LSDy
X-Received: by 2002:a05:6402:1436:: with SMTP id c22mr40462309edx.70.1560143184555;
        Sun, 09 Jun 2019 22:06:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560143184; cv=none;
        d=google.com; s=arc-20160816;
        b=s/BUvxAjmz8QC0pE3T9vz5Y4SPbObNPlArSDz7dtgucvjaheL0U6l9WWF07W/fJouw
         zOqJ0EMWEzSodvbjso2SNw0uOxvwv8E8clGISQha/4+cyKN6mPrGOsVnINm+gI7LIc1v
         Xcje+Htmk1meaEPNQtJFgZmEYs3UT7qIzX51fsGUS2nR/C9uq9zJK8eY6X7XQu2ntEnW
         1QSD0NDDMwSssb1V2Owgzoyk8ug0MBYk98ABVRJ5QwiHcI9TwbGnXu8A8YUxDHbIWcVs
         FgzexUdIaAfsNtiV8K1/ZXYhJr5nSrDrsicPMxDYlPKmE5WZJ23CiXrF5kdFo1VUqz/g
         u0RA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Wz2zQ+Nf23f/S37L/eyEoJVgucVH00h1gMyuDCGh3XU=;
        b=mYgfUQSsLwrQJxYnrNPt485cnOaH4ALOkHkFw3ALiNXZNNhqdjVngHB6v6hwZcC4bJ
         4LUeV5gT7Xc65epj+V89K2qxqFDwNLmdXR5rvHVjxhw63ihRMkAYxJ79H8FNvUp3HQtm
         2xh+PQClDFFkGy2XR2j2hBcjTnx4gVy77XFMacjXnEirKpp8UNySNg4xolO+mbyPF4Ar
         RHrdHQ4jceL3VF359wH8Go6ehpOH3a1OuyQmdWjoUdlhEn8Kd2Ap4lD6Bx0rJWy6P9sJ
         OHHv9/sWl6PRZJsQRIhgFSyv64zPNkzDhPODtRGwWAVr3in3xGo6TdLP4IAFP5/4C44d
         XWCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id t46si1794374edd.224.2019.06.09.22.06.24
        for <linux-mm@kvack.org>;
        Sun, 09 Jun 2019 22:06:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A00A9337;
	Sun,  9 Jun 2019 22:06:23 -0700 (PDT)
Received: from [10.162.42.131] (p8cg001049571a15.blr.arm.com [10.162.42.131])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D10043F557;
	Sun,  9 Jun 2019 22:06:13 -0700 (PDT)
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Dave Hansen <dave.hansen@intel.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
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
 Dave Hansen <dave.hansen@linux.intel.com>, Vineet Gupta
 <vgupta@synopsys.com>, linux-snps-arc@lists.infradead.org,
 James Hogan <jhogan@kernel.org>, linux-mips@vger.kernel.org,
 Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <20190607201202.GA32656@bombadil.infradead.org>
 <f1b109a3-ef4c-359c-a124-e219e84a6266@arm.com>
 <33c6a1cd-5c07-e623-28e5-f31f6fe30394@intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <62aa0369-9542-17bc-034b-8445664c7c10@arm.com>
Date: Mon, 10 Jun 2019 10:36:32 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <33c6a1cd-5c07-e623-28e5-f31f6fe30394@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/10/2019 10:27 AM, Dave Hansen wrote:
> On 6/9/19 9:34 PM, Anshuman Khandual wrote:
>>> Do you really think this is easier to read?
>>>
>>> Why not just move the x86 version to include/linux/kprobes.h, and replace
>>> the int with bool?
>> Will just return bool directly without an additional variable here as suggested
>> before. But for the conditional statement, I guess the proposed one here is more
>> compact than the x86 one.
> 
> FWIW, I don't think "compact" is generally a good goal for code.  Being
> readable is 100x more important than being compact and being un-compact
> is only a problem when it hurts readability.
> 
> For a function like the one in question, having the individual return
> conditions clearly commented is way more important than saving 10 lines
> of code.

Fair enough. Will keep the existing code flow from x86.

