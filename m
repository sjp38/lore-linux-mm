Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41B75C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:47:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1277823D61
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:47:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1277823D61
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89D6C6B0276; Fri, 31 May 2019 04:47:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84CF56B0278; Fri, 31 May 2019 04:47:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73CB56B027A; Fri, 31 May 2019 04:47:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27B306B0276
	for <linux-mm@kvack.org>; Fri, 31 May 2019 04:47:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c67so2341403edf.17
        for <linux-mm@kvack.org>; Fri, 31 May 2019 01:47:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=LX4aAvIyyVRU6jnwoMJoM9TkuxWPCQ9qm8BVsGwSR+g=;
        b=l+sF94Mr/6XBSJfoXOMIN7l8QOWWAoNOAbYZW0JK/NFcGbHY185L3Ws+Uo/TKAfqeQ
         EUGGQ5Op/MaFRxVMugxb1TTOL61oPkx67AvHc/x+66H9v+O4YyuC6xQrjjry4cJbNlyM
         fSoWWTbDPnuUDZvki/QWUPGcyRgfS57PDfP1MqmIef6QE6pvAHS7TIGIjpbL2+oIp6Ro
         tFI7i9KRkZpuzAezPbbnw2EKGZMsyl8/CC4jScQTyD34CfFcgH4/ytfgRYIJE6XEPGoP
         AAz4RHkZ71/2U6KujKe5G4gIN0h/+oqW7VfcQaSI3OTnBpJvIUV/YnKDg+aENU6oDfpa
         UWLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUk6Bi9B8clHtoMuoGPGEB0epBUx1QD5t4gYQcT2QDQ+9sF0+Iw
	ViX/uhrVxlKo8RJvxFxQgDHgwY2tVLS92VzKX/C4tKXMR+892dJlO9uZywuoMmVZLbFcXLJJxIT
	yhv0vV0DXeeIDlKznMUW17+8ERfnZUiGPwn7cmJkFmLL7BMMGYR+C6RXBKv9awP9wSw==
X-Received: by 2002:a17:907:36e:: with SMTP id rs14mr586167ejb.297.1559292459733;
        Fri, 31 May 2019 01:47:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPXmE1tlh4jp7kEZLcYxHLAo33lQBxAm2efRrYZy47P1OF2LNDstkRi8y73MPYOWoNVo82
X-Received: by 2002:a17:907:36e:: with SMTP id rs14mr586103ejb.297.1559292458901;
        Fri, 31 May 2019 01:47:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559292458; cv=none;
        d=google.com; s=arc-20160816;
        b=GNwhFzmO9aNkIG0SNDl27v6W/NvB9b1Ls476bm0DOTN518VcRiVQSf8gsFwjrYcPvh
         486YJEpluWa0aS3FGDF2L9GOmgM7j/Jj+F03oqzVokBFXqb1Y16GvCQ7CXisGogi4lgZ
         /A9q7g6yCErB2P2i1ahb2el4QeeELpZgvQXoPuYcsuqiyV5+r22Oyu47RFrzPt05PdGi
         W4dG4/rHf6Xle1Ggax1xYcYqiaNNyWA2Ie2kK/EfTMmGYGICc2OjRF3qibGDHmW13vNa
         8bDA2lEcIUZyKqqq+oRkyYtQ24yr0h7bJ7vLK6c25cq8jzvyRvtLvL/GwUoAY8ez6LAs
         DM3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=LX4aAvIyyVRU6jnwoMJoM9TkuxWPCQ9qm8BVsGwSR+g=;
        b=Jtj+BSRyNla2ogyozGnmfJS7v9AqHLy/yusPsRLGwVtZbL6A3k97f7UKv5408TDv8B
         u17TnkWSdnQESTewZ1HHL113WwH1fy7buskOUWgKHZRu+u/k9iuSxQUBlrOfwW1XjiS3
         kvq/YcsKgGmPaSM46K+IX4gtU5Y9yApt+XHWvHKf+4JCS6+3kZGp246KiBAncYRehd0I
         OmPRzdxL5dSivUEVZ4caD0NQF2kVYcbmkMFS+CWah89AoQ1v1OX+1N5K5zN0As/5sjKF
         1UWF6ZKaCQkpNeFIFq2XmdYU7TLn/Dvv38PHo2U2tt6Srqv1t8M7yZZXcorhFhlG0oSH
         D4aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k17si305180ejz.93.2019.05.31.01.47.38
        for <linux-mm@kvack.org>;
        Fri, 31 May 2019 01:47:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7619E341;
	Fri, 31 May 2019 01:47:37 -0700 (PDT)
Received: from [10.162.42.223] (unknown [10.162.42.223])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 20D713F59C;
	Fri, 31 May 2019 01:47:28 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [RFC] mm: Generalize notify_page_fault()
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
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
 "David S. Miller" <davem@davemloft.net>
References: <1559195713-6956-1-git-send-email-anshuman.khandual@arm.com>
 <20190530110639.GC23461@bombadil.infradead.org>
 <4f9a610d-e856-60f6-4467-09e9c3836771@arm.com>
 <20190530133954.GA2024@bombadil.infradead.org>
Message-ID: <f1995445-d5ab-f292-d26c-809581002184@arm.com>
Date: Fri, 31 May 2019 14:17:43 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190530133954.GA2024@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/30/2019 07:09 PM, Matthew Wilcox wrote:
> On Thu, May 30, 2019 at 05:31:15PM +0530, Anshuman Khandual wrote:
>> On 05/30/2019 04:36 PM, Matthew Wilcox wrote:
>>> The two handle preemption differently.  Why is x86 wrong and this one
>>> correct?
>>
>> Here it expects context to be already non-preemptible where as the proposed
>> generic function makes it non-preemptible with a preempt_[disable|enable]()
>> pair for the required code section, irrespective of it's present state. Is
>> not this better ?
> 
> git log -p arch/x86/mm/fault.c
> 
> search for 'kprobes'.
> 
> tell me what you think.
> 

Are you referring to these following commits

a980c0ef9f6d ("x86/kprobes: Refactor kprobes_fault() like kprobe_exceptions_notify()")
b506a9d08bae ("x86: code clarification patch to Kprobes arch code")

In particular the later one (b506a9d08bae). It explains how the invoking context
in itself should be non-preemptible for the kprobes processing context irrespective
of whether kprobe_running() or perhaps smp_processor_id() is safe or not. Hence it
does not make much sense to continue when original invoking context is preemptible.
Instead just bail out earlier. This seems to be making more sense than preempt
disable-enable pair. If there are no concerns about this change from other platforms,
I will change the preemption behavior in proposed generic function next time around.

