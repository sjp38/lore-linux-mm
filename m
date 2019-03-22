Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6D1AC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:47:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B776206BA
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:47:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="tMfQjo2J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B776206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FF786B0006; Fri, 22 Mar 2019 13:47:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B1D66B0007; Fri, 22 Mar 2019 13:47:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1783B6B0008; Fri, 22 Mar 2019 13:47:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D21996B0006
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:47:57 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v16so2982948pfn.11
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:47:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=u0uNQgdU9iPi2AZeRa/JpiB2eMPriaZmBEZB7zw2ODY=;
        b=sYbu+RyFB3jDqKXgWbjBMHsGSeXY0Bezz6XWW5Ko7xJkkI+ZmwoyGqW5PCkNk40du8
         O3/elbU+5NH4uCB250YG4RDA6ryn0DRkuOUMdAVJFCC1nGum2Q0D04tySwRt3KP894lR
         Q6P5eUKn9XBnMzdc3ZI0xgd/Y2aZgNXUd+TpuBLa/0dQty6QP7tssW12cCveS+sIbxBT
         udiPfPjqVfXErYcj2KpWwDUoDSBpyU+3G80cQeilPT2sVFe023s4Ok7O+SMdbpICN5Ip
         j2U3ve2P7aI9PGT4H3Kn3ceZKaX7XIitgtxVCsgflvGz8PA4SQ119letLLuXHe5YTb65
         z6Sw==
X-Gm-Message-State: APjAAAVAl72Qzc2k4rBIbDWqYzEDqZ7Nnhi0rY6gGUS0bs2v69Ko7efY
	Mp9o/vKZ+KxePpjWCBgYoi1lRgE08/PtpDvemDINKv5YiUmXgXD/c0gcw3qg8Mv4X57IGQGcfNz
	IGF3Ywk9J6/YAWqE8VxN3r5TRm/wYhzwyH6PBoLsbfaZ9CK78iQ9PSLQKxkleiES4yw==
X-Received: by 2002:a17:902:469:: with SMTP id 96mr10545863ple.46.1553276877337;
        Fri, 22 Mar 2019 10:47:57 -0700 (PDT)
X-Received: by 2002:a17:902:469:: with SMTP id 96mr10545805ple.46.1553276876498;
        Fri, 22 Mar 2019 10:47:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553276876; cv=none;
        d=google.com; s=arc-20160816;
        b=i2fuoOHv5kAbbbd/GoL9HBPNk2iUu0K+bbBC9Ip7aSF093iXakOlAP2jebqLSzqFPZ
         s2WpwVYlpJp6FFDhHNeZ3UiP3oO03qYJyXmQvTSCdMAtD59lEuN9tRd0Tw1NANEvmVgy
         RyXmM7NdsbdwVy9EB25exYPSaOqrSQ9aFJNmVAqKBYenwbh48T8sEKdVUqn5HzxT/iQ5
         Za9sZZvNOdhCRc8BV7o/q3iV1RNo4sAIDv13mejfU3di7R48tblifzqSAJHh7POcEZ86
         mIZOROI6ra6B2GWKhQE6yDqYtfOg0JugcHdYxM58g6NqjT/Gyjf0h8tr9fFZvNN3CCiS
         F0rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=u0uNQgdU9iPi2AZeRa/JpiB2eMPriaZmBEZB7zw2ODY=;
        b=N2ycp0YEDZeAumltVpDbPMcTF+MLaFpyAb2sPzerqifMGtbhEMVTU/t/D+Crc1qqX+
         C7R4X4vlP7neZcV87fLWh1CYtfRuj7ip4HAsXHAA50GY/rP3eW27nrUytRTIZPnA3AgO
         tcTh3pP8lMs+7jl1MGK65PH0PZuRmAJrCrt3LNG1fjnfLlW7HTrUCC2kYIDhoKGVn9uH
         mBfK21TAE5rEPBHby+pBe65d5o6y9gYS9dGwq2U4TpHsQ9BTGYjCy6enCU+HEm29BDbq
         Ef/1AmFMYpqgpmtSEdz1Gp4MJkFENflE68UtnCaYcF2a0WdxtElHz3t5LfSyMH++u7ln
         jC0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=tMfQjo2J;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s87sor2063386pfa.62.2019.03.22.10.47.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 10:47:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=tMfQjo2J;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=u0uNQgdU9iPi2AZeRa/JpiB2eMPriaZmBEZB7zw2ODY=;
        b=tMfQjo2J5b4Ie59iqxG7Mf0GQx3uzZheqE3eZnF37crg1+rgbgdWibKaxu3r3WfdRT
         XGjkXUX6cBTlKx7N0Ufy5sh6pEf44WLxi5m0w9CkA3UCmWEaVCTx7E5YZPAgtobA8+Cu
         VAz/NDQXr63ZnvFIo7ze0Xr9hu6RlOlayw3nU=
