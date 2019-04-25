Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B3DDC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:52:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4649720652
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:52:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4649720652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C17E6B0003; Thu, 25 Apr 2019 11:52:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34A0D6B000A; Thu, 25 Apr 2019 11:52:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 212076B000C; Thu, 25 Apr 2019 11:52:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id EEA6E6B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:52:31 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id s22so185793otk.16
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:52:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=wUbnBCfcHyV0vNXyYVD6zYLPFFHhox+A9FH7LbqJShI=;
        b=rRTzAs53P86m7GLZey/5o/3jRYur86zowjW+EAy0TnhEvsn9EjYbqXovF0VejuD7Nv
         DBkM/Ir7X2k+u0c63/po26qVkupswKCW/1y8WUPAkQKEZWJa9UfxGbYc/Tss0aXsx5c4
         PYqHSEgrHUIjCo6TzN4P62s5FgMKFId1W8bs0ZeoX3gMt33Ns9j3qSgr1mQ+OVT4O0I4
         f6yezV7+Cu/wrZqbVs0aiX0+IrsAOolKr4DnO1/zlgQUvN8gQxISXQpaftSVW6nZbR58
         1qrLASMLFQpxzKbL4DmJcBazf+6UnHtNm28alcLUfd3Au+w8NiZ4lIgky6F46IoRGdvn
         TfJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUwKrfMjUduEuFr91R+32hK3qsQWTbhdc6qpBLVbUKa2T0IBkgh
	UikbHG+Y0N4UB66sfe+clL3Mv1sAgRa3ujst5LkuahbGH6Wm1qFpiCrPTqOKvxwKvwmrUrMzfHU
	dcW7j1p8uPmvWI0NmjZT7TAb5M6D+BAS/j7kOMkeKzAvRGETyDYL/00yMZdCc20gIVw==
X-Received: by 2002:a9d:77d5:: with SMTP id w21mr24641917otl.227.1556207551704;
        Thu, 25 Apr 2019 08:52:31 -0700 (PDT)
X-Received: by 2002:a9d:77d5:: with SMTP id w21mr24641868otl.227.1556207550872;
        Thu, 25 Apr 2019 08:52:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556207550; cv=none;
        d=google.com; s=arc-20160816;
        b=RGEhKVyM1/l1HDYtqJnZ3cYwz5JVq6958HD/Vj1heslN8TE23pdu0qqHBn5XzaTApg
         Nx9cB/H27zx0qH4IAHwxCxrJ4gnBCma4Sq0AalqxUIcTEz0qWFb3aWhcc8WWObjlzdSK
         JoxG5I5Gcn2FSBV0VJPC9L0XhsZNXP5kXAbaWUjEvvMCj55wmCoifNKtLmNSoRARu0DZ
         64rhSdanLsxQpJ505DOWndjX8bk2icRpM5mBoQeFYViHo8ha+i++9wzurGKTagYMfp1Y
         JdzMhvWj1YJpDklyFtm909P9PWvlT6ZUdKnfwlzhelHz+qO0FlLCEk30HUMe7u7+qFa+
         qwxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=wUbnBCfcHyV0vNXyYVD6zYLPFFHhox+A9FH7LbqJShI=;
        b=bbbs5ghm2rU0aArT4OY0xUt4hHCilIH/kpVULrLsLk0ExUD3Lm+FNTGcGT1W8566hm
         DEqv+ao8BmPBgJwSykEaW3Q6XN3sFQbHWFfqRVgdLG5RvI4ZMeE7+pY/P//etBuw5Hdz
         Y8JP04ZzJ0/oKZx0whfJjebo5cEqWbes6OuvUxoF7oRl0vIsxJ63CzYr3yy7tidLc0Rc
         KBMfemSFzu+ULrQSt81Uuq7QaunO4q8tyYRRSwmcjju77XMXLf6PhacRFNs6R4XWIbNB
         D+9XU9M+A/FNbPOLZpnqrYpQiPj99mFmkbJg/SCyIuhOU+5LOuHapUU9prrgrttyNvNl
         8T5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x26sor10368867otq.176.2019.04.25.08.52.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 08:52:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzjZH52CaT/Rszuj+CrArtdz/r/7uwwRZ3+qFEQ3zh1Kq9rxBRI6hm2zdYXb3FpvOI8PD7g1dHNIpUn3m+ucmc=
X-Received: by 2002:a9d:3b04:: with SMTP id z4mr23507491otb.1.1556207550633;
 Thu, 25 Apr 2019 08:52:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190425152631.633-1-agruenba@redhat.com> <20190425152940.GJ19031@bombadil.infradead.org>
In-Reply-To: <20190425152940.GJ19031@bombadil.infradead.org>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 25 Apr 2019 17:52:19 +0200
Message-ID: <CAHc6FU6hNiQhzQq3+Z_efPpon6LfB_8i+OQqOUVQg7uZ-wPJRA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] iomap: Add a page_prepare callback
To: Matthew Wilcox <willy@infradead.org>
Cc: cluster-devel <cluster-devel@redhat.com>, Christoph Hellwig <hch@lst.de>, 
	Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, 
	Ross Lagerwall <ross.lagerwall@citrix.com>, Mark Syms <Mark.Syms@citrix.com>, 
	=?UTF-8?B?RWR3aW4gVMO2csO2aw==?= <edvin.torok@citrix.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Apr 2019 at 17:29, Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Apr 25, 2019 at 05:26:30PM +0200, Andreas Gruenbacher wrote:
>
> This seems to be corrupted; there's no declaration of a page_ops in
> iomap_write_begin ... unless you're basing on a patch I don't have?

Oops, this has slipped into the 2nd patch, sorry.

> > diff --git a/fs/iomap.c b/fs/iomap.c
> > index 97cb9d486a7d..967c985c5310 100644
> > --- a/fs/iomap.c
> > +++ b/fs/iomap.c
> > @@ -674,9 +674,17 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
> >       if (fatal_signal_pending(current))
> >               return -EINTR;
> >
> > +     if (page_ops) {
> > +             status = page_ops->page_prepare(inode, pos, len, iomap);
> > +             if (status)
> > +                     return status;
> > +     }
> > +
> >       page = grab_cache_page_write_begin(inode->i_mapping, index, flags);
> > -     if (!page)
> > -             return -ENOMEM;
> > +     if (!page) {
> > +             status = -ENOMEM;
> > +             goto no_page;
> > +     }
> >
> >       if (iomap->type == IOMAP_INLINE)
> >               iomap_read_inline_data(inode, page, iomap);

Andreas

