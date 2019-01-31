Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 677F5C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:23:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 314C12075D
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:23:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 314C12075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF7A28E0002; Thu, 31 Jan 2019 05:23:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA6B88E0001; Thu, 31 Jan 2019 05:23:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A96068E0002; Thu, 31 Jan 2019 05:23:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 527188E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:23:51 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so1116767edz.15
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:23:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vSTPWU0/sT5EebRTZSfumSnbMN+E7dxb8tiuKW3ZPa0=;
        b=eaaLrD4gAVbS7PwyRN/YUAeaZkHmrRGBJzclcsfPcu1tiadtRi4LBhZ32EbVnJ/a0o
         UjpOxj4GFW7+0ulD2lSgvZTnfWbD0PSkSDCsbx2oPjsk43FRHlz9+27J8d0il290Bpn/
         3ceNAwnzOqEYi8xlQO1j9nbL96LaaZZrTU848zOI3zqJUW28V4AflrJPpcdLM7aPCWBE
         vwyW3+ZUTHbww5AMr1Yw6ausvCJPUI9CcBtXGrmfadlwIOkQ2bp6PR085F9VUGQ+zs/M
         S1GUcFdYNQfXXRGq/a28BQt87PVsj/dY+ColYZD4gmKjIbRuDFYnhYkPacS3WF7j0FZF
         EHvA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukftjO0PRskQUemrMZiGtiofY+VRvkik/LLGtna4fnQy1yBQ6ov2
	VwffwHSwwf/G77/khE9nNtkaVoDaLwtrYc0khPnNjTs/4czsE3rPvm1eOC9WrKC5WYz4sJWCSjZ
	Ja6YRd58n3MeSFnTQpe+z3EDBGybZG6f+TEYKBQ678Q+8RaoG5IP8oxklZxN8QEU=
X-Received: by 2002:a17:906:1956:: with SMTP id b22mr28665639eje.216.1548930230866;
        Thu, 31 Jan 2019 02:23:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6tx9/5h3Jgz2aSvS4KkeGeQUcBOIuGJw0j/spgDG7+RhktIxdd8Jr0Q/tXUCYDpuwX/pZe
X-Received: by 2002:a17:906:1956:: with SMTP id b22mr28665597eje.216.1548930230040;
        Thu, 31 Jan 2019 02:23:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548930230; cv=none;
        d=google.com; s=arc-20160816;
        b=aUKUItkMDJbeFX/fYgsNXyUr5AgSQY0vQWWyitCmacPdlv+seYfcI5uSbUNEb0zTja
         NdlzzNfiLGwC7Bc8Ji+zIbZ3pqk4RDnYaVFOTlwfdUNGCoAB/lOFyQsi1MVf3y+wErBK
         DTvRCiy2kix5+iEXks3sgK7sNMfNAhmb3aF5nOMqLNxBQcaS6rfcEZHtlElqgUVJm3p7
         mVuF4lIgSJ5KUJudys+M0b+Pmres+6FOlNfpPooD3//JSKemzOT/0RjR+K2N/gadXd0d
         3JzGrQidsL789A4FFR38hH3vLHvjjIcchVhICjplJkBQKP0G8WApytxvQSiTkZAjKRrL
         bHgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vSTPWU0/sT5EebRTZSfumSnbMN+E7dxb8tiuKW3ZPa0=;
        b=eZpYtSpEbvY+rXB8yd/3oSHta0q7nFTPg10DDGhA168WMrrpmSymUA7xzKDCeS3arA
         njcp2dV5Q4NK53BWa8nIveU83XLzOt6N4Z82N2xT5ge8L3TJTm5KDNn2IAo/F1ChC9/v
         jZKZMHDeKwVewHIB3CJ3yr6hbYXAJ5kt2ywqRv21gD+5LVicX1PNsHqDpyJz7XvNBU/1
         j6JQ/pNndyNAL1179IiRndPzpkfNAT3/XzIjzKHOa0IIvmAMFWb6xFrBYXQviNRt/inL
         R2nGD2mzWooaqZkVt32Cv+zdweqJzy2YJZuBMIVtMope4rkqx/5+sOji7rAdE1VVtqxv
         TfHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l91si2047709ede.307.2019.01.31.02.23.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 02:23:50 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7619CB049;
	Thu, 31 Jan 2019 10:23:49 +0000 (UTC)
Date: Thu, 31 Jan 2019 11:23:48 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
Message-ID: <20190131102348.GT18811@dhcp22.suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-3-vbabka@suse.cz>
 <20190131095644.GR18811@dhcp22.suse.cz>
 <nycvar.YFH.7.76.1901311114260.6626@cbobk.fhfr.pm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YFH.7.76.1901311114260.6626@cbobk.fhfr.pm>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 31-01-19 11:15:28, Jiri Kosina wrote:
> On Thu, 31 Jan 2019, Michal Hocko wrote:
> 
> > > diff --git a/mm/filemap.c b/mm/filemap.c
> > > index 9f5e323e883e..7bcdd36e629d 100644
> > > --- a/mm/filemap.c
> > > +++ b/mm/filemap.c
> > > @@ -2075,8 +2075,6 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
> > >  
> > >  		page = find_get_page(mapping, index);
> > >  		if (!page) {
> > > -			if (iocb->ki_flags & IOCB_NOWAIT)
> > > -				goto would_block;
> > >  			page_cache_sync_readahead(mapping,
> > >  					ra, filp,
> > >  					index, last_index - index);
> > 
> > Maybe a stupid question but I am not really familiar with this path but
> > what exactly does prevent a sync read down page_cache_sync_readahead
> > path?
> 
> page_cache_sync_readahead() only submits the read ahead request(s), it 
> doesn't wait for it to finish.

OK, I guess my question was not precise. What does prevent taking fs
locks down the path?
-- 
Michal Hocko
SUSE Labs

