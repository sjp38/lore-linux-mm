Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAD66C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 14:22:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C7C920825
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 14:22:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="gda2MW/V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C7C920825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 049046B0007; Mon, 15 Apr 2019 10:22:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F37356B0008; Mon, 15 Apr 2019 10:22:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFE956B0010; Mon, 15 Apr 2019 10:22:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A7DD96B0007
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 10:22:36 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u2so10483829pgi.10
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 07:22:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pmyvWH9ZMN07VK8oyhMskbovsYoBe8IQZyso9rGspVI=;
        b=po26odIDssuvZLKIquvPUZbpo/R3OSvvETYbGLXccbA4vuHaLSSN65lshH+1pURI1F
         qjLRPi7oz9Ztm4k+tCl/tv3GtH2TM5BKUOJNOB5S8Z9MrGF62HcbxoGYQw6ckIoHoxFM
         yrqUBDCM4QvfIlbBh2HbiL+dCjGBkqoR9RfwBm1HKn9T09C2CMkOXGAcD9BsPyfbigZk
         fh8KJPE5iSA/T6JIQhO8bJohAp5R7O/8YyjHVfIXdt7htcJL0TMKxP/5SXXZZEVf6Tvh
         BCJxUKUTmTS6px0u8g+XXxow+BR6Twpg5hb06zj487a545ydOOWxDR1t4FPfIso+AI2s
         /SgQ==
X-Gm-Message-State: APjAAAXgTA41hEewh/RsyhubRJ3C9bP10zpnhfbaX13C37A+ohaQlMm7
	oye++dXiBO/Z+GSzrC0sKuQhGkePvBZEgIpVjuxDaS1EYSjsqk79F12iDP+cHKzA8Y9ksEL7V3V
	fmuvN9dKlhLqx7g/ntC4JTXw18r5MxwEh2PoDG8u6F9KFZSw4ZddES+FW0xjJX9glcQ==
X-Received: by 2002:aa7:8092:: with SMTP id v18mr74128375pff.35.1555338156155;
        Mon, 15 Apr 2019 07:22:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzd+6dpv+m/oMRtwtBRTonmWqh9ITzDJ5jliQPsc5cW6QoJZZvoxoNrlfXAaOsT1divFrBq
