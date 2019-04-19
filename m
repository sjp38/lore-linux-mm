Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D6E9C282DF
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 19:08:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE8A420869
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 19:08:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE8A420869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F6F36B0003; Fri, 19 Apr 2019 15:08:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A5686B0005; Fri, 19 Apr 2019 15:08:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 796086B0006; Fri, 19 Apr 2019 15:08:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2CFE76B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 15:08:24 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id e6so5575987wrs.1
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 12:08:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent:sender;
        bh=bvQaBOFTAaBMZuFo01KAVk4NSO1CgUkBXec0Cwf1BhE=;
        b=SFI7Mp1vd4CwgxhBV0LllfWISHO44ID0hMNHRsqDyNknBPDydhij+zmM8cAxPGui2r
         Zb7j2jbLP3llpeKRgUdDTWsGU7GeaKlkY7dBGpYkD6w/LDhPdGmVFGHyjWrBlyx930Wr
         7HMnbz8O+tEYvZ53sufIwEmC+rmL82rTkm2yy2+Dl6MeliUP4Xl3eJd2QVFmzTwDHZng
         HyS18dy10oYbd4XELxMhzPcfASBsk64SWO5t5aheCYmD55xK+bhAh2FysN/QUCWOraqX
         QwPjvrfwlyCKOX3Es9q8XEOetm+2APr0mlRf2CtZOY+C4OlHfDdTxJ3yxpwULJ0n+4nK
         uPRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
X-Gm-Message-State: APjAAAXHGXRBkCQHLStcQ0WElQfBdMBkS1ehx2bLF5yI6H2niDBF5Q1i
	cxSYXh2/q1EJl0Fy+WCwZ2EaO1/L1trUry13mIB9jYqExs3sXrTrYyVd9Q79J1eo4DohKl4nP0L
	tmedoVJm+gIP7SMOl2F6zEykryrwrc+L6Z7kwBGPVUqzRcIcTbEkPXLnxtL5PcWtcfQ==
X-Received: by 2002:a1c:1dc3:: with SMTP id d186mr3312147wmd.64.1555700903662;
        Fri, 19 Apr 2019 12:08:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0SzBcR26K7ufmbegC2W+/FZCBSzA4hIIZLqYYV4kj89RbPv+ORYAV42fz4/a1P2j9oBAo
X-Received: by 2002:a1c:1dc3:: with SMTP id d186mr3312107wmd.64.1555700902571;
        Fri, 19 Apr 2019 12:08:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555700902; cv=none;
        d=google.com; s=arc-20160816;
        b=o3AU/zm6FSJHdUlMNkRo7Yc1z5llSSErAPZ/GvVB96xltHykoIxa7FI5T0nSWbNhfk
         yhQj3HoMXgs+7ECV7qlEwNSsgaMPME6stmvxeGFH8a63XSJzOOzbPYwtVFBKyXR59jYI
         77haV24rrHViSrpYjlzpWMpY7cLTQOXrd15lAVqzLVltpHVF3lL6l1+RkOwkYWvEst4/
         3NeMvv3sMJGHQ0Tvsm3kTHPhbGFL6+LaAkbVXNQyGrutWHaupZbBJfY6dLtDRbdY6BCE
         sOMsCFNODkqs/H50SlQXg/SRcltVIYEVi4hBFrDb4zw5FZeZU0yAJ5FjAOFDwBRirZD9
         zwmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:user-agent:in-reply-to:content-disposition:mime-version
         :references:message-id:subject:cc:to:from:date;
        bh=bvQaBOFTAaBMZuFo01KAVk4NSO1CgUkBXec0Cwf1BhE=;
        b=qYmLtIIFwMOKZ5/OxuS+AKvY86z7+gdfc3dQv+qAegIIrwtHaq76bC56T1UAVgY0Ue
         NqmI6qGipfLBhF1uN0nZvf+d87z4mYXFjnvTOdJZM4KtXuPVoNyEnO/8CF32vD3fjCN5
         qJKZ4Gqx4dVQYTrOrvw8J0TkSI3RfDyOC+F+ZpgXGzU+LRnVFkHYXBH/dHDR1oXUP+Zw
         S/WgUgU6ZPJNokp+jLhav/QXNOCh1PUu604VsdDfQ3RQONBzrJREJ4w02j5c0ol0t7R+
         BlVOYq7sZfJOh2p0mZ+tjBgtaPZhDWvQoND7LnvClGoei23uBiyv2FWXECTTeQ3If7cA
         dAnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id s6si1535955wrr.251.2019.04.19.12.08.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Apr 2019 12:08:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) client-ip=195.92.253.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of viro@ftp.linux.org.uk designates 195.92.253.2 as permitted sender) smtp.mailfrom=viro@ftp.linux.org.uk
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hHYrr-00056j-D4; Fri, 19 Apr 2019 19:08:11 +0000
Date: Fri, 19 Apr 2019 20:08:11 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Roman Gushchin <guroan@gmail.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin <guro@fb.com>,
	Christoph Hellwig <hch@lst.de>, Joel Fernandes <joelaf@google.com>
Subject: Re: [PATCH v4 1/2] mm: refactor __vunmap() to avoid duplicated call
 to find_vm_area()
Message-ID: <20190419190811.GF2217@ZenIV.linux.org.uk>
References: <20190417194002.12369-1-guro@fb.com>
 <20190417194002.12369-2-guro@fb.com>
 <20190417145827.8b1c83bf22de8ba514f157e3@linux-foundation.org>
 <20190418111834.GE7751@bombadil.infradead.org>
 <20190418152431.c583ef892a8028c662db3e6a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418152431.c583ef892a8028c662db3e6a@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 03:24:31PM -0700, Andrew Morton wrote:
> On Thu, 18 Apr 2019 04:18:34 -0700 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > On Wed, Apr 17, 2019 at 02:58:27PM -0700, Andrew Morton wrote:
> > > On Wed, 17 Apr 2019 12:40:01 -0700 Roman Gushchin <guroan@gmail.com> wrote:
> > > > +static struct vm_struct *__remove_vm_area(struct vmap_area *va)
> > > > +{
> > > > +	struct vm_struct *vm = va->vm;
> > > > +
> > > > +	might_sleep();
> > > 
> > > Where might __remove_vm_area() sleep?
> > > 
> > > >From a quick scan I'm only seeing vfree(), and that has the
> > > might_sleep_if(!in_interrupt()).
> > > 
> > > So perhaps we can remove this...
> > 
> > See commit 5803ed292e63 ("mm: mark all calls into the vmalloc subsystem as potentially sleeping")
> > 
> > It looks like the intent is to unconditionally check might_sleep() at
> > the entry points to the vmalloc code, rather than only catch them in
> > the occasional place where it happens to go wrong.
> 
> afaict, vfree() will only do a mutex_trylock() in
> try_purge_vmap_area_lazy().  So does vfree actually sleep in any
> situation?  Whether or not local interrupts are enabled?

IIRC, the original problem that used to prohibit vfree() in interrupts
was the use of spinlocks that were used in a lot of places by plain
spin_lock().  I'm not sure it could actually sleep in anything not
too ancient...

