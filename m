Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E1F4C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 07:00:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55AD4264D2
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 07:00:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="jZWrssK4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55AD4264D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA8886B0276; Fri, 31 May 2019 03:00:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D582F6B0278; Fri, 31 May 2019 03:00:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C491D6B027A; Fri, 31 May 2019 03:00:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 75E786B0276
	for <linux-mm@kvack.org>; Fri, 31 May 2019 03:00:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y12so12490866ede.19
        for <linux-mm@kvack.org>; Fri, 31 May 2019 00:00:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=7A86gT5ZbQGdEaQPTXTX362/h2RCatTQByTt+5Bm06w=;
        b=FewvtQOiiwl+QqyTlD8wKLTj23hIF+J1CkennbK/B0LzAZuTA/TAWzuX9CmHnr1dQ+
         5eRJpyQYX6+xYFDBBv5ivrP6APv1K9YIjzGwcE0yAg1xZHxRV7mrr8xZdYRQwMmgyU9Q
         m/2N3Eyt20HzbzpksgSP4SGtXKbbTOEOUtUCgZu65tEI3hfuDQpZgESBvX2sJytN2iUh
         X2F5Kv4RgUUUrO9Yi0l/QaA9nLoiBTxLsPndMSaDCq4goio30+pgWorS1c2GIdhCOFTv
         rWDQ8Ztovi/84o6WpOTYvVVklfz0eTocTiyaypQzJfitK2kNK1V6gWo+Ff0Yh9ctXY/i
         dUmg==
X-Gm-Message-State: APjAAAVNmO7bcLjy3MzK5kOXXkdLHJDk7QP+tG9xwKrqpruJf6YRGJxd
	ocvGc4h2VPCK9AscCvDU16/hFes8ejQVJDuXTjemHjOBHVmDU7hFc1zK0MtCoSXYqcba5ag13DK
	AtVjosf0+kCn96qJNgksFbP0lgf2BNysUuglTfrHigByYTr/7bJzBhifNof8nCwEG7A==
X-Received: by 2002:a50:cc0c:: with SMTP id m12mr9500462edi.8.1559286006905;
        Fri, 31 May 2019 00:00:06 -0700 (PDT)
X-Received: by 2002:a50:cc0c:: with SMTP id m12mr9500377edi.8.1559286006118;
        Fri, 31 May 2019 00:00:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559286006; cv=none;
        d=google.com; s=arc-20160816;
        b=IW1jQ/hVOGBPV13hyQhL/WtZpD1Ghv2MxBTC+OuYqmldJU9yp8yRi6ZTxQbHQpblem
         xNIgzUz82sUDZBO/LUGrkywFnK49ruWolzV5+y8jIPEjKEZ7EHTP5JluPMEDawQLv3m9
         k5rFSq/3yqbrZ9AaOhxo6jQAESRbfMaLzW909iPEGXs2Nr14/WmuwrzUjlFTYhZ1ujO6
         oUi5fxqp7d6MOD2oDaVAEDmDu6xvcrKFJRupzAZplBRSE4vrAZ3abk5LZarGl3/4TTdu
         ZZvLuUXYLtabj6jumOmBTsi3+kQWKqI7OF/fVgn8AAP3VdNiDubp1oSBs4eQsVuISpTB
         /w+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=7A86gT5ZbQGdEaQPTXTX362/h2RCatTQByTt+5Bm06w=;
        b=LyRllXCzN9TsPkbNhTWcAkx5qR5FdemxgEyqYDI3LS8VrbI3aszjdluF1by0rlGzlR
         EYXHCuisS2OV71lQqSE9a1efFJgtKKMxMNH9tQW5b8aP8fSmmZzuJqab6VM/N49xh3dh
         /+SRhrJARMNqNA8Vk+21vPPitJkDegADWuAlfCZMA8MmlMQDVeAkyQi0WllaeYws/w9M
         QMLDwC3xa6WaMwpmy3bYUoC436eAfkcuLO93hyvu56Vl1+Xk+SB0WU0HiVlfp6BQQuBp
         ugrfEY40Wf7EO6anHxp9OBCO0ZHruZ7iM+KHO7UuSAZUcyQywwwaB6IhPIOGDofAkO8F
         j1EA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=jZWrssK4;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s53sor4598364eda.4.2019.05.31.00.00.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 00:00:06 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=jZWrssK4;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7A86gT5ZbQGdEaQPTXTX362/h2RCatTQByTt+5Bm06w=;
        b=jZWrssK4m8KO9SfE4seS+D6HRtswXAVNT4nI+9zN8mxexOUmabIaw+4QoejvYmvigV
         G2cap7wbZTuOvQB9hLXRtG9NLIMuckuFnu9GVKtlD3dBP2al4lQGtxRDV9WTMvf1BwnT
         8wf4REbcTOJDsSeNoItEOzTtQGfOT2tZbKMSGDv8oZ8NPXuWDXgcNB8lbvM2JS045Lca
         UPVh00IeZ3JbY9iCQYeNQgUyfjcFZ33frXk+D82lcyKCkiiIPOMHQnU2owx4o9BxwkJX
         s2hI+sTateQXokSKni8Pyz/QAU2wcCRtFcSlUIc4R2O8OPCYU3T0ob3l9ji3QGGzYFjV
         qpUQ==
X-Google-Smtp-Source: APXvYqzS/ipkpGo3nJd8w25N+g60WqQ1WzHcInhSZRUv5x4IGfs+C6xmKC4mcuaVLrbE7X+s7u5GFA==
X-Received: by 2002:a50:9855:: with SMTP id h21mr9488194edb.264.1559286005679;
        Fri, 31 May 2019 00:00:05 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id gt16sm810459ejb.60.2019.05.31.00.00.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 00:00:04 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 7E5751041F1; Fri, 31 May 2019 10:00:04 +0300 (+03)
Date: Fri, 31 May 2019 10:00:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	"namit@vmware.com" <namit@vmware.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"oleg@redhat.com" <oleg@redhat.com>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	"mhiramat@kernel.org" <mhiramat@kernel.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"chad.mynhier@oracle.com" <chad.mynhier@oracle.com>,
	"mike.kravetz@oracle.com" <mike.kravetz@oracle.com>
Subject: Re: [PATCH uprobe, thp 4/4] uprobe: collapse THP pmd after removing
 all uprobes
Message-ID: <20190531070004.2dwa2cjol2q7yq4u@box.shutemov.name>
References: <20190529212049.2413886-1-songliubraving@fb.com>
 <20190529212049.2413886-5-songliubraving@fb.com>
 <20190530122055.xzlbo3wfpqtmo2fw@box>
 <4E8A7A5E-D425-40EC-B40A-7DA21BA1866F@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E8A7A5E-D425-40EC-B40A-7DA21BA1866F@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 05:26:38PM +0000, Song Liu wrote:
> 
> 
> > On May 30, 2019, at 5:20 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Wed, May 29, 2019 at 02:20:49PM -0700, Song Liu wrote:
> >> After all uprobes are removed from the huge page (with PTE pgtable), it
> >> is possible to collapse the pmd and benefit from THP again. This patch
> >> does the collapse.
> > 
> > I don't think it's right way to go. We should deferred it to khugepaged.
> > We need to teach khugepaged to deal with PTE-mapped compound page.
> > And uprobe should only kick khugepaged for a VMA. Maybe synchronously.
> > 
> 
> I guess that would be the same logic, but run in khugepaged? It doesn't
> have to be done synchronously. 

My idea was that since we have all required locking in place we can call
into khugepaged code that does the collapse, without waithing for it to
get to the VMA.

-- 
 Kirill A. Shutemov

