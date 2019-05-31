Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22A88C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 10:41:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8A2B2679C
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 10:41:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XGkP53Ss"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8A2B2679C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C0BB6B0273; Fri, 31 May 2019 06:41:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 698186B0274; Fri, 31 May 2019 06:41:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AD2D6B0276; Fri, 31 May 2019 06:41:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE736B0273
	for <linux-mm@kvack.org>; Fri, 31 May 2019 06:41:10 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id y13so4869686iol.6
        for <linux-mm@kvack.org>; Fri, 31 May 2019 03:41:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=f7K/6YQSxV880DkgJ09eg6h5iBlyiK20sdzcSTZG0aM=;
        b=lvMCY1UZrdTSoRVgZ6t0c24bZoRbG+w+ZvTphGZqPuoYbI8suGDTtB7nO5RxkkB+CQ
         YeiCpm9UxXLAwtCUCdi2cJR4LQkSJc8nQvPImh3ClgZAo7vonqj/YA+flvfQhkRIWQqC
         ROAAaOXhi/m+mN+wlEoUtNniVeKXRsqfejq7aMPJd5TL/OP98kAtxyYU6qRcFvUpRk9Z
         yE2D9HKCvhFKRS5I9bAgDeaHVK6I9AlpPd9JDH3gg8w6xo6kSHhW9JDO6yIPZ1jHrqVQ
         fk2wnZM2Ey8OsvBZ8pVu3A5FvCiyseZTWcgdCrckSgGboe0AX1nufS7TnCtUABH/JRxy
         JEUA==
X-Gm-Message-State: APjAAAWmDm2oq8qwS8G36fEhgnTK4nhHpqYVz9m8lsUgQyssxerQTr/8
	4uZZfqC0iylYyWffHLjoJWRQtVY4gVqHpfdCOeNA+fxrkWxQ52n3RUoGR3+MD6LD2lNDu799odV
	CDamzUkaCeBSPE2rc6Z1xGDzdxfnFtnbd0Dsmhk8+jSa+0ltOAnK4IpNl4l70NWDArw==
X-Received: by 2002:a02:c544:: with SMTP id g4mr4108504jaj.45.1559299269980;
        Fri, 31 May 2019 03:41:09 -0700 (PDT)
X-Received: by 2002:a02:c544:: with SMTP id g4mr4108481jaj.45.1559299269449;
        Fri, 31 May 2019 03:41:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559299269; cv=none;
        d=google.com; s=arc-20160816;
        b=fY+p4/Jf60sfoFtNoc56SmcLKsWHlRnDoqs4vb2GIpmAKJ5RboEjT6wFMmEIdhJLFD
         B0bx6xvKI+4kQO0Oce5UjKD7rBrBrQkaWZcFkKkEMjngyy8tTZNCPrdT6ErQF8JGilhw
         JDh9AE2+UdKXTaUQZmMQnCm+oEwpt0M5Qv+x3yTyidFrv9/QcpZQj5uZD376lTzdmbiT
         6us7OlfzWyodDpAjAC0X77NfQHnAXYPxxkMeej6SGqty/TsHonwzmh7PwE6IA4BrGTQw
         arrFde5tvL7Vl7dZq3amLwtKihkEK9zvI7OfAzZSoP2URMUlGD/S1F10OGHRPoD1B3dU
         TEBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=f7K/6YQSxV880DkgJ09eg6h5iBlyiK20sdzcSTZG0aM=;
        b=s4Om/7PUx+UwbJbugcv+fyqOuQuQFAZ8MIQnOgsR34DPVfsCAS0jOuk3BEN1cHEJJk
         tysCWenHsSaDjJz/OnHPkUMIN0ekw5Fm+wpcMfgSzf7TE6MjBG1Wc7eNudUNurz6p69U
         Nwpz4FiZ82fkyUVc/3c7leYLE0F3zLiif17S23j2xFeFG1GoFhCaI7D8DG20isZR0FLr
         tZzn0nkUThr0gNZXRwS2pBbuGQUhU7mpz3neKmhuV9ul8KwjYhyG2wn8ER67fDvDXuXs
         RmDJhtD6r3f7Y1h+5m4Akt+KqKUrfOAliKmuIpgM8lmbrBeEZzC4R3A7gFzLbJec8ZR8
         ra7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XGkP53Ss;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t24sor2994097iom.11.2019.05.31.03.41.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 03:41:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XGkP53Ss;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=f7K/6YQSxV880DkgJ09eg6h5iBlyiK20sdzcSTZG0aM=;
        b=XGkP53SshfAPmjGlZUh6RXC8I0N9LNtD1Gjnv7hElsZCRY70TqFTw5zLekprBErZVZ
         kWW0cxpj4Vk8TtbhgL2/m+oJDO93uQmRsgY/3PUAHt72ui+eu+8iMoi0sbO9zp5mjhfA
         1GujwFE4vKK3kFHn8SsgGZLlVsT8v4F/yInGr08a92cncLzgqLyq6eBfsYPsWvYCZ0Ih
         Zwia03Ei1sgEs8sRg0TKkx6I68y9yoOrNuuq1r2Ve5+NvzhE/6WwPZedH24GZrPPwrEj
         U+tPejHGcQjYBJptZNJZri0w0gnND+Gb+fk6g/Kx+1B2BKjDwxaCQbbHjB796JljRktB
         FTLg==
X-Google-Smtp-Source: APXvYqyXE1xefJ2rEEvK1/15mQpuixTmPfm9Ib8UnCkKZn3rkf3o8/n4IOBDBtlTAiwv3kEYQXoYI4jiTop8Ywfoefc=
X-Received: by 2002:a6b:e005:: with SMTP id z5mr4968657iog.161.1559299269094;
 Fri, 31 May 2019 03:41:09 -0700 (PDT)
MIME-Version: 1.0
References: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
 <20190530214726.GA14000@iweiny-DESK2.sc.intel.com> <1497636a-8658-d3ff-f7cd-05230fdead19@nvidia.com>
 <20190530235307.GA28605@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190530235307.GA28605@iweiny-DESK2.sc.intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 31 May 2019 18:40:57 +0800
Message-ID: <CAFgQCTtFmK1=7a4ewb+Dy3JZk=rxthi6ZAJBkkMaTgW2DxtubA@mail.gmail.com>
Subject: Re: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, linux-mm@kvack.org, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 7:52 AM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Thu, May 30, 2019 at 04:21:19PM -0700, John Hubbard wrote:
> > On 5/30/19 2:47 PM, Ira Weiny wrote:
> > > On Thu, May 30, 2019 at 06:54:04AM +0800, Pingfan Liu wrote:
> > [...]
> > >> +                          for (j = i; j < nr; j++)
> > >> +                                  put_page(pages[j]);
> > >
> > > Should be put_user_page() now.  For now that just calls put_page() but it is
> > > slated to change soon.
> > >
> > > I also wonder if this would be more efficient as a check as we are walking the
> > > page tables and bail early.
> > >
> > > Perhaps the code complexity is not worth it?
> >
> > Good point, it might be worth it. Because now we've got two loops that
> > we run, after the interrupts-off page walk, and it's starting to look like
> > a potential performance concern.
>
> FWIW I don't see this being a huge issue at the moment.  Perhaps those more
> familiar with CMA can weigh in here.  How was this issue found?  If it was
> found by running some test perhaps that indicates a performance preference?
>
I found the bug by reading code. And I do not see any performance
concern. Bailing out early contritute little to performance, as we
fall on the slow path immediately.

Regards,
  Pingfan
[....]

