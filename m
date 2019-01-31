Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFDB4C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 09:44:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80D17218D3
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 09:44:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80D17218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E34938E0002; Thu, 31 Jan 2019 04:44:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBF488E0001; Thu, 31 Jan 2019 04:44:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C60668E0002; Thu, 31 Jan 2019 04:44:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 607D58E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:44:02 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so1065686edd.16
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:44:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OThIg1X1vSpQkzENK4GGU8PIshLPaP693e3SGyYLOEg=;
        b=V+rtega1JUg82qXKwHP2kJ+p14i1b2AUbAaPjAR3OabjTWTajA0teFq3MRpc1XNDZt
         3QytYNhwxSoUj8hRxqt/8GyfNp/7g+AAJtrvg197kAL1ZtK2lmbTls6/ZwjsE5OU5fMK
         fdOTxlo7jKMUkuuVfIM657wYesDJlO3GyRtJQ/S2iQMQfq2XJ2XjIozZTvW0Nf43uJJm
         Bi8JLtc5arJK0up+D8d3jDO7xdoFqj17KrscBBUfVJza77V0bQMq0UDq4cgxZTXt7Wxz
         GCALzavxeln6J5WwNr7rlDkwfcEfHsKegW/uDRVMnBsmil9CqxL1MyVGUun4Kj8EvJ3D
         dU3A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdJ43ZBQkk57UGgGPPc1VU91xnj/d41iEMaMccqaxHvI36sMjb2
	boo0LAVHYl+G3i57oo6v7bAzBeyueFWei16YsL3TY4WA9Qr92fh66O78WNiYzfC0zhzgLtTv846
	Qa1Q4VXNAug20FkZuIVpxzU6N3MGYXcLAWT3w0Na3f+/JusCBaogWZghokT+Hs2E=
X-Received: by 2002:aa7:d88c:: with SMTP id u12mr32149953edq.237.1548927841866;
        Thu, 31 Jan 2019 01:44:01 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4oPPAmkKGcAy5LqzYVzCaA3OgECAJzrzKVyAOo5SRDxYNt68o61pKbrBjFrOSaCkN6nvck
X-Received: by 2002:aa7:d88c:: with SMTP id u12mr32149907edq.237.1548927840868;
        Thu, 31 Jan 2019 01:44:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548927840; cv=none;
        d=google.com; s=arc-20160816;
        b=RQyx55gkOp8PIJGFumkCGbDZng2gj0Uj1hzdTCNoJiZwgzlfoVF1GoV+Fyz/URmsbW
         lYqCzK/IS+kh+Cd1wxnX1rEfo4dpAIfc8tasOLcMvif3id7XmAUQrw2/c0koMwVpszk5
         MjzTni1TN+38I0zPuCxDbxDwLUUDW8a9KdcDIm44wvqJA4YFiapXRJwIUtp9ks+ozbbL
         Ty+vSY46VeMO9/4KRtjhmIUPNl+djJbWHuiTn1orFf1G3zSNDI6BwUOdkazF2MltuOYp
         lFTT2ZBDRJv1AC0M6Dx4mOGx7V2ZHVnIHl9Wq5RKvruhjFRbHX3Pt4eJ06v/430CRWtT
         +wnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OThIg1X1vSpQkzENK4GGU8PIshLPaP693e3SGyYLOEg=;
        b=bFD0mfSonRUK2wPv9NfwI3nwFOnXxINWgS2v+NeAOz160VK4CHuehUFD2OLwC8qDVK
         PwRYvP8tPJJfdgx3XeKuSb2kXNNf4j7I0YRRp+ZWadeS1RqhWcceyc+WJwa7ImVwgpDP
         ks2Pw1bHHtJRWAnGy2LnD1WVJYkYq8F0N9LHrr5y7BoHlLakxPc5n+8+e427TMijulLO
         LlknZ1S0SXfoE/xZia1kSF+/pjTYjHupdaGTgX28ijAwFlPICXdIo3CprpL1QK0Z5sHI
         fA9/zX0vkNToNK1JdnmMz/RcIWssXCJmmI67IHKGHs9AqQOP2G7Ehh8JXbULg/9MSrNj
         CoEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s23si2191414edm.254.2019.01.31.01.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 01:44:00 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D38F7ACD8;
	Thu, 31 Jan 2019 09:43:59 +0000 (UTC)
Date: Thu, 31 Jan 2019 10:43:57 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>, Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 1/3] mm/mincore: make mincore() more conservative
Message-ID: <20190131094357.GQ18811@dhcp22.suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-2-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130124420.1834-2-vbabka@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 30-01-19 13:44:18, Vlastimil Babka wrote:
> From: Jiri Kosina <jkosina@suse.cz>
> 
> The semantics of what mincore() considers to be resident is not completely
> clear, but Linux has always (since 2.3.52, which is when mincore() was
> initially done) treated it as "page is available in page cache".
> 
> That's potentially a problem, as that [in]directly exposes meta-information
> about pagecache / memory mapping state even about memory not strictly belonging
> to the process executing the syscall, opening possibilities for sidechannel
> attacks.
> 
> Change the semantics of mincore() so that it only reveals pagecache information
> for non-anonymous mappings that belog to files that the calling process could
> (if it tried to) successfully open for writing.

I agree that this is a better way than the original 574823bfab82
("Change mincore() to count "mapped" pages rather than "cached" pages").
One thing is still not clear to me though. Is the new owner/writeable
check OK for the Netflix-like usecases? I mean does happycache have
appropriate access to the cache data? I have tried to re-read the
original thread but couldn't find any confirmation.

I nit below

> Originally-by: Linus Torvalds <torvalds@linux-foundation.org>
> Originally-by: Dominique Martinet <asmadeus@codewreck.org>
> Cc: Dominique Martinet <asmadeus@codewreck.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Kevin Easton <kevin@guarana.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Cyril Hrubis <chrubis@suse.cz>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Daniel Gruss <daniel@gruss.cc>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

other than that looks good to me.
Acked-by: Michal Hocko <mhocko@suse.com>

If this still doesn't help happycache kind of workloads then we should
add a capability check IMO but this looks like a decent foundation to
me.

> ---
>  mm/mincore.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/mincore.c b/mm/mincore.c
> index 218099b5ed31..747a4907a3ac 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -169,6 +169,14 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	return 0;
>  }
>  
> +static inline bool can_do_mincore(struct vm_area_struct *vma)
> +{
> +	return vma_is_anonymous(vma) ||
> +		(vma->vm_file &&
> +			(inode_owner_or_capable(file_inode(vma->vm_file))
> +			 || inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0));
> +}

This is hard to read. Can we do
	if (vma_is_anonymous(vma))
		return true;
	if (!vma->vm_file)
		return false;
	return inode_owner_or_capable(file_inode(vma->vm_file)) ||
		inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;

-- 
Michal Hocko
SUSE Labs

