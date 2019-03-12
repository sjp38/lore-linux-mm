Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90299C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 04:52:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E825214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 04:52:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="dElPNkce"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E825214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE14A8E0003; Tue, 12 Mar 2019 00:52:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B91748E0002; Tue, 12 Mar 2019 00:52:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A80788E0003; Tue, 12 Mar 2019 00:52:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0938E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:52:08 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d49so1185313qtd.15
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:52:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=qK7Kkdb/luLy5flAaiCvdcEVBIH2RfSi6TODITDFLgA=;
        b=HTtj33ton4/ahpDPVjuSjT56llz4Ud/bkejhV9fP486ZUFOZoBfjMWFReGM4jhg6tR
         c3Ju4Idmgx4g67CYAVybmJGNFroiwKPu2k6n70LxlgbKylghEogvRmFINoqIbBss1SL1
         bFw6qK8IQ6iyJy1CaoMZhpaTni21de4hT6Q7qE6XfnirporZru81eleNqeWHVj68DL55
         pqNpJvLehjYVL5irta4nb7h/RRMTOh0/dUN320e1spnI6qQJF811/qABDM2c8BkKTahg
         2PalAhHzDakdePg1Hvdn6+uW1d8XxpiVTtN5Y7T9xIMnEQbTqdywe0W24CNKb/Os/Spg
         jPyA==
X-Gm-Message-State: APjAAAX3mxIYYuAoAmduPSzFIADa2jSj1VdjAE/lufupc1uxWQnYkTR/
	ITMG7jZUBMVtKKgmNcUvYNoVRqr5cUHmocHtO9Qbt0RronZcoTdRqdMBfcG00taSIMA31oBtB3H
	9+GsmzB8oKvPjKh24CIQwH672yJWKBG+DiN62X1ty16PUgeqiswJxD5i6lh4ghdE=
X-Received: by 2002:ac8:3653:: with SMTP id n19mr5079746qtb.95.1552366328299;
        Mon, 11 Mar 2019 21:52:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxO6x573+yOTisLH1UFAlSKEiM/8Rsw2OGnthFKqvTgo3wGo2AffAMYXVxISfWi/0bbcgKF
X-Received: by 2002:ac8:3653:: with SMTP id n19mr5079727qtb.95.1552366327621;
        Mon, 11 Mar 2019 21:52:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552366327; cv=none;
        d=google.com; s=arc-20160816;
        b=wwRrYDlN1x3ceyu5vFGKde2PSKZ7i4O41swVRH8emebOku0UVMA0nNqzj1AemUZv+k
         92u6EkG05FHprsXo0XTy7ikk2AaWCQXnjcEKfqI8hCwbwNVgjVKriTC4KRhwpVSNu2zE
         owoT09ykDsHZquuVVDJyUatfeILfBqSEgd5SouivWLW/bzGhinHWRwh3WYDfjGN+0s+a
         1EHKMcbBXT+FdKjD6J1tdib3JGR9XuDIp2Shxw2d8n1n03T143vBs12qXXjJ0XoGS8Ej
         MwptAGfthM8z3l5M+za7gats7xPtqWDUbbQ3eHpSsFgwxILDdX5V4ZA0nU14fU5IegYs
         Y4/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=qK7Kkdb/luLy5flAaiCvdcEVBIH2RfSi6TODITDFLgA=;
        b=DS4roxoJ/pgJ47v/UxcuJTRwobruXILFnVxoOLGfjvwg2DccgzCRVLUpZbOluPfUPC
         WUoGgaSNeNoA2jS3WuAUWbYQxEHgjpgJmejkvwdrIcxXsn5dGzfR1PoWn3YPwphfmuhL
         4Gy018Z8FnKZQ+ekh5N0UN1MhpmEn642+JPdU/WtZFsXx9FtUGLy4o4+zg9Zgan2W36I
         /3sfzDhNQ1lg6xCnGy3kh13lKg5k3K0y0rouPVjHE8v4igzIXwMxR0g9hc/X+SeZa6HZ
         j3aTDNdDVm6eXWKFmjlMpmaWL0jtoieM41Bdb+iflH+n9TVAl5Anb2yq+S1Y2ukowpXF
         nBGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=dElPNkce;
       spf=pass (google.com: domain of 01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@amazonses.com
Received: from a9-32.smtp-out.amazonses.com (a9-32.smtp-out.amazonses.com. [54.240.9.32])
        by mx.google.com with ESMTPS id 30si1674093qtt.223.2019.03.11.21.52.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Mar 2019 21:52:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@amazonses.com designates 54.240.9.32 as permitted sender) client-ip=54.240.9.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=dElPNkce;
       spf=pass (google.com: domain of 01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@amazonses.com designates 54.240.9.32 as permitted sender) smtp.mailfrom=01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1552366327;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=qK7Kkdb/luLy5flAaiCvdcEVBIH2RfSi6TODITDFLgA=;
	b=dElPNkceskPXXplCyxkN3dRK3hqf46DyzKgPZ7kq+A9+qVfIrCUBt86RwQ9sawsh
	l/WOqpQNr7g2MIGzf2mgaad0g5o3koVlF16EgjpIcP5ROkP90TqcntjqBI+w1bPoYQe
	xcBj3TFY3yhzoc369I5gBAAaRilESZrIA3dLnEaI=
Date: Tue, 12 Mar 2019 04:52:07 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Jerome Glisse <jglisse@redhat.com>
cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>, 
    linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, 
    Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, 
    Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
In-Reply-To: <20190308190704.GC5618@redhat.com>
Message-ID: <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com> <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com> <20190308190704.GC5618@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.12-54.240.9.32
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Mar 2019, Jerome Glisse wrote:

> >
> > It would good if that understanding would be enforced somehow given the problems
> > that we see.
>
> This has been discuss extensively already. GUP usage is now widespread in
> multiple drivers, removing that would regress userspace ie break existing
> application. We all know what the rules for that is.

The applications that work are using anonymous memory and memory
filesystems. I have never seen use cases with a real filesystem and would
have objected if someone tried something crazy like that.

Because someone was able to get away with weird ways of abusing the system
it not an argument that we should continue to allow such things. In fact
we have repeatedly ensured that the kernel works reliably by improving the
kernel so that a proper failure is occurring.


> > > In fact, the GUP documentation even recommends that pattern.
> >
> > Isnt that pattern safe for anonymous memory and memory filesystems like
> > hugetlbfs etc? Which is the common use case.
>
> Still an issue in respect to swapout ie if anon/shmem page was map
> read only in preparation for swapout and we do not report the page
> as dirty what endup in swap might lack what was written last through
> GUP.

Well swapout cannot occur if the page is pinned and those pages are also
often mlocked.

> >
> > Yes you now have the filesystem as well as the GUP pinner claiming
> > authority over the contents of a single memory segment. Maybe better not
> > allow that?
>
> This goes back to regressing existing driver with existing users.

There is no regression if that behavior never really worked.

> > Two filesystem trying to sync one memory segment both believing to have
> > exclusive access and we want to sort this out. Why? Dont allow this.
>
> This is allowed, it always was, forbidding that case now would regress
> existing application and it would also means that we are modifying the
> API we expose to userspace. So again this is not something we can block
> without regressing existing user.

We have always stopped the user from doing obviously stupid and risky
things. It would be logical to do it here as well.

