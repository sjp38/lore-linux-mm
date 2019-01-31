Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77392C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 17:47:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17D7E218AF
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 17:47:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netflix.com header.i=@netflix.com header.b="RsVaYmhB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17D7E218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=netflix.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83E908E0002; Thu, 31 Jan 2019 12:47:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C55D8E0001; Thu, 31 Jan 2019 12:47:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B67D8E0002; Thu, 31 Jan 2019 12:47:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0E948E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 12:47:02 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id x9-v6so672071ljd.21
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 09:47:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YQ0CTgjbmd0pdovplDj2NTtmiXDZ+p8m8vgln3T/kaw=;
        b=kV3DiibUwA9uQvFormWcrKwsyXbUhRRwDPGhicl6dgexbhK0W6f74ZcKKFHsQp45Sw
         LlBVfrMJW1SORx2qtB0tDnSDVPv1STX/kHSwbA9ZC8lERGgeOzbDgjcTUTQDZIUXYzqe
         j/SOmmA8sQzs1bbIzUbeVR/Xh4yw807Jo4DBRrc09hIExiGGK9qr4xhI4yQD3ZiaXBO/
         HOctVncHDt8BZaVFFHM4E3fTy7bX4q9BxJ+pYZd8xtDri0wcj9YjHYlIPotHtRNpfcVK
         PkkGPji2slNeXDUyoReEeGz1JYy9bT4HOE8RZrdCKqZpeJmYGp5/eaSe2q5uHjsxajlr
         6M1g==
X-Gm-Message-State: AJcUukcTnvOZAjwmPFy5VzSYGr9OvZlIsuLwMt0dpEvgsBIuxpLUytZp
	Cx/xOe4lbjRLcFxmyjKHr2/WQsfOtlYB5ORzVMhsX58BcVtsQNOR3FZDsxOpefA9KHXBC1TXdzi
	yhe/4+KUsv4KxDe8o/glsHHchdM3dMD0zboJsG2kFk4J1m7pGOcXsEOYvqF0Xev1seBDVkV5qyj
	HYAeRaPnB5aX0EU9p812qVnVIhDwiyAxhNZe6+md99X3haVVpVUX5YWuNFyDOo7M8mU93sDJBOX
	KE7NxTXmFEEOjWyvPliH1Ps8wiJylpHTBhXK4qybqTEuYAc4FFwhw7XhZvOnasWooKkQJGAc7bh
	UOGNYeOCi9Kmb29CpdNEITVwYYN8q3TyDruDMGBthos4rDnCnKYUuxB7tdT+7MK2kUKU2WmHv9k
	o
X-Received: by 2002:a2e:5303:: with SMTP id h3-v6mr28425476ljb.35.1548956822177;
        Thu, 31 Jan 2019 09:47:02 -0800 (PST)
X-Received: by 2002:a2e:5303:: with SMTP id h3-v6mr28425436ljb.35.1548956821038;
        Thu, 31 Jan 2019 09:47:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548956821; cv=none;
        d=google.com; s=arc-20160816;
        b=MQ0I1C/tu4hRhwtVxhDT5C12Z4Ko9bnjz5l9S4Egv8NtVHcWU4cXJjua/yZomhzJru
         BOBg86j6oUN5FvhWllGcwUkc2m01LdjIJVuZvvT5wRmeZUZDR6dER7tHzALhd3nTU6SK
         mPUBnPxx1a3paJBOY5lsb8lMxOXygfKXtyuFwklit1UqYiXrishVCmInXzHcqbDGsHsp
         7ciJdtpm52XmEo4gGu0XR/VCD4YhAaBpsltgznD8MHEAaFV2HdAI70UVEhtyuRYUTcgB
         SiXx9Ld7bvSjhnUI6qGD66DGBwPr2+UEDuAxlztmMsDRQ3Q5cQI7EUBXijbxmv+ZAk8X
         cHxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YQ0CTgjbmd0pdovplDj2NTtmiXDZ+p8m8vgln3T/kaw=;
        b=tRNI48a71bfOAhTfVbGA+7gGXosHffbm4o/ctNAgySB8hG7ehhc07A98WaZ2Q+zwki
         0m+QIlyAI71Wmm/ljEtMlnGi3mvTXIeB1TcSmG9Q0SvuDm6nAtOW1pAxBCTH8YIuQoI1
         OIyVvXc3KDBrOP6hl3i7eQHWVeD6p0llkCWClxNW86DA9hONn8ByQn2J0yk+tRNBUNZI
         8PDflKsQ4o+PrPicahqBxYqsnaAW5hlTHSOhn6M2/jj65Zn9X6t24DwbmwcKDMcvdcPd
         9Xpi40siVXMn1Rem8mwnPB1FWmVyDEGoZHDlI0z+rd5URPzM7punHv8wEdnPSjzoNi25
         qx2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@netflix.com header.s=google header.b=RsVaYmhB;
       spf=pass (google.com: domain of joshs@netflix.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=joshs@netflix.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=netflix.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k189sor1683377lfg.2.2019.01.31.09.47.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 09:47:01 -0800 (PST)
Received-SPF: pass (google.com: domain of joshs@netflix.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@netflix.com header.s=google header.b=RsVaYmhB;
       spf=pass (google.com: domain of joshs@netflix.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=joshs@netflix.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=netflix.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=netflix.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YQ0CTgjbmd0pdovplDj2NTtmiXDZ+p8m8vgln3T/kaw=;
        b=RsVaYmhBlOMvoKu0Bs80xDlVn5d/2mEFZfCWvwoNREkNG5gxJdU1M+i7AXhkE0F7vW
         OyNoAefM1EAdRDJLMDPbYWrqvJYZTdxjbpF3G1ZKHc5ccIgQkP675sGCT4IovbulvJqR
         AAO+eTtsQpEy6wH/2b6ttNHnNSij2ra0H7y4Y=
X-Google-Smtp-Source: ALg8bN7WyUdF3lMQZG0vshgU7Ox7FsCVbh5rnJsJCpT9ySluP1phE9AEe1cSAkPmPgqITFfyJbpAJqZ0Xqgfhsx6yGM=
X-Received: by 2002:a19:4bc9:: with SMTP id y192mr27207292lfa.49.1548956820295;
 Thu, 31 Jan 2019 09:47:00 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-2-vbabka@suse.cz> <20190131094357.GQ18811@dhcp22.suse.cz>
In-Reply-To: <20190131094357.GQ18811@dhcp22.suse.cz>
From: Josh Snyder <joshs@netflix.com>
Date: Thu, 31 Jan 2019 09:46:48 -0800
Message-ID: <CA+t-nXQwU7q_2jVM+PY16wETRp9tBngcpWMtSnBz1u1ev-ZBig@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/mincore: make mincore() more conservative
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, open list <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Jann Horn <jannh@google.com>, Jiri Kosina <jkosina@suse.cz>, 
	Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, 
	Dave Chinner <david@fromorbit.com>, Kevin Easton <kevin@guarana.org>, 
	Matthew Wilcox <willy@infradead.org>, Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
	"Kirill A . Shutemov" <kirill@shutemov.name>, Daniel Gruss <daniel@gruss.cc>, Jiri Kosina <jikos@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 1:44 AM Michal Hocko <mhocko@kernel.org> wrote:
> One thing is still not clear to me though. Is the new owner/writeable
> check OK for the Netflix-like usecases? I mean does happycache have
> appropriate access to the cache data? I have tried to re-read the
> original thread but couldn't find any confirmation.

The owner/writable check will suit every database that I've ever used
happycache with, including cassandra, postgres and git.

Acked-by: Josh Snyder <joshs@netflix.com>

