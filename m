Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 130DEC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:47:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA8C721738
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:47:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="Zmts+InM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA8C721738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 625786B000C; Tue, 23 Jul 2019 09:47:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D7C88E0003; Tue, 23 Jul 2019 09:47:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ED098E0002; Tue, 23 Jul 2019 09:47:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19B1D6B000C
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:47:50 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n1so21960899plk.11
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:47:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Y4bJNUBVZG75Wm6fTCb90iILIxIQdsm+YFE3cN2CDj8=;
        b=VrPIpQqpLOlBC7m+8ES400MOT3fFSNnON4zIet7t6Y+OaQi3HcWadQQsqHQwWfJEmY
         yL3sYheGNRAoFe37uejfh1985xy2iZHa16CnKfGrZfdNchoo3AbmppPnJTHSJHF6Dh3Q
         wG9kGjhjyK6caNNmD/llzB+ieNW4t43lvxeFRx1YOmGAc0oYWlIMYVBm+u0yOxlCOsq0
         fkzkbMah+8lIvFpz1kWN8lxwnaxkoQCHWZJeWN1PDER0xW4pQrMMTs7M11ePORLzh+ju
         rhcaTJ3pTejwAMtCZrj8KALEuvqRdAuO0GxiAcTeIwcl0deAMRQ2VyGbHvgrpBHJlhPK
         T9Eg==
X-Gm-Message-State: APjAAAXSGUBwVmhl+SQHgKQArI08Mp+JrKGZSGYnRecuQuIRW3WlyYr7
	017yL8DOjbpaEL6C+X2Qqqd4pWKoryKTcbMUOKatSGNph618IcynQfbzUqc9hhBMD9TaPzJdCgA
	EJS8VJYShmJO0TKElHRAq/dVtBPvYNRHWS26II6Vzfs7KEzljdyepWBAr7U7gCuVcQg==
X-Received: by 2002:a17:90b:d8a:: with SMTP id bg10mr82760974pjb.92.1563889669680;
        Tue, 23 Jul 2019 06:47:49 -0700 (PDT)
X-Received: by 2002:a17:90b:d8a:: with SMTP id bg10mr82760935pjb.92.1563889669000;
        Tue, 23 Jul 2019 06:47:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563889668; cv=none;
        d=google.com; s=arc-20160816;
        b=F9bw2++bpMYznIEh5ZlAdLprZcsVwKoZbzogxQjGRi5JsSbnFxx3es2p50LpBq+OiV
         T9Nco+UIfl/EgB19mPlELL0sZpE8vb9lG54g8x+4hL2PK8hzJ2+TvW3Y18seaBDOO/aI
         5ZIRsq6UfB53CQHc2KF5vvjYWIPXeduDZp3taPpKmOqfJbjBNwD+vsxR7ExMb/xcU9Gz
         E53Wf/fAWo/1ZXcTE7vDudZvMRwnKw+XeZIRp6cIfzlAlCFjV4o0YuCL39+U8dbztvPJ
         GrESaAP+QdqoXRzZiTs/vhdzrkH5qJgDH2asR4meqgXKahGah2oczF9WKyy8p4DGf75D
         pbeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=Y4bJNUBVZG75Wm6fTCb90iILIxIQdsm+YFE3cN2CDj8=;
        b=xy4EK7KPo3PdVS853aW3c20aaNEyanl98wTyGUtbD3fVi9oIPVTxTtyTt3S3E0mIKC
         QCeihy4ZJ+vB7Efp4nqKJNFnuXaxw2aRjdPthg2RvOyNE8WFuw2vGKNo5MS84MsMFmLP
         QIlRxC4eNLIUjUuGGPPvGtctHOsCNhKisKVrFrUW+TBs5b3BZm/EQIrUCouZ6e2Atz/z
         kKqrAX9jOk7w6gxXx+nihVVCOZFoxEBx1G8evhPqC5p503IbZ7Y0ls+t+SQiVAamjUKZ
         cDLY07jzDkhzgTi4fOy9y9Tmbj0k8PccXh4OAPyKUZADYfe4Ex6UgWaIIix3UETm46H7
         iy0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=Zmts+InM;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34sor7560145pgl.9.2019.07.23.06.47.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 06:47:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=Zmts+InM;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=Y4bJNUBVZG75Wm6fTCb90iILIxIQdsm+YFE3cN2CDj8=;
        b=Zmts+InMHsGjlJGme/8wFfX+TuhCwWTW+otdQ5V8txyciEL0cqRu54oilSH2RbNNAF
         VWdY0Y/WyGvj48CrXvtBZLJzvdZFqixczAL7t2xx2vgMiD6TpktWsVIczAVKZN0pibRE
         X3xgb5a1uRr0Khp6dguCzf7wxkuf0OkwWPAOo=
