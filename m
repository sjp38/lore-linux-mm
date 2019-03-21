Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A018C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:24:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 261C5218D3
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:24:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 261C5218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB9F36B0003; Thu, 21 Mar 2019 16:24:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8D9B6B0006; Thu, 21 Mar 2019 16:24:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97E496B0007; Thu, 21 Mar 2019 16:24:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75A1F6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:24:51 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id o135so24983632qke.11
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:24:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=dn5fIfYe0nF1RgJ06yCiTusEy6RueB3vGzcw0aQfz1Q=;
        b=CXBtDpAbso5tXDgx4vTS31u1VZGfYRr7F0TU8odgip9xbEqmC6TWca8XhkOV2imx3x
         aewfzutHrkSL3GYY1mN4HCaZmFpaX6Mm1m/HVaFKGikKuJ03lE4uhKx3OQpekNX0SPl+
         1bZ8LAHuETLYh5PpPVg/nAyKmXweuH+G7XwnIivGWTo+zc9T9tuQQQEbpaDwA9LCQfK6
         /uUAwQOA/P3bq7dqjzulnC44XqjAGdQzbWuxDWHohCIlUOdWtQv2sWW/QCkCHIPmfozm
         9U3UDjGS/YAiCHpyu2ekPKJBAKjHjhvxqZtbSNwOVadmu0QWnkmIOxpdt6tVIijocWct
         YKdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUWaBV7LUjSQawBSnbuqvrb0ijgdgnu09bpEC8n4Q+Qwwx4BHy9
	gkDRQ18oIz8Fjhj3sO1+OYK9Pv7JJ7cm0BkWHvsC08nALOcbnHIeh0jbqFlH/RDsDGdGTUoCnZQ
	SgQQn6KJfefEXTtvx8RVF7t9/a2vnMeTOUYf/VG55Woxmu3EVTn5oyfIkjE85+rkMmg==
X-Received: by 2002:ac8:268d:: with SMTP id 13mr4936044qto.53.1553199891151;
        Thu, 21 Mar 2019 13:24:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiTcdpuZNAF4+Hlv2m13JKSEaATKFZs6tvpEq4MoqdMf9/nYFduqn33cFsI+IsoYfEk5wF
X-Received: by 2002:ac8:268d:: with SMTP id 13mr4935999qto.53.1553199890547;
        Thu, 21 Mar 2019 13:24:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553199890; cv=none;
        d=google.com; s=arc-20160816;
        b=lHXpV+CjUJ0Atzf66xKXOFl8cFUsqnGXbh5J1DgNyaZKnNsivPnIkpy90lV++WEqmz
         T/uLgV5LHRsnl/6C8jrccmQrNIfo62gqoICVcVMzASWzZEwiMx6B1JKeI60Cf+iHqm/E
         4ZO1kZoooKp9876uVIxAP5aP9HOTEtwrHODAJY+4+KiJ7ScJgT9nuzEYavW5psfgIlPB
         1ls7WSqPpiO0Qym7Hf+5CrlhcrZCKU1wkz8UjjM0KdfiSD9RBh9cziMNFe8XHwdS/3kT
         g5pL9a3k4KOjnmFD6yIII1CB9ragapT36YNjn3Gw8+E8sOKUm/15BepYd67BoFLdOC50
         HpTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=dn5fIfYe0nF1RgJ06yCiTusEy6RueB3vGzcw0aQfz1Q=;
        b=XaPCOhMBaaWFLNGScEoMk7bl8EdIiMc4hTi8iBUM72Ydh8gYMyoC2o2qK5qAKUCJ5U
         n84cZtHmFyRoF+cdpFqkcdzOOAIs4ndR+FzOrd0XG7ZFicO29qpzNRDqc9yGnrL4uf3z
         LtJHQ/lSiN6L6SJG06CFlFhIsXooHIkWUWFVUFsfvQ1G3kHDneOnGqbrewJitXfahQtF
         Dw6al8EeH3R5sk1zt65AAZPx2kzKVaE/BfbdSA3P5/cqgMM4zv+Gewxg2IHIR4S1Rd/o
         /0pQIng8gkjMemlgwb5muTgUEbaaPYtmK+PqMrVw7RttQA8GAs6J7m5raZdzAyseP9OE
         6Qmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 31si1547822qvb.93.2019.03.21.13.24.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 13:24:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 84F6E5945D;
	Thu, 21 Mar 2019 20:24:49 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DA45E60BE2;
	Thu, 21 Mar 2019 20:24:47 +0000 (UTC)
Date: Thu, 21 Mar 2019 16:24:46 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"willy@infradead.org" <willy@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"jrdr.linux@gmail.com" <jrdr.linux@gmail.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"minchan@kernel.org" <minchan@kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"mhocko@suse.com" <mhocko@suse.com>,
	"ying.huang@intel.com" <ying.huang@intel.com>,
	"riel@surriel.com" <riel@surriel.com>
Subject: Re: [RFC PATCH RESEND 2/3] mm: Add an apply_to_pfn_range interface
Message-ID: <20190321202445.GA15074@redhat.com>
References: <20190321132140.114878-1-thellstrom@vmware.com>
 <20190321132140.114878-3-thellstrom@vmware.com>
 <20190321135202.GC2904@redhat.com>
 <c9d05087a0fb9002145aa2f7c58552615a694e9e.camel@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c9d05087a0fb9002145aa2f7c58552615a694e9e.camel@vmware.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 21 Mar 2019 20:24:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 07:59:35PM +0000, Thomas Hellstrom wrote:
> On Thu, 2019-03-21 at 09:52 -0400, Jerome Glisse wrote:
> > On Thu, Mar 21, 2019 at 01:22:35PM +0000, Thomas Hellstrom wrote:
> > > This is basically apply_to_page_range with added functionality:
> > > Allocating missing parts of the page table becomes optional, which
> > > means that the function can be guaranteed not to error if
> > > allocation
> > > is disabled. Also passing of the closure struct and callback
> > > function
> > > becomes different and more in line with how things are done
> > > elsewhere.
> > > 
> > > Finally we keep apply_to_page_range as a wrapper around
> > > apply_to_pfn_range
> > 
> > The apply_to_page_range() is dangerous API it does not follow other
> > mm patterns like mmu notifier. It is suppose to be use in arch code
> > or vmalloc or similar thing but not in regular driver code. I see
> > it has crept out of this and is being use by few device driver. I am
> > not sure we should encourage that.
> 
> I can certainly remove the EXPORT of the new apply_to_pfn_range() which
> will make sure its use stays within the mm code. I don't expect any
> additional usage except for the two address-space utilities.
> 
> I'm looking for examples to see how it could be more in line with the
> rest of the mm code. The main difference from the pattern in, for
> example, page_mkclean() seems to be that it's lacking the
> mmu_notifier_invalidate_start() and mmu_notifier_invalidate_end()?
> Perhaps the intention is to have the pte leaf functions notify on pte
> updates? How does this relate to arch_enter_lazy_mmu() which is called
> outside of the page table locks? The documentation appears a bit
> scarce...

Best is to use something like walk_page_range() and have proper mmu
notifier in the callback. The apply_to_page_range() is broken for
huge page (THP) and other things like that. Thought you should not
have THP within mmap of a device file (at least i do not thing any
driver does that).

Cheers,
Jérôme

