Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E115EC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:11:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9A122077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:11:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9A122077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 447776B0003; Fri, 26 Apr 2019 09:11:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F6C56B0008; Fri, 26 Apr 2019 09:11:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E6A76B000A; Fri, 26 Apr 2019 09:11:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 029266B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:11:17 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id m15so1580700otf.22
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 06:11:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZiEqINjWIRfIVbP9F5CJ9LmrqEpNmidWj1MJ0FFZ5/M=;
        b=Xsf7NKcwat/3sHU6bwNMQVw9kDxuFQof1cQglksPr1LyFVjFPMlVQNskqOuanDJRL2
         ii513wJL4qjwA+RAGujSXjWYUyDhBIyvSw3P+xngzVXq2iRzfodK+P/T1jqfHom/PPD0
         EjOS7n0bvAcQK0+ngUG+mNT+yIviJu7mOtxh0HThrXXaMhxaHt3xFpFgoFoGfe62IvCe
         7oGcA8QF0gUo4I3kX5dotfc+qfsfoVuCStMl6rxB1JT2ryXzbKWJp3RM3L37TEJAR0h4
         OMpx8phIdTLlzdBU66qMJFJmuXjifdQWvv4mGH41bTqagIa3sFLzya4yyBwZ4fIYk2P2
         prsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXgxqOuibJU3y+zvApgMlkYYPT0fA1h3EEthuSO4RJs7YiobvbV
	nFeacKBSOc1+7d03omgyqlDYQPMX8RlowTnjV8ZQM4/rB0IXLE5nOLgSuEYMMucDcHTuftXp7yL
	15etHZ33c7b+feFYYuUp23J16aDZfbwt1j4sRquzJ1Psg8QGZdikuctD+1GgovQermw==
X-Received: by 2002:a9d:7a50:: with SMTP id z16mr25640573otm.363.1556284276450;
        Fri, 26 Apr 2019 06:11:16 -0700 (PDT)
X-Received: by 2002:a9d:7a50:: with SMTP id z16mr25640533otm.363.1556284275628;
        Fri, 26 Apr 2019 06:11:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556284275; cv=none;
        d=google.com; s=arc-20160816;
        b=BCmzYX6VGhWmtAoGWNIQKcKuOGIYHhe0jUW3J96qywzk3sjl5qFHCisU2KXSda5Ofa
         g4M9WUeLK28B0H4VY4iHOiB01Y64kwCByrvpSmmlGi4IVNg9Zz4g6iTKhIiPGs8UW1w2
         bGwlL4DvHZBB9oI9HjljmKEjxL8fdxsdZaF7QgWAHzGZYg0VXAxZMgnqRfhSkdHZrha2
         KOVuqt4I0NNmY+OvvPxNdesuEFzKJHmjKCubGq7vQtMUWNSfXuaJkCjWboCjP5+03/4f
         jMf8OHWZwwNIZnjTvft+eS299tUF2Ww3xhsh4xxpuPTK8SgmKrAbdNJzHQ2SxJVVWRvC
         WnCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=ZiEqINjWIRfIVbP9F5CJ9LmrqEpNmidWj1MJ0FFZ5/M=;
        b=M9DjThDMvZ00rDGhDYgMdoMdw2jcCNx3yXc2ZyG6QiNvEk1JgZ1sJUoNPY/j9vZJAp
         4ykkOEnsOevUBYXlXWUV06HoamGbTPPuauSPCU5rdMHu1XG8vBLJw0fXR1v3qJoxCOUu
         j+NiED0malFhs4vJRL/4sCnFKhYJDxQ7X7MMTH4w+coZzeCe2p2Z0GuHHRTpNSHpYo3J
         41gLQc1AiASjRhUO/Rve6sXpScPIDP2fUV915vRur4IUVRXe2Q7NYtZk7ZT9qXUL3tgK
         QAajqFmsfcE/xOWXcZV/mTggAWbJ0lNX1vFDB3j71XX1F/ZNZYz8MJs1wyn+GDHlTbu9
         Hx5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z18sor11237191oto.31.2019.04.26.06.11.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 06:11:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of agruenba@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=agruenba@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyrBQFW7e0yI6GQM1YP6SGu3J05anOT/doOEscD6yRtuKRQvZxrIcYLjLgJUNCujZUTITvA1SwpvF+uMOD2QtY=
X-Received: by 2002:a9d:61c6:: with SMTP id h6mr7568358otk.316.1556284275288;
 Fri, 26 Apr 2019 06:11:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190425160913.1878-1-agruenba@redhat.com> <20190426083016.GA11637@quack2.suse.cz>
In-Reply-To: <20190426083016.GA11637@quack2.suse.cz>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Fri, 26 Apr 2019 15:11:03 +0200
Message-ID: <CAHc6FU5=g1vzD7iURmcPBEqnQ1WC7GR32r=zzngi+-80mUVv8w@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] iomap: Add a page_prepare callback
To: Jan Kara <jack@suse.cz>
Cc: cluster-devel <cluster-devel@redhat.com>, Christoph Hellwig <hch@lst.de>, 
	Bob Peterson <rpeterso@redhat.com>, Dave Chinner <david@fromorbit.com>, 
	Ross Lagerwall <ross.lagerwall@citrix.com>, Mark Syms <Mark.Syms@citrix.com>, 
	=?UTF-8?B?RWR3aW4gVMO2csO2aw==?= <edvin.torok@citrix.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Apr 2019 at 10:30, Jan Kara <jack@suse.cz> wrote:
>
> On Thu 25-04-19 18:09:12, Andreas Gruenbacher wrote:
> > Move the page_done callback into a separate iomap_page_ops structure and
> > add a page_prepare calback to be called before a page is written to.  In
> > gfs2, we'll want to start a transaction in page_prepare and end it in
> > page_done, and other filesystems that implement data journaling will
> > require the same kind of mechanism.
>
> ...
>
> > @@ -674,9 +675,17 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
> >       if (fatal_signal_pending(current))
> >               return -EINTR;
> >
> > +     if (page_ops) {
> > +             status = page_ops->page_prepare(inode, pos, len, iomap);
> > +             if (status)
> > +                     return status;
> > +     }
> > +
>
> Looks OK for now I guess, although I'm not sure if later some fs won't need
> to get hold of the actual page in ->page_prepare() and then we will need to
> switch to ->page_prepare() returning the page to use. But let's leave that
> for a time when such fs wants to use iomap.

Alright.

> > @@ -780,8 +794,8 @@ iomap_write_end(struct inode *inode, loff_t pos, unsigned len,
> >               ret = __iomap_write_end(inode, pos, len, copied, page, iomap);
> >       }
> >
> > -     if (iomap->page_done)
> > -             iomap->page_done(inode, pos, copied, page, iomap);
> > +     if (page_ops)
> > +             page_ops->page_done(inode, pos, copied, page, iomap);
>
> Looking at the code now, this is actually flawed (preexisting problem):
> __iomap_write_end or generic_write_end() will release the page reference
> and so you cannot just pass it to ->page_done(). That is a potential
> use-after-free...

Ouch. I'm sending a fix.

Thanks,
Andreas

