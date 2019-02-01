Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4723AC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:28:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 029392082F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 07:28:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="Dz9K88dH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 029392082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81E288E0003; Fri,  1 Feb 2019 02:28:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A4C18E0001; Fri,  1 Feb 2019 02:28:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 695338E0003; Fri,  1 Feb 2019 02:28:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id E9E848E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 02:28:56 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id 2-v6so1175756ljs.15
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 23:28:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=P18BFRM3FHB2HT0zP5dgNZMDiNjCSTJ5pMr531eoN/M=;
        b=ksIfehysV6IZeMYhAYpwDCznFKYbDYj3nI5eNQe+su/rbjnvX9HJs2K7J/ISRfqgMV
         UgViyowdm350mOturXeqnlXwr/A7aq5oIpZyyVIlCjCdsqq/rL5/51OTBRLzZ0OpydTT
         8wNMr1/S3asv+7x9xMTQ2F1gVDdwITYoCre6nyn4GSSimdh9atRYMIn8OLySNnFZdAOg
         Rppit7HchZQ/xSmkvHt0A2sGUfp0Rlr+3PI3cvIXMZ+/X8PhEkpJpEw5O9g9/qW0HDb5
         eBAqXsqjL221BQJGhdSjZb8vVxRyIvm9xTzvJWL7plYxx3VRp35jPYIBkkdGEd8bUxmV
         zJ9g==
X-Gm-Message-State: AHQUAuYbCnUEIJmu7pKoeVkqt7Z64FeZ97u1A92zN4Uqphs7FAejljK1
	kFfTPmoEZjnPFBVkrmNo5Ld3M0KMdUPPC2q9K7myUPjuF59xvRgqr1goIjjl1E2D2ENk0lsFbZA
	zVafXBzk7Doek/kzqgrQJSs8YMicRjNpQtTjDronmGKTLvFy0fWzKuva5gM6Oj7fCnJjBdnTle8
	g3Z6zjJuZZsUsrzMt/c2GcfgSo4U/lj6mRdIV+cxoHQoj7Fpwont2ahvX7NsBaH84v4jo9s3i+Q
	m5QC8Lyq9DQ+QOJxI7qGa/31gNuEqjSkOguj+h4470QRJZKDEinkMx5XLbPCsGZChXN2rcFdquc
	B7b9JPNMrPOAlkrDJ4xhqfEzSIWRbC/xNZP013ttGdfrqrh5KP596dc3MIJwPeUTP6A0cJ2ZfYG
	z
X-Received: by 2002:ac2:52aa:: with SMTP id r10mr3636053lfm.56.1549006135981;
        Thu, 31 Jan 2019 23:28:55 -0800 (PST)
X-Received: by 2002:ac2:52aa:: with SMTP id r10mr3636006lfm.56.1549006134933;
        Thu, 31 Jan 2019 23:28:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549006134; cv=none;
        d=google.com; s=arc-20160816;
        b=WOuLbpLjQKFnIS9nKqWYjfGa/6cyTdrZidwpus5355DDeW2QMHbKLBw+xMhgGoo5vE
         p95m7RrDKWcwhaBH2AkvJ7VWYWgX0hYOAl+5H22+XDkwToo7k9M7KuNGcQ7d94zvkfvA
         PVr0WZJT5SfCyHRhrp312xIL67sq8TMcAhT9cR0hK9jjfR49KN7aY1md3vK7NI89KE2d
         tT5oZA4uqT623bNsAO/VS9FPAkmzAnz3VPTZyDRVdmg96fv/fiXULADXJjUOqOdsCkuW
         +xsfmXPFeFY3KBcIb+hQFQvfe9KQ1W65Mqgcwj7yxFUgKYZMeDylnjzokqgxEtk0F58S
         4jSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=P18BFRM3FHB2HT0zP5dgNZMDiNjCSTJ5pMr531eoN/M=;
        b=RGIT8MCHTgmnkgy6d3Fih6Ag/d5mG1P/a6VFa9IM3dEe0nj4SIo6aUGw1aVX+BbIID
         loQJrC7YbsoiuFKHMloPLtmiLu2H7XU8iTqgnh7LJipGPIx3bhdIpa2nxQWtKIQGTVDs
         5eyJ5JJg4OV7bCaUgAEyXgKWHfB9mmAhAZ6EsU230WAxodBW7rhsj6r5ZZD4fDj4f/Pa
         dZwsbKPjq42RD5FFaV2WQNObtwN3GSoelKB4IHqIrfE8pEhSoa6n0DSeLYFjYrfpak8B
         eskGeEnpg07Fr0qHOl5n/fMoX/inl0NF7nNaCT9xuqyZFbOeXbu4JPdeF9x+YFj0jRk+
         pWEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Dz9K88dH;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o22-v6sor4741431lji.38.2019.01.31.23.28.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 23:28:54 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Dz9K88dH;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=P18BFRM3FHB2HT0zP5dgNZMDiNjCSTJ5pMr531eoN/M=;
        b=Dz9K88dHG0MbOo5xXIKHy6zdQlsgU8yR75VOq/fcOVBfdMTH0TkY2f7OZ29Vni7G7T
         PrPv8xbCSagWseLm8k1O37oAaGqIQshCQSPPfK6Op87yEDO24e8qkElqk+QU7F0wW8Bm
         eG7DkoUiiW6lL19Q6f2MiV+avBrpKbTpyAAkI=
