Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5494C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 01:36:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EF85218A1
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 01:36:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="iOZl57fg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EF85218A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A6888E000B; Mon, 11 Feb 2019 20:36:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1581B8E000A; Mon, 11 Feb 2019 20:36:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06CD18E000B; Mon, 11 Feb 2019 20:36:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B60E98E000A
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 20:36:14 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 59so822669plc.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:36:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AEB07sD0Nm37HdBEPjbf5+EZZV+iXv560mnR7taNMDo=;
        b=tMntiwuSO3hmzCPq11UpC84WovZ0snaGdWY7V2heghkaocIEGeZFN+ba2mDcGbURRU
         6g6l5IsEuFIZKmIV0z4yRMPo19WMehAKZJiEO+XVU0y+WaOXcLXcMYC+tb4k6eIsvChE
         h8BPd+RSBjezlNZk5VhTmz9EnWV9sSUYOz9c5x2hPI/vY5zlzemUfU4mODTMucSlXHrh
         tmMc3QD5+RqmrSDP/7IDoWj+8NGCwuNDzYzR0/GNFVM68Yl05WQgfR7WzGyqsEPh/mYM
         Tz4hU+WO258JI8jkYcfYzyUUeooc9Bc+WwieOh9FNnxm5l4LfOFmUo8pGr1w/g732I0u
         er8Q==
X-Gm-Message-State: AHQUAuaUFm3ZT+0EMbyViw9b6OJEO2yjsO9eW5GuDgqbHD+wnQSthR/A
	UdAdalgokpqJyK8RY/8ijUY8ey8A/Es/D+V8qd9tM5klR+oVECGUKgCLUAZMdfAaVey6l+ExWNy
	loooOkUHk9VsrPiJ795N6gAnv9+jciF9dhSF1Kj/0m5V0iH0hPuVVYlYPis1rJMWUmQ==
X-Received: by 2002:a62:1d0c:: with SMTP id d12mr1358943pfd.126.1549935374186;
        Mon, 11 Feb 2019 17:36:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iat1jJG8MYzNzmlJvCYc50DvKIbvTHjDn8dlNytC0hdBMqLwxVrYhAGpjp7RxpC8EKPrT+O
X-Received: by 2002:a62:1d0c:: with SMTP id d12mr1358867pfd.126.1549935373318;
        Mon, 11 Feb 2019 17:36:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549935373; cv=none;
        d=google.com; s=arc-20160816;
        b=skz0tJtpSOPaAfwolFFy6si2fKhxv7shJpUoJ5bPL5RDe7w/eG0BOuGBRb4TbNxibF
         ilRoSIE628WLs2c/FMD6ev5oTxi++UZkGZfKBPDEF5QjCgnhxX3418FXN+SBmePSzDH/
         /XAiPYQ3Z7erf9gAYhOgQqwoysUaSUTACmka4BJD0SgM5e9jQkncyTXXYIJwE2LflPVE
         9EWEdJJDWtXxuiVaWTCXlxfkOJR0lk8eGCMArDygCFSu4HuHJEx7yxIsgl3KFMM1eiu9
         yKTi++knc95GB5iXo0ZQCrA0/VHuDR+vmj7m0nrdBOBDB62CF22yNeYPRZlYd33pWt1x
         3qdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AEB07sD0Nm37HdBEPjbf5+EZZV+iXv560mnR7taNMDo=;
        b=PBsC3kng8iDIO2eaZIwEKagziILmM42zR2dzdl1wG7NWOE0yPae6YZ9iUw/Jp7oA09
         O0snR49+tx/9f+LDvWTBdpIuDB3UKWzRpZFhY/Sgcz3v5SNf4X9twuaxW+SJUEZJerGG
         Ou+grzMa/QYmBS9ZZOAXR8jux6TrIGrZhxWowbjliEV/lutpYdMJnE85fwMNbOYO/Oj/
         eNJAuwuxdZ8fVMolk222wmo7T7Krb0bQFnMbtlPFFy6tcJUJ1dmI7aGbf+M1mZ9bCZ6w
         bC7YC3c8wFmXJ1a7i9zmAJ75TCLEDcv+DgvtzF/tZHUf81AR7n3CapxQoKIJpzFWWPOH
         Rkfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=iOZl57fg;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f12si10850523pgo.562.2019.02.11.17.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 17:36:13 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=iOZl57fg;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=AEB07sD0Nm37HdBEPjbf5+EZZV+iXv560mnR7taNMDo=; b=iOZl57fgU9wlCpGzjFNhMpfIt
	S5VVbkMFdabBrJSw3Xt+0t7Tfv9LwhP6d/mBzDyA4fgDJFQ8VQ71MdtKdGQ9GzZN7JU9DfdRCd+VY
	NlvH9TdZfqsFv7rB8ileVj7O6f6UYpMMRxM9+Kxx2mJq6zaai9ZlmaOyiixesWcn1iJHuZKuLQZn6
	Z/7IYWWjr6cIk27oieKFUp+I5cd0ux49D0VPnY4riVpGoSAkW4hmyW34IEqKXt4eoe3Z+znY9z5oP
	paDKlSnXLCV+TWOc/jfAmBrjxu04c0+TxQir0Pm9dzEwagQOKHDdUKHMjOSnVo4iAPCA/ww+9n/vl
	nsuVeIwFQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtMzW-0004MR-OT; Tue, 12 Feb 2019 01:36:06 +0000
