Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE92DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:47:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86D0420830
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:47:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86D0420830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cn.fujitsu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 203126B0007; Tue, 26 Mar 2019 05:47:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B14E6B0008; Tue, 26 Mar 2019 05:47:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A2706B000A; Tue, 26 Mar 2019 05:47:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C70E96B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:47:37 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b12so9797631pfj.5
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:47:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JCJRbJPEjZwyJQ1m5qe9ApEOtDj772nTdJ1KtD8scDc=;
        b=VTjOBsJ1EVQNb/t7l85+QgdwnNUZYwKPy5ZrAJUAey6uCFcqa+HdzSaLWJoiCZP7fG
         oi0UJ4TNvwW8odgbWugxhEtqkSzJmIlQU4eUbnggGF7Qzpxwa9QcprKYONIj7+VFpOod
         /nwDwh9EhPT1umxAJmAvx56dtgyIUdM+jr1qDlYL2a3JotXRVJ4kUwHhpiV7IEIZ80/n
         OoF1nln59Xa5l266VRESQv0eR/5MEQhHZbxW2skDd7cpQXkk5SxAuZf7Ij+K471pvkxn
         JEdB8i8lslEDaQ9FkDmSbAz0DnbADLJRiwJI7FMc09XXpShn+5xRaC/F2aeUWqqw5S2A
         8DtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
X-Gm-Message-State: APjAAAXDEVvk8gykBo5TlbsNZTqcgf+jGFxY06XbcXkBb8MkfZ21FwM7
	nP6ItBRCmayL2vv2CBR3Iewz/JV+KUM5CukLZhA49HaoGj60jhb0zD3FMFaCA8uKPi1sg8gFfC5
	wHDsZSM8LOhEwF0U0tyFD9wwrrZ7Hxna22LPRkz8XcPfwdGhWSjKDXzQdMXnYz4IrrA==
X-Received: by 2002:a63:f146:: with SMTP id o6mr27556543pgk.360.1553593657376;
        Tue, 26 Mar 2019 02:47:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIXOpxtaDRcPI/GdSRUHRyM8RB7qpc0FJX4l2PnQHoF/GgCAzcSm2mZMoL2Rf8UxfQmT1F
X-Received: by 2002:a63:f146:: with SMTP id o6mr27556501pgk.360.1553593656723;
        Tue, 26 Mar 2019 02:47:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553593656; cv=none;
        d=google.com; s=arc-20160816;
        b=sf6JZWzwpEtnay4xFhlVT3DAdbohTrw68NxlEF/6RFGVbpXJw5c0R/+hFXaaxDVFCQ
         +e2r4XO5w4zlHUvXU/qJX8tOPKiaXlv+guc3VeNRHiuqZvwz6YLFfxRzztMTPPCap751
         STWvwXef5zsMNQSi69ZIAaKD61h//+zoJUA5fLbTPU3xPYu6N56cswm38ke68aMbJenv
         cd8WKlwmRTcodFrcJQ6nRsTioBvWKRvev9J+9SHpE5fFWLpDO3khpkh1ZO/Phnv8pKHW
         XlB8kYhQWY6V3jHORe9Bu0dly/nPDh2jLJuBBISBWjZJAs8ti3+ag23J/nKwIa9Sadfc
         UguA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JCJRbJPEjZwyJQ1m5qe9ApEOtDj772nTdJ1KtD8scDc=;
        b=VT7FzFJk58HW2ilHkJrIy/I+ngoNZDcdY5iLUfDtIUUol24P0yubSgujOSQWh46ynY
         UEITBlJm1cD9lUHrdSjbd4nAX31pHEgyTTYG3ys15j10H9uj7Zp8Cot+UFolokeLx2Uj
         aIHFKt62qil/Q2+Kg96Tax0/nQH7xWaPzb2u0TeLyt3jhUU8OTFnMuxDFMDETAYoCY++
         +QMu301hzZ6htBLw96+ipfhlItbQcdMOFnrg4NqD/ftFRjwFVQCP0ePeDHyjkfSIrOU1
         4qSa6eCiOpWg8NP5ua4GeMnKXp5fBNsgb810ugv8cYbrLMINa1HgKgtt0v1vTWPFS+ld
         +DOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