X-Google-Smtp-Source: ALg8bN5RMF+F60bZnD1Wiv3mw7AcD9LbUE7LsYltiQpQdP5YUfDgozraEl7BxxRd46TUXmTxeqz2tg==
X-Received: by 2002:a2e:8087:: with SMTP id i7-v6mr30008892ljg.179.1549006133967;
        Thu, 31 Jan 2019 23:28:53 -0800 (PST)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com. [209.85.167.50])
        by smtp.gmail.com with ESMTPSA id 10sm1131748ljr.4.2019.01.31.23.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 23:28:53 -0800 (PST)
Received: by mail-lf1-f50.google.com with SMTP id p6so4330576lfc.1
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 23:28:53 -0800 (PST)
X-Received: by 2002:a19:ef15:: with SMTP id n21mr29965253lfh.21.1549005729676;
 Thu, 31 Jan 2019 23:22:09 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz>
 <20190131095644.GR18811@dhcp22.suse.cz> <nycvar.YFH.7.76.1901311114260.6626@cbobk.fhfr.pm>
 <20190131102348.GT18811@dhcp22.suse.cz> <CAHk-=wjkiNPWb97JXV6=J6DzscB1g7moGJ6G_nSe=AEbMugTNw@mail.gmail.com>
 <20190201051355.GV6173@dastard> <CAHk-=wg0FXvwB09WJaZk039CfQ0hEnyES_ANE392dfsx6U8WUQ@mail.gmail.com>
In-Reply-To: <CAHk-=wg0FXvwB09WJaZk039CfQ0hEnyES_ANE392dfsx6U8WUQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 31 Jan 2019 23:21:53 -0800
X-Gmail-Original-Message-ID: <CAHk-=wibb_cXG2e81ZiapC-SJPDwG4kaQ16XgJ_1cb3jgF9X3Q@mail.gmail.com>
Message-ID: <CAHk-=wibb_cXG2e81ZiapC-SJPDwG4kaQ16XgJ_1cb3jgF9X3Q@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT is
 set for the I/O
To: Dave Chinner <david@fromorbit.com>
Cc: Michal Hocko <mhocko@kernel.org>, Jiri Kosina <jikos@kernel.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Linux API <linux-api@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
	Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, 
	Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, Cyril Hrubis <chrubis@suse.cz>, 
	Tejun Heo <tj@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Daniel Gruss <daniel@gruss.cc>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 11:05 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> And part of "best effort" is very much "not a security information leak".

Side note: it's entirely possible that the preadv2(RWF_NOWAIT)
interface is actually already effectively too slow to be effectively
used as much of an attack vector.

One of the advantages of mincore() for the attack was that you could
just get a lot of page status information in one go. With RWF_NOWAIT,
you only really get "up to the first non-cached page", so it's already
a weaker signal than mincore() gave.

System calls aren't horrendously slow (at least not with fixed
non-meltdown CPU's), but it might still be a somewhat noticeable
inconvenience in an attack that is already probably not all that easy
to do on an arbitrary target.

So it might not be a huge deal. But I think we should at least try to
make things less useful for these kinds of attack vectors.

And no, that doesn't mean "stop all theoretical attacks". It means
"let's try to make things less convenient as a data leak".

That's why things like "oh, you can still see the signal if you can
keep the backing device congested" is not something I'd worry about.
It's just another (big) inconvenience, and not all that simple to do.
At some point, it's simply not worth it as an attack vector any more.

               Linus