X-Google-Smtp-Source: APXvYqwFhO2CTRE4uTw9aTfSTJFvnhmcTLTF00a8sW30riT/gKhZKqUJpKXl6lPXY7UzdTnG5BLlJw==
X-Received: by 2002:a62:7049:: with SMTP id l70mr10513791pfc.78.1553276875878;
        Fri, 22 Mar 2019 10:47:55 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id m79sm18890920pfi.60.2019.03.22.10.47.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 10:47:54 -0700 (PDT)
Date: Fri, 22 Mar 2019 13:47:53 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 0/1] improve vmap allocation
Message-ID: <20190322174753.GA106077@google.com>
References: <20190321190327.11813-1-urezki@gmail.com>
 <20190321150106.198f70e1e949e2cb8cc06f1c@linux-foundation.org>
 <20190322165259.uorw6ymewjybxwwx@pc636>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322165259.uorw6ymewjybxwwx@pc636>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 05:52:59PM +0100, Uladzislau Rezki wrote:
> On Thu, Mar 21, 2019 at 03:01:06PM -0700, Andrew Morton wrote:
> > On Thu, 21 Mar 2019 20:03:26 +0100 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:
> > 
> > > Hello.
> > > 
> > > This is the v2 of the https://lkml.org/lkml/2018/10/19/786 rework. Instead of
> > > referring you to that link, i will go through it again describing the improved
> > > allocation method and provide changes between v1 and v2 in the end.
> > > 
> > > ...
> > >
> > 
> > > Performance analysis
> > > --------------------
> > 
> > Impressive numbers.  But this is presumably a worst-case microbenchmark.
> > 
> > Are you able to describe the benefits which are observed in some
> > real-world workload which someone cares about?
> > 
> We work with Android. Google uses its own tool called UiBench to measure
> performance of UI. It counts dropped or delayed frames, or as they call it,
> jank. Basically if we deliver 59(should be 60) frames per second then we
> get 1 junk/drop.

Agreed. Strictly speaking, "1 Jank" is not necessarily "1 frame drop". A
delayed frame is also a Jank. Just because a frame is delayed does not mean
it is dropped, there is double buffering etc to absorb delays.

> I see that on our devices avg-jank is lower. In our case Android graphics
> pipeline uses vmalloc allocations which can lead to delays of UI content
> to GPU. But such behavior depends on your platform, parts of the system
> which make use of it and if they are critical to time or not.
> 
> Second example is indirect impact. During analysis of audio glitches
> in high-resolution audio the source of drops were long alloc_vmap_area()
> allocations.
> 
> # Explanation is here
> ftp://vps418301.ovh.net/incoming/analysis_audio_glitches.txt
> 
> # Audio 10 seconds sample is here.
> # The drop occurs at 00:09.295 you can hear it
> ftp://vps418301.ovh.net/incoming/tst_440_HZ_tmp_1.wav

Nice.

> > It's a lot of new code. I t looks decent and I'll toss it in there for
> > further testing.  Hopefully someone will be able to find the time for a
> > detailed review.
> > 
> Thank you :)

I can try to do a review fwiw. But I am severely buried right now. I did look
at vmalloc code before for similar reasons (preempt off related delays
causing jank / glitches etc). Any case, I'll take another look soon (in next
1-2 weeks).

> > Trivial point: the code uses "inline" a lot.  Nowadays gcc cheerfully
> > ignores that and does its own thing.  You might want to look at the
> > effects of simply deleting all that.  Is the generated code better or
> > worse or the same?  If something really needs to be inlined then use
> > __always_inline, preferably with a comment explaining why it is there.
> > 
> When the main core functionalities are "inlined" i see the benefit. 
> At least, it is noticeable by the "test driver". But i agree that
> i should check one more time to see what can be excluded and used
> as a regular call. Thanks for the hint, it is worth to go with
> __always_inline instead.

I wonder how clang behaves as far as inline hints go. That is how Android
images build their kernels.

thanks,

 - Joel

