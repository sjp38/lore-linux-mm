Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB896C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 14:04:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAF7A206C1
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 14:04:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="YnSjsjmq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAF7A206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36BF36B0005; Fri, 16 Aug 2019 10:04:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31D466B0006; Fri, 16 Aug 2019 10:04:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20AF46B0007; Fri, 16 Aug 2019 10:04:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0031.hostedemail.com [216.40.44.31])
	by kanga.kvack.org (Postfix) with ESMTP id EEC616B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:04:33 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 920038780
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 14:04:33 +0000 (UTC)
X-FDA: 75828461226.27.goose96_27bb74365f419
X-HE-Tag: goose96_27bb74365f419
X-Filterd-Recvd-Size: 4522
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 14:04:32 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id h13so5199016edq.10
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 07:04:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=j/6BPKwgYdq3kl7X0DqLCdZOmgeTKbt4kEmnV+oeC6I=;
        b=YnSjsjmqORHGTHdLdT4KBnuh8v3t5NbxdxRxz3vfItQsLFguH8BIUURBkKImiy3fc+
         QKMSsp4mKy1//EDwlszPaGY31GZAyFNdG4ssiVrhdszq9NlYgjlosyognbxKAcI3ilra
         N/JfIZ8yhEgylnIyMvpv1wmwtlDBvAcfCtiYWfk9USKXRvvTP0EkR6dYW7QHIP0dfzBb
         A0ac3u0A4PJ8TfFimtt9BL7EOajczxJ2XfDozJdP3e/pu3EntdUyw/HNezq23EFggd7A
         +83PyOi1icjBaMtvayv/2K09oVZtJ3h4iUj0aHkVaDkYwd3Nk/aXrAwbLxEvTQlhoJRU
         djfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=j/6BPKwgYdq3kl7X0DqLCdZOmgeTKbt4kEmnV+oeC6I=;
        b=J4PsaWMvAfiLff73zTkWpKfNHWNJIMEd/30WEK8mYxlchwN+wTcGQDrbWdAhyaU//y
         YJ3j9KrWiZKZZcVO5QBE/q1SGfFDxMAvByPMPYUJabZIj9XUNKpRdwGYfIf8ych+tQyM
         +EjB4eXpNSyUi5dSTofikmg0AsI9axwEyBDJAHH3Nu+rdPPOG05RiXofrJCuo3ftFRm+
         27dEUHPdLw+J+buceu3ByL8fgM5ucz/gEZs3DssIfjqudB2ijWYqDjvXPe2X/HRU7K+6
         vU+sL1jhOzo1mBRPnJY1DsJ2YYH1LYBl7Cw516kQ+MJkfQh0sLZPCMS9PqWg2v03KMCt
         318w==
X-Gm-Message-State: APjAAAUUvZWFUZCckKoE4Al9tAnvNd4fl6VyLGMbFewKQZkVzlEPMSZ4
	scRsd/+s/11Sjkzptmkq6ri8dg==
X-Google-Smtp-Source: APXvYqwqdMEG9G2Oq0aACS617rRtH166b9AKeywrjTiPb1fssPssuw3ekoGQZcKpFtGVZiXPMI46Rg==
X-Received: by 2002:a50:e8c5:: with SMTP id l5mr11205255edn.120.1565964271580;
        Fri, 16 Aug 2019 07:04:31 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id gz5sm829374ejb.21.2019.08.16.07.04.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Aug 2019 07:04:30 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 263B710490E; Fri, 16 Aug 2019 17:04:30 +0300 (+03)
Date: Fri, 16 Aug 2019 17:04:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/3] mm, page_owner: record page owner for each subpage
Message-ID: <20190816140430.aoya6k7qxxrls72h@box>
References: <20190816101401.32382-1-vbabka@suse.cz>
 <20190816101401.32382-2-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816101401.32382-2-vbabka@suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 12:13:59PM +0200, Vlastimil Babka wrote:
> Currently, page owner info is only recorded for the first page of a high-order
> allocation, and copied to tail pages in the event of a split page. With the
> plan to keep previous owner info after freeing the page, it would be benefical
> to record page owner for each subpage upon allocation. This increases the
> overhead for high orders, but that should be acceptable for a debugging option.
> 
> The order stored for each subpage is the order of the whole allocation. This
> makes it possible to calculate the "head" pfn and to recognize "tail" pages
> (quoted because not all high-order allocations are compound pages with true
> head and tail pages). When reading the page_owner debugfs file, keep skipping
> the "tail" pages so that stats gathered by existing scripts don't get inflated.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Hm. That's all reasonable, but I have a question: do you see how page
owner thing works for THP now?

I don't see anything in split_huge_page() path (do not confuse it with
split_page() path) that would copy the information to tail pages. Do you?

-- 
 Kirill A. Shutemov

