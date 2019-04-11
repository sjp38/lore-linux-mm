Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74291C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:33:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F43F2083E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:33:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OBiPuxAU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F43F2083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFCA06B0003; Thu, 11 Apr 2019 11:33:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAD596B0005; Thu, 11 Apr 2019 11:33:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99D176B000D; Thu, 11 Apr 2019 11:33:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6E56B0003
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:33:29 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y10so4299769pll.14
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:33:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KCh9rGSq/KL+6mqDbYpIlhQVTAEOXp0DwEg9orG5vFk=;
        b=LU1SWXna4Bgve5TEkX8j+SN84kozr6+s17/d1UHJvtG7QKNw6XLo2+FynJgDzjKDgp
         b5Nxa+h+YvaLoTjGo8otOL5Zn48d5z8uvlcAN5V5lyFbRW215ViYzrHXeEG7EluQmiqD
         kdVJA+FsUXd/6Cp2imjKWoH5m5dWChWJga63bbibSxvSovTstS39AExQu/eQJtpl2RWn
         hOhGPvoqj58huQWZzeHEJDJb5HmAkKc9yNRMqyIINgRhX04O14rqox2VmJ+8Z69+BVCU
         EfBaLTYI3sDYjJo107TsCuhPzV8UX/0sX4mtxijqQo9y5NfRgNux7Lr4f1Qpsg5bkvZ2
         jwMA==
X-Gm-Message-State: APjAAAUqdKpceXH1EYjc89lNFXYZ5S9dzQ5BiMCS5X0CinDlMVKXgQrB
	isBXdfBW2GKweBHbdzQU22IRYUTp+0oplJkS49qvAsy0vE6F3DX8wnJeER//yg7wusBUau4oI+o
	ONpjAQVHtzR7Zu11DDKA/ToyXpvLDOd14nz5vh6HSnLJYqI40N0TjRFquYj3MvyFFjw==
X-Received: by 2002:a63:e004:: with SMTP id e4mr48222836pgh.344.1554996808906;
        Thu, 11 Apr 2019 08:33:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy93/h3xOdk0c1fa9qQJYP5G9iN8Q6HaE+j5dqihFpd5yHRcAdznbtX8Udp/syPX09M5HIb
X-Received: by 2002:a63:e004:: with SMTP id e4mr48222782pgh.344.1554996808298;
        Thu, 11 Apr 2019 08:33:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554996808; cv=none;
        d=google.com; s=arc-20160816;
        b=YZMh0y9/G6VX9AFhYVDWhrlzyGfkCWiOTghhkQYgpIVaSfakBe7vZWP2GeLNn/rckw
         bwlyb7u1K9x8BQtv1+0XctwSOgolFbTrLnXM2I6d1adKbW6mZ46FDAscWxcyu50X6B4T
         F/Z/vhKdobkO+79vNliPEc47vuwnQXf2Sq3fR5lkuJhECgdP0Je1y43zlKsymHfkUCUl
         9CYeI200F0ocT0lmB5ram7hOlv3BySUMhA8Md5HKdYAJPUwAw1qYNU9MSg5nk6nBYlVS
         6Q5AfDcVr2qyPZfvlShYTz1GdHWCCZFhvO06QZo80BJR9JCiabtQUsTTc7EFzIsBVTmL
         bPiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KCh9rGSq/KL+6mqDbYpIlhQVTAEOXp0DwEg9orG5vFk=;
        b=b+eya5jQXKxK5amWugoxkZocKR328egAmgp3suHLsFVEZCU2B/jEqXC6ejSwmGEqwR
         xlu0t6WH839T00q/QO66J5J4gioi0w7/r8Ic/0P/u1fl+D8+f7ZblUGYXBY2rKkHNk2J
         Cgs6cwaZ6NhGNeE1srPyb9mBCrpJi4rdJtEidgOuiI78W5PTp/XPy4njh7enlujmSuZZ
         hqVgiCSbrs4AqgCZ9XcT1Ll/rnb16b345ZuYIGMwf2LzM6S93mS9ltuFBwa8ztJPJ64l
         4xwQ01kBvGYD4qdxGJ4GbSe1+8yNVv45LWhLn07kB39Xdt3m2XRLOD4ydiyUxE/594CK
         ykHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OBiPuxAU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s9si22922009pfa.282.2019.04.11.08.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 08:33:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OBiPuxAU;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=KCh9rGSq/KL+6mqDbYpIlhQVTAEOXp0DwEg9orG5vFk=; b=OBiPuxAUqmi4MzzMOAbfGUg3p
	OsRROYl/3oMT+lqMELNrjtTdjmaVU12ZIvPy1FUKd7IaQdx3001ZjQfUwxsPDbpEpQ4t3K1anfRwb
	mfeQVW5DYiApCBa1+F1q0ISj2o5jsPKF9RB5Qygpqo9r2RefUae3Vg7XKslgaIrXSDE4oF9unbEwM
	61iSdWXRcAqbiynMfNqpz99f+OKBTkQruOitwbYhW77q3qFUfMCl1G4UNlsI5GFmcKgYQhr7UKH+Q
	0CUUcg3x87CVAUNx3f6AE58umR0TooNMRd/ErVEm+IV/gev4UEn3czJF2NE7Kv61qYZrM1Bkcmzqj
	niIdh0kKw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hEbhR-0004hT-HN; Thu, 11 Apr 2019 15:33:13 +0000
Date: Thu, 11 Apr 2019 08:33:13 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com,
	yuzhoujian@didichuxing.com, jrdr.linux@gmail.com, guro@fb.com,
	hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp,
	ebiederm@xmission.com, shakeelb@google.com, christian@brauner.io,
	minchan@kernel.org, timmurray@google.com, dancol@google.com,
	joel@joelfernandes.org, jannh@google.com, linux-mm@kvack.org,
	lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
Message-ID: <20190411153313.GE22763@bombadil.infradead.org>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411014353.113252-3-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411014353.113252-3-surenb@google.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> pidfd_send_signal() syscall to allow expedited memory reclaim of the
> victim process. The usage of this flag is currently limited to SIGKILL
> signal and only to privileged users.

What is the downside of doing expedited memory reclaim?  ie why not do it
every time a process is going to die?

