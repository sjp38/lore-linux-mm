Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81052C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 15:01:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FCEC20868
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 15:01:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JFrfzX8J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FCEC20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D188E8E0003; Fri,  8 Mar 2019 10:01:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC7AA8E0002; Fri,  8 Mar 2019 10:01:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B90708E0003; Fri,  8 Mar 2019 10:01:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 74EE38E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 10:01:11 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id h68so20456225pgc.3
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 07:01:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ATug9pmku95GuCzviW2NA14TTeXks8vpcEsMnFKd+Ng=;
        b=DEDHxa7RSwxVaVQO2mj6P7nnQ2vCIZoWe775UfzMCkW76VMObf+qGBiUbd2ZM/Q9O6
         yjHY9Jk3ejttcXMI9LHwJ0Jh1eFRpTbo1aV50/cfFrjDRr9kGJ6Yioo+Xwwu3MZN1Mjd
         X3ifwiXNSFuEVoU0I9zr+a8HWyMHkPnlqqI7ry4lR1i2+wiuJFHi8S7WvOAngyXG1sfa
         i74shXK+HA7T1q8JM255FTQbG8pxxPV486rzxlkIV+zB4UwbRMqEXmVJTqL4FTxRwRHb
         8VWfZ+kQQo15dLMpPC1e/CscsslsBS1acnU3zG1p/IEP1Avm+XIVUd4oGsiMIrp0lChO
         Q7mA==
X-Gm-Message-State: APjAAAV7entfVRGO8ijmem0V4bPYNKGoopF0GsuBBgbkpINvIXwTUTm3
	nrxOYbtlLpA8/lSWIuehSM8raet5VIy9DgB1vWiCiMhP2ticlk3qTH5g4q8jK2GpJOkPZtsvnfO
	gxVIOw5ALYxcgGJFXaB4cJkxBnsf6kGyTd4yLnPg83J6QTYwbYqHlCeKk8pnuSRuAng==
X-Received: by 2002:a65:5181:: with SMTP id h1mr17180231pgq.422.1552057271075;
        Fri, 08 Mar 2019 07:01:11 -0800 (PST)
X-Google-Smtp-Source: APXvYqzbv5Bo4jP/vu+mGnjQ1BfHbtxAVq2ojPXeRIak+1rlvsX5ftlc6mprVMF4c47T+OVEsxSp
X-Received: by 2002:a65:5181:: with SMTP id h1mr17180112pgq.422.1552057269720;
        Fri, 08 Mar 2019 07:01:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552057269; cv=none;
        d=google.com; s=arc-20160816;
        b=GCqedNsFOcwMVA+3gxrYq0wPEdBTGvJb1RDU7JSZ9dVQE6JXKekeucr2HjAQ40PX9D
         AS2Y54xOZjozl1GuDuy4MOz903H7Ubk5r9aAYQlISe+cq/D8g4T0O7PWIpWOM7ATQqKT
         dVaEtQIa2qTGQNHl86C+BHWDzf1e45AT+vgHPdYzbHvCwNOvR1ush93JrJbxKK1VQq0q
         8vnVDekIxHN5q79ZyffIGAs13ULyNoYv99dqlQzdI6S0HvfhWhhZxpNN4pJN2PSVhhrO
         8QY7g5sYY3lrpcBLTzYQ3nsXXpvwH5EuGADcnz9WQyG//++3nbYP2DJevVGoNhtse4tV
         w9Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ATug9pmku95GuCzviW2NA14TTeXks8vpcEsMnFKd+Ng=;
        b=u8REDDdQHPAUDWu0Zjy5R4w+Q08RYBelQJ/9Z0y65V4LJDmde1wFrj1vBA2rGWsV6X
         8G3Bcd1AYOyCybVgu/mI2boM0mzFTUhxpSxAinzzD1kZSjqQRGrp3jewwtOKUtOZ4c26
         fivCygZoT6HwhmHMd75A/+iPslN8/cYHKT5REf2yN2GK8h10BR69cS3nM5/qdlXv/k4s
         E7rn1tMbg8iSyPHFo0prHUU6Zexi9vIElQioN6M6FM5ivgzBki+m601TX/+qbfWh2z9z
         6YkraaPIMoxmyvXVlFHCCJniop+O9dx5ofDD4BPZ5Fb1CF9T0Yo89KDPobD4gUi4Zodk
         Q5UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JFrfzX8J;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o4si6564441pgv.512.2019.03.08.07.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Mar 2019 07:01:09 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JFrfzX8J;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ATug9pmku95GuCzviW2NA14TTeXks8vpcEsMnFKd+Ng=; b=JFrfzX8Je4p+XdM/dBHwVZWSQ
	MH1yBqkJFSPIHmft71vL87V5Ulgk+renpND5cJ2siD/dn7HvMMT3zZAFq3UJs1HJ3m6vJgY8nM0Q2
	ZfArasZBzA9Ed9wJXYSS8CNkaBqzlw3MSOkwH5D8ZWlOzoX+ToTZfy/sEm5/+/Cx3bj31xRXRzPkf
	q93zMFsVPs1BghQVFwAYIb2PBYeC7HTS9YaTWkzpybvP8f9+z6qdM5tW9XfaNVZ2bBcWiiPdN0B7A
	PgrXquaHRA6z2cDrYt3+wA9enUDvkBRsRrOnfZ6UiWEISOEgE3JAXxE2CHLfPEt2xQBh/FRU7jZPE
	GnawQxjYQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h2Gzk-0006Yt-3d; Fri, 08 Mar 2019 15:01:08 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 122A320281DC5; Fri,  8 Mar 2019 16:01:05 +0100 (CET)
Date: Fri, 8 Mar 2019 16:01:05 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	akpm@linux-foundation.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
Message-ID: <20190308150105.GZ32494@hirez.programming.kicks-ass.net>
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190308110325.GF5232@dhcp22.suse.cz>
 <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
 <20190308115413.GI5232@dhcp22.suse.cz>
 <20190308115802.GJ5232@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190308115802.GJ5232@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 12:58:02PM +0100, Michal Hocko wrote:
> On Fri 08-03-19 12:54:13, Michal Hocko wrote:
> > [Cc Petr for the lockdep part - the patch is
> > http://lkml.kernel.org/r/1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp]
> 
> now for real.

That really wants a few more comments; I _think_ it is ok, but *shees*.

