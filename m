Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2876C742BA
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:07:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A668F2080A
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:07:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="A9qfZo9s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A668F2080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 203CE8E0149; Fri, 12 Jul 2019 09:07:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B3E88E00DB; Fri, 12 Jul 2019 09:07:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A3788E0149; Fri, 12 Jul 2019 09:07:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDC178E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:07:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a20so5499859pfn.19
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:07:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=T+6x5moI4ijHJRrmZf1/HMLH18HnK/GwuxqCFGxwS5I=;
        b=CfzJZOS06geYrZ9ckpNCAVrXuRJzJu9PnPDZz6yPCyMtG7udRNJEJmby/LEApizXv4
         jqlRnK6fbCiVClOZuf1ZxRrmtNowKcnmtHGghOc1RqDi4gzwFcAp7i8lLzvt1/wk6G22
         mnT+7EDLv6GlMuxflQx+hnrkfXD1AQst0ZXptPhvVUQT9WXcEh1uhbFYOvbnPjcG624F
         59qmJnLrekHhVBP4pgfPm/+w+vqel40XXjlgtouuRKZv3Qwp5FzaaNB33U3ep1ufiMVK
         oi6E62Uhrl33xBTY7miyKwqLjSOmhh3xIrusCbt8B4uJsMl6Gh+X9rQ7UOgjKoy2VPSN
         B1UA==
X-Gm-Message-State: APjAAAVCztBp+/rBdD+M9UmEcl0kHWv2FO+bJR4qK5NFH1jW2WNC14cl
	kpCkW07mRhWJoqs03i+EdIA8dsqRGcncolreTDNe8FeuR/U8mZUhi7nsu3MJXcbrAKNGVwEeJjP
	RdHsIGOPAQ3gFnIt1aiccn3N10DU+5Adf6znpr2lhq77EzXShpmuoox9sLWg0tpHQXA==
X-Received: by 2002:a17:902:b68f:: with SMTP id c15mr11542994pls.104.1562936848408;
        Fri, 12 Jul 2019 06:07:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypT9UrI1n6mnZVedLSneQdHW4fVqgmURjzyX0Ss8zvJd3h0YS308Sz4YuaxQuVcPCB/8B5
X-Received: by 2002:a17:902:b68f:: with SMTP id c15mr11542937pls.104.1562936847790;
        Fri, 12 Jul 2019 06:07:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562936847; cv=none;
        d=google.com; s=arc-20160816;
        b=BWmO7xRcm85ijcIo2IPiKL8sryJyJL9cN8CJRvl3/AOMC/iJrf8NputTc+oht+BkTa
         K7/88biGEshaSP2fF+NLeI5fgFR2D1bBPP/7rxQ12O3Q0NpG5K5S2RMWx1J4l/ZPB7kR
         HgXoH4EDvXGfxXI8gfrDXwP+LuVVagkJFjikG2s25Xs3yjUrXgGlAEVENJ0RHIUgBF/Y
         YEDGk0S//TJSVwTqXPlvQ0l5HajahNYCofXtwQjUjuLSgIpU2y7zIpCDbL3Y/AA7e7PO
         yGQyQe6KD+Ivr+oQ9NU2737K6HtApnPnaWJVIzqiJEAZbBexwlhfk78r71ezVDugqwnz
         ieVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=T+6x5moI4ijHJRrmZf1/HMLH18HnK/GwuxqCFGxwS5I=;
        b=gG66XY50Q3VanxGjQ+Lj6M3Z44ChTR1WYV9ypDbPyBQ5ecHOZQrbYf/Iz+EL5S1hfX
         nF5hUf6gmBpWP4zUjL4jcPeGbvOHNZRwiH122AlhnpEBBFYoLXIo0hPSVy+tAaSWpx/0
         eSQAjac0NEcfWy5pc3ZOVloxBGSI3btCbxSNkaDjT0Fd9pQOUGNkBuqKYUEx5UGsiOaF
         UlPtx1lJX7QJ6Z1et7RqaQWXopRHYJEbUkOK5gYW1UAOZMc2M0tUH8X7/49FwzOY+JHO
         X1XqO/CQh6++WkpaUUOF2X+e+fz8u5Q0FivBGG071du0xa3XKMjNMFSnr7Qy9ukBEanh
         MzbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=A9qfZo9s;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k137si8131585pga.59.2019.07.12.06.07.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 06:07:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=A9qfZo9s;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=T+6x5moI4ijHJRrmZf1/HMLH18HnK/GwuxqCFGxwS5I=; b=A9qfZo9sr9OqLZBSfJxGmDAhT
	ZZZxl019nrb97yxFuvWomOiduo/GheSG9p3CTkWHjArZa/UIhnADvaTM2LCb7qveLtJPfNHxCY5Ap
	VzbwMtbtgFfbjgLgq3H8NkhaQxltntOiM2EFFj4c4+An38q/pSMHUFlzuTruF3le5kVT5DstWyawJ
	0IM58fcRQ4R3Qv6CHhx3ZR71wy6honrRdfbJ4ndntJn2vZRnPGcXcNfzUR/MDifTTAU/5Pb33Ygw9
	xfBSaPB1K6FZ6cTT7Qfx0psmi4ERnnwigSBp81Wf0w32b4Utoxw/Xs+GMw7Sw+zKMa/nE42cMR4oA
	6jQAdEZ5w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hlvGk-0006ES-Se; Fri, 12 Jul 2019 13:07:23 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E8AA3209772E8; Fri, 12 Jul 2019 15:07:20 +0200 (CEST)
Date: Fri, 12 Jul 2019 15:07:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
	mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
	x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
	liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
	rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
Message-ID: <20190712130720.GQ3419@hirez.programming.kicks-ass.net>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <20190712114458.GU3402@hirez.programming.kicks-ass.net>
 <1f97f1d9-d209-f2ab-406d-fac765006f91@oracle.com>
 <20190712123653.GO3419@hirez.programming.kicks-ass.net>
 <b1b7f85f-dac3-80a3-c05c-160f58716ce8@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1b7f85f-dac3-80a3-c05c-160f58716ce8@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 02:47:23PM +0200, Alexandre Chartre wrote:
> On 7/12/19 2:36 PM, Peter Zijlstra wrote:
> > On Fri, Jul 12, 2019 at 02:17:20PM +0200, Alexandre Chartre wrote:
> > > On 7/12/19 1:44 PM, Peter Zijlstra wrote:
> > 
> > > > AFAIK3 this wants/needs to be combined with core-scheduling to be
> > > > useful, but not a single mention of that is anywhere.
> > > 
> > > No. This is actually an alternative to core-scheduling. Eventually, ASI
> > > will kick all sibling hyperthreads when exiting isolation and it needs to
> > > run with the full kernel page-table (note that's currently not in these
> > > patches).
> > > 
> > > So ASI can be seen as an optimization to disabling hyperthreading: instead
> > > of just disabling hyperthreading you run with ASI, and when ASI can't preserve
> > > isolation you will basically run with a single thread.
> > 
> > You can't do that without much of the scheduler changes present in the
> > core-scheduling patches.
> > 
> 
> We hope we can do that without the whole core-scheduling mechanism. The idea
> is to send an IPI to all sibling hyperthreads. This IPI will interrupt these
> sibling hyperthreads and have them wait for a condition that will allow them
> to resume execution (for example when re-entering isolation). We are
> investigating this in parallel to ASI.

You cannot wait from IPI context, so you have to go somewhere else to
wait.

Also, consider what happens when the task that entered isolation decides
to schedule out / gets migrated.

I think you'll quickly find yourself back at core-scheduling.

