Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5CF6C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:59:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B84212067D
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 09:59:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B84212067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 470DF6B0003; Fri,  2 Aug 2019 05:59:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4220D6B0005; Fri,  2 Aug 2019 05:59:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 338146B0006; Fri,  2 Aug 2019 05:59:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id C69476B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 05:59:22 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id a25so8216834lfl.0
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 02:59:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=FRhDmYHZIC1Hev3Vv4LwKKKvNdO5WcDiXLTEJa0Wb6Q=;
        b=e0U/w3uv8qJPRzo75bEo+D/92pZJKYwZF/1As4ARwSTvLOPK7U+FMe6plkzd7fobvj
         r74H61tUcmbB5hkS6eqz9xiNHTOdbojyCnEY3Q83I2PPW70xLDC8fcFlFww1b7h3WjIs
         Ptdp6fV26YsKABGLLYa3Tey0S4mckEekDRQC6FOtT7tMwwXPYf0+AwB1Tp9D/G4zw0pu
         52Ez3y7wFpvxIFXldjQsuZ1x7qjQ9hcZEnT+qXV2zef0LjJCohthavqjF6Qd7NUKZW7x
         KJCqozjZhBwEJzB2Zf9o5ahcdI7NkpxjrXWU4tE5HjggnacPGWh4nf+09/gdAX/d3efP
         W0dA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX2Yt2qLI0oitWU5S4eGPKBk2/RwtX+U+7sk0WtH/lyVN1vGZoI
	3xRyimD/b2dx5uVNihQ/8YYSxaUkePNUqDN38ZX0bPI26aRMoNZp+aSVEKIUAdzrW02ag38Y7F3
	FThfEGJwjLR+NsktWc3n3kN6oy74SuS6bFzuGBcaubb/08Mu9y9/K5XDW16ioAHmE9w==
X-Received: by 2002:a2e:534a:: with SMTP id t10mr31917747ljd.109.1564739962127;
        Fri, 02 Aug 2019 02:59:22 -0700 (PDT)
X-Received: by 2002:a2e:534a:: with SMTP id t10mr31917726ljd.109.1564739961397;
        Fri, 02 Aug 2019 02:59:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564739961; cv=none;
        d=google.com; s=arc-20160816;
        b=kDUebTIkWPujyEgxQC25VvssqO3+iGZ9Vu8zVhKaR5+BrCjEvzjj2/nfUh9Fzx6F/C
         QJ7+YbT+5DDpZ2Q0Ij/PksZWRVtf7X9JsNhfD9SEiEFKX1hptsRkBfw7uYnIOTe+ZSIR
         3kqS6hRaOotKS7fMy9Opf4fPeYHWUwQrwP59vqkljrTEzCehjfwWtt3m8E9N0tcKp5BW
         Ly/KXVVPMrys7wumEihYf1g07bHA6rWaQjono48pgoq41O4karcULXYkMiC5Zbtey5X3
         0qQ/M3Z2ZiyvmJH8qFQ3hLoGMvfZGSw/rfHd4w5NWMEyC9x0DO3Wojje1Rucw17afr5c
         Pijw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=FRhDmYHZIC1Hev3Vv4LwKKKvNdO5WcDiXLTEJa0Wb6Q=;
        b=uPw8yDBVsAav65YOq5OnRbta4A4odZRPXUFkXqD1LeUOSBw0sjlX0OTtCWydy7ox7y
         Kox8zpJThDiLSWSJ9clWO+mktAUMAGvKBSEO0P0sJTOxRHKh7x/LcKwJs0Z8mMPkYTIy
         18o84xEENIs91o8xmu62S57WF38R4+EB60ZFIU+EWBtIWR9px0gGhHCFWKwp7bwN93qH
         r4aGHGesYaAjbye/3IalWfGhurlTPuYarWv22pO28/pj/Up/vEfwZnkUCS21McelFuBV
         VRxQaQK8/xCJAAnsnvskEgXLqgNwKNBuQxP8/R3zP9hUQWJp6BYnYYU5r+wN7Xz+q2VJ
         yn/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 62sor40226838ljj.17.2019.08.02.02.59.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 02:59:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liwan@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liwan@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyyK8EgEmz8hF+2gSEiUSnFsdUe/4zdhbsFLQgor8iBA7jBOi8dJU07SXwKtSguTF5nPuH/prS2cMwzOy8x7vA=
X-Received: by 2002:a2e:5b94:: with SMTP id m20mr69692992lje.7.1564739960962;
 Fri, 02 Aug 2019 02:59:20 -0700 (PDT)
MIME-Version: 1.0
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com> <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
 <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com> <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
In-Reply-To: <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
From: Li Wang <liwang@redhat.com>
Date: Fri, 2 Aug 2019 17:59:09 +0800
Message-ID: <CAEemH2drL4LKRi52SQMOgVXQJSpztSKp54jRdNTkfWvPCxe34g@mail.gmail.com>
Subject: =?UTF-8?Q?Re=3A_=5BMM_Bug=3F=5D_mmap=28=29_triggers_SIGBUS_while_doing_the?=
	=?UTF-8?Q?=E2=80=8B_=E2=80=8Bnuma=5Fmove=5Fpages=28=29_for_offlined_hugepage_in_background?=
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux-MM <linux-mm@kvack.org>, 
	LTP List <ltp@lists.linux.it>, xishi.qiuxishi@alibaba-inc.com, mhocko@kernel.org, 
	Cyril Hrubis <chrubis@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

Thanks for working on this.

On Fri, Aug 2, 2019 at 8:20 AM Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
> On 7/30/19 5:44 PM, Mike Kravetz wrote:
> > A SIGBUS is the normal behavior for a hugetlb page fault failure due to
> > lack of huge pages.  Ugly, but that is the design.  I do not believe this
> > test should not be experiencing this due to reservations taken at mmap
> > time.  However, the test is combining faults, soft offline and page
> > migrations, so the there are lots of moving parts.
> >
> > I'll continue to investigate.
>
> There appears to be a race with hugetlb_fault and try_to_unmap_one of
> the migration path.
>
> Can you try this patch in your environment?  I am not sure if it will
> be the final fix, but just wanted to see if it addresses issue for you.

It works for me. After rebuilding the kernel with your patch, SIGBUS
does not appear anymore.

And I'm also thinking that why the huge_pte is not none here when race
with page migration (try_to_unmap_one).

--
Regards,
Li Wang

