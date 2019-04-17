Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50AF6C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:52:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F21B7206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:52:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="aQd1aeO2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F21B7206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.ws
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86F106B000A; Wed, 17 Apr 2019 15:52:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81E8C6B000D; Wed, 17 Apr 2019 15:52:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 734166B000E; Wed, 17 Apr 2019 15:52:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 501616B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:52:19 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id q127so21902110qkd.2
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:52:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Uru0Jbz4B8OYoAQYJt2C55pxQlJkGfm/+9nWfpEgZPQ=;
        b=bOz6u+8B8Id8kh92MgbVCUKiWxEdojvIZltkAAaQuyv+RpFkOM2LNOU50gg2iCrM8f
         9VP+Y++PhO119GEi01c3eIE9YtDY5iDr0ChKVH4wCKc+7ZgZsvfZUHREwDRl5v+SDxaK
         GSz+Zw79gRHO8xFUbicffhyh8k3NfeBQWAgDhB778GKZPQ6Fk9RPZTpuJ/gJQtxHu4qx
         iuWizCqD9TjMygNKlxgAh4ZDdRWPZD2AB2eNHm02+MC2CEWvQGgEVjl6N3yJNcdsy8ib
         vUDe9iPCXl3MzjOwh4f9hsohh4b7aUEcdIEzmlr4hH+4sHrjcFqAmSAaeM3HYvlWm7RP
         YUjA==
X-Gm-Message-State: APjAAAWKl+4yE7oxzIP1oJ3JbBN/7RE3n35+jhrs/S9J/2l5zb+eaKIW
	ly0Jqh8DP0o7+954mYuQSetrnfSE6Wv5Kc4w9RTv2XW25ISk3xj0d0pwxegRTRiFYuptKNDh5wN
	bBtLD6AgCPp5tdEVSOf/+yymvDqY2vG4bPj3eqWi76YedqGy50iiRA1l3p6omF2aanA==
X-Received: by 2002:a0c:c988:: with SMTP id b8mr72332866qvk.33.1555530739054;
        Wed, 17 Apr 2019 12:52:19 -0700 (PDT)
X-Received: by 2002:a0c:c988:: with SMTP id b8mr72332841qvk.33.1555530738577;
        Wed, 17 Apr 2019 12:52:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555530738; cv=none;
        d=google.com; s=arc-20160816;
        b=JYVs6sZiSIKMtMcIG5NDxLV0/zpuXlCs24VamOPcD4IODv/zenKJ5UiQ8uFDQCHrry
         Yr/bfu4AeLon//B8pMM/XTnl6dczxPdUdZS1fqmBgGgWBJZ9+OtJGqgT8z2xgnw57R7q
         MPRcpJaiecBaQF/A7fW03eS70zJMkXZgxn5uGdzoZYRFPxilA/UynBuNfQQk6zt4NNM5
         0eUqcjlmO9+7yiWXl+LTXO2uH3mwM0KX/Q+4TuiCp1yL77cw7JowO2n2JTXfL993mhjT
         VdFXJlGPJ+eAvobV/qXA4cekm66YBFteqMn1YQRLfXl9KFwt4973bQ2n1uEE4rAddJfR
         xvJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Uru0Jbz4B8OYoAQYJt2C55pxQlJkGfm/+9nWfpEgZPQ=;
        b=VRBcojpQDCHOoJvhmkpPY0hZ1QqBc/fgjd4zj3pQxoSIsAliREeGK2ooy9aeVjEmCm
         +b/0/NhrtPCPNddOZ2zGNPC+1xYiyA2LCFwppJeSKcNq7sSPoNa62cFohi0QbOqgP3/P
         XfswbUnPGwbtESI7pVqRhl1IHgFNes0Rz0V4O/yBvTWeo3mY9SJyUdFBH/2JJ9kjTDuH
         6MZ7+JGnf6Xn7O0PteEwupV4r8GFT28pPt21cKzlSRanFn/jK2QZjSuF3lFQFOC+1bf9
         YcSFO7HQMxXW1LkiZr+6luVN0xc+ypKxbUobeWEkyGMGbfbhGX2xZFl55+O82j8ry2JF
         axfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=aQd1aeO2;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p19sor32697181qke.11.2019.04.17.12.52.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 12:52:18 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=aQd1aeO2;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Uru0Jbz4B8OYoAQYJt2C55pxQlJkGfm/+9nWfpEgZPQ=;
        b=aQd1aeO2CXg7gYGOcvtEUcXMyHfbY37wbHMchotalTNQZ2RxhJxZjLextp8ZWtQKA9
         ElDQno8BAegcG5tWka17SzrohZ4MVbbZKar4D1otZqJs6viRLbUgEjktrlyhXOKFoRRr
         Xqiz5AKyn2cqhIrRtLq2t6y4exSmyJWI+xolW690Pg05j5xcNprdRzKeq2BM/bBe7uD9
         Mna5BBYIALxIoHSfeGneAc4J6qlxgdl4umsVpI32Ws6NYWtDPh57d2uN8d9IDlmzf+34
         LgmN/QkDbE6mdN4NdIUb/v42FYkyBUW0DAfjxZ5Ti4wxRTTn11MCXXYyLy0I5wiy+cup
         dbCA==
X-Google-Smtp-Source: APXvYqxALLwioQYr156hXrQYUcVxn+eWorINAhsmvLl+aLFkTmy03SLo3tuclnCeyTO/WqSU4/UWYQ==
X-Received: by 2002:ae9:e64d:: with SMTP id x13mr70666110qkl.112.1555530737946;
        Wed, 17 Apr 2019 12:52:17 -0700 (PDT)
Received: from cisco ([2601:282:901:dd7b:7136:cebf:c0d3:8091])
        by smtp.gmail.com with ESMTPSA id v30sm28498609qta.4.2019.04.17.12.52.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 12:52:17 -0700 (PDT)
Date: Wed, 17 Apr 2019 13:52:13 -0600
From: Tycho Andersen <tycho@tycho.ws>
To: Andy Lutomirski <luto@kernel.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Ingo Molnar <mingo@kernel.org>,
	Juerg Haefliger <juergh@gmail.com>, jsteckli@amazon.de,
	Kees Cook <keescook@google.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
	Tyler Hicks <tyhicks@canonical.com>,
	"Woodhouse, David" <dwmw@amazon.co.uk>,
	Andrew Cooper <andrew.cooper3@citrix.com>,
	Jon Masters <jcm@redhat.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Khalid Aziz <khalid@gonehiking.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20190417195213.GE3758@cisco>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com>
 <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com>
 <8d314750-251c-7e6a-7002-5df2462ada6b@oracle.com>
 <CALCETrXFzWFMrV-zDa4QFjB=4WnC9RZmorBko65dLGhymDpeQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXFzWFMrV-zDa4QFjB=4WnC9RZmorBko65dLGhymDpeQw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:49:04PM -0700, Andy Lutomirski wrote:
> I also proposed using a gcc plugin (or upstream gcc feature) to add
> some instrumentation to any code that pops RSP to verify that the
> resulting (unsigned) change in RSP is between 0 and THREAD_SIZE bytes.
> This will make ROP quite a bit harder.

I've been playing around with this for a bit, and hope to have
something to post Soon :)

Tycho