Date: Mon, 11 Feb 2019 17:36:06 -0800
From: Matthew Wilcox <willy@infradead.org>
To: "Paul E. McKenney" <paulmck@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	kbuild test robot <lkp@intel.com>,
	Suren Baghdasaryan <surenb@google.com>, kbuild-all@01.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 6618/6917] kernel/sched/psi.c:1230:13:
 sparse: error: incompatible types in comparison expression (different
 address spaces)
Message-ID: <20190212013606.GJ12668@bombadil.infradead.org>
References: <201902080231.RZbiWtQ6%fengguang.wu@intel.com>
 <20190208151441.4048e6968579dd178b259609@linux-foundation.org>
 <20190209074407.GE4240@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190209074407.GE4240@linux.ibm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 11:44:07PM -0800, Paul E. McKenney wrote:
> On Fri, Feb 08, 2019 at 03:14:41PM -0800, Andrew Morton wrote:
> > On Fri, 8 Feb 2019 02:29:33 +0800 kbuild test robot <lkp@intel.com> wrote:
> > 
> > > tree:   https://urldefense.proofpoint.com/v2/url?u=https-3A__git.kernel.org_pub_scm_linux_kernel_git_next_linux-2Dnext.git&d=DwICAg&c=jf_iaSHvJObTbx-siA1ZOg&r=q4hkQkeaNH3IlTsPvEwkaUALMqf7y6jCMwT5b6lVQbQ&m=myIJaLgovNwHx7SqCW_p1sQx2YvRlmVbShFnuZEFqxY&s=0Y32d-tVCGOq6Vu_VAGgVgbEplhfvOSJ5evHbXTtyBI&e= master
> > > head:   1bd831d68d5521c01d783af0275439ac645f5027
> > > commit: e7acbba0d6f7a24c8d24280089030eb9a0eb7522 [6618/6917] psi: introduce psi monitor
> > > reproduce:
> > >         # apt-get install sparse
> > >         git checkout e7acbba0d6f7a24c8d24280089030eb9a0eb7522
> > >         make ARCH=x86_64 allmodconfig
> > >         make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'
> > > 
> > > All errors (new ones prefixed by >>):
> > > 
> > >    kernel/sched/psi.c:151:6: sparse: warning: symbol 'psi_enable' was not declared. Should it be static?
> > > >> kernel/sched/psi.c:1230:13: sparse: error: incompatible types in comparison expression (different address spaces)
> > >    kernel/sched/psi.c:774:30: sparse: warning: dereference of noderef expression
> > > 
> > > vim +1230 kernel/sched/psi.c
> > > 
> > >   1222	
> > >   1223	static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
> > >   1224	{
> > >   1225		struct seq_file *seq = file->private_data;
> > >   1226		struct psi_trigger *t;
> > >   1227		__poll_t ret;
> > >   1228	
> > >   1229		rcu_read_lock();
> > > > 1230		t = rcu_dereference(seq->private);

So the problem here is the opposite of what we think it is -- seq->private
is not marked as being RCU protected.

> If you wish to opt into this checking, you need to mark the pointer
> definitions (in this case ->private) with __rcu.  It may also
> be necessary to mark function parameters as well, as is done for
> radix_tree_iter_resume().  If you do not wish to use this checking,
> you should ignore these sparse warnings.

radix_tree_iter_resume is, happily, gone from my xarray-conv tree.
__radix_tree_lookup, __radix_tree_replace, radix_tree_iter_replace and
radix_tree_iter_init are still present, but hopefully not for too much
longer.  For example, __radix_tree_replace() is (now) called only from
idr_replace(), and there are only 12 remaining callers of idr_replace().

