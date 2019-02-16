Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42962C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 14:23:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8006222E0
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 14:23:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8006222E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.crashing.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62E6A8E0002; Sat, 16 Feb 2019 09:23:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DD668E0001; Sat, 16 Feb 2019 09:23:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F38D8E0002; Sat, 16 Feb 2019 09:23:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB528E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 09:23:11 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id 135so21325238itb.6
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 06:23:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3bLgPNiWV8dBwDe/bDhNhXLkTGdkROYJDsjGvI/ADOQ=;
        b=ie+fEsfWUjX9abLk8DzBkFIe4iW9FKgS3fHggTTA144PiMz9//OgvgYEl9CY0R057e
         XkE+3gxgwZGsKtB13S6C9zYtFbef+BL0nTJTqYjUkKjftPKVQsSS3I/Nz1shy7GN2J+x
         TDpbhMhi+oH/IbyFS14pY7CiKy4Pxier3vts1iHJfw49tKLswKiiZy9zu51qq+9d84ti
         GL3eatsEMgpPVhibrTPrkZdf9fUMcuG5wEE+1fI29BOeTTqHxHX6lao8NQvpR2buoyjD
         PirU7AtBlidztKzw4B9qFRd0irBqAej3fOts0yWY81+U3yB9MRGDplulQppr3NSdlnG8
         JH8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) smtp.mailfrom=segher@kernel.crashing.org
X-Gm-Message-State: AHQUAuY/CXXty+OWSjyCAM6QX2wRJvu4k7gQ7zUXV75uxN1FSeoADbU8
	j+wnIMjogKGcQ73ZeFAjipG+YPwSQxgT4LZ+jX7qS2XclzV2aTqG5fYnTByo0oD1i9d4hjpiqsl
	3TmQakWdUoSz02/ZESpsdHDw1GkVQCffeNvXj0GA5DH/Y+oDi4X2oksyxPv2BnC/1Cw==
X-Received: by 2002:a5d:8582:: with SMTP id f2mr9778367ioj.28.1550326991009;
        Sat, 16 Feb 2019 06:23:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYklK1oZrTQHzCO0CaI3GwW7I7FsrzovV2+dWMa+0gZZX0sROhpQaMqqeewjFk5wNVbd7m4
X-Received: by 2002:a5d:8582:: with SMTP id f2mr9778350ioj.28.1550326990431;
        Sat, 16 Feb 2019 06:23:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550326990; cv=none;
        d=google.com; s=arc-20160816;
        b=ZfKdNwcbuKL2Q7r5p5bOkS12ldEciQWkgf4AK3NgLS9iVi1O/9/IQDKAC7mSnlp4w/
         JcEmxrprcNQjfEmdREymmM4JiP4ZL7P+6SjgOkKOhLHw+8WfxTB3LeAiqYVCYgYJr1Uc
         qjR+MJuvoYOT5+oV4IES7FcGrLdSiE7gwgyRGwQw4j7+Ljvd+evx10IszAIRt0z3G07q
         0mDKssQ3I0Kb0vxBdgcgQfULDlBHv9Prp4laT8V2aBIKMp6qKbFfLbaFNIB2u3FDnWBo
         tr9BtE5u39gg8MJe8iAQfj9Xjb/6z0WdQQMJZyiVf+LeX15kODq8rDfWSE2kCThSGki/
         SQ+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3bLgPNiWV8dBwDe/bDhNhXLkTGdkROYJDsjGvI/ADOQ=;
        b=CoTEmrk2XC/288J10seXAEqYoC/h9ZZ8tPT/pGAeW3+MqK0QwUjeokEBGjO+M4GFoj
         lqtjIyDKGuhm1FW927zIINaYvCpGAC0ofHqVuEaQq9iYD26j82oH5W3DVi6kCZCOYqtZ
         UTrajDqDwUV/JOsOKBzCCYQGw9wvmfh4NuC4RJoPtXFlcrW68e6s/xYoLzjVsTuKtQpW
         L/sfd7XmIfcoqXz/jRicyskp23D7hXQdGxELnPREXfkJmYXYDE5x3F+eg+mSnZDX8Obn
         nSMdCNo0USePMUEb8mlYNovAjvf//yOt+4CdentpLgDPSkDIVuH3cKN88IQlpRwp5jU7
         VXDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) smtp.mailfrom=segher@kernel.crashing.org
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id 11si2277067itx.11.2019.02.16.06.23.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 16 Feb 2019 06:23:10 -0800 (PST)
Received-SPF: pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) client-ip=63.228.1.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of segher@kernel.crashing.org designates 63.228.1.57 as permitted sender) smtp.mailfrom=segher@kernel.crashing.org
Received: from gate.crashing.org (localhost.localdomain [127.0.0.1])
	by gate.crashing.org (8.14.1/8.14.1) with ESMTP id x1GEMUfJ030078;
	Sat, 16 Feb 2019 08:22:30 -0600
Received: (from segher@localhost)
	by gate.crashing.org (8.14.1/8.14.1/Submit) id x1GEMCDe030050;
	Sat, 16 Feb 2019 08:22:12 -0600
X-Authentication-Warning: gate.crashing.org: segher set sender to segher@kernel.crashing.org using -f
Date: Sat, 16 Feb 2019 08:22:12 -0600
From: Segher Boessenkool <segher@kernel.crashing.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, erhard_f@mailbox.org, jack@suse.cz,
        linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
Message-ID: <20190216142206.GE14180@gate.crashing.org>
References: <20190214062339.7139-1-mpe@ellerman.id.au> <20190216105511.GA31125@350D>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190216105511.GA31125@350D>
User-Agent: Mutt/1.4.2.3i
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

On Sat, Feb 16, 2019 at 09:55:11PM +1100, Balbir Singh wrote:
> On Thu, Feb 14, 2019 at 05:23:39PM +1100, Michael Ellerman wrote:
> > In v4.20 we changed our pgd/pud_present() to check for _PAGE_PRESENT
> > rather than just checking that the value is non-zero, e.g.:
> > 
> >   static inline int pgd_present(pgd_t pgd)
> >   {
> >  -       return !pgd_none(pgd);
> >  +       return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
> >   }
> > 
> > Unfortunately this is broken on big endian, as the result of the
> > bitwise && is truncated to int, which is always zero because

(Bitwise "&" of course).

> Not sure why that should happen, why is the result an int? What
> causes the casting of pgd_t & be64 to be truncated to an int.

Yes, it's not obvious as written...  It's simply that the return type of
pgd_present is int.  So it is truncated _after_ the bitwise and.


Segher

