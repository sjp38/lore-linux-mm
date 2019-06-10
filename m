Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB491C2BCA1
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 01:43:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62754206E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 01:43:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62754206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A633C6B0008; Sun,  9 Jun 2019 21:43:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A14536B000D; Sun,  9 Jun 2019 21:43:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 929716B0266; Sun,  9 Jun 2019 21:43:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7690F6B0008
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 21:43:32 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q13so7830539qtj.15
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 18:43:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=agQ2QJU1XwbHQq46yP+XGXkj2wp9ZpFAIxnWm3mvt30=;
        b=mekUnqaxh2egCbLA5mxBfyaLRUItYRbY5qgLy0fUoKlYFdGXneMmeZlA49CMwHnQVd
         cXaYczuVI2HxLCiefau597RqSmxHRx+NVsoSCoIFz/N752oE+KQnAlnUOmuUmWUnJcvF
         TmyHUo5fH9rfy6JMLSITmMQ/XHeaAwtOh1+2rbqytUpy5leJj/mRTcbd2DJ3FcSXRil0
         vpLbT79iFVvztElNEfEU/m9Y7sCYxK/13q3cZ3JIN22sDdCBp6wJqbmw8Im6jKerUSCm
         TSzE3bIiPM8HijWhYWTo9ASUMTl09GNudIQXXgs4D1p0nTXZAvIB+nJ2kj+p+uchA7tK
         BtCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAWOl3lrQ0/N4Sb7Rhh0LkE8laX3r/cVHCJqa7uP7VDzY+IOc8H9
	9P+Gf/AzP6uANGjNdfu5B7MBGVVKX4XJYp6YXzXNGwa51k5bnZ2xPDNekCekSJ4bNy/YubXtOmw
	uBHBmNzFnbdxXBW/lbybnSqe+fyq/hgUpPhE60uiUg8RYuHcQ0hJQBFU1Ll2vJWW36Q==
X-Received: by 2002:ac8:849:: with SMTP id x9mr8796478qth.16.1560131012261;
        Sun, 09 Jun 2019 18:43:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy05b/dUTzS6T4NmfNs6xmjq9pM6qtDBfhLW6oTRzmJLveS5nGk8+qPQCBowZQYome4aY+6
X-Received: by 2002:ac8:849:: with SMTP id x9mr8796450qth.16.1560131011600;
        Sun, 09 Jun 2019 18:43:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560131011; cv=none;
        d=google.com; s=arc-20160816;
        b=O4qWCRIeOJNjuI4429rbaUstE6ErGyNkdMn4zT0gat+jX69NHoflTe7h+ybFlgo1D0
         +4DMPLs1Q/BW2TNRDp34M4XDTqRpoQzfTc3clUn8yGWOskeU5gg5Kzz+qluUJsKtrFbU
         IebFJMjpvcsXpj2VMdI6cqQTOu3sZNQFSqiAjEwD0jOvFJCdRsnR6PsCY9C6OIcebl1v
         /fQsySN0doy2ZbYUKwZk6trZnb06ZiqBOYm7rSXHSmphRaJNCuXvgyW+u1MvUs7lxSa9
         DGsX8OftVX5jP0CCkWKiybRwV1yfnK67FrULGoniF1x3ul9nO98JehW299tYgGIMR+xa
         HoQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=agQ2QJU1XwbHQq46yP+XGXkj2wp9ZpFAIxnWm3mvt30=;
        b=T1ZQsRLE0Nzm9hCkZyVP8t5lvT5i/+pDWKauFaNgSY/L3puuARhdCbN0jXuJgSiEF2
         AnXdY74CV9djsVdvYHZD2mBIESqov1jn7JaDcbZe+miRiV01JFslfplgw4iAlXfBP059
         f6tHfB9u36wNVwW5ZzBkOOK8A4CaI4ncQcyrxmotbdeuEDmTPqiv4hm2S++rp4sv3ZPf
         JjKVw4Z03r5yrNhqsBG8u+B6pvyw1dQz92PkFK3Z8SU3f4vxmfIWdEJyK3p+98t3gXUR
         MP9A3kRrgAfzWxHcPTJ5waQuiziMgUAMZz821JEzRotyue6kbUNaI+vkhzXtrb3TiUoK
         SsUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id g206si3567252qkb.58.2019.06.09.18.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 18:43:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org ([66.31.38.53])
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x5A1hTAK032337
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Sun, 9 Jun 2019 21:43:30 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id A857F420481; Sun,  9 Jun 2019 21:43:29 -0400 (EDT)
Date: Sun, 9 Jun 2019 21:43:29 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 1/8] mm/fs: don't allow writes to immutable files
Message-ID: <20190610014329.GA3266@mit.edu>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
 <155552787330.20411.11893581890744963309.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155552787330.20411.11893581890744963309.stgit@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:04:33PM -0700, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> The chattr manpage has this to say about immutable files:
> 
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
> 
> Once the flag is set, it is enforced for quite a few file operations,
> such as fallocate, fpunch, fzero, rm, touch, open, etc.  However, we
> don't check for immutability when doing a write(), a PROT_WRITE mmap(),
> a truncate(), or a write to a previously established mmap.
> 
> If a program has an open write fd to a file that the administrator
> subsequently marks immutable, the program still can change the file
> contents.  Weird!
> 
> The ability to write to an immutable file does not follow the manpage
> promise that immutable files cannot be modified.  Worse yet it's
> inconsistent with the behavior of other syscalls which don't allow
> modifications of immutable files.
> 
> Therefore, add the necessary checks to make the write, mmap, and
> truncate behavior consistent with what the manpage says and consistent
> with other syscalls on filesystems which support IMMUTABLE.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Thanks, looks good.  I'm going to take this patch through the ext4
tree since it doesn't have any dependencies on the rest of the patch
series.

	    	     	       	     - Ted

