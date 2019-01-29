Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13308C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:09:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3AC220844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:09:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gVcqUjmO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3AC220844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C1528E001C; Tue, 29 Jan 2019 14:09:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56F988E0001; Tue, 29 Jan 2019 14:09:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 485068E001C; Tue, 29 Jan 2019 14:09:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2528E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:09:06 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id g188so14453920pgc.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:09:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Cua5YyY3UCe/2GZUwqOSzY6Efy7wQkjzkYSxkI+PGIc=;
        b=IadmxelqAMLUSH48mlzSjAxZT/a9MKypo0j6YtiO5kVtBd9w099G7QKogH2Y9usjl3
         Nuj/mdhKZPce74bmV0LHvtIt2iEVz39JakJE3IorLc190ROtn/1kmWa003/3Dn43L4tW
         +JqKRmCV7LptMK3tFNMZiuRQ6c918S+SBeHNH5w3b8NklrJniiqs9MGzn+TJ+W6GAfC9
         H/ESmvvZyq9WP6nmQSDL4R9JwfBCywLK6ccrlvVqEGDbk70lacqcJFTzJp+paAsm9Ajd
         ZtbwGs/0+8iPrrwaSi8abVgprXbyliFYlLcw81aNHObRCwOoPy4oTnIG17SwZ4CIgZZK
         PuGA==
X-Gm-Message-State: AJcUukeT64IxQwOrzL3W/dcg/9Tmzt09iwX+AuAR1NE0BRWUZ6QQBz+5
	rKSeiCy18TsHPUjCaVxeh65b/AozItuSPpty4N2NDX8P+ur2GWHiilWIp4F24svXH+MHcICzsgP
	dflPivrmNGtAm8+kXAvbc//thpvazNiDdcYn+1oChdwECYtX318H4Wv626+bBxDPnNw==
X-Received: by 2002:a63:da45:: with SMTP id l5mr25013602pgj.111.1548788945681;
        Tue, 29 Jan 2019 11:09:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4ojXjU0SRW36gzI5ggvtzdYw9xnOwErSa3B24x7mN7VJucJaR2DSY4Yi58Bw8DVijdJgPk
X-Received: by 2002:a63:da45:: with SMTP id l5mr25013555pgj.111.1548788944916;
        Tue, 29 Jan 2019 11:09:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548788944; cv=none;
        d=google.com; s=arc-20160816;
        b=JWum+LJdnjrZNHjSgHQrelKDyjI1G+vpIA28E/7o1a1W82/AfNcgMX949H9NPi8gc7
         3rVoWfR2J6ZVx/ostEqgkt8Nq90IFZkrjU+wrhB1PTiOMyvDr99UuuI+buToN/sTXNXs
         NgGMn6gOhZECEqf9WT6XCjUsMaH/SV7bEcsj/zIBeaQDgNnlFlYDoTLVSAcfvQNjAiSf
         sdCtueBGKUItW/qT/jBq+KakBiJL7JkBTgozabSd7nVjWMmZlE+iVUs9LRhD2fQIAXYe
         ciS9QsJ6mSP6Jom/YR1u9koBF2aYdW2qO6jDGAAFtuc/71DWHb8bPiWgn5tkevDwFYml
         aRAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Cua5YyY3UCe/2GZUwqOSzY6Efy7wQkjzkYSxkI+PGIc=;
        b=LDXlQCMGyh25va9XUOlKT1NX3vL10D5WoSk43nl2fBxTD73VuWzGoh5JAzGNE4IAwv
         lnES2c/obhWnNUIBt2O6q4HRFe1wpQ3Cyog2ktIwM+hVT9MsTSWAByqigbpJccHv97V2
         i36mk2RLy6W82dClgTqL8oDNHaUaZl0GC5p+hu7skvg81Em+a2PhSrkB6PyjvhRLhX+d
         hA9H1Mj8odX1UFHHXvPY3FP9zLHk786Ml3ufik8U9unSf+VLQrawOhNxYnbNqy0SWXR+
         P6KZ6YTjb87eWxEfypoHFSKeSamHtJDFGMsUmC9+mgmbvJJuYbjMk4pEtdPCGWOvW5XE
         hfjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gVcqUjmO;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x1si38000238plb.366.2019.01.29.11.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 11:09:04 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gVcqUjmO;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Cua5YyY3UCe/2GZUwqOSzY6Efy7wQkjzkYSxkI+PGIc=; b=gVcqUjmOXq5LVw8P80svC9HYP
	AV8bRa1e6rYmZwXtE6cNeG0FGcm8XcguwKoNEFRTx7ABc+Nx/PtM4QjuVMLk/RfooU0lRdnkWxOqT
	QRzoVNadl1qrmH2b/smBvJ9lU7mKAOS0dIfiwUBYj+kivO4cslH6ojOFJH/BPXeYDEcZWq2+4VDuH
	KymK/JiSENNQxnkaa9PJ5pz11okYs9d5b4ZeGmCvOtzi8CKSuHWlJUnZhwhOn4KQ4rEiylU4FISEn
	iLyexJFSEeziwNmFVxQ7FBZ122QdaCxlvNN0P6++7mqVuXcvrpnc6QI7RMXH5dLVQs1bJW0S+fMlb
	WpgokPBRg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1goYkf-0003Mo-DW; Tue, 29 Jan 2019 19:08:53 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 84A3F201EC171; Tue, 29 Jan 2019 20:08:51 +0100 (CET)
