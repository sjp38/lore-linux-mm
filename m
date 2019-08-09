Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10CF4C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:26:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0375208C4
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:26:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JH5PlAW1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0375208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51D436B0003; Fri,  9 Aug 2019 10:26:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CD8D6B0006; Fri,  9 Aug 2019 10:26:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36F536B0007; Fri,  9 Aug 2019 10:26:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 003736B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 10:26:25 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s21so57484456plr.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 07:26:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EaBoxEWlwr4zZ1rJszejMFTUZoMex/Sf4azgLrG5t04=;
        b=e+OvQd64CqZl2jy+s+EXmkI5bO85aOQ16Vzq9/Y1qY1nSS26NAiXZDGJa5mzyj4tkf
         gdnVobbTipXgHFjOogPArQpFDPXZMflUfMRCk59YX1efmtX6w0w5o9S7QMnGBVyRojQW
         sja3kHFsDUERightPLghctYxfpnysu4RWQ5bLfZAHEQAKxR+63WpJ4n5TZ/AZT+w4s6M
         60BB2D6fURigiLT6Qc8OYYSKGTEshoKDE+l6ybVRL9gFZHA0u/gv99slOr8JCe3FAstv
         oH+xgE7vTBRvvGBA4ZCes3HVhNmBMpZuZYQ6qafb0h3cCO7nsdMEYOq3WsPz52idC5qG
         +axA==
X-Gm-Message-State: APjAAAXsN494Jpm8Xfrc008EKm2RtNxpPVdmkhwNNmRoSP/DWpSM03X5
	6BFWYrwPdJM51EXgs7YHrrwkizuc6A70dhkNelT0flx7zSQLf0gw/qwTFbVtX+GHY3GlJoT8wAl
	rQ0n9yywjySkBdEQ3Q2e/WqADUQXASN1gHBt3pS4ywSvbdf1MaoUrNQobS6B0l2xDTw==
X-Received: by 2002:a17:90a:8a15:: with SMTP id w21mr9765124pjn.134.1565360785526;
        Fri, 09 Aug 2019 07:26:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAKBzE8tMiUDXdqZN9VkRh30qz4hz18+Hjg7o8GWNHR98alD9oj2ahjHn3malykaA4EQDJ
X-Received: by 2002:a17:90a:8a15:: with SMTP id w21mr9765079pjn.134.1565360784848;
        Fri, 09 Aug 2019 07:26:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565360784; cv=none;
        d=google.com; s=arc-20160816;
        b=Sew0U/4Q46THM+fs+ZwE/NyUW/pStoGf6F2LMOT1EHOg8hyritlcGZ06Aib1YV1IPf
         rYad8hjYhwNN4qJghq09gl5ze7fNxn2lMSBodCjewbXk4gTTbXn0zJS0k9R+DG+WGX1q
         DINJ1ndGm4AeqOjlCaaGiQkponFcY4lHcCpxLJu7y3L6dXCyaMEl9jb778Q7pCZdcRgo
         k7ZZ7H0XFMqIg9cvQ83V0ZsgRb+n7HozB7EpqlAlRIYdeP8rdtNe9F2A7Hozv1jgBFfw
         hCkQKPxmdROr6mqGAGTLo3g9eWrscY+gqPZVcQB8DRHx062Wo7xw+94pm10LO9WkcCU9
         Crxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EaBoxEWlwr4zZ1rJszejMFTUZoMex/Sf4azgLrG5t04=;
        b=UDVSuFtiPNJ8nvG9l/jZUXdp1CjqywvEilE1zzK/WOZBsyniWE7D8VpImCxaIyrVB3
         KKzU2aqBNiUsasaWdbed+pFHKX/c0yMcYwzvw8XsyUkC5yNy7As6eWZglS1vD7jWAw5V
         aOrHWDaELMEZN4cPe6bJwsgePvy66jgbV9y1KtfvMn+e0iHryLpssR5CLAiWs8Mze00T
         3Qy3MjXnyk5IoGVWCSJSDxyYl/Zu0lwsWATHUB6dnSoUzFoagc9gFJX8KZ3A5NYKD66x
         E5/wiAdiWzrUbzvlGlL7I0RVGqZT1jpGeeq2tmd54k/1KvHLLhEeVIS883s/QqSwr+pT
         dDiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JH5PlAW1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u17si58010576pfc.210.2019.08.09.07.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 09 Aug 2019 07:26:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JH5PlAW1;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=EaBoxEWlwr4zZ1rJszejMFTUZoMex/Sf4azgLrG5t04=; b=JH5PlAW1P2xfQ+UotOi2WPcif
	C19dMDk6AncmpZY3SMLP16T8M5SGZUNI02MGYfsWwHSsQxhnYdPMXDE/rLpAP+7lCYOyADYpGM0z7
	gtGfOgSE7pZzBwYe+vjSFFHzHmuJDIsqXYQL3ViPGaBxFATmoPqv3oK1UJBO9sAZ02mPwUw29Najp
	nWDEyZSTpAapVfw0ofuowNHThlH+U7ZlvyQyETUpS2WbUhnYzz9F7kwdt5498KBCoEACm6R+Y6j7q
	pZa5eIT2eGWi3ZBnt4MBZ2NR5uL/1SxETSyrY8IFjGvtEQ73OpE+b1AxiX4A/ilb/+hcfrlkKqrEv
	VYTD+LGxg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hw5qT-0007Je-Q0; Fri, 09 Aug 2019 14:26:17 +0000
Date: Fri, 9 Aug 2019 07:26:17 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	wsd_upstream@mediatek.com, "Tobin C . Harding" <me@tobin.cc>,
	Kees Cook <keescook@chromium.org>
Subject: Re: [RFC PATCH v2] mm: slub: print kernel addresses in slub debug
 messages
Message-ID: <20190809142617.GO5482@bombadil.infradead.org>
References: <20190809010837.24166-1-miles.chen@mediatek.com>
 <20190809024644.GL5482@bombadil.infradead.org>
 <1565359918.12824.20.camel@mtkswgap22>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1565359918.12824.20.camel@mtkswgap22>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 10:11:58PM +0800, Miles Chen wrote:
> On Thu, 2019-08-08 at 19:46 -0700, Matthew Wilcox wrote:
> > On Fri, Aug 09, 2019 at 09:08:37AM +0800, miles.chen@mediatek.com wrote:
> > > INFO: Slab 0x(____ptrval____) objects=25 used=10 fp=0x(____ptrval____)
> > 
> > ... you don't have any randomness on your platform?
> 
> We have randomized base on our platforms.

Look at initialize_ptr_random().  If you have randomness, then you
get a siphash_1u32() of the address.  With no randomness, you get this
___ptrval___ string instead.

