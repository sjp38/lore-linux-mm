Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E4B9C43612
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 04:16:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF9122080A
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 04:16:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TlDyqnPH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF9122080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEBEA8E000B; Tue,  1 Jan 2019 23:16:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9AEE8E0002; Tue,  1 Jan 2019 23:16:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB0518E000B; Tue,  1 Jan 2019 23:16:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id A50008E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 23:16:39 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id d7so21773134oif.5
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 20:16:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=sGf8qo2Wdx2LK1OhcJgrgfHsKFZtTfQlC5pl8JudtzE=;
        b=kuMLnRlmK2YqnJ0yBtNIEg+ZiMmNA9kwQGLMCX6yj4UeIPJ9zEHn8je3lBAUF7LLZZ
         H4PFxrk+UxuSUgYLtme0svM526eFTyWS3X8YH5ck76WwwvVrXklnajHHyaw32pl+h7fS
         mI4AEdjn/ZWdpHu9xTGM8ilfws8secyJD2I713hQGjLX5ruOWxE3dbZdoORCtv3TWSxe
         yoY4hZEGa9A57RQA+nM1RRWFo1aupYLYxHr+z0fUUm8BusQFf2El6MG7Hj6+PiViXxz4
         JHuzRHr8QmI46y+TOf4lltjtuegzbF3ayMXBVUlBRpJXT/XTCO/lI0GpiMj8LIoG25Ct
         eJxA==
X-Gm-Message-State: AJcUukcdwy9Wf2h0Fxr6FVgr53CYdgQMKAYJCCGhbbHJ/9Ymy8w83eUJ
	p9LA+jKpu83XqNKfKmJy7zjHTdXlsxPokYs0RQkSI5+nODbg15VB7x+Z08tGJaVNmfUO2qr/nr7
	Htwx43aOOur4cAEzVEz2N+D6ICWiQIiyLVLKq00xKvo1VzLarBwtqpe/yU/gMMUdRNlHCINujLm
	HgWACaZ4VUI+mWkLxClLY0ZmYEUhEXzHG+WGyjnh2cpFXWgrsArIgU9AN/zgz/ltY8rLzLEUaNR
	TkBxkxvlWNyiB6Mk18a/KIIyUTzmvePdGt5O4ny4A3Nw/WeyEr3CZL5qx2PFbihwhyUqvYq3VMO
	r0bJvQ2iAB388EUWjWZyhkNK7yZCSWr4k4brjCQRQ+2gVa6JkcqT51JRYYu2ERdz9YVGGpGaAiS
	8
X-Received: by 2002:a05:6830:16c2:: with SMTP id l2mr30505684otr.20.1546402599281;
        Tue, 01 Jan 2019 20:16:39 -0800 (PST)
X-Received: by 2002:a05:6830:16c2:: with SMTP id l2mr30505668otr.20.1546402598520;
        Tue, 01 Jan 2019 20:16:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546402598; cv=none;
        d=google.com; s=arc-20160816;
        b=qBZpCysdvPRqez4IY7Cob00WrLyjWODeyesjuWYQ5q2JpaKK7FKyVn/Wxz/pb+Tlaj
         EM1Mt/rNQFRsj/d/xoOKnwH+kmcTF7ezWfEj3kyt0eKW6LqbOtwiUOK6Cc+mXAkQr7Zy
         9eTJTr/4IJPY9m2ij+veJ9CR813+HnUqBFaLkBE0In+iePQVRZuvaL69DUSst4GGES67
         V1/v69UB+P07A3HS1jSqtl3crRlOwQ5ZwDvgtU66mpYFwrreKNVxT1aIq9f4Ab1QiHo7
         2qyQFYbHPA2mPtjdu3mLoN1JcFJaMKwWOYYxe7qW2FFTKrv+9J7EDbiOdR9PaN9PBo+W
         wTtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=sGf8qo2Wdx2LK1OhcJgrgfHsKFZtTfQlC5pl8JudtzE=;
        b=BOEFZIVt8JcHsxkNzbniCbcQB9dPfPSX9FMw3iz8h1k8IfwDgqVzCjOBm4OYcI1uWg
         RmzULytLTeQHmc9zudLQU9LALqMK5PdepoSheHodpxpHFXf0ngKJyMw4x6KpVCG8GZRB
         SG3CTm3yIzvwVsaddhObKQdYPKSiGL0g/g2hiVZ+aaKrTBJt26L32iH16fmG4Uy0zbQj
         FvWhWbw+zYiVcUMYeQPBr8MO42Jm2SmdHnIPSF0GZx0thM4p/A/vBUMYETonYt3z806I
         L+uvIo/28FEcRQvG+AKTwK6eMm2IApQMbXfC8OUr2TAybK+OhV+tAsu5ox69mzWr3w3w
         8qZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TlDyqnPH;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor26440580ota.72.2019.01.01.20.16.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 20:16:38 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TlDyqnPH;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=sGf8qo2Wdx2LK1OhcJgrgfHsKFZtTfQlC5pl8JudtzE=;
        b=TlDyqnPHZSSgvwoclhmoj5ys8xDZm6AlFzh05iWq49a0NRex24EjU20DyAzpNHTUT9
         uRytyqszNnfGIMXVM/NFBwcNXsFtkxYspclXZAz3c2+g15YObn+SUogf8XaTA8DIeE2K
         ocCl0fV6dGBnOPKUF3b97m7ySSCWjVhPDwUhr2YyuSNUkfxZqr+XiZTD+K/u9s10C9Zf
         Le5E3McHGCXl1ohRSkIOtmOyLYHTVM7ChSDXX3bf6Ps5+9Ln/adFK1P4iSr6jK6ZYm76
         fR3gRj5Y1C1QVCMJi4sqEETFCjfuEZMOZApxYz1eqmVGlwetjzwxPK+81yhXcQPCYQoy
         14IQ==
