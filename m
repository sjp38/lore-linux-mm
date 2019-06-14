Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8246C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:28:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 737AD20851
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 13:28:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="voy0OQVz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 737AD20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB9D86B0003; Fri, 14 Jun 2019 09:28:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D69336B000A; Fri, 14 Jun 2019 09:28:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C7F816B000D; Fri, 14 Jun 2019 09:28:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE936B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 09:28:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k22so3730291ede.0
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 06:28:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/bEFMtHnd0Lq4R6BgJaHDb9jSNJdzL1pBjuE2g5cik8=;
        b=l6wbo42JJoXfGJzgnUvuXUJLQgkUpWYc03vh9yfKxYzfhFyMyXdTpnfyTTHxEFbA/9
         +WQg7JcTEmZbBQDba4pLPXhr8xaP9ekDD7R7QNiYQBDECoWuWExlSV0pUSBORxS09yOW
         wRaJC9QyJB63oHGfBMwIxIsPOHzkDtXVEOFoIv0r0FVHx9RY8Qgr8sXy7HTWvBm6dTbq
         hFjPGUQql6WJunFcm5cagHowTiRtyebEpQAOt4uEhXVQphrnGf0cpl8y3gzCQht0zCk+
         oCW/M06UHCq6Y8L6m0ao6mEtIVkgKcycdT2HW3B5/n5PHNJ9fm0qZ5IG5/eHqCojR1yX
         raGw==
X-Gm-Message-State: APjAAAUMPZqUEI9MGo9/rRcRuhNj8oevTOzV1yU4hMZKd30+1/jvbq06
	UnBLY7H5m1WnWNCs9mhMoARSJe+b2nP5LwUpTiBIDy9y19eGJ9RxJqzHu7gplTTdvdK0ecRGAy2
	BZDvXEYZGv5yMQbOCpRB/mAb3DnuRe2Cdg0j8nnp/rLLY2EV46puQuTYScq5NmDXMiw==
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr52889433edq.251.1560518918078;
        Fri, 14 Jun 2019 06:28:38 -0700 (PDT)
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr52889335edq.251.1560518917100;
        Fri, 14 Jun 2019 06:28:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560518917; cv=none;
        d=google.com; s=arc-20160816;
        b=CeEx6EuWuNhh45Vu763+KvQUeYqnMrHWcewUb2v1wyKmStbHAeseh4elvtRjHwU8Wj
         vYoByTMuUO1r83Ly4Z/D6rpnxOiOe5P9BOVbKfLmF0y9Yg47gKyLNbEjiONgu+Xx23Yi
         RQc6rffonRGWdFwfF3tpcw5Q9bqyH3+wwFK2IIImbW6BpX8x53ap6cLGyU+v36PAXJ2b
         Cc49T2pBXWtBJ/Ej3174m9mqD83tURCw3wRakqIVwOGyX+iwHu/Hlk7roiOmhVqJ7i/0
         dSxJaNIKCaC54LnxRSEXwbmoTwFGknas1dJglbx+pmTdcPvIEBtUVZu/Q/Ov6nn4Cd+M
         Rq4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/bEFMtHnd0Lq4R6BgJaHDb9jSNJdzL1pBjuE2g5cik8=;
        b=ODrBJrhnH9AmmzwrUUwI5Iy4S7c0k4AeighBsgrgpDWIuUP1wKucqpeayRuml2aqnv
         6SHYuo0Iye5aMux7NJZ5wnhsEias80ttD7dMLHVusqwPPr4/MefpDhbQNqS9Mu+p3kS3
         OiqPw3Ae56+6VWlJLqQeuBALfXo5gpHG3wOY09tFQN7B9FBqoIaHhxlnbQk2muwE4bcr
         Jd0FJeM8DkDg7j6Vl4g9QgwWiBiSD4Z1jo5UYbNZsKlhEDpFoc2bQAL9k8/EjypH9uOO
         XdqVsZCE8D2aS2DTo3bulJlVPGj17yULU2dJG/kNpm0Uo4mJg5ABuzGV9MidaoQPHLqh
         4aOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=voy0OQVz;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w44sor2878231edw.26.2019.06.14.06.28.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 06:28:37 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=voy0OQVz;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/bEFMtHnd0Lq4R6BgJaHDb9jSNJdzL1pBjuE2g5cik8=;
        b=voy0OQVzAPCvIAmwQgiYtlSleenOKuT/qpb01Z/+4pGuPKe1skxIJEkKDPpwS9HC3H
         d2duEeopfKNnnkQCjYrCgqImAQqW5bLMgwugLa222v0jda83+go22NOjY5PWaEnTSvyV
         KLhBwBJPS7SZJtXCtxB7OvQQqgSQ3kPKWmFUA1MJa9Wrfld0MCSAXdHUdWfClFnEwpgf
         sOPE6zcJmB0iiUGNc4akPixQ19M5SCYisvcVkA0vU6UsVVet+GzmRtabFV//WJ5mNMyj
         qJmJDuvP10aBanhB/RZD0uRXen4zbe9eWcwwuargF/sjpjd9dhGMdU11acHxnHjo9xUZ
         o5vw==
X-Google-Smtp-Source: APXvYqwTjBWiaWugHv92n/VOXJckmXdJ0ij79tTSCt3WN5QrjcsRYX/bfqnOjwWa25VDWFa14JeAyw==
X-Received: by 2002:a50:b178:: with SMTP id l53mr75879420edd.244.1560518916776;
        Fri, 14 Jun 2019 06:28:36 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id 34sm901697eds.5.2019.06.14.06.28.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 06:28:36 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 8857010086F; Fri, 14 Jun 2019 16:28:36 +0300 (+03)
Date: Fri, 14 Jun 2019 16:28:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 13/62] x86/mm: Add hooks to allocate and free
 encrypted pages
Message-ID: <20190614132836.spl6bmk2kkx65nfr@box>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-14-kirill.shutemov@linux.intel.com>
 <20190614093409.GX3436@hirez.programming.kicks-ass.net>
 <20190614110458.GN3463@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614110458.GN3463@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 01:04:58PM +0200, Peter Zijlstra wrote:
> On Fri, Jun 14, 2019 at 11:34:09AM +0200, Peter Zijlstra wrote:
> > On Wed, May 08, 2019 at 05:43:33PM +0300, Kirill A. Shutemov wrote:
> > 
> > > +		lookup_page_ext(page)->keyid = keyid;
> 
> > > +		lookup_page_ext(page)->keyid = 0;
> 
> Also, perhaps paranoid; but do we want something like:
> 
> static inline void page_set_keyid(struct page *page, int keyid)
> {
> 	/* ensure nothing creeps after changing the keyid */
> 	barrier();
> 	WRITE_ONCE(lookup_page_ext(page)->keyid, keyid);
> 	barrier();
> 	/* ensure nothing creeps before changing the keyid */
> }
> 
> And this is very much assuming there is no concurrency through the
> allocator locks.

There's no concurrency for this page: it has been off the free list, but
have not yet passed on to user. Nobody else sees the page before
allocation is finished.

And barriers/WRITE_ONCE() looks excessive to me. It's just yet another bit
of page's metadata and I don't see why it's has to be handled in a special
way.

Does it relax your paranoia? :P

-- 
 Kirill A. Shutemov

