Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0E4BC606BD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:35:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F7E72173C
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:35:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oIfcgycO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F7E72173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1786E8E002B; Mon,  8 Jul 2019 13:35:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 159438E0027; Mon,  8 Jul 2019 13:35:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03EE68E002B; Mon,  8 Jul 2019 13:35:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C415F8E0027
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:35:42 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n7so10929700pgr.12
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:35:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=n9fo3wNw7aw0RbIvRpzphALTB15Qd7wOzZ709YJZYuY=;
        b=sgfny1nXjCNSqBVQLjvpE6DnbC+CeG47TkH/y12qUT4VUgoW62/yb7y6rYWZ1MdOHm
         YJ1UZoLuG2DQRKZ1llpWQssjMx15XSirkAB2vQ7hz8HgIHEQLLemBeQm/JERO9IpqYwZ
         c1eRHmYHZF7zmPKYN7oNS0HhTjSLfE3DhOc1pttJJwbIO7wcqvZQ/qBvIFTGNULdZTBy
         IKFn3QxX0iGax3ewNoMuPo+fhZsM2NsPoZ/gbKEXmgrxi5aZXk2TLPHhvk5wX4xZ4imR
         aULxG9FeePSVAwKTHougiGJzr2rjb76QxnabCeU/dTp+tJ3/LQ0tjOg50WPXEfjZSpL/
         ayFw==
X-Gm-Message-State: APjAAAUZkjLMIMgz8OvBmNXMZ8Q706Q+fQOtkXX0Fa1rtRec0LNnVAqs
	GM8mvq1oEWeU97F8xaHbk+B+5V3jd6iFaSyYoIEyvzJaCjbzKPjcHTj24EY1AurJ+B1Um3yhf2n
	+Ojf/2LKz0J/Z653EGjHmzIGQFLQSthatG+yEPytiKnJz5H+CisJMbtT4COeGzIY1ow==
X-Received: by 2002:a63:5945:: with SMTP id j5mr25164500pgm.452.1562607342451;
        Mon, 08 Jul 2019 10:35:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtMSNWHZUOBMWcc22ilZF9OKP3s1PLFWGphSoVHBXLfdJR729ADiK1cjVlsYwxOsu4tbFB
X-Received: by 2002:a63:5945:: with SMTP id j5mr25164458pgm.452.1562607341788;
        Mon, 08 Jul 2019 10:35:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562607341; cv=none;
        d=google.com; s=arc-20160816;
        b=YtonPRKDuIcTG05EDv3STXkfr7pjvwZL8edWpobChM34Nf5EMEAYQ+bTtXuOu1WGJg
         7bPTf/hxe+LeCz84hQzPmV+F8rtcQ82U1wcA5VNHuiNmeo1JE+IPpoqX98RVb+mnWya3
         dTzPKNOPeK/mMHdYyjKyTzAGLwridvShumA37KXjNKnPEXXVlR4jaitj8GU+/RZxJ3tx
         J4hdcRo+B5hA6oEH1D6vJZ7Rs4BKEuVTteWs/Pa5ESPap3+3DEt7Jh8c0g6sgXl8SEG7
         9apgNLHCO9OJbrMqzRUNjUWfkZJAfb1/jz9FIRtKExi/F8UVvV3Oq2+saNjqQ/c+VsEE
         3aEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=n9fo3wNw7aw0RbIvRpzphALTB15Qd7wOzZ709YJZYuY=;
        b=L3IWh5pmsdDW51J4Myh7tau3hg1CamusUmdgr2NZXGj50gC9fMkbn+z+HsdFHrs3Vt
         yc8yyZoLP+IxSAxAJK6cH9tnCxba8pMsJtEjjZ74+dS48uRZGMqXScbkN9d1x7QqZ5Su
         9G2tnnXsTv9xDfpjAv4b1to+q/IBQxZS5eZLwC+JIFRLFGGJNt8XMkRdS3cK4N+ISfSB
         AZ7IR/uif/3dMPNLffRgfDK3hRsweFDsiNfETMXyeSmXff911ZOKMIgcGrOzPYm0hXJj
         RYBU/Ej3qDYiX4hU3p4qoicxyDswgFFI/Cj1QHdGY66A9k/4wXacEsWZDmWDVcNDMeuC
         Ov0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oIfcgycO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c1si16469397plr.405.2019.07.08.10.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 08 Jul 2019 10:35:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oIfcgycO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=n9fo3wNw7aw0RbIvRpzphALTB15Qd7wOzZ709YJZYuY=; b=oIfcgycOcXRvCrTXgzSUV3Bbf
	KxQgqOLbwzHQGVNcZ7LSDii9CxBNLC5dofvJT19StoJNVlTzLJeQMrZ4MDiLx8JWqU9/dAlS8j4rs
	x3Cjiih3NScNZa19n6elIHzrcKQNF/BnylzXlnLZ6FbTZCo0oVYG5LuOfOj3yMH5DmF5nlBBi/lCi
	QKu8WOzXkvlFv4ag30R/h4cbVeI3BCx11EqJI5VVi7aT+6gD0MS493/D0mhY+otM0exYLPWc79BJ4
	5/ffMw6ehL1nj9mt8Yo3CRY11wQVVZ6ZR3lTUgVce2PL8EKpnd2GtWPjkUGTpACd3m3/PQudvUw6z
	n0VyKrmZA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hkXY6-0006it-Eo; Mon, 08 Jul 2019 17:35:34 +0000
Date: Mon, 8 Jul 2019 10:35:34 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Pengfei Li <lpf.vector@gmail.com>
Cc: akpm@linux-foundation.org, urezki@gmail.com, rpenyaev@suse.de,
	peterz@infradead.org, guro@fb.com, rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com, aryabinin@virtuozzo.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/vmalloc.c: Remove always-true conditional in
 vmap_init_free_space
Message-ID: <20190708173534.GF32320@bombadil.infradead.org>
References: <20190708170631.2130-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190708170631.2130-1-lpf.vector@gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 09, 2019 at 01:06:31AM +0800, Pengfei Li wrote:
> When unsigned long variables are subtracted from one another,
> the result is always non-negative.
> 
> The vmap_area_list is sorted by address.
> 
> So the following two conditions are always true.
> 
> 1) if (busy->va_start - vmap_start > 0)
> 2) if (vmap_end - vmap_start > 0)
> 
> Just remove them.

That condition won't be true if busy->va_start == vmap_start.