X-Received: by 2002:aa7:8092:: with SMTP id v18mr74128277pff.35.1555338155209;
        Mon, 15 Apr 2019 07:22:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555338155; cv=none;
        d=google.com; s=arc-20160816;
        b=yge7uwwH23FhIkfV7bmB8ptMdBIJj0IlSrYdfPqZSmMbECvT3t/LPWUkgoMvHY7MkF
         VYjAEiPapdXDr1vAEx7UcUwWO94hygQGn4rEFCXhFhPchm9KC+EulCH403t7Utu5UGD3
         +DDhmmrs1zOLe4dfpGhK8ZxaZUK6wbtXyA/Vct4I0znI9IFlMNnpaOQheMjMn4fEDJxM
         ao6634jlPs3K+BoD5mudUqLhCRDJwyCLtFzFb951SefUr55re6eTKdaEW1qdGZb4qMKe
         2EaHN1WUCY5GRTuUVnHST9NKBXDSz88P0pPEMjyiFdKx329NrNPPI7CCJTiUmRAP+ZpD
         6fTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pmyvWH9ZMN07VK8oyhMskbovsYoBe8IQZyso9rGspVI=;
        b=DuZj/Uy8riw692kLG8EmDB+0idM88xwPa62qgYjilpPpFK5I1SVnAakVYOshU+P5Pk
         avnjj5p9Tl+5DmGv4CLIfqY/OpZjkHJZlEAobH/bFgfIBCTGRsOyIdzLzHMoYQPECNRw
         BCeIDNO2aZumC4NO1WvTFVGFg7HX+14sDGTEbbGDiEaMtP6A0/cvMgCUE/o5xUQild8O
         +5ExpGTI+6WG6YuXNMCbH4JQ4HgBxUWby17brCbTd+uf7KtEJasWLP7zFSwAVpnWXhcD
         QwZvBz05eJhJbTUMZgWtKax46zmU5FM8N8ANEaPkAKyS4DHrh5+2iZNoOo5CLLtxSnZi
         aO8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="gda2MW/V";
       spf=pass (google.com: domain of jeyu@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jeyu@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x3si44624349pll.268.2019.04.15.07.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 07:22:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jeyu@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="gda2MW/V";
       spf=pass (google.com: domain of jeyu@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jeyu@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from linux-8ccs (ip5f5adbb4.dynamic.kabel-deutschland.de [95.90.219.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 51E4020880;
	Mon, 15 Apr 2019 14:22:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555338154;
	bh=f0MTa7O9eKaqafBFgQG47VlmY1xfprmetDMdk8EjmCs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=gda2MW/VzVJSa3xOMiLc5NR4KzuPJtxxImHxRxhpaIVjF3mbNKxbji4LvC98vvwgE
	 XwggmmZ9821q4ATTw4dihR9dTGPKKAvqWEz08cOFZPlPBvEy+veEOoO2291H5Pne6I
	 rWHkItre8LoCmzTpMcHtAu27dKt48fVWz1d/1L08=
Date: Mon, 15 Apr 2019 16:22:29 +0200
From: Jessica Yu <jeyu@kernel.org>
To: Nick Desaulniers <ndesaulniers@google.com>
Cc: Tri Vo <trong@android.com>, Matthew Wilcox <willy@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Peter Oberparleiter <oberpar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Hackmann <ghackmann@android.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	kbuild-all@01.org, kbuild test robot <lkp@intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH] module: add stub for within_module
Message-ID: <20190415142229.GA14330@linux-8ccs>
References: <20190407022558.65489-1-trong@android.com>
 <CAKwvOdmBa-Ckk4wnp4OEPNdxeYSxEhzddykuWWGG1Wi6JEGDwA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAKwvOdmBa-Ckk4wnp4OEPNdxeYSxEhzddykuWWGG1Wi6JEGDwA@mail.gmail.com>
X-OS: Linux linux-8ccs 5.1.0-rc1-lp150.12.28-default+ x86_64
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+++ Nick Desaulniers [08/04/19 11:08 -0700]:
>On Sat, Apr 6, 2019 at 7:26 PM Tri Vo <trong@android.com> wrote:
>>
>> Provide a stub for within_module() when CONFIG_MODULES is not set. This
>> is needed to build CONFIG_GCOV_KERNEL.
>>
>> Fixes: 8c3d220cb6b5 ("gcov: clang support")
>
>The above commit got backed out of the -mm tree, due to the issue this
>patch addresses, so not sure it provides the correct context for the
>patch.  Maybe that line in the commit message should be dropped?

Yeah, if the commit is no longer valid, then we should drop this line
and perhaps generalize the commit message more, maybe something like
"provide a stub for within_module() to prevent build errors when 
!CONFIG_MODULES".

>> Suggested-by: Matthew Wilcox <willy@infradead.org>
>> Reported-by: Randy Dunlap <rdunlap@infradead.org>
>> Reported-by: kbuild test robot <lkp@intel.com>
>> Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
>> Signed-off-by: Tri Vo <trong@android.com>
>> ---
>>  include/linux/module.h | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/include/linux/module.h b/include/linux/module.h
>> index 5bf5dcd91009..47190ebb70bf 100644
>> --- a/include/linux/module.h
>> +++ b/include/linux/module.h
>> @@ -709,6 +709,11 @@ static inline bool is_module_text_address(unsigned long addr)
>>         return false;
>>  }
>>
>> +static inline bool within_module(unsigned long addr, const struct module *mod)
>> +{
>> +       return false;
>> +}
>> +
>
>Do folks think that similar stubs for within_module_core and
>within_module_init should be added, while we're here?
>
>It looks like kernel/trace/ftrace.c uses them, but has proper
>CONFIG_MODULE guards.

Tri, if you plan on sending a v2, could you add Nick's suggestion
above? Would probably be good to prevent future build errors if a user
omits CONFIG_MODULE guards.

Thanks,

Jessica

