Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E96C7C282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 18:43:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 857F320883
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 18:43:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kXiGqdmh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 857F320883
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28C2E6B000A; Tue,  9 Apr 2019 14:43:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23BB26B000C; Tue,  9 Apr 2019 14:43:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12B5A6B0266; Tue,  9 Apr 2019 14:43:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D18156B000A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 14:43:57 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g83so13649449pfd.3
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 11:43:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=VQum5xkYgWrLXwSjhxQf413Vq4UHlR9jwivyiD7Y/bg=;
        b=eFSCmQNlprdeDzV4mLfFtbxX+lzgP4Kkri9frYzBr2r9oZNjW34iK+feXFcFWWFLFG
         u2toLH/PSX1U46XTbTums9Ir3+MB/CU7aTImF6oNlA1ztZFmA/3btH3AIl1RaVnGQC6z
         S5BAyoualZ8oxweJpEQsLoDfGR0Uk8UJ3+Vf4dKhoNQL+Ke8jwT1eGbox0/wZZTZ39uk
         fprN4mWUQ0+HMoodSkAdUFVON8J84L1/SAw0U6f2Ina2qJcX4dzjVvkwbjL6r5MZlo6q
         QYY0oxj6MKNyIcJErc+x60KtdF4dMS5DF3RQ/xKgzVhdTP4zfVvmc34NA4gvcvinypoy
         NYjQ==
X-Gm-Message-State: APjAAAVCoDP1jj4sPDLz2i6FtvRCFbgt7sW0ez9QNJ9WCn0TfgMtk4wa
	InOqTNZa6uHYUYuKWy5d1ZbXySF0vG1lMCRIwF5sK3YI7/b+8/GBu/bjbT5fMYoeOs2ShAXbygC
	x/vG5xI7VrHC/YYNqwLaeg1tMqKpg+4CYEhK3kg1J9Sozbm8+1DprHxcgxEwQA2BUZw==
X-Received: by 2002:a63:4a5f:: with SMTP id j31mr36393938pgl.369.1554835437411;
        Tue, 09 Apr 2019 11:43:57 -0700 (PDT)
X-Received: by 2002:a63:4a5f:: with SMTP id j31mr36393905pgl.369.1554835436687;
        Tue, 09 Apr 2019 11:43:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554835436; cv=none;
        d=google.com; s=arc-20160816;
        b=UY0Wgdpy1hX5uTHVPMD3KfRpUqHjz5LXr6R11TdzyfggjJnwRKboHpTQG2pAeAR7W5
         VlfQo8JRmJR1wDU8RbNF4/Pnrk/rfJ8c00oM3Fe+6WSB5waRGChw4Xe2aXVb5kOtV39t
         Gfw2sxhmSAYXuJAVEYMZRJ6bR0/k54S2RKbPZH4MgDKXuef4DZjusQHfuCwtleHWzpb4
         aYGrqT57lzWh6M6cMA90zQ4zerjZtGdh6eOkGkxnJRmVW33PH8CZlmk4gOZGiQ5M6r+n
         0FTBLzBnT/GHSWsacS+4NRWTMRMG9KqBpp/M9QT/XzU32i9NSqkszytayBXAw+pTnMoH
         jxYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=VQum5xkYgWrLXwSjhxQf413Vq4UHlR9jwivyiD7Y/bg=;
        b=H4573sr7vBT2Gif2USWFzo+wTR1FcrIDZOiGLb5lSwMpHRF+MQNbStxhyiKZpAsQjj
         YaV6k9tlm/KWZ0zbX6gH82JBUuNCeO8xOR5i++co2wPBCaYqukKy4wpeB+PqpwG5J8tc
         sLX7zjlkEdrJQgBl1pPnDd8B/BfrYeVW6b7T/Yf2xfEZOCQ9hg+4wEht+mC9a/sgKCqI
         NDH3HkuI8fTGCNupggs2nq4oiaiBX/6Dcwsm9bdmb9h4zaxZT4eSj1DuXV/5ativgDKl
         BtVJMDN75C5L6M5Tc0sCktKgRSZGiygbhL+VTjmdKPdm136KDA5CNdmBBBUlX7FbS17Q
         FVdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kXiGqdmh;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i87sor35099460pfj.24.2019.04.09.11.43.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 11:43:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kXiGqdmh;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=VQum5xkYgWrLXwSjhxQf413Vq4UHlR9jwivyiD7Y/bg=;
        b=kXiGqdmhzGJFnZefmVu8+1fsPksdI4g02LjE7x28Geuj4AKDMzgJRrYp32h3ms6d3g
         0N49bR9pRDi/Lv0oFonXcgnyf1Jd7Zl+nBo1jWAzsHpyaKXvkHiVAfMd/WeSFAcNyNIg
         z646DH2Q9kIK4yvL5mpT4iN6IZ3O8IxA0+nt/PSkXPCAZXivhq16YB5hgNn2buWD71e3
         epQyVuKRsZpBixpARJt9lSF5qlj02PLMwJgtI7X5U+960mesQJkFOsiOKSUWDzO9BfwL
         8vlRAE8FlS2xgPx7Gag/erQ4VlWUYInzpcwNueaGDbfu8zb3OiikTHCZELb6/od9IpXk
         dqug==