Received: from heian.cn.fujitsu.com (mail.cn.fujitsu.com. [183.91.158.132])
        by mx.google.com with ESMTP id d12si17225513pla.80.2019.03.26.02.47.36
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 02:47:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) client-ip=183.91.158.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of fanc.fnst@cn.fujitsu.com designates 183.91.158.132 as permitted sender) smtp.mailfrom=fanc.fnst@cn.fujitsu.com
X-IronPort-AV: E=Sophos;i="5.60,271,1549900800"; 
   d="scan'208";a="57730665"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 26 Mar 2019 17:47:35 +0800
Received: from G08CNEXCHPEKD01.g08.fujitsu.local (unknown [10.167.33.80])
	by cn.fujitsu.com (Postfix) with ESMTP id C13AE4CD5BD8;
	Tue, 26 Mar 2019 17:47:30 +0800 (CST)
Received: from localhost.localdomain (10.167.225.56) by
 G08CNEXCHPEKD01.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.439.0; Tue, 26 Mar 2019 17:47:36 +0800
Date: Tue, 26 Mar 2019 17:46:42 +0800
From: Chao Fan <fanc.fnst@cn.fujitsu.com>
To: Baoquan He <bhe@redhat.com>
CC: Michal Hocko <mhocko@kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <akpm@linux-foundation.org>, <rppt@linux.ibm.com>,
	<osalvador@suse.de>, <willy@infradead.org>, <william.kucharski@oracle.com>
Subject: Re: [PATCH v2 1/4] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190326094642.GE4234@localhost.localdomain>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-2-bhe@redhat.com>
 <20190326092324.GJ28406@dhcp22.suse.cz>
 <20190326093057.GS3659@MiWiFi-R3L-srv>
 <20190326093642.GD4234@localhost.localdomain>
 <20190326094348.GT3659@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20190326094348.GT3659@MiWiFi-R3L-srv>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Originating-IP: [10.167.225.56]
X-yoursite-MailScanner-ID: C13AE4CD5BD8.AE87B
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: fanc.fnst@cn.fujitsu.com
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 05:43:48PM +0800, Baoquan He wrote:
>On 03/26/19 at 05:36pm, Chao Fan wrote:
>> On Tue, Mar 26, 2019 at 05:30:57PM +0800, Baoquan He wrote:
>> >On 03/26/19 at 10:23am, Michal Hocko wrote:
>> >> On Tue 26-03-19 17:02:24, Baoquan He wrote:
>> >> > The code comment above sparse_add_one_section() is obsolete and
>> >> > incorrect, clean it up and write new one.
>> >> > 
>> >> > Signed-off-by: Baoquan He <bhe@redhat.com>
>> >> 
>> >> Please note that you need /** to start a kernel doc. Other than that.
>> >
>> >I didn't find a template in coding-style.rst, and saw someone is using
>> >/*, others use /**. I will use '/**' instead. Thanks for telling.
>> 
>> How to format kernel-doc comments
>> ---------------------------------
>> 
>> The opening comment mark ``/**`` is used for kernel-doc comments. The
>> ``kernel-doc`` tool will extract comments marked this way. The rest of
>> the comment is formatted like a normal multi-line comment with a column
>> of asterisks on the left side, closing with ``*/`` on a line by itself.
>> 
>> See Documentation/doc-guide/kernel-doc.rst for more details.
>> Hope that can help you.
>
>Great, there's a specific kernel-doc file. Thanks, I will update and
>repost this one with '/**'.

In that file, there is also some sample for a function comment:

Function documentation
----------------------

The general format of a function and function-like macro kernel-doc comment is::

  /**
   * function_name() - Brief description of function.
   * @arg1: Describe the first argument.
   * @arg2: Describe the second argument.
   *        One can provide multiple line descriptions
   *        for arguments.
   *
   * A longer description, with more discussion of the function function_name()
   * that might be useful to those using or modifying it. Begins with an
   * empty comment line, and may include additional embedded empty
   * comment lines.
   *
   * The longer description may have multiple paragraphs.
   *
   * Context: Describes whether the function can sleep, what locks it takes,
   *          releases, or expects to be held. It can extend over multiple
   *          lines.
   * Return: Describe the return value of function_name.
   *
   * The return value description can also have multiple paragraphs, and should
   * be placed at the end of the comment block.
   */


Anyway, I think you can get more information in that document.

Thanks,
Chao Fan

>
>


