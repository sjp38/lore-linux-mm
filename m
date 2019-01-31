Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9881AC282C7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 09:56:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F592218D3
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 09:56:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F592218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ABA78E0002; Thu, 31 Jan 2019 04:56:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15B688E0001; Thu, 31 Jan 2019 04:56:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 023F28E0002; Thu, 31 Jan 2019 04:56:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC658E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:56:47 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so1054796edt.23
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:56:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Qo2xxeek5vA+c1FFjuJ/H4icDx/FEzYp0Mj/oj/MdFQ=;
        b=IIuwqCVCml7MEMNwr6JALvVwIExF/U9eZPA1bPNANCXcfPOCuUgImSvNsv8qLSgRYa
         UvVK1enuKnqyfSzUoekp41vaWEFIR+ZZk2Wv00eeEOhpOvIVPaLVpN4AdJGsS5XMrSES
         cGsZJBww/yyiNkK5SGUkHXBsEF3WP0MuqTU7tkgDAv/Bbdq2Uyf7N/Hm1gWqEHT36ynW
         +DUYjeSLkVdzm2CRa0F6qNqd7rL3dYKzTHT6rGM6ApnUR0zhNDcB/5R38VYbatVr9SQk
         V1SZyhFxhxgKMOq3QgNm1tIjlEYrHogVPkas7ogL4686lhWsKtZvPZ61lbUNY9u3DOWH
         vKJQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukfV+vcKb9WUxeMqui2CqC9I/+WZ5t+0RH1HscttMQ40pZK0XGj6
	UJ1cpcn7eBnFStkH1HD8SziLbtleKSfdRHiQpVj7hrVXH5fX0Bsv/PXpS1aeWO6VEr9ObNnVywj
	8ram0gfuzX2lRaJXSIGQ0Mg1cTgs/Xj6W/sX4SvNHRk0c93BwiSi3o3EF77pIc3A=
X-Received: by 2002:a50:9624:: with SMTP id y33mr32728881eda.206.1548928607172;
        Thu, 31 Jan 2019 01:56:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7EKU6c3rCqqRzuQGlyPdHnLFq4/Eriys6XtuQiPhYw0Vlk0mOdMaj3dpuflqQIRDBfm9GR
X-Received: by 2002:a50:9624:: with SMTP id y33mr32728841eda.206.1548928606324;
        Thu, 31 Jan 2019 01:56:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548928606; cv=none;
        d=google.com; s=arc-20160816;
        b=eRwcwZhFpUajEh52YnUZt+fbRdNEmhx7NLOZG13kkLCCijG8z54DOeDDbNjdpQ6fAH
         8Fr+f4xKGIyfNybVNRk1lYbqV88hC7JJr56t/SZdAD2FIdiF75CAUg29zyHL+jwvb1kI
         PWRyS/nTq+80EnXDNhoJ1lSwMhveXHJjiwTH3CjajaL7u3HWFerP+mBZuTvnBhTtrw3x
         riOFoQe+lUarUDNEH1e/NFJ0hX2WFO7JB5ws1DEH+zydWWB+qR2cQKXFQSeF+A5BgAL7
         9If6PEsaOIGz/vacxQyvUjhE+O0mvZa8k9eUdOnQL7ZAFSoSLcyGokgvN1VDbUaaRhNl
         aHRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Qo2xxeek5vA+c1FFjuJ/H4icDx/FEzYp0Mj/oj/MdFQ=;
        b=oL0xz4KGrCwjxxkEcj8YqnaxJbfan5cM9PJhVDpkv8F+K7DEitxw/+mlsO14vnjuri
         2H88WsIwID2r3ncyr7JLl/afn/l1SJMb3YNkiUBsjDYbBQahQUlPjcSttB7UbxDFi1W3
         CeY3P9j0SBPMfKCL8Ian0ggYOovFmBae3WRQzipiVO4PF3AQux/QsdmE9E5Losj+gcRA
         PZUzFBwA2l8tGPzv1I91A/Bw3PvYkh8yoIIo0X9HJSnGztogu60tuxQ3TpdIq6j7i7cv
         ovU4Y71aXDifYf1bLEl5qvYrb4swkOj/TXwA5MKvVehdKUP1lB/4OsU4Qbnkji6Gskey
         LXQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si2309290eda.325.2019.01.31.01.56.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 01:56:46 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 603D8AD3C;
	Thu, 31 Jan 2019 09:56:45 +0000 (UTC)
Date: Thu, 31 Jan 2019 10:56:44 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>, Jiri Kosina <jikos@kernel.org>,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
Message-ID: <20190131095644.GR18811@dhcp22.suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130124420.1834-3-vbabka@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc fs-devel]

On Wed 30-01-19 13:44:19, Vlastimil Babka wrote:
> From: Jiri Kosina <jkosina@suse.cz>
> 
> preadv2(RWF_NOWAIT) can be used to open a side-channel to pagecache contents, as
> it reveals metadata about residency of pages in pagecache.
> 
> If preadv2(RWF_NOWAIT) returns immediately, it provides a clear "page not
> resident" information, and vice versa.
> 
> Close that sidechannel by always initiating readahead on the cache if we
> encounter a cache miss for preadv2(RWF_NOWAIT); with that in place, probing
> the pagecache residency itself will actually populate the cache, making the
> sidechannel useless.

I guess the current wording doesn't disallow background IO to be
triggered for EAGAIN case. I am not sure whether that breaks clever
applications which try to perform larger IO for those cases though.

> Originally-by: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Dominique Martinet <asmadeus@codewreck.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Kevin Easton <kevin@guarana.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Cyril Hrubis <chrubis@suse.cz>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Daniel Gruss <daniel@gruss.cc>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/filemap.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 9f5e323e883e..7bcdd36e629d 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2075,8 +2075,6 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
>  
>  		page = find_get_page(mapping, index);
>  		if (!page) {
> -			if (iocb->ki_flags & IOCB_NOWAIT)
> -				goto would_block;
>  			page_cache_sync_readahead(mapping,
>  					ra, filp,
>  					index, last_index - index);

Maybe a stupid question but I am not really familiar with this path but
what exactly does prevent a sync read down page_cache_sync_readahead
path?
-- 
Michal Hocko
SUSE Labs