X-Google-Smtp-Source: APXvYqyAUQtY4lQn95KRxjt3Hp0Tst4ecafBe59Qw7NS1ELgN6YNiVEfNzhOZlnA+sKKmUsgZkIW3g==
X-Received: by 2002:aa7:8453:: with SMTP id r19mr39172856pfn.44.1554835435382;
        Tue, 09 Apr 2019 11:43:55 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id v15sm48210009pff.105.2019.04.09.11.43.53
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Apr 2019 11:43:54 -0700 (PDT)
Date: Tue, 9 Apr 2019 11:43:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>, 
    Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
cc: Hugh Dickins <hughd@google.com>, "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>, 
    Vineeth Pillai <vpillai@digitalocean.com>, 
    Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: [PATCH 4/4] mm: swapoff: shmem_unuse() stop eviction without
 igrab()
In-Reply-To: <84d74937-30ed-d0fe-c7cd-a813f61cbb96@yandex-team.ru>
Message-ID: <alpine.LSU.2.11.1904091133570.1898@eggly.anvils>
References: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils> <alpine.LSU.2.11.1904081259400.1523@eggly.anvils> <84d74937-30ed-d0fe-c7cd-a813f61cbb96@yandex-team.ru>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Apr 2019, Konstantin Khlebnikov wrote:
> On 08.04.2019 23:01, Hugh Dickins wrote:
> > -		if (!list_empty(&info->swaplist)) {
> > +		while (!list_empty(&info->swaplist)) {
> > +			/* Wait while shmem_unuse() is scanning this inode...
> > */
> > +			wait_var_event(&info->stop_eviction,
> > +				       !atomic_read(&info->stop_eviction));
> >   			mutex_lock(&shmem_swaplist_mutex);
> >   			list_del_init(&info->swaplist);
> 
> Obviously, line above should be deleted.

Definitely. Worryingly stupid. I guess I left it behind while translating
from an earlier tree.  Many thanks for catching that in time, Konstantin.
I've rechecked the rest of this patch, and the others, and didn't find
anything else as stupid.

Andrew, please add this fixup for folding in - thanks:

[PATCH] mm: swapoff: shmem_unuse() stop eviction without igrab() fix

Fix my stupidity, thankfully caught by Konstantin.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
Fix to fold into mm-swapoff-shmem_unuse-stop-eviction-without-igrab.patch

 mm/shmem.c |    1 -
 1 file changed, 1 deletion(-)

--- patch4/mm/shmem.c	2019-04-07 19:18:43.248639711 -0700
+++ patch5/mm/shmem.c	2019-04-09 11:24:32.745337734 -0700
@@ -1086,7 +1086,6 @@ static void shmem_evict_inode(struct ino
 			wait_var_event(&info->stop_eviction,
 				       !atomic_read(&info->stop_eviction));
 			mutex_lock(&shmem_swaplist_mutex);
-			list_del_init(&info->swaplist);
 			/* ...but beware of the race if we peeked too early */
 			if (!atomic_read(&info->stop_eviction))
 				list_del_init(&info->swaplist);