X-Google-Smtp-Source: ALg8bN45dgSFZYcm+zGi65miW7qopuu4TeQu4nqCYJSidDyIUBobIzzQRL8h0VOde/VcbbUE/YeMUw==
X-Received: by 2002:a9d:1421:: with SMTP id h30mr28318662oth.321.1546402597919;
        Tue, 01 Jan 2019 20:16:37 -0800 (PST)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id 21sm29760692oie.24.2019.01.01.20.16.36
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 01 Jan 2019 20:16:37 -0800 (PST)
Date: Tue, 1 Jan 2019 20:16:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Vineeth Pillai <vpillai@digitalocean.com>
cc: Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, 
    Rik van Riel <riel@surriel.com>
Subject: Re: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
In-Reply-To: <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1901012010440.13241@eggly.anvils>
References: <20181203170934.16512-1-vpillai@digitalocean.com> <20181203170934.16512-2-vpillai@digitalocean.com> <alpine.LSU.2.11.1812311635590.4106@eggly.anvils> <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102041628.U5SOdxDQiSbe2HRHmu9cCnDFimEb3HfuegI0TwPrqkg@z>

On Tue, 1 Jan 2019, Vineeth Pillai wrote:

> Thanks a lot for the fixes and detailed explanation Hugh! I shall fold all
> the changes from you and Huang in the next iteration.
> 
> Thanks for all the suggestions and comments as well. I am looking into all
> those and will include all the changes in the next version. Will discuss
> over mail in case of any clarifications.

One more fix on top of what I sent yesterday: once I delved into
the retries, I found that the major cause of exceeding MAX_RETRIES
was the way the retry code neatly avoided retrying the last part of
its work.  With this fix in, I have not yet seen retries go above 1:
no doubt it could, but at present I have no actual evidence that
the MAX_RETRIES-or-livelock issue needs to be dealt with urgently.
Fix sent for completeness, but it reinforces the point that the
structure of try_to_unuse() should be reworked, and oldi gone.

Hugh

---

 mm/swapfile.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- mmotm/mm/swapfile.c	2018-12-31 12:30:55.822407154 -0800
+++ linux/mm/swapfile.c	2019-01-01 19:50:34.377277830 -0800
@@ -2107,8 +2107,8 @@ int try_to_unuse(unsigned int type, bool
 	struct swap_info_struct *si = swap_info[type];
 	struct page *page;
 	swp_entry_t entry;
-	unsigned int i = 0;
-	unsigned int oldi = 0;
+	unsigned int i;
+	unsigned int oldi;
 	int retries = 0;
 
 	if (!frontswap)
@@ -2154,6 +2154,7 @@ retry:
 		goto out;
 	}
 
+	i = oldi = 0;
 	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		/*
 		 * Under global memory pressure, swap entries