X-Google-Smtp-Source: APXvYqy1yaJdw72Q0Nn6ojy3Q+rfO8ub0HIQhJmz+v+fs5k97MSDA2l1FqDyB6T38VJefPW//aW01A==
X-Received: by 2002:a63:20d:: with SMTP id 13mr65441358pgc.253.1563889668469;
        Tue, 23 Jul 2019 06:47:48 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id v126sm11955926pgb.23.2019.07.23.06.47.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 06:47:47 -0700 (PDT)
Date: Tue, 23 Jul 2019 09:47:46 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com,
	Brendan Gregg <bgregg@netflix.com>, kernel-team@android.com,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>, carmenjackson@google.com,
	Christian Hansen <chansen3@cisco.com>,
	Colin Ian King <colin.king@canonical.com>, dancol@google.com,
	David Howells <dhowells@redhat.com>, fmayer@google.com,
	joaodias@google.com, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>,
	minchan@google.com, minchan@kernel.org, namhyung@google.com,
	sspatil@google.com, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, timmurray@google.com,
	tkjos@google.com, Vlastimil Babka <vbabka@suse.cz>, wvw@google.com
Subject: Re: [PATCH v1 1/2] mm/page_idle: Add support for per-pid page_idle
 using virtual indexing
Message-ID: <20190723134746.GB104199@google.com>
References: <20190722213205.140845-1-joel@joelfernandes.org>
 <01568524-ed97-36c9-61f7-e95084658f5b@yandex-team.ru>
 <8b15dac6-f776-ac9a-8377-ae38f5c9007f@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8b15dac6-f776-ac9a-8377-ae38f5c9007f@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 01:10:05PM +0300, Konstantin Khlebnikov wrote:
> On 23.07.2019 11:43, Konstantin Khlebnikov wrote:
> > On 23.07.2019 0:32, Joel Fernandes (Google) wrote:
> > > The page_idle tracking feature currently requires looking up the pagemap
> > > for a process followed by interacting with /sys/kernel/mm/page_idle.
> > > This is quite cumbersome and can be error-prone too. If between
> > > accessing the per-PID pagemap and the global page_idle bitmap, if
> > > something changes with the page then the information is not accurate.
> > > More over looking up PFN from pagemap in Android devices is not
> > > supported by unprivileged process and requires SYS_ADMIN and gives 0 for
> > > the PFN.
> > > 
> > > This patch adds support to directly interact with page_idle tracking at
> > > the PID level by introducing a /proc/<pid>/page_idle file. This
> > > eliminates the need for userspace to calculate the mapping of the page.
> > > It follows the exact same semantics as the global
> > > /sys/kernel/mm/page_idle, however it is easier to use for some usecases
> > > where looking up PFN is not needed and also does not require SYS_ADMIN.
> > > It ended up simplifying userspace code, solving the security issue
> > > mentioned and works quite well. SELinux does not need to be turned off
> > > since no pagemap look up is needed.
> > > 
> > > In Android, we are using this for the heap profiler (heapprofd) which
> > > profiles and pin points code paths which allocates and leaves memory
> > > idle for long periods of time.
> > > 
> > > Documentation material:
> > > The idle page tracking API for virtual address indexing using virtual page
> > > frame numbers (VFN) is located at /proc/<pid>/page_idle. It is a bitmap
> > > that follows the same semantics as /sys/kernel/mm/page_idle/bitmap
> > > except that it uses virtual instead of physical frame numbers.
> > > 
> > > This idle page tracking API can be simpler to use than physical address
> > > indexing, since the pagemap for a process does not need to be looked up
> > > to mark or read a page's idle bit. It is also more accurate than
> > > physical address indexing since in physical address indexing, address
> > > space changes can occur between reading the pagemap and reading the
> > > bitmap. In virtual address indexing, the process's mmap_sem is held for
> > > the duration of the access.
> > 
> > Maybe integrate this into existing interface: /proc/pid/clear_refs and
> > /proc/pid/pagemap ?
> > 
> > I.e.  echo X > /proc/pid/clear_refs clears reference bits in ptes and
> > marks pages idle only for pages mapped in this process.
> > And idle bit in /proc/pid/pagemap tells that page is still idle in this process.
> > This is faster - we don't need to walk whole rmap for that.
> 
> Moreover, this is so cheap so could be counted and shown in smaps.
> Unlike to clearing real access bits this does not disrupt memory reclaimer.
> Killer feature.

I replied to your patch:
https://lore.kernel.org/lkml/20190723134647.GA104199@google.com/T/#med8992e75c32d9c47f95b119d24a43ded36420bc

