Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46429C19759
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 05:29:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0386E218C5
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 05:29:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nCFuvFNj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0386E218C5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DF2B6B0007; Wed,  7 Aug 2019 01:29:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 868316B0008; Wed,  7 Aug 2019 01:29:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E2086B000A; Wed,  7 Aug 2019 01:29:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 32B006B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 01:29:10 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j96so3920777plb.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 22:29:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1vTjKKjPXcwvezFpuQlHk79++RRKGCelf1VGueOrrEQ=;
        b=kt65VtiJzH1D7lWHs85peBSGx3Cjyc6dk3owfzZn4/7ZWOfwYs7/+C5Orxg90Qz9rJ
         N2IJOJ87hH9xfaBrQzTpIzXQErMrgB8CJr5tQWVsD+HvlDNUukhNBONZGE3uPWQMCA3B
         HX32kn9+wFGy3+4D0cufLK1xNi09qCB9Vyk3ta1G9imbLd+YBkl1773GUyaM52x3iaLo
         GoRLXHifD8Kap+ABUCPrcb0hv6NI6cuwSjVrwTBV2Q33aOc5a1T6fHnOrCI9A76xuXZR
         11tYgpLXSoi/1Q2332zvTv6stQYY+1/ym+tvS0ewnn1tYgRHyXRsGWYjvtV7Sr5DMLSF
         5KrA==
X-Gm-Message-State: APjAAAVCg8bAwK15BYQQoCaWxvvD3mINJNvaHk/yBIOBoMIfH2/tt/Tb
	Slz/k+b/CbFD4PIJKinLs/JtQ9UbvhEj2pedhly6pNXYHwoqdQ7y4oBpUu3KPYq3ffJA6bCew66
	qDIn9b1ONJMwPYePCDCaXCINaOMcS76NfD+JpuzpBAh7ffwmsSsOpurqy18ivtK3Skw==
X-Received: by 2002:a17:90a:2525:: with SMTP id j34mr6847366pje.11.1565155749889;
        Tue, 06 Aug 2019 22:29:09 -0700 (PDT)
X-Received: by 2002:a17:90a:2525:: with SMTP id j34mr6847344pje.11.1565155749223;
        Tue, 06 Aug 2019 22:29:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565155749; cv=none;
        d=google.com; s=arc-20160816;
        b=LXU4C6v+L7S4/hvK2WZ8d/JaVy6Hz8BPsKfu+aRMb842dfJAb7dyoEDQHqukfISS2O
         vy+AufOM1koPfHVXXA5Ea3ZjA063O2F7FZh+Srh0FXc8DK37OtmAJKPqNbUqiMU/euTk
         E6cnT609fWeMpj1kSSXTcCqaQ2R/sBIj7eUU8Z78O6GoaMZyCJSoWL2auK6c5DfYIlwk
         fa+UWkIXVTA1lNIYL9TwEAdhDXOevhhA2JON/tNBaksdUKmNJbIB2OGeArTmvaBxcKrU
         2pkEiQ1V6FHdG7FJ4aN11M447loJJ0wb0o9OKi4x2hMCLH5TGYr6nyVlkq7IhKmQlJ9T
         zZAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1vTjKKjPXcwvezFpuQlHk79++RRKGCelf1VGueOrrEQ=;
        b=kl0PEPLZ7VG7QL5tjioCQ2VDI/M7bAbqgZS2+tnfByg6xv+OTkqaGjrEkoOuXpcwIQ
         zIwocLDYTKlENA6fYpzvlsYunV78G1fhh7Y7pEohHOpt93h4x3aB7GUxeYsiOwthktEH
         iXGGvbDNeBIefDIT/BjSGf86fB9kXmX/c8A9mNYXdWA26r8B7G/zqHFq1bC9ZfOzJOfI
         suGkRaUTF0KfwaJ3Kmxu6jSiFLVagy6JQeQsFV54+HT7Bv7bIuZuIF8daOo1ZfGB7SYu
         Vjhxg1X8KZ1s8AbrzaiwSMqUvJNQrn/ZkZ+1+aHQxIV5gDAc1SfJCIVnDZddl/cKghFz
         SXOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nCFuvFNj;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e16sor27710193pjp.20.2019.08.06.22.29.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 22:29:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nCFuvFNj;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1vTjKKjPXcwvezFpuQlHk79++RRKGCelf1VGueOrrEQ=;
        b=nCFuvFNjI+cgrH3oDF1fIJi/Gq7hJFsokBsK8Uk0siw2EVuKNJSVN0AMOq6AEhD4Dx
         E6gEWGICMUy//3HQJjqquj7/B4tN4HRsxaKuilwqEnslFkay5kXcE4m4Z+7pnIfDNX4z
         J2MmaMZx/wIlbGaJqxZafWOrIgP0h2OmTm+nFq+KC5BQjgYoFj4YY61UuWYfPrzIK1NE
         OeM5sPFCAxPN4PUucNSQx0XuJcGZW5qJ7jDu+Ylt3wKlLwGa3tGfCcU6uunEtQEA6FsO
         GrtjjJOB+u2Fqwe4751ta6gDwDK1jAz6djR9iimXtoy14zH+CavZcZL7RtJ9tlZ9aCbF
         f4qw==
X-Google-Smtp-Source: APXvYqy8DYamhO+Xxeu70pQ++qwQXuBclAgixKYv4wKka+YwFq7p/cQW6qI5JZSet/yTl8yH7Gy/lg==
X-Received: by 2002:a17:90a:30cf:: with SMTP id h73mr6810509pjb.42.1565155748748;
        Tue, 06 Aug 2019 22:29:08 -0700 (PDT)
Received: from mypc ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id v63sm91853525pfv.174.2019.08.06.22.29.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 22:29:08 -0700 (PDT)
Date: Wed, 7 Aug 2019 13:28:58 +0800
From: Pingfan Liu <kernelfans@gmail.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/3] mm/migrate: clean up useless code in
 migrate_vma_collect_pmd()
Message-ID: <20190807052858.GA9749@mypc>
References: <1565078411-27082-1-git-send-email-kernelfans@gmail.com>
 <20190806133503.GC30179@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806133503.GC30179@bombadil.infradead.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 06:35:03AM -0700, Matthew Wilcox wrote:
> 
> This needs something beyond the subject line.  Maybe ...
> 
> After these assignments, we either restart the loop with a fresh variable,
> or we assign to the variable again without using the value we've assigned.
> 
> Reviewed-by: Matthew Wilcox (Oracle) <willy@infradead.org>
> 
> >  			goto next;
> >  		}
> > -		pfn = page_to_pfn(page);
> 
> After you've done all this, as far as I can tell, the 'pfn' variable is
> only used in one arm of the conditions, so it can be moved there.
> 
> ie something like:
> 
> -               unsigned long mpfn, pfn;
> +               unsigned long mpfn;
> ...
> -               pfn = pte_pfn(pte);
> ...
> +                       unsigned long pfn = pte_pfn(pte);
> +
> 
This makes code better. Thank you for the suggestion. Will send v2 for
this patch.

Regards,
	Pingfan