Date: Tue, 29 Jan 2019 20:08:51 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Tejun Heo <tj@kernel.org>, lizefan@huawei.com,
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk,
	dennis@kernel.org, Dennis Zhou <dennisszhou@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jonathan Corbet <corbet@lwn.net>, cgroups@vger.kernel.org,
	linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, kernel-team@android.com
Subject: Re: [PATCH v3 5/5] psi: introduce psi monitor
Message-ID: <20190129190851.GA2961@hirez.programming.kicks-ass.net>
References: <20190124211518.244221-1-surenb@google.com>
 <20190124211518.244221-6-surenb@google.com>
 <20190129123843.GK28467@hirez.programming.kicks-ass.net>
 <CAJuCfpGxtGHsow002nd8Ao8mo9MaZQqZau_NLTMrZ8=aypTkig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpGxtGHsow002nd8Ao8mo9MaZQqZau_NLTMrZ8=aypTkig@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 10:18:20AM -0800, Suren Baghdasaryan wrote:
> On Tue, Jan 29, 2019 at 4:38 AM Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > On Thu, Jan 24, 2019 at 01:15:18PM -0800, Suren Baghdasaryan wrote:
> > > +                     atomic_set(&group->polling, polling);
> > > +                     /*
> > > +                      * Memory barrier is needed to order group->polling
> > > +                      * write before times[] read in collect_percpu_times()
> > > +                      */
> > > +                     smp_mb__after_atomic();
> >
> > That's broken, smp_mb__{before,after}_atomic() can only be used on
> > atomic RmW operations, something atomic_set() is _not_.
> 
> Oh, I didn't realize that. After reading the following example from
> atomic_ops.txt 

That document it woefully out of date (and I should double check, but I
think we can actually delete it now). Please see
Documentation/atomic_t.txt

> I was under impression that smp_mb__after_atomic()
> would make changes done by atomic_set() visible:
> 
> /* All memory operations before this call will
> * be globally visible before the clear_bit().
> */
> smp_mb__before_atomic();
> clear_bit( ... );
> /* The clear_bit() will be visible before all
> * subsequent memory operations.
> */
> smp_mb__after_atomic();
> 
> but I'm probably missing something. Is there a more detailed
> description of these rules anywhere else?

See atomic_t.txt; but the difference is that clear_bit() is a RmW, while
atomic_set() is just a plain store.

> Meanwhile I'll change smp_mb__after_atomic() into smp_mb(). Would that
> fix the ordering?

It would work here; but I'm still trying to actually understand all
this. So while the detail would be fine, I'm not ready to judge the
over-all thing.

