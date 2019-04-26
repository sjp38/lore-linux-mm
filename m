Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 531B5C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:46:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E7F92084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:46:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E7F92084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D272F6B0006; Fri, 26 Apr 2019 10:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD6726B000A; Fri, 26 Apr 2019 10:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC64D6B000C; Fri, 26 Apr 2019 10:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8127E6B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:46:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u191so2234614pgc.0
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:46:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=mdUP6r3s8Bj5vFbjihMOM2vWSrrPgMMVKPDIHYXk2Vw=;
        b=R72IryVSVqe0A2o/J2uyxkkI869SVWPfOEye8tVXe8DauDtRKaIwg7ujJIwWZ42fq1
         v5hOuY6gnBnPw7ROSxSHBcJmokNEqO89q90sI8qbGIrnMMopywicwfcEb9hSd7SJcysJ
         PmJUjH8LoE1WcyT+Gx7Z+UHk530IiiQKdZf8xrR6N/neW2Br3di/Vk764Ixs8l2LXkvJ
         a0Gyb1wNMMgTf5nmoVLxJdSPk3yAmdklELtuM8xwrDrpaFuPfy8WA+4wBXCwj0DlpLEi
         LLiRagfh58/OZh3A8p2Dz1RWNt5hwpEk2+BxbI+S7NvI2qsY7GjX4hRieqo6T5JiEuB0
         M96w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXfa2W48Tvbhog9SzMSYoGaBvK4sNAdibcg1/jauVx4XAPJgz+c
	WYlPahoCEKgCkxdlS9exctZ+UoSNQtauBwd9CHgILRD7M8MA8Tez4uSS+yuMCb0T3XWLzWBqspv
	k+nH0qLuZQPIJDA1H6+9m/oJS/Nueejup/5qrrP8Oe36YCI4R8TRLhbzYEL8JhVpleQ==
X-Received: by 2002:a17:902:4481:: with SMTP id l1mr27624273pld.75.1556289982210;
        Fri, 26 Apr 2019 07:46:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHRcXYO2RketGNZy+nETNhTSwYt1okTdThFNZ4rilIqlborqJKvHqhEYClu/HFQZhZHkiu
X-Received: by 2002:a17:902:4481:: with SMTP id l1mr27624228pld.75.1556289981661;
        Fri, 26 Apr 2019 07:46:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556289981; cv=none;
        d=google.com; s=arc-20160816;
        b=URK8ARbNB4I4Q1cdSbncFamE3Fm39pHycasmwVQDhPB068GiTimVbaIt3MM7R9MF8o
         gSAY9UMmgm2Ug5nlurUUr9crUTNrzzPzRj5FBton1wQvzTK44pCyQZGd3/CAiS3ox2P9
         QxE+x2B2TF7YKCXVxDaiG6AVd49ZSi2SREdeX+WSE22zEGO+oxSRdZHrviOej+CRdfgw
         m7fGFyj666wRlp18dAWSgkcy0kMe7rH9iTa5l9Ely/ZjwQ1LH9ghXPpXrNDJr6eMJSGf
         73pUEuGuuQpftgdiZzGN2R15Hquf5kxketUOI+eSFlyf9Rr6qyChLobqeHl9Vr6fBNqP
         P+jA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=mdUP6r3s8Bj5vFbjihMOM2vWSrrPgMMVKPDIHYXk2Vw=;
        b=OuhhvA4dCegqEy7xtFPGg1gub9qHqqL1iNLdY/xRbwMHT6sf/hVoW/bqc4/Zt9h+4C
         uzKuNCjU+2bUs3MdbEycECR4xFDjnsGJYSt4BHzVmjSdCVFtT5rXex//1uiEnvooB64J
         m2Vm23Ks5TQINVIScG7txPmcTID/ZMusUolvZKGOqNHfo9qkEH+cC7nRyE8a8ujZw9t5
         chuJFSMRg/2v8AwInRTcSjvlOEmUXmEIgSCwTML77btWvSxJY/7YDBJyGoEFHyNAURVz
         oPRmOFuG4PaBLWNFKowlHh+YHixtlQwIqu8NoifI67/kXJTuIruzs7eG0aplScFsn+yA
         bPdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f5si12070030pgs.86.2019.04.26.07.46.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 07:46:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Apr 2019 07:46:21 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,397,1549958400"; 
   d="scan'208";a="165331429"
Received: from gbotts-mobl.amr.corp.intel.com (HELO [10.254.86.96]) ([10.254.86.96])
  by fmsmga004.fm.intel.com with ESMTP; 26 Apr 2019 07:46:19 -0700
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system call
 isolation
To: Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
 Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
 Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
 Paul Turner <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org, x86@kernel.org
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <627d9321-466f-c4ed-c658-6b8567648dc6@intel.com>
Date: Fri, 26 Apr 2019 07:46:18 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/25/19 2:45 PM, Mike Rapoport wrote:
> After the isolated system call finishes, the mappings created during its
> execution are cleared.

Yikes.  I guess that stops someone from calling write() a bunch of times
on every filesystem using every block device driver and all the DM code
to get a lot of code/data faulted in.  But, it also means not even
long-running processes will ever have a chance of behaving anything
close to normally.

Is this something you think can be rectified or is there something
fundamental that would keep SCI page tables from being cached across
different invocations of the same syscall?

