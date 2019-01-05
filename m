Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0D8DC43387
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:39:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D93C222F1
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:39:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="T5rpLbUe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D93C222F1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A0FD8E0136; Sat,  5 Jan 2019 18:39:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 151798E00F9; Sat,  5 Jan 2019 18:39:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F33018E0136; Sat,  5 Jan 2019 18:39:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 832B28E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 18:39:30 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id l12-v6so10655272ljb.11
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:39:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bqn7KU+WgVrfy/zTMX85nX2nASUNdrmXGozjZhj/P34=;
        b=YXf5OzCgtv3+OQGul6uGFLwlDpYHvWTn0ok4YA+9m/VQe5MV2PyOzqoiv48tIXNLB5
         3Agtd1hDN29XQmyTvPdphL1IWxsFohSyRq0I457V2vsJkU+45YqMQPwQ6PEW7MwVB1KX
         GPePgP0V/A26qV0gBFED1Pn0KLoBIgyTQDHJXWRCOuq9B80uwGyeVG3Gr5USx/R9TTn0
         UDWiAu1WRWu6Hp0gBOzCZY/vpzrAby2B6gV8PzCNLyTDh0y7e/KxI7OxkRTdOGmhcKRb
         Ryi2qvcK4Hgadvin74t4xCXqzdU2cWq5rm8sXXja+IuMoKqyI34yUD5rsPUC7eyphUi4
         blPQ==
X-Gm-Message-State: AA+aEWa8KkoaTa3B9vZM6Tq6YUssbPZP/wJ1MjfnqD8PDpDPKyry789K
	Ar4p6a7/CfmlC+1dnc5MOBgl9oqycr78TbJ9M5lEWb9EsX3VXL19UuNDgWg+F4dUBZqSRxyL7df
	rQqtxsfVSMhzEBXgAkZKi/GLyyDnEgLxLaip/jhXg6dEeJOVFz8tsMCXv9JMp53m81fZi+sZzDm
	/6HOrUrKdxtflqW5DAAFsNBP8yJwOLE2TfMQFcZHq2fmP566kcnIED4tXA9xpqJBeOKuq0K0Z4Q
	dcSYAlvYCTGXUuOLXaTTT1uNYpwP91SMNw8D6X82rTWlNqvF+U9cSDX3Yxm5bSjwSiDZXxHCmPh
	IkfXSeW0jIYZXSXJt1NWfOePIc24RUBdzOtDVGGVsvj/HDIRJM4VoS9oBuyEAxvN+uMivZnWyz/
	0
X-Received: by 2002:a19:9653:: with SMTP id y80mr27918479lfd.66.1546731569816;
        Sat, 05 Jan 2019 15:39:29 -0800 (PST)
X-Received: by 2002:a19:9653:: with SMTP id y80mr27918469lfd.66.1546731569159;
        Sat, 05 Jan 2019 15:39:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546731569; cv=none;
        d=google.com; s=arc-20160816;
        b=SklErsIWUAAzRvqcuTGELS+zzXtYQmJd5juDPlNjUaBUT6CYPv6mKDZTRUg4qayXaQ
         CMBtPkS8TpQ44ydECcdgNNnYmh5ZwAwI3uyDNHRpXY9IX/lZeypL8KeOsLkz1SsDVdzr
         ojvEAG3lxhxnkU00+1t5BKUHP+FaulPVUT6UnxDrR9SrWG5cOiy7ln9hz83mm3+hHgzZ
         yK8zu3QO65bpL1Vk/EXmknRBQihoxlVUQHYQ9iHgL5T8DGmolwOaMY8fKWQRcqjT6P+R
         bP3ARBX3A5ZruLMe83+0xo0QO1+6dRU0e982bU9OAkUWf9r3lM9DAY8uw6Rtek3MALgS
         qnlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bqn7KU+WgVrfy/zTMX85nX2nASUNdrmXGozjZhj/P34=;
        b=R6K/tamjdhy55+BV3QKAMfc98aPlVpROPJ7dfshOlWs2hlm8/nZiV6BTg5mNkQmES4
         HJbfs6uHNRDonS0z876EXzdFup5RsMwbOAc3DNGlQEolcUdU8/wP+ZEzpxjtLf6gnkpY
         r9yzx4BRPPU0hTsglVH9CYOnPhHDKKOrZgeU6uyGr9Jn18qtxW4xg/PQtZHXt9wiYILt
         T7h3dPWqvqB9kX8UcjGLgoEMDZE+nn85TJ6zxcoKKEr5Pxxrvlgf/83LnG2JTAzkiaE8
         iNoWxtsAjIHak2smdMTr4aNdvDazkxS4Nh5QkOCfbeFhsug/kQFCD3cALEu1l2082+ox
         PaMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=T5rpLbUe;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h14sor15292361lfc.14.2019.01.05.15.39.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 15:39:29 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=T5rpLbUe;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bqn7KU+WgVrfy/zTMX85nX2nASUNdrmXGozjZhj/P34=;
        b=T5rpLbUe43AjyR/Tays+5hbKh/g/PPzb5DJwZdl42hJPSlD71AGfF/5kapE247v3zf
         WwJ+RVtey6C00eBVmeJ6Ke+ra/20LG+umoF5rijWao25CREZdQDrrdSryW3gSlN1T25V
         nd/Di9P/35w1cIE/gk7xjYwTnPmL9y0w+5e5o=
X-Google-Smtp-Source: AFSGD/Ugc0eiVEJE8HC8UAs47q9LWI9b/v519tFRf8gcBQjvbaFtv1R2gzQr16qP3rJ21EyJm6NoMQ==
X-Received: by 2002:a19:c995:: with SMTP id z143mr23755826lff.79.1546731568261;
        Sat, 05 Jan 2019 15:39:28 -0800 (PST)
Received: from mail-lf1-f41.google.com (mail-lf1-f41.google.com. [209.85.167.41])
        by smtp.gmail.com with ESMTPSA id k3-v6sm13023310lja.8.2019.01.05.15.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 15:39:27 -0800 (PST)
Received: by mail-lf1-f41.google.com with SMTP id e26so27780245lfc.2
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:39:26 -0800 (PST)
X-Received: by 2002:a19:6e0b:: with SMTP id j11mr30186946lfc.124.1546731566565;
 Sat, 05 Jan 2019 15:39:26 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com> <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
In-Reply-To: <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 15:39:10 -0800
X-Gmail-Original-Message-ID: <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
Message-ID:
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jann Horn <jannh@google.com>
Cc: Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105233910.fouo8zoqHIMv5MF6WITaoOt2d9u-mRf779NNq4fpYLI@z>

On Sat, Jan 5, 2019 at 3:16 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> It goes back to forever, it looks like. I can't find a reason.

mincore() was originally added in 2.3.52pre3, it looks like. Around
2000 or so. But sadly before the BK history.

And that comment about

  "Later we can get more picky about what "in core" means precisely."

that still exists above mincore_page() goes back to the original patch.

           Linus

